--[[
  DragonUI - Frame Enhancements: indicators (modules/bbf/indicators.lua)

  * Combat indicator: sword icon beside the portrait while the unit is in
    combat (nothing is shown out of combat).
  * Portrait CC: crowd control / immunity icon over target, focus and party
    portraits with a countdown. CC data comes from DragonUI's
    addon.AuraDurations (SpellMechanic ids, every rank), no class tables.
  * Stealth: tinted glow around the player frame while IsStealthed().
  * Quest: "!" on target/focus when the mob is an active quest objective.

  All widgets are non-protected children, safe to show/hide in combat.
]]

local addon = select(2, ...)
local BBF = addon.BBF
if not BBF then return end

local GetTime = GetTime
local UnitExists, UnitAffectingCombat = UnitExists, UnitAffectingCombat
local FONT = (addon.UF and addon.UF.DEFAULT_FONT) or "Fonts\\FRIZQT__.TTF"

-- ============================================================================
-- COMBAT INDICATOR
-- ============================================================================

-- The dual-wield spell icon reads best, but spell icons carry an opaque dark
-- background. Drawn with ADD blending, black adds nothing (fully transparent)
-- while the bright blades stay; the crop trims the icon's built-in edge.
local COMBAT_ICON = "Interface\\Icons\\ABILITY_DUALWIELD"
local COMBAT_ICON_COORDS = { 0.08, 0.92, 0.08, 0.92 }
local COMBAT_UNITS = {
    player = { frame = "PlayerFrame", portrait = "PlayerPortrait", side = "LEFT" },
    target = { frame = "TargetFrame", portrait = "TargetFramePortrait", side = "RIGHT" },
    focus  = { frame = "FocusFrame",  portrait = "FocusFramePortrait",  side = "RIGHT" },
}

local combatIcons = {}
local combatCfg = nil

local function EnsureCombatIcon(unit)
    local icon = combatIcons[unit]
    if icon then return icon end
    local info = COMBAT_UNITS[unit]
    local owner = _G[info.frame]
    if not owner then return nil end

    icon = CreateFrame("Frame", nil, owner)
    icon:SetFrameLevel(owner:GetFrameLevel() + 10)
    local tex = icon:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints(icon)
    tex:SetTexture(COMBAT_ICON)
    tex:SetTexCoord(unpack(COMBAT_ICON_COORDS))
    tex:SetBlendMode("ADD")
    icon:Hide()
    combatIcons[unit] = icon
    return icon
end

local function LayoutCombatIcon(unit, icon)
    local info = COMBAT_UNITS[unit]
    local anchor = _G[info.portrait] or _G[info.frame]
    local size = tonumber(combatCfg.size) or 24
    local x, y = tonumber(combatCfg.x) or 0, tonumber(combatCfg.y) or 0
    icon:SetWidth(size)
    icon:SetHeight(size)
    icon:ClearAllPoints()
    if info.side == "LEFT" then
        icon:SetPoint("RIGHT", anchor, "LEFT", -4 + x, y)
    else
        icon:SetPoint("LEFT", anchor, "RIGHT", 4 + x, y)
    end
end

local function UpdateCombatIcons()
    for unit in pairs(COMBAT_UNITS) do
        local icon = combatIcons[unit]
        if icon then
            local want = combatCfg and combatCfg[unit] == true
                and UnitExists(unit) and UnitAffectingCombat(unit)
            if want then icon:Show() else icon:Hide() end
        end
    end
end

-- UNIT_FLAGS is unreliable for target/focus combat changes on 3.3.5a; poll instead.
local combatTicker = BBF.CreateTicker(0.25, UpdateCombatIcons)

local function RefreshCombat(cfg)
    combatCfg = cfg and cfg.combat and cfg.combat.enabled == true and cfg.combat or nil
    if not combatCfg then
        combatTicker:Hide()
        for _, icon in pairs(combatIcons) do icon:Hide() end
        return
    end
    for unit in pairs(COMBAT_UNITS) do
        if combatCfg[unit] == true then
            local icon = EnsureCombatIcon(unit)
            if icon then LayoutCombatIcon(unit, icon) end
        end
    end
    combatTicker:Show()
    UpdateCombatIcons()
end

-- ============================================================================
-- PORTRAIT CC
-- ============================================================================

-- Immunities have no SpellMechanic flag, so they are listed by hand (all ranks).
local IMMUNITY_IDS = {
    642,                 -- Divine Shield
    498,                 -- Divine Protection
    1022, 5599, 10278,   -- Hand of Protection
    45438,               -- Ice Block
    19263,               -- Deterrence
    31224,               -- Cloak of Shadows
    48707,               -- Anti-Magic Shell
    47585,               -- Dispersion
    46924,               -- Bladestorm
}
local IMMUNITY_SET = {}
for i = 1, #IMMUNITY_IDS do IMMUNITY_SET[IMMUNITY_IDS[i]] = true end

local PRIORITY_IMMUNITY, PRIORITY_CC, PRIORITY_DISARM = 3, 2, 1

local ccCfg = nil
local ccExtraSet = {}
local ccWidgets = {} -- unit -> widget
local ccUnits = {}   -- unit -> owner info

local function GetPortraitFor(unit)
    if unit == "target" then
        return _G.TargetFrame, _G.TargetFramePortrait
    elseif unit == "focus" then
        return _G.FocusFrame, _G.FocusFramePortrait
    end
    local index = unit:match("^party(%d)$")
    if index then
        return _G["PartyMemberFrame" .. index], _G["PartyMemberFrame" .. index .. "Portrait"]
    end
end

local function EnsureCCWidget(unit)
    local widget = ccWidgets[unit]
    if widget then return widget end
    local owner, portrait = GetPortraitFor(unit)
    if not owner or not portrait then return nil end

    widget = CreateFrame("Frame", nil, owner)
    widget:SetFrameLevel(owner:GetFrameLevel() + 8)
    widget:SetAllPoints(portrait)
    local tex = widget:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints(widget)
    widget.icon = tex
    local timer = widget:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    timer:SetPoint("CENTER", widget, "CENTER", 0, 0)
    widget.timer = timer
    widget:Hide()
    ccWidgets[unit] = widget
    return widget
end

local function ClassifyAura(spellId, isBuff)
    if not spellId then return nil end
    if isBuff then
        if ccCfg.immunities ~= false and IMMUNITY_SET[spellId] then
            return PRIORITY_IMMUNITY
        end
        return nil
    end
    local data = addon.AuraDurations
    if (data and data.CrowdControl and data.CrowdControl[spellId]) or ccExtraSet[spellId] then
        return PRIORITY_CC
    end
    if data and data.Disarm and data.Disarm[spellId] then
        return PRIORITY_DISARM
    end
    return nil
end

-- Highest priority wins; ties go to the aura that lasts longest.
local function FindPortraitAura(unit)
    local bestPrio, bestIcon, bestExpires, bestDuration = 0, nil, 0, 0
    for pass = 1, 2 do
        local isBuff = pass == 2
        local query = isBuff and UnitBuff or UnitDebuff
        for i = 1, 40 do
            local name, _, icon, _, _, duration, expires, _, _, _, spellId = query(unit, i)
            if not name then break end
            local prio = ClassifyAura(spellId, isBuff)
            if prio then
                local exp = expires or 0
                local better = prio > bestPrio
                -- expires == 0 means no duration: it outlasts anything timed
                if not better and prio == bestPrio and bestExpires ~= 0 then
                    better = exp == 0 or exp > bestExpires
                end
                if better then
                    bestPrio, bestIcon, bestExpires, bestDuration = prio, icon, exp, duration or 0
                end
            end
        end
    end
    return bestIcon, bestExpires, bestDuration
end

local ccTicker -- forward

local function UpdateCCUnit(unit)
    local widget = ccWidgets[unit]
    if not widget then return end
    if not ccCfg or not ccUnits[unit] or not UnitExists(unit) then
        widget:Hide()
        return
    end
    local icon, expires = FindPortraitAura(unit)
    if not icon then
        widget:Hide()
        return
    end
    if widget.iconPath ~= icon then
        SetPortraitToTexture(widget.icon, icon)
        widget.iconPath = icon
    end
    widget.expires = expires
    local size = widget:GetHeight()
    if size and size > 0 then
        widget.timer:SetFont(FONT, math.max(9, math.floor(size / 3)), "OUTLINE")
    end
    widget:Show()
    ccTicker:Show()
end

local function UpdateCCTimers()
    local any = false
    local now = GetTime()
    for _, widget in pairs(ccWidgets) do
        if widget:IsShown() then
            any = true
            local left = (widget.expires or 0) - now
            if widget.expires and widget.expires > 0 and left > 0 then
                widget.timer:SetText(BBF.FormatTime(left))
            else
                widget.timer:SetText("")
            end
        end
    end
    if not any then ccTicker:Hide() end
end

ccTicker = BBF.CreateTicker(0.1, UpdateCCTimers)

local function UpdateAllCC()
    for unit in pairs(ccWidgets) do
        UpdateCCUnit(unit)
    end
end

BBF.RegisterEvent("UNIT_AURA", function(event, unit)
    if ccCfg and ccUnits[unit] then UpdateCCUnit(unit) end
end)
BBF.RegisterEvent("PLAYER_TARGET_CHANGED", function()
    if ccCfg then UpdateCCUnit("target") end
end)
BBF.RegisterEvent("PLAYER_FOCUS_CHANGED", function()
    if ccCfg then UpdateCCUnit("focus") end
end)
BBF.RegisterEvent("PARTY_MEMBERS_CHANGED", function()
    if ccCfg then UpdateAllCC() end
end)

local function RefreshPortraitCC(cfg)
    ccCfg = cfg and cfg.portrait_cc and cfg.portrait_cc.enabled == true and cfg.portrait_cc or nil
    wipe(ccUnits)
    if ccCfg then
        ccExtraSet = BBF.ParseIdSet(ccCfg.extra)
        if ccCfg.target ~= false then ccUnits.target = true end
        if ccCfg.focus ~= false then ccUnits.focus = true end
        if ccCfg.party ~= false then
            for i = 1, 4 do ccUnits["party" .. i] = true end
        end
        for unit in pairs(ccUnits) do
            EnsureCCWidget(unit)
        end
    end
    UpdateAllCC()
end

-- ============================================================================
-- STEALTH GLOW
-- ============================================================================

local stealthCfg = nil
local stealthFrame = nil

local function EnsureStealthFrame()
    if stealthFrame then return stealthFrame end
    if not _G.PlayerFrame then return nil end
    stealthFrame = CreateFrame("Frame", "DragonUIBBFStealthGlow", _G.PlayerFrame)
    stealthFrame:SetFrameStrata("LOW")
    stealthFrame:SetFrameLevel(999)
    local tex = stealthFrame:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints(stealthFrame)
    tex:SetBlendMode("ADD")
    stealthFrame.texture = tex
    stealthFrame:Hide()

    -- Slow breathing pulse so it reads differently from the rest glow.
    local t = 0
    stealthFrame:SetScript("OnUpdate", function(self, elapsed)
        t = t + elapsed
        self:SetAlpha(0.65 + 0.35 * math.sin(t * 3))
    end)
    return stealthFrame
end

-- Reuse DragonUI's rest-glow geometry (normal / fat / elite all differ).
local function LayoutStealthFrame(frame)
    local dragonFrame = _G.DragonUIUnitframeFrame
    local refFrame = _G.DragonUIStatusGlow
    local refTex = dragonFrame and dragonFrame.DragonUIStatusTexture
    frame:ClearAllPoints()
    if refFrame and refFrame:GetNumPoints() > 0 and refTex and refTex:GetTexture() then
        frame:SetAllPoints(refFrame)
        frame.texture:SetTexture(refTex:GetTexture())
        frame.texture:SetTexCoord(refTex:GetTexCoord())
    else
        frame:SetWidth(192)
        frame:SetHeight(71)
        frame:SetPoint("TOPLEFT", _G.PlayerFrame, "TOPLEFT", 22, -9)
        frame.texture:SetTexture("Interface\\CharacterFrame\\UI-Player-Status")
        frame.texture:SetTexCoord(0, 0.74609375, 0, 0.53125)
    end
end

local function UpdateStealth()
    if not stealthCfg then
        if stealthFrame then stealthFrame:Hide() end
        return
    end
    local frame = EnsureStealthFrame()
    if not frame then return end
    if IsStealthed() then
        LayoutStealthFrame(frame)
        local c = stealthCfg.color or {}
        frame.texture:SetVertexColor(c.r or 0.35, c.g or 0.6, c.b or 1, 1)
        frame:Show()
    else
        frame:Hide()
    end
end

BBF.RegisterEvent("UPDATE_STEALTH", UpdateStealth)
BBF.RegisterEvent("UNIT_AURA", function(event, unit)
    if unit == "player" and stealthCfg then UpdateStealth() end
end)

local function RefreshStealth(cfg)
    stealthCfg = cfg and cfg.stealth and cfg.stealth.enabled == true and cfg.stealth or nil
    UpdateStealth()
end

-- ============================================================================
-- QUEST INDICATOR
-- ============================================================================

local QUEST_ICON = "Interface\\GossipFrame\\AvailableQuestIcon"
local questCfg = nil
local questIcons = {}
local questScanTip = nil
local killNames = {} -- lowercased mob name -> true (incomplete "X slain: n/m" objectives)

local killNamePattern
do
    local fmt = QUEST_MONSTERS_KILLED or "%s slain: %d/%d"
    fmt = fmt:gsub("%%s", "\001"):gsub("%%d", "\002")
    fmt = fmt:gsub("([%^%$%(%)%.%[%]%*%+%-%?%%])", "%%%1")
    fmt = fmt:gsub("\001", "(.-)"):gsub("\002", "%%d+")
    killNamePattern = "^" .. fmt .. "$"
end

-- "50% Threat" also parses as progress; filter those lines out.
local threatPattern = THREAT_TOOLTIP and (THREAT_TOOLTIP:gsub("%%d", "%%d+"))

local function RebuildKillNames()
    wipe(killNames)
    for i = 1, GetNumQuestLogEntries() do
        local _, _, _, _, isHeader, _, isComplete = GetQuestLogTitle(i)
        if not isHeader and not isComplete then
            for o = 1, GetNumQuestLeaderBoards(i) do
                local desc, objType, finished = GetQuestLogLeaderBoard(o, i)
                if desc and objType == "monster" and not finished then
                    local mob = desc:match(killNamePattern)
                    if mob and mob ~= "" then
                        killNames[mob:lower()] = true
                    end
                end
            end
        end
    end
end

local function ScanTooltipForQuest(unit)
    if not questScanTip then
        questScanTip = CreateFrame("GameTooltip", "DragonUIBBFQuestScan", UIParent, "GameTooltipTemplate")
    end
    questScanTip:SetOwner(UIParent, "ANCHOR_NONE")
    questScanTip:ClearLines()
    questScanTip:SetUnit(unit)
    -- Show() populates the dynamic quest lines; same-frame Hide() = no flicker.
    questScanTip:Show()
    local found = false
    for i = 2, questScanTip:NumLines() do
        local fs = _G["DragonUIBBFQuestScanTextLeft" .. i]
        local text = fs and fs:GetText()
        if text and text ~= "" and not (threatPattern and text:match(threatPattern)) then
            local done, total = text:match("(%d+)%s*/%s*(%d+)")
            if done and total and tonumber(done) < tonumber(total) then
                found = true
                break
            end
        end
    end
    questScanTip:Hide()
    return found
end

local function IsQuestUnit(unit)
    if not UnitExists(unit) or UnitIsPlayer(unit) or UnitPlayerControlled(unit) or UnitIsDead(unit) then
        return false
    end
    -- Improved clients expose the retail API; stock 3.3.5a falls through.
    if C_QuestLog and type(C_QuestLog.GetUnitQuestInfo) == "function" then
        local status = C_QuestLog.GetUnitQuestInfo(unit)
        if status == "collect" or status == "objective" then
            return true
        end
    end
    local name = UnitName(unit)
    if name and killNames[name:lower()] then
        return true
    end
    return ScanTooltipForQuest(unit)
end

local QUEST_UNITS = {
    target = { frame = "TargetFrame", portrait = "TargetFramePortrait" },
    focus  = { frame = "FocusFrame",  portrait = "FocusFramePortrait" },
}

local function EnsureQuestIcon(unit)
    local icon = questIcons[unit]
    if icon then return icon end
    local info = QUEST_UNITS[unit]
    local owner = _G[info.frame]
    local portrait = _G[info.portrait] or owner
    if not owner then return nil end
    icon = CreateFrame("Frame", nil, owner)
    icon:SetFrameLevel(owner:GetFrameLevel() + 10)
    icon:SetWidth(20)
    icon:SetHeight(20)
    icon:SetPoint("BOTTOMRIGHT", portrait, "TOPLEFT", 10, -10)
    local tex = icon:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints(icon)
    tex:SetTexture(QUEST_ICON)
    icon:Hide()
    questIcons[unit] = icon
    return icon
end

local function UpdateQuestUnit(unit)
    local icon = questIcons[unit]
    if not icon then return end
    if questCfg and questCfg[unit] ~= false and IsQuestUnit(unit) then
        icon:Show()
    else
        icon:Hide()
    end
end

BBF.RegisterEvent("PLAYER_TARGET_CHANGED", function()
    if questCfg then UpdateQuestUnit("target") end
end)
BBF.RegisterEvent("PLAYER_FOCUS_CHANGED", function()
    if questCfg then UpdateQuestUnit("focus") end
end)
BBF.RegisterEvent("QUEST_LOG_UPDATE", function()
    if not questCfg then return end
    RebuildKillNames()
    UpdateQuestUnit("target")
    UpdateQuestUnit("focus")
end)

local function RefreshQuest(cfg)
    questCfg = cfg and cfg.quest and cfg.quest.enabled == true and cfg.quest or nil
    if questCfg then
        EnsureQuestIcon("target")
        EnsureQuestIcon("focus")
        RebuildKillNames()
    end
    UpdateQuestUnit("target")
    UpdateQuestUnit("focus")
end

-- ============================================================================
-- REGISTRATION
-- ============================================================================

BBF.RegisterFeature("indicators", function(cfg)
    RefreshCombat(cfg)
    RefreshPortraitCC(cfg)
    RefreshStealth(cfg)
    RefreshQuest(cfg)
end)
