--[[
  DragonUI - Frame Enhancements: cast bars (modules/bbf/castbars.lua)

  * Party cast bars (party1-4) and a pet cast bar, styled like DragonUI's bars.
  * Cast target name under the DragonUI target/focus cast bars.
  * Interrupt readiness: tints the target/focus cast bar by your interrupt's
    cooldown and shows its icon. CoA classes have no fixed interrupt, so the
    spell list is user-configurable; empty = the common interrupts you know.

  Our bars are plain StatusBars parented to UIParent (never protected), so they
  can be shown, hidden and moved in combat.
]]

local addon = select(2, ...)
local BBF = addon.BBF
if not BBF then return end

local GetTime = GetTime
local UnitCastingInfo, UnitChannelInfo = UnitCastingInfo, UnitChannelInfo
local min, max = math.min, math.max

local TEXTURE_PATH = "Interface\\AddOns\\DragonUI\\Textures\\Castbar\\"
local TEX_ATLAS = TEXTURE_PATH .. "uicastingbar2x"
local TEX_STANDARD = TEXTURE_PATH .. "CastingBarStandard2"
local TEX_CHANNEL = TEXTURE_PATH .. "CastingBarChannel"
local TEX_SPARK = TEXTURE_PATH .. "CastingBarSpark"
local UV_BACKGROUND = { 0.0009765625, 0.4130859375, 0.3671875, 0.41796875 }
local UV_BORDER = { 0.412109375, 0.828125, 0.001953125, 0.060546875 }

local HOLD_TIME = 0.6
local FONT = (addon.UF and addon.UF.DEFAULT_FONT) or "Fonts\\FRIZQT__.TTF"

-- ============================================================================
-- MINI CAST BAR (party / pet)
-- ============================================================================

local function ClipTexture(bar, progress)
    local tex = bar:GetStatusBarTexture()
    if tex then
        tex:SetTexCoord(0, max(0.01, min(0.99, progress)), 0, 1)
    end
end

local function ResetVisuals(bar)
    local tex = bar:GetStatusBarTexture()
    if tex then
        tex:SetVertexColor(1, 1, 1, 1)
        if tex.SetDesaturated then tex:SetDesaturated(false) end
    end
    bar:SetAlpha(1)
end

local function MiniCastbar_Stop(bar, failedText)
    if not (bar.casting or bar.channeling) and not bar.testing then
        return
    end
    bar.casting, bar.channeling, bar.testing = false, false, false
    if failedText then
        local tex = bar:GetStatusBarTexture()
        if tex then tex:SetVertexColor(1, 0.15, 0.15, 1) end
        bar:SetValue(1)
        ClipTexture(bar, 1)
        bar.text:SetText(failedText)
    end
    bar.timer:SetText("")
    bar.spark:Hide()
    bar.holdUntil = GetTime() + HOLD_TIME
end

local function MiniCastbar_OnUpdate(bar, elapsed)
    -- Party frames hide in raids / when the slot empties; follow them.
    if bar.owner and not bar.testing and not bar.owner:IsVisible() then
        bar.casting, bar.channeling, bar.holdUntil = false, false, nil
        bar:Hide()
        return
    end

    local now = GetTime()
    if bar.casting or bar.channeling or bar.testing then
        local total = bar.endTime - bar.startTime
        local progress = 1
        if total > 0 then
            if bar.channeling then
                progress = (bar.endTime - now) / total
            else
                progress = (now - bar.startTime) / total
            end
        end
        progress = max(0, min(1, progress))
        bar:SetValue(progress)
        ClipTexture(bar, progress)
        bar.spark:ClearAllPoints()
        bar.spark:SetPoint("CENTER", bar, "LEFT", bar:GetWidth() * progress, 0)

        local remaining = bar.endTime - now
        if bar.showTimer then
            bar.timer:SetText(BBF.FormatTime(remaining))
        end
        if remaining <= -0.2 then
            -- Missed STOP event (unit went out of range etc.)
            MiniCastbar_Stop(bar)
        end
    elseif bar.holdUntil then
        local left = bar.holdUntil - now
        if left <= 0 then
            bar.holdUntil = nil
            bar:Hide()
        else
            bar:SetAlpha(left / HOLD_TIME)
        end
    else
        bar:Hide()
    end
end

local function CreateMiniCastbar(name)
    local bar = CreateFrame("StatusBar", name, UIParent)
    bar:SetFrameStrata("MEDIUM")
    bar:SetFrameLevel(5)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)
    bar:SetStatusBarTexture(TEX_STANDARD)
    bar:EnableMouse(false)
    bar:Hide()

    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture(TEX_ATLAS)
    bg:SetTexCoord(unpack(UV_BACKGROUND))
    bg:SetPoint("TOPLEFT", bar, "TOPLEFT", -2, 0)
    bg:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, 0)

    local border = bar:CreateTexture(nil, "OVERLAY")
    border:SetTexture(TEX_ATLAS)
    border:SetTexCoord(unpack(UV_BORDER))
    border:SetPoint("TOPLEFT", bar, "TOPLEFT", -2, 2)
    border:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, -2)
    bar.border = border

    local spark = bar:CreateTexture(nil, "OVERLAY")
    spark:SetTexture(TEX_SPARK)
    spark:SetBlendMode("ADD")
    spark:SetWidth(10)
    spark:Hide()
    bar.spark = spark

    local icon = bar:CreateTexture(nil, "ARTWORK")
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    icon:SetPoint("RIGHT", bar, "LEFT", -4, 0)
    bar.icon = icon

    local text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", bar, "LEFT", 3, 0)
    text:SetPoint("RIGHT", bar, "RIGHT", -24, 0)
    text:SetJustifyH("LEFT")
    bar.text = text

    local timer = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    timer:SetPoint("RIGHT", bar, "RIGHT", -3, 0)
    timer:SetJustifyH("RIGHT")
    bar.timer = timer

    bar:SetScript("OnUpdate", MiniCastbar_OnUpdate)
    return bar
end

local function ApplyMiniLayout(bar, cfg, owner)
    local width = tonumber(cfg.width) or 100
    local height = tonumber(cfg.height) or 10
    bar:SetWidth(width)
    bar:SetHeight(height)
    bar:ClearAllPoints()
    bar:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", tonumber(cfg.x) or 0, tonumber(cfg.y) or 0)
    bar.spark:SetHeight(height * 2)
    bar.icon:SetWidth(height + 4)
    bar.icon:SetHeight(height + 4)
    bar.showIcon = cfg.show_icon ~= false
    bar.showTimer = cfg.show_timer ~= false
    local fontSize = max(7, min(12, height - 1))
    bar.text:SetFont(FONT, fontSize, "OUTLINE")
    bar.timer:SetFont(FONT, fontSize, "OUTLINE")
    if not bar.showTimer then bar.timer:SetText("") end
    bar.owner = owner
end

local function MiniCastbar_Start(bar, unit, isChannel)
    local name, text, texture, startMS, endMS, notInterruptible, _
    if isChannel then
        name, _, text, texture, startMS, endMS, _, notInterruptible = UnitChannelInfo(unit)
    else
        name, _, text, texture, startMS, endMS, _, _, notInterruptible = UnitCastingInfo(unit)
    end
    if not name or not startMS or not endMS then
        return
    end

    bar.casting = not isChannel
    bar.channeling = isChannel and true or false
    bar.testing = false
    bar.holdUntil = nil
    bar.startTime = startMS / 1000
    bar.endTime = endMS / 1000

    bar:SetStatusBarTexture(isChannel and TEX_CHANNEL or TEX_STANDARD)
    ResetVisuals(bar)
    local tex = bar:GetStatusBarTexture()
    if tex and notInterruptible then
        if tex.SetDesaturated then tex:SetDesaturated(true) end
        tex:SetVertexColor(0.75, 0.75, 0.75, 1)
    end

    bar.text:SetText(text ~= "" and text or name)
    if bar.showIcon and texture then
        bar.icon:SetTexture(texture)
        bar.icon:Show()
    else
        bar.icon:Hide()
    end
    bar.spark:Show()
    bar:Show()
    MiniCastbar_OnUpdate(bar, 0)
end

local function MiniCastbar_SetInterruptible(bar, notInterruptible)
    if not (bar.casting or bar.channeling) then return end
    local tex = bar:GetStatusBarTexture()
    if not tex then return end
    if tex.SetDesaturated then tex:SetDesaturated(notInterruptible and true or false) end
    if notInterruptible then
        tex:SetVertexColor(0.75, 0.75, 0.75, 1)
    else
        tex:SetVertexColor(1, 1, 1, 1)
    end
end

-- Re-reads the unit's current cast (unit swapped, roster changed, reload mid-cast).
local function MiniCastbar_Sync(bar, unit)
    if UnitChannelInfo(unit) then
        MiniCastbar_Start(bar, unit, true)
    elseif UnitCastingInfo(unit) then
        MiniCastbar_Start(bar, unit, false)
    elseif bar.casting or bar.channeling then
        bar.casting, bar.channeling, bar.holdUntil = false, false, nil
        bar:Hide()
    end
end

local function MiniCastbar_Test(bar, spellText, duration)
    bar.casting, bar.channeling, bar.testing = false, false, true
    bar.holdUntil = nil
    bar.startTime = GetTime()
    bar.endTime = bar.startTime + duration
    bar:SetStatusBarTexture(TEX_STANDARD)
    ResetVisuals(bar)
    bar.text:SetText(spellText)
    if bar.showIcon then
        bar.icon:SetTexture("Interface\\Icons\\Spell_Holy_HolyBolt")
        bar.icon:Show()
    else
        bar.icon:Hide()
    end
    bar.spark:Show()
    bar:Show()
end

-- ============================================================================
-- PARTY / PET BARS
-- ============================================================================

local unitBars = {}       -- unit token -> bar
local partyEnabled, petEnabled = false, false

local function GetOwnerFrame(unit)
    if unit == "pet" then
        return _G.PetFrame
    end
    local index = unit:match("^party(%d)$")
    return index and _G["PartyMemberFrame" .. index]
end

local function EnsureBar(unit)
    local bar = unitBars[unit]
    if not bar then
        bar = CreateMiniCastbar("DragonUIBBF_" .. unit .. "Castbar")
        unitBars[unit] = bar
    end
    return bar
end

local function IsUnitTracked(unit)
    if unit == "pet" then return petEnabled end
    return partyEnabled and unit:match("^party%d$") ~= nil
end

local CAST_EVENTS = {
    "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_INTERRUPTIBLE",
    "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
}

local function OnCastEvent(event, unit)
    if not unit or not IsUnitTracked(unit) then return end
    local bar = unitBars[unit]
    if not bar then return end

    if event == "UNIT_SPELLCAST_START" then
        MiniCastbar_Start(bar, unit, false)
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        MiniCastbar_Start(bar, unit, true)
    elseif event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        local _, startMS, endMS
        if bar.channeling then
            _, _, _, _, startMS, endMS = UnitChannelInfo(unit)
        else
            _, _, _, _, startMS, endMS = UnitCastingInfo(unit)
        end
        if startMS and endMS then
            bar.startTime, bar.endTime = startMS / 1000, endMS / 1000
        end
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        MiniCastbar_Stop(bar, _G.INTERRUPTED or "Interrupted")
    elseif event == "UNIT_SPELLCAST_FAILED" then
        if bar.casting then
            MiniCastbar_Stop(bar, _G.FAILED or "Failed")
        end
    elseif event == "UNIT_SPELLCAST_STOP" then
        if bar.casting then MiniCastbar_Stop(bar) end
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        if bar.channeling then MiniCastbar_Stop(bar) end
    elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
        MiniCastbar_SetInterruptible(bar, false)
    elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
        MiniCastbar_SetInterruptible(bar, true)
    end
end

for i = 1, #CAST_EVENTS do
    BBF.RegisterEvent(CAST_EVENTS[i], OnCastEvent)
end

local function SyncAllUnits()
    for unit, bar in pairs(unitBars) do
        if IsUnitTracked(unit) and UnitExists(unit) then
            MiniCastbar_Sync(bar, unit)
        elseif not bar.testing then
            bar.casting, bar.channeling, bar.holdUntil = false, false, nil
            bar:Hide()
        end
    end
end

BBF.RegisterEvent("PARTY_MEMBERS_CHANGED", SyncAllUnits)
BBF.RegisterEvent("UNIT_PET", function(event, unit)
    if unit == "player" then SyncAllUnits() end
end)

local function RefreshUnitBars(cfg)
    local partyCfg = cfg and cfg.party_castbar
    local petCfg = cfg and cfg.pet_castbar
    partyEnabled = partyCfg and partyCfg.enabled == true or false
    petEnabled = petCfg and petCfg.enabled == true or false

    for i = 1, 4 do
        local unit = "party" .. i
        local owner = GetOwnerFrame(unit)
        if partyEnabled and owner then
            ApplyMiniLayout(EnsureBar(unit), partyCfg, owner)
        elseif unitBars[unit] then
            unitBars[unit].testing = false
            unitBars[unit]:Hide()
        end
    end

    local petOwner = GetOwnerFrame("pet")
    if petEnabled and petOwner then
        ApplyMiniLayout(EnsureBar("pet"), petCfg, petOwner)
    elseif unitBars.pet then
        unitBars.pet.testing = false
        unitBars.pet:Hide()
    end

    SyncAllUnits()
end

-- Options "Test" button: 4 s fake casts on every enabled bar, even with no group.
function BBF.TestCastbars()
    local label = (addon.L and addon.L["Test Cast"]) or "Test Cast"
    for unit, bar in pairs(unitBars) do
        if IsUnitTracked(unit) then
            MiniCastbar_Test(bar, label, 4)
        end
    end
end

-- ============================================================================
-- TARGET / FOCUS: CAST TARGET NAME + INTERRUPT READINESS
-- ============================================================================

-- Common interrupts on 3.3.5a; CoA classes that reuse them are picked up automatically.
local DEFAULT_INTERRUPT_IDS = {
    1766,  -- Kick
    6552,  -- Pummel
    72,    -- Shield Bash
    2139,  -- Counterspell
    57994, -- Wind Shear
    47528, -- Mind Freeze
    19647, -- Spell Lock
    34490, -- Silencing Shot
    15487, -- Silence
    47476, -- Strangulate
    16979, -- Feral Charge - Bear
    28730, -- Arcane Torrent
}

local interruptCandidates = {}
local activeInterrupt = nil -- localized spell name, or nil when none is known

local function IsSpellKnownByName(name)
    -- By-name lookups only resolve for spells in the player's spellbook on 3.3.5a.
    return name and GetSpellInfo(name) ~= nil and GetSpellCooldown(name) ~= nil
end

local function ResolveInterrupt()
    activeInterrupt = nil
    for i = 1, #interruptCandidates do
        if IsSpellKnownByName(interruptCandidates[i]) then
            activeInterrupt = interruptCandidates[i]
            return
        end
    end
end

local function RebuildInterruptCandidates(cfg)
    wipe(interruptCandidates)
    local list = BBF.ParseSpellNames(cfg and cfg.spells)
    if #list == 0 then
        for i = 1, #DEFAULT_INTERRUPT_IDS do
            local name = GetSpellInfo(DEFAULT_INTERRUPT_IDS[i])
            if name then list[#list + 1] = name end
        end
    end
    for i = 1, #list do
        interruptCandidates[i] = list[i]
    end
    ResolveInterrupt()
end

BBF.RegisterEvent("SPELLS_CHANGED", function() ResolveInterrupt() end)
BBF.RegisterEvent("LEARNED_SPELL_IN_TAB", function() ResolveInterrupt() end)

-- Returns "ready" | "delayed" | "cd", plus cooldown start/duration.
local function GetInterruptState(castEnd)
    if not activeInterrupt then return nil end
    local start, duration, enable = GetSpellCooldown(activeInterrupt)
    if not start then return nil end
    local remaining = 0
    -- duration <= 1.5 is the global cooldown, not the interrupt's own cooldown
    if enable == 1 and start > 0 and duration > 1.5 then
        remaining = start + duration - GetTime()
    end
    if remaining <= 0 then
        return "ready", 0, 0
    end
    if castEnd and remaining < castEnd - GetTime() then
        return "delayed", start, duration
    end
    return "cd", start, duration
end

local castExtras = {} -- unitType -> { targetText, icon = { frame, texture, cooldown }, tinted }

local function EnsureExtras(unitType)
    local extras = castExtras[unitType]
    if extras then return extras end
    local module = addon.CastbarModule
    local frames = module and module.frames and module.frames[unitType]
    if not frames or not frames.container or not frames.castbar then
        return nil
    end

    extras = {}
    local targetText = frames.container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    targetText:SetFont(FONT, 10, "OUTLINE")
    targetText:Hide()
    extras.targetText = targetText

    local iconFrame = CreateFrame("Frame", nil, frames.container)
    iconFrame:SetWidth(20)
    iconFrame:SetHeight(20)
    iconFrame:SetPoint("LEFT", frames.castbar, "RIGHT", 6, 0)
    iconFrame:Hide()
    local iconTex = iconFrame:CreateTexture(nil, "ARTWORK")
    iconTex:SetAllPoints(iconFrame)
    iconTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local iconBorder = iconFrame:CreateTexture(nil, "OVERLAY")
    iconBorder:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    iconBorder:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    iconBorder:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", -6, 6)
    iconBorder:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", 6, -6)
    local cooldown = CreateFrame("Cooldown", nil, iconFrame)
    cooldown:SetAllPoints(iconFrame)
    extras.icon = { frame = iconFrame, texture = iconTex, cooldown = cooldown }

    castExtras[unitType] = extras
    return extras
end

local function HideExtras(unitType, extras)
    extras.targetText:Hide()
    extras.icon.frame:Hide()
    if extras.tinted then
        local module = addon.CastbarModule
        local frames = module and module.frames[unitType]
        local tex = frames and frames.castbar and frames.castbar:GetStatusBarTexture()
        if tex then tex:SetVertexColor(1, 1, 1, 1) end
        extras.tinted = false
    end
end

local castTargetCfg, interruptCfg = nil, nil

local function UpdateCastExtras(unitType)
    local extras = EnsureExtras(unitType)
    if not extras then return end

    local frames = addon.CastbarModule.frames[unitType]
    local castbar = frames.castbar
    local active = (castbar.castingEx or castbar.channelingEx) and frames.container:IsShown()
    if not active then
        HideExtras(unitType, extras)
        return
    end

    -- Cast target name
    if castTargetCfg and castTargetCfg[unitType] ~= false then
        local who = unitType .. "target"
        if UnitExists(who) then
            local name = UnitName(who)
            local cfg = BBF.GetConfig()
            if cfg and cfg.names and cfg.names.remove_realm ~= false then
                name = BBF.StripRealm(name)
            end
            local color = BBF.GetUnitClassColor(who)
            if color then
                extras.targetText:SetTextColor(color.r, color.g, color.b)
            else
                extras.targetText:SetTextColor(1, 0.82, 0)
            end
            extras.targetText:SetText(name or "")
            extras.targetText:ClearAllPoints()
            local below = (frames.textBackground and frames.textBackground:IsShown()) and frames.textBackground or castbar
            extras.targetText:SetPoint("TOP", below, "BOTTOM", 0, 1)
            extras.targetText:Show()
        else
            extras.targetText:Hide()
        end
    else
        extras.targetText:Hide()
    end

    -- Interrupt readiness
    local tex = castbar:GetStatusBarTexture()
    local state, cdStart, cdDuration
    if interruptCfg then
        state, cdStart, cdDuration = GetInterruptState(castbar.endTime)
    end
    if state and not castbar.notInterruptible then
        local c = (state == "cd" and interruptCfg.cd_color) or (state == "delayed" and interruptCfg.delayed_color)
        if tex then
            if c then
                tex:SetVertexColor(c.r or 1, c.g or 1, c.b or 1, 1)
            else
                tex:SetVertexColor(1, 1, 1, 1)
            end
            extras.tinted = true
        end
    elseif extras.tinted then
        if tex then tex:SetVertexColor(1, 1, 1, 1) end
        extras.tinted = false
    end

    local icon = extras.icon
    if state and interruptCfg.show_icon ~= false then
        icon.texture:SetTexture(GetSpellTexture(activeInterrupt))
        if icon.texture.SetDesaturated then
            icon.texture:SetDesaturated(state ~= "ready")
        end
        local size = max(16, castbar:GetHeight() + 8)
        icon.frame:SetWidth(size)
        icon.frame:SetHeight(size)
        if state ~= "ready" and cdDuration and cdDuration > 0 then
            if icon.cdStart ~= cdStart then
                CooldownFrame_SetTimer(icon.cooldown, cdStart, cdDuration, 1)
                icon.cdStart = cdStart
            end
        else
            icon.cooldown:Hide()
            icon.cdStart = nil
        end
        icon.frame:Show()
    else
        icon.frame:Hide()
    end
end

local extrasTicker = BBF.CreateTicker(0.1, function()
    UpdateCastExtras("target")
    UpdateCastExtras("focus")
end)

local castStartHooked = false
local function HookCastStart()
    if castStartHooked then return end
    local module = addon.CastbarModule
    if not module or type(module.HandleCastStart_Simple) ~= "function" then return end
    hooksecurefunc(module, "HandleCastStart_Simple", function(self, unitType)
        if extrasTicker:IsShown() and (unitType == "target" or unitType == "focus") then
            UpdateCastExtras(unitType)
        end
    end)
    castStartHooked = true
end

local function RefreshCastExtras(cfg)
    castTargetCfg = cfg and cfg.cast_target and cfg.cast_target.enabled == true and cfg.cast_target or nil
    interruptCfg = cfg and cfg.interrupt and cfg.interrupt.enabled == true and cfg.interrupt or nil

    if interruptCfg then
        RebuildInterruptCandidates(interruptCfg)
    else
        activeInterrupt = nil
    end

    if castTargetCfg or interruptCfg then
        HookCastStart()
        extrasTicker:Show()
    else
        extrasTicker:Hide()
        for unitType, extras in pairs(castExtras) do
            HideExtras(unitType, extras)
        end
    end
end

-- Lets the options panel show which interrupt was picked.
function BBF.GetActiveInterrupt()
    return activeInterrupt
end

BBF.RegisterFeature("castbars", function(cfg)
    RefreshUnitBars(cfg)
    RefreshCastExtras(cfg)
end)
