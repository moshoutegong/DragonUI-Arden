--[[
  DragonUI - Frame Enhancements: appearance (modules/bbf/appearance.lua)

  * Names: strip the realm from cross-realm players and class-color party
    names. Player/target/focus name color and the class-colored name banner
    are read by unitframes/player.lua and target_style.lua via addon.BBFGet().
  * Hide elements: group number, level, PvP/leader/rest icons, portrait hit text.
    Done with alpha (+ a SetAlpha guard) so we never Hide() anything Blizzard
    or DragonUI manage and nothing protected is touched in combat.
  * Smooth bars: health / power animate toward the new value.
]]

local addon = select(2, ...)
local BBF = addon.BBF
if not BBF then return end

local GetTime = GetTime
local abs, min, max = math.abs, math.min, math.max

-- ============================================================================
-- NAMES
-- ============================================================================

local NAME_STRINGS = {
    { name = "PlayerName",                  unit = "player" },
    { name = "TargetFrameTextureFrameName", unit = "target" },
    { name = "FocusFrameTextureFrameName",  unit = "focus" },
    { name = "PartyMemberFrame1Name",       unit = "party1", party = true },
    { name = "PartyMemberFrame2Name",       unit = "party2", party = true },
    { name = "PartyMemberFrame3Name",       unit = "party3", party = true },
    { name = "PartyMemberFrame4Name",       unit = "party4", party = true },
}

local namesCfg = nil
local nameHooked = {}
local settingName = false

local function ApplyPartyNameColor(fs, unit)
    if not namesCfg or not namesCfg.class_color then return end
    local color = BBF.GetUnitClassColor(unit)
    if color then
        fs:SetTextColor(color.r, color.g, color.b)
    end
end

local function OnNameSetText(fs)
    if settingName or not namesCfg then return end
    local entry = nameHooked[fs]
    local unit = entry and entry.unit
    if not unit or not UnitExists(unit) then return end

    if namesCfg.remove_realm ~= false and UnitIsPlayer(unit) then
        -- GetUnitName adds " (*)" for other realms; UnitName's 2nd return is the realm.
        local short, realm = UnitName(unit)
        if realm and realm ~= "" and short and fs:GetText() ~= short then
            settingName = true
            fs:SetText(short)
            settingName = false
        end
    end
    if entry.party then
        ApplyPartyNameColor(fs, unit)
    end
end

local function HookNameStrings()
    for i = 1, #NAME_STRINGS do
        local entry = NAME_STRINGS[i]
        local fs = _G[entry.name]
        if fs and not nameHooked[fs] then
            nameHooked[fs] = entry
            hooksecurefunc(fs, "SetText", OnNameSetText)
        end
    end
end

local function UpdatePartyNames()
    if not namesCfg then return end
    for fs, entry in pairs(nameHooked) do
        if entry.party and UnitExists(entry.unit) then
            OnNameSetText(fs)
        end
    end
end

BBF.RegisterEvent("PARTY_MEMBERS_CHANGED", UpdatePartyNames)
BBF.RegisterEvent("UNIT_NAME_UPDATE", function(event, unit)
    if namesCfg and unit and unit:match("^party%d$") then UpdatePartyNames() end
end)

local lastNameState = nil

local function RefreshNames(cfg)
    namesCfg = cfg and cfg.names or nil
    if namesCfg then
        HookNameStrings()
        for fs, entry in pairs(nameHooked) do
            local text = fs:GetText()
            if text then OnNameSetText(fs) end
        end
    end
    -- Class-colored names / banners live in DragonUI's own updaters: re-run them on change.
    local state = namesCfg and ((namesCfg.class_color and "c" or "-") .. (namesCfg.name_bg_class_color and "b" or "-")) or "off"
    if lastNameState and lastNameState ~= state then
        BBF.RefreshDragonFrames()
        if not (namesCfg and namesCfg.class_color) then
            for fs, entry in pairs(nameHooked) do
                if entry.party then fs:SetTextColor(1, 0.82, 0) end
            end
        end
    end
    lastNameState = state
end

-- ============================================================================
-- HIDE ELEMENTS
-- ============================================================================

local HIDE_GROUPS = {
    group_indicator = { "PlayerFrameGroupIndicator", "DragonUIPlayerGroupIndicator" },
    level = { "PlayerLevelText", "TargetFrameTextureFrameLevelText", "FocusFrameTextureFrameLevelText" },
    pvp_icon = {
        "PlayerPVPIcon", "TargetFrameTextureFramePVPIcon", "FocusFrameTextureFramePVPIcon",
        "PartyMemberFrame1PVPIcon", "PartyMemberFrame2PVPIcon",
        "PartyMemberFrame3PVPIcon", "PartyMemberFrame4PVPIcon",
    },
    hit_indicator = { "PlayerHitIndicator", "PetHitIndicator" },
    leader_icon = {
        "PlayerLeaderIcon", "PlayerMasterIcon", "PlayerGuideIcon",
        "TargetFrameTextureFrameLeaderIcon", "FocusFrameTextureFrameLeaderIcon",
        "PartyMemberFrame1LeaderIcon", "PartyMemberFrame2LeaderIcon",
        "PartyMemberFrame3LeaderIcon", "PartyMemberFrame4LeaderIcon",
        "PartyMemberFrame1MasterIcon", "PartyMemberFrame2MasterIcon",
        "PartyMemberFrame3MasterIcon", "PartyMemberFrame4MasterIcon",
    },
    rest_icon = { "PlayerRestIcon", "PlayerRestGlow" },
}

local hiddenRegions = {}  -- region -> alpha to restore
local alphaHooked = {}

local function GuardAlpha(region, alpha)
    -- SetAlpha(0) re-enters with alpha 0, so no recursion guard is needed.
    if hiddenRegions[region] and alpha and alpha > 0 then
        hiddenRegions[region] = alpha
        region:SetAlpha(0)
    end
end

local function SetRegionHidden(region, hide)
    if hide then
        if not hiddenRegions[region] then
            hiddenRegions[region] = region:GetAlpha() > 0 and region:GetAlpha() or 1
        end
        if not alphaHooked[region] then
            hooksecurefunc(region, "SetAlpha", GuardAlpha)
            alphaHooked[region] = true
        end
        region:SetAlpha(0)
    elseif hiddenRegions[region] then
        local restore = hiddenRegions[region]
        hiddenRegions[region] = nil
        region:SetAlpha(restore)
    end
end

local function RefreshHide(cfg)
    local hideCfg = cfg and cfg.hide
    for key, names in pairs(HIDE_GROUPS) do
        local hide = hideCfg and hideCfg[key] == true or false
        for i = 1, #names do
            local region = _G[names[i]]
            if region and region.SetAlpha then
                SetRegionHidden(region, hide)
            end
        end
    end
end

-- ============================================================================
-- SMOOTH BARS
-- ============================================================================

local SMOOTH_BARS = {
    health = {
        { "PlayerFrameHealthBar", "player" }, { "TargetFrameHealthBar", "target" },
        { "FocusFrameHealthBar", "focus" }, { "PetFrameHealthBar", "pet" },
        { "PartyMemberFrame1HealthBar", "party1" }, { "PartyMemberFrame2HealthBar", "party2" },
        { "PartyMemberFrame3HealthBar", "party3" }, { "PartyMemberFrame4HealthBar", "party4" },
        { "DragonUIToTHealthBar", "targettarget" }, { "DragonUIFoTHealthBar", "focustarget" },
    },
    power = {
        { "PlayerFrameManaBar", "player" }, { "TargetFrameManaBar", "target" },
        { "FocusFrameManaBar", "focus" }, { "PetFrameManaBar", "pet" },
        { "PartyMemberFrame1ManaBar", "party1" }, { "PartyMemberFrame2ManaBar", "party2" },
        { "PartyMemberFrame3ManaBar", "party3" }, { "PartyMemberFrame4ManaBar", "party4" },
        { "DragonUIToTManaBar", "targettarget" }, { "DragonUIFoTManaBar", "focustarget" },
    },
}

local SMOOTH_SPEED = 12 -- higher = snappier (~0.25 s to settle)

local smoothState = {}   -- bar -> { kind, unit, cur, target, guid, snap }
local animating = {}     -- bar -> true
local smoothOn = { health = false, power = false }
local internalSet = false
local smoothDriver = CreateFrame("Frame")
smoothDriver:Hide()

local function SetBarValue(bar, value)
    internalSet = true
    bar:SetValue(value)
    internalSet = false
end

local function FinishBar(bar, st)
    animating[bar] = nil
    if st.cur ~= st.target then
        st.cur = st.target
        SetBarValue(bar, st.target)
    end
end

smoothDriver:SetScript("OnUpdate", function(self, elapsed)
    local step = min(1, elapsed * SMOOTH_SPEED)
    local any = false
    for bar in pairs(animating) do
        local st = smoothState[bar]
        if not st or not smoothOn[st.kind] or not bar:IsVisible() then
            if st then FinishBar(bar, st) else animating[bar] = nil end
        else
            local _, maxValue = bar:GetMinMaxValues()
            local diff = st.target - st.cur
            if abs(diff) <= max(1, (maxValue or 0) * 0.002) then
                FinishBar(bar, st)
            else
                st.cur = st.cur + diff * step
                SetBarValue(bar, st.cur)
                any = true
            end
        end
    end
    if not any then self:Hide() end
end)

local function OnBarSetValue(bar, value)
    if internalSet then return end
    local st = smoothState[bar]
    if not st or not value then return end

    local guid = UnitGUID(bar.unit or st.unit)
    if not smoothOn[st.kind] or st.snap or st.guid ~= guid or st.cur == nil or not bar:IsVisible() then
        -- New unit, max changed or hidden: jump straight to the value.
        st.guid, st.snap = guid, false
        st.cur, st.target = value, value
        animating[bar] = nil
        return
    end
    if value == st.target then return end

    st.target = value
    -- The bar already shows the new value; put it back and animate from there.
    SetBarValue(bar, st.cur)
    animating[bar] = true
    smoothDriver:Show()
end

local function OnBarSetMinMax(bar)
    local st = smoothState[bar]
    if st then st.snap = true end
end

local function HookSmoothBars()
    for kind, list in pairs(SMOOTH_BARS) do
        for i = 1, #list do
            local bar = _G[list[i][1]]
            if bar and not smoothState[bar] and bar.SetValue then
                smoothState[bar] = { kind = kind, unit = list[i][2] }
                hooksecurefunc(bar, "SetValue", OnBarSetValue)
                hooksecurefunc(bar, "SetMinMaxValues", OnBarSetMinMax)
            end
        end
    end
end

local function RefreshSmooth(cfg)
    local smoothCfg = cfg and cfg.smooth
    smoothOn.health = smoothCfg and smoothCfg.health == true or false
    smoothOn.power = smoothCfg and smoothCfg.power == true or false
    if smoothOn.health or smoothOn.power then
        HookSmoothBars()
    end
    -- Settle anything mid-animation for a kind that was just switched off.
    for bar, st in pairs(smoothState) do
        if animating[bar] and not smoothOn[st.kind] then
            FinishBar(bar, st)
        end
    end
end

-- ============================================================================
-- REGISTRATION
-- ============================================================================

BBF.RegisterFeature("appearance", function(cfg)
    RefreshNames(cfg)
    RefreshHide(cfg)
    RefreshSmooth(cfg)
end)
