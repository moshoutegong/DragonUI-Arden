-- Copyright (c) 2026 NeticSoul. Licensed under the MIT License; see LICENSE.

--[[
  DragonUI - Target of Target (ToT)

  ToT-specific configuration passed to the UF.SmallFrame closure factory.
]]

local _, addon = ...
local UF = addon.UF

local UNIT = "targettarget"
local CVAR = "showTargetOfTarget"
local nativeFrame = TargetFrameToT
local frame = CreateFrame("Button", "DragonUIToTFrame", UIParent, "SecureUnitButtonTemplate")
frame:SetSize(93, 47)
frame:SetAttribute("unit", UNIT)
frame:SetAttribute("*type1", "target")
frame:RegisterForClicks("AnyUp")
frame.unit = UNIT
frame:SetScript("OnEnter", UnitFrame_OnEnter)
frame:SetScript("OnLeave", UnitFrame_OnLeave)
frame:Hide()

local portrait = frame:CreateTexture(nil, "ARTWORK")
portrait:SetSize(26, 26)
portrait:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -3)

local textures = UF.TEXTURES.smallStyle
local health = CreateFrame("StatusBar", nil, frame)
health:SetStatusBarTexture(textures.BAR_PREFIX .. "Health")
local power = CreateFrame("StatusBar", nil, frame)
power:SetStatusBarTexture(textures.BAR_PREFIX .. "Mana")
frame.healthbar, frame.manabar = health, power
frame.DragonUI_IndependentToT = true
local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
local dead = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
dead:SetText(DEAD)

-- Debuffs (Blizzard's ToT showed up to 4, 2x2 to the right of the frame).
-- Plain (insecure) children, created before combat, so they are safe to update.
local DEBUFF_SIZE = 15
local debuffs = {}
for i = 1, 4 do
    local button = CreateFrame("Frame", nil, frame)
    button:SetSize(DEBUFF_SIZE, DEBUFF_SIZE)
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetAllPoints()
    button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    button.border = button:CreateTexture(nil, "OVERLAY")
    button.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
    button.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
    button.border:SetPoint("TOPLEFT", -1, 1)
    button.border:SetPoint("BOTTOMRIGHT", 1, -1)
    button.count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    button.count:SetPoint("BOTTOMRIGHT", 2, -2)
    button:EnableMouse(true)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:SetUnitDebuff(UNIT, self.index)
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:Hide()
    debuffs[i] = button
end
debuffs[1]:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 120, 35)
debuffs[2]:SetPoint("LEFT", debuffs[1], "RIGHT", 2, 0)
debuffs[3]:SetPoint("TOP", debuffs[1], "BOTTOM", 0, -2)
debuffs[4]:SetPoint("LEFT", debuffs[3], "RIGHT", 2, 0)

local function UpdateDebuffs()
    for i = 1, 4 do
        local button = debuffs[i]
        local _, _, icon, count, debuffType = UnitDebuff(UNIT, i)
        if icon then
            button.index = i
            button.icon:SetTexture(icon)
            button.count:SetText((count and count > 1) and count or "")
            local color = DebuffTypeColor[debuffType or "none"] or DebuffTypeColor["none"]
            button.border:SetVertexColor(color.r, color.g, color.b)
            button:Show()
        else
            button:Hide()
        end
    end
end

local function UpdateUnitData()
    if not UnitExists(UNIT) then
        name:SetText("")
        dead:Hide()
        health:SetValue(0)
        power:SetValue(0)
        for i = 1, 4 do debuffs[i]:Hide() end
        return
    end

    UpdateDebuffs()

    name:SetText(UnitName(UNIT))
    local isDead = UnitIsDeadOrGhost(UNIT)
    if isDead then dead:Show() else dead:Hide() end
    health:SetMinMaxValues(0, math.max(1, UnitHealthMax(UNIT)))
    health:SetValue(UnitHealth(UNIT))

    local powerType = UnitPowerType(UNIT)
    local maxPower = UnitPowerMax(UNIT, powerType)
    power:SetMinMaxValues(0, math.max(1, maxPower))
    power:SetValue(UnitPower(UNIT, powerType))
    if addon.RefreshIndependentToTLayers then addon.RefreshIndependentToTLayers(frame) end
    if maxPower > 0 then power:Show() else power:Hide() end

    local guid = UnitGUID(UNIT)
    if frame.DragonUI_UnitGUID ~= guid then
        frame.DragonUI_UnitGUID = guid
        SetPortraitTexture(portrait, UNIT)
        addon.TargetOfTarget.UpdateClassPortrait()
    end
end

local ToTModule = UF.SmallFrame.Create({
    configKey         = "tot",
    unitToken         = UNIT,
    parentUnit        = "target",
    unitEvent         = "PLAYER_TARGET_CHANGED",
    unitTargetFilters = {"target"},
    secureVisibility  = true,
    namePrefix        = "ToT",
    frames = {
        main      = frame,
        healthBar = health,
        manaBar   = power,
        portrait  = portrait,
        nameText  = name,
        deadText  = dead,
        parent    = TargetFrame,
    },
    defaultAnchor       = "BOTTOMRIGHT",
    defaultAnchorParent = "BOTTOMRIGHT",
    defaultX            = -35,
    defaultY            = -30,
    cvar                = CVAR,
})

-- The parent frame can also invoke the native updater. Give that updater
-- a parent without a real unit and keep the retired button out of hit testing.
local nativeParking = CreateFrame("Frame")
nativeParking.unit = "none"
nativeParking:Hide()

local function DisableNativeToT()
    if not nativeFrame or nativeFrame.DragonUI_ToTReplaced then return end
    nativeFrame:UnregisterAllEvents()
    nativeFrame:SetScript("OnUpdate", nil)
    nativeFrame:SetAlpha(0)
    nativeFrame:EnableMouse(false)
    nativeFrame:SetParent(nativeParking)
    nativeFrame:Hide()
    nativeFrame.DragonUI_ToTReplaced = true
end

-- Arden visibility modes: raid, party, solo, either group, or always.
local MODE_CONDITIONS = {
    ["1"] = "group:raid",
    ["2"] = "group:party,nogroup:raid",
    ["3"] = "nogroup",
    ["4"] = "group",
}

local function BuildVisibilityRule()
    if not ToTModule.IsEnabled() or GetCVar(CVAR) == "0" or UnitIsUnit("target", "player") then
        return "hide"
    end
    local ok, cvarMode = pcall(GetCVar, "targetOfTargetMode")
    local mode = (ok and cvarMode) or _G.SHOW_TARGET_OF_TARGET_STATE or "5"
    local group = MODE_CONDITIONS[tostring(mode)]
    -- Blizzard also hides ToT while the target is dead.
    return "[target=target,dead] hide; [target=targettarget,exists"
        .. (group and ("," .. group) or "") .. "] show; hide"
end

local activeRule
local function RefreshVisibility()
    if InCombatLockdown() then return end
    DisableNativeToT()

    local rule = BuildVisibilityRule()
    if activeRule ~= rule then
        RegisterStateDriver(frame, "visibility", rule)
        activeRule = rule
    end
end

-- The target frame's aura rows make room beside a visible ToT (target.lua);
-- Blizzard used to re-lay them out from TargetofTarget_Update, now we do.
local function RelayoutTargetAuras()
    if addon.RelayoutTargetAurasForToT then
        addon.RelayoutTargetAurasForToT()
    end
end

local function RefreshSelfTarget()
    local hide = UnitIsUnit("target", "player") and true or false
    if frame.DragonUI_SuppressAlpha == hide then return end
    frame.DragonUI_SuppressAlpha = hide
    frame:SetAlpha(hide and 0 or (TargetFrame and TargetFrame:GetAlpha() or 1))
    if addon.VisibilityFade then addon.VisibilityFade.Update("target") end
    RelayoutTargetAuras()
end

local elapsed = 0
frame:HookScript("OnShow", function()
    RefreshSelfTarget()
    UpdateUnitData()
    RelayoutTargetAuras()
end)
frame:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed < 0.15 then return end
    elapsed = 0
    UpdateUnitData()
end)
frame:HookScript("OnHide", function()
    frame.DragonUI_UnitGUID = nil
    RelayoutTargetAuras()
end)

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("PLAYER_TARGET_CHANGED")
events:RegisterEvent("CVAR_UPDATE")
events:RegisterEvent("UNIT_PORTRAIT_UPDATE")
events:SetScript("OnEvent", function(_, event, unit)
    if event == "UNIT_PORTRAIT_UPDATE" then
        if unit == UNIT and frame:IsShown() then
            frame.DragonUI_UnitGUID = nil
            UpdateUnitData()
        end
    else
        -- CVAR_UPDATE passes the option's global name (e.g. SHOW_TARGET_OF_TARGET),
        -- not the CVar name; RefreshVisibility only re-registers when the rule changes.
        if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
            RefreshSelfTarget()
        end
        RefreshVisibility()
    end
end)

local function RefreshToT()
    ToTModule.Refresh()
    RefreshVisibility()
    if frame:IsShown() then UpdateUnitData() end
end

-- Export public API (must match names used by DragonUI_Options/unitframes.lua)
addon.TargetOfTarget = {
    Refresh = RefreshToT,
    frame = frame,
    RefreshToTFrame = RefreshToT,
    Reset = ToTModule.Reset,
    anchor = ToTModule.anchor,
    UpdateClassPortrait = ToTModule.UpdateClassPortrait,
}

function addon:RefreshToTFrame()
    RefreshToT()
end


