--[[
  DragonUI - Frame Enhancements core (modules/bbf/core.lua)

  Unit frame features ported from BetterBlizzFrames (Wrath "classics" branch) to
  the 3.3.5a client. Every feature is class-agnostic: Ascension (CoA) classes
  are all custom, so nothing here keys on WARRIOR/MAGE/... tokens or specs.
  Class colors always go through UF.GetClassColor (uf_core.lua).

  Config: addon.db.profile.modules.bbf (defaults in database.lua).
  Feature files register a refresh callback with BBF.RegisterFeature(); the
  options panel calls addon.RefreshBBF() after any change.
]]

local addon = select(2, ...)

local BBF = {
    features = {},
    applied = false,
}
addon.BBF = BBF

local L = addon.L

if addon.RegisterModule then
    addon:RegisterModule("bbf", BBF,
        (L and L["Frame Enhancements"]) or "Frame Enhancements",
        (L and L["Unit frame features ported from BetterBlizzFrames"]) or "Unit frame features ported from BetterBlizzFrames",
        {
            lifecycle = {
                refresh = "RefreshBBF",
                restore = "RestoreBBF",
            },
        })
end

-- ============================================================================
-- CONFIG ACCESS
-- ============================================================================

function BBF.GetConfig()
    local profile = addon.db and addon.db.profile
    return profile and profile.modules and profile.modules.bbf
end

-- Returns a feature section, or nil when the master switch is off.
function addon.BBFGetSection(section)
    local cfg = BBF.GetConfig()
    if not cfg or cfg.enabled == false then
        return nil
    end
    return cfg[section]
end

function addon.BBFGet(section, key)
    local sec = addon.BBFGetSection(section)
    return sec and sec[key]
end

-- True when section.enabled is on (and the master switch is on).
function BBF.IsOn(section)
    local sec = addon.BBFGetSection(section)
    return sec and sec.enabled == true or false
end

-- ============================================================================
-- SHARED HELPERS
-- ============================================================================

function BBF.GetClassColor(classToken)
    local UF = addon.UF
    return UF and UF.GetClassColor and UF.GetClassColor(classToken)
end

function BBF.GetUnitClassColor(unit)
    local UF = addon.UF
    return UF and UF.GetUnitClassColor and UF.GetUnitClassColor(unit)
end

-- "Name-Realm" -> "Name" (cross-realm battleground names).
function BBF.StripRealm(name)
    if type(name) ~= "string" then return name end
    local short = name:match("^([^%-]+)%-.+$")
    return short or name
end

-- Splits "a, b,123" into a set of spell names; numeric entries resolve through GetSpellInfo.
function BBF.ParseSpellNames(raw)
    local list = {}
    if type(raw) ~= "string" then return list end
    for token in raw:gmatch("[^,;\n]+") do
        token = token:gsub("^%s+", ""):gsub("%s+$", "")
        if token ~= "" then
            local id = tonumber(token)
            local name = id and GetSpellInfo(id) or (not id and token) or nil
            if name then
                list[#list + 1] = name
            end
        end
    end
    return list
end

-- Comma-separated numeric IDs -> { [id] = true }.
function BBF.ParseIdSet(raw)
    local set = {}
    if type(raw) ~= "string" then return set end
    for token in raw:gmatch("%d+") do
        set[tonumber(token)] = true
    end
    return set
end

-- Whole seconds above 10, one decimal below (cast timers, CC countdown).
function BBF.FormatTime(seconds)
    if not seconds or seconds <= 0 then return "" end
    if seconds >= 60 then
        return string.format("%dm", math.floor(seconds / 60 + 0.5))
    elseif seconds >= 10 then
        return string.format("%d", math.floor(seconds + 0.5))
    end
    return string.format("%.1f", seconds)
end

-- Throttled OnUpdate driver (no C_Timer on 3.3.5a).
function BBF.CreateTicker(interval, callback)
    local ticker = CreateFrame("Frame")
    local acc = 0
    ticker:SetScript("OnUpdate", function(self, elapsed)
        acc = acc + elapsed
        if acc >= interval then
            local dt = acc
            acc = 0
            callback(dt)
        end
    end)
    ticker:Hide()
    return ticker
end

-- ============================================================================
-- EVENT BUS
-- ============================================================================

local eventFrame = CreateFrame("Frame")
local eventHandlers = {}

eventFrame:SetScript("OnEvent", function(self, event, ...)
    local handlers = eventHandlers[event]
    if not handlers then return end
    for i = 1, #handlers do
        handlers[i](event, ...)
    end
end)

function BBF.RegisterEvent(event, handler)
    local handlers = eventHandlers[event]
    if not handlers then
        handlers = {}
        eventHandlers[event] = handlers
        -- pcall: tolerate events a custom client build might not know
        pcall(eventFrame.RegisterEvent, eventFrame, event)
    end
    handlers[#handlers + 1] = handler
end

-- ============================================================================
-- FEATURE REGISTRY
-- ============================================================================

-- refresh(cfg) is called with the bbf config table, or nil when everything must turn off.
function BBF.RegisterFeature(name, refresh)
    BBF.features[#BBF.features + 1] = { name = name, refresh = refresh }
end

local function RunFeatures(cfg)
    for i = 1, #BBF.features do
        local feature = BBF.features[i]
        local ok, err = pcall(feature.refresh, cfg)
        if not ok and addon.Error then
            addon:Error("Frame Enhancements:", feature.name, "-", err)
        end
    end
end

function addon.RefreshBBF()
    local cfg = BBF.GetConfig()
    if not cfg or cfg.enabled == false then
        RunFeatures(nil)
        BBF.applied = false
        return
    end
    RunFeatures(cfg)
    BBF.applied = true
end

function addon.RestoreBBF()
    RunFeatures(nil)
    BBF.applied = false
end

-- Re-runs Blizzard/DragonUI updates that read BBF options (names, banners, aura layout).
-- Unit frame refreshes may reposition protected frames, so they wait for combat to end.
function BBF.RefreshDragonFrames()
    if InCombatLockdown() then
        if addon.CombatQueue then
            addon.CombatQueue:Add("bbf_refresh_frames", BBF.RefreshDragonFrames)
        end
        return
    end
    if addon.PlayerFrame and addon.PlayerFrame.Refresh then
        pcall(addon.PlayerFrame.Refresh)
    end
    if addon.RefreshTargetFrame then pcall(addon.RefreshTargetFrame, addon) end
    if addon.RefreshFocusFrame then pcall(addon.RefreshFocusFrame, addon) end
    if addon.RefreshTargetFocusAuraLayout then pcall(addon.RefreshTargetFocusAuraLayout) end
end

-- ============================================================================
-- SELF-INITIALIZATION
-- ============================================================================

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "DragonUI" then
        addon:After(0.5, function()
            if addon.db and addon.db.RegisterCallback then
                addon.db.RegisterCallback(BBF, "OnProfileChanged", addon.RefreshBBF)
                addon.db.RegisterCallback(BBF, "OnProfileCopied", addon.RefreshBBF)
                addon.db.RegisterCallback(BBF, "OnProfileReset", addon.RefreshBBF)
            end
        end)
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        -- Let DragonUI finish restyling the frames before we attach to them.
        addon:After(1, addon.RefreshBBF)
    end
end)
