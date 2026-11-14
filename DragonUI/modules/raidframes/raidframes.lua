-- ===============================================================
-- DRAGONUI RAID FRAMES MODULE
-- ElvUI-style raid frames, fully custom (replaces the client's compact
-- raid frame system like Cell_Ascension does).
-- The actual frame implementation lives in frames.lua
-- (SecureGroupHeaderTemplate + polled updates); this file owns the module
-- lifecycle, resurrect cast tracking, editor mode integration and the
-- raid debuff data wiring.
-- ===============================================================
local addon = select(2, ...)
local L = addon.L

-- ===============================================================
-- MODULE REGISTRATION
-- ===============================================================
local RaidFrames = {
    applied = false,
    hooks = {},
    resCasts = {},    -- castGUID -> unit token (active res casts)
    resTargets = {},  -- unit token -> true (pending resurrect)
    anchor = nil,
    editorRegistered = false,
}
addon.RaidFrames = RaidFrames

if addon.RegisterModule then
    addon:RegisterModule("raidframes", RaidFrames,
        L["Raid Frames"],
        L["Custom raid frames: flat skin, boss debuffs, raid icons, resurrect indicator, smart visibility"])
end

local function IsModuleEnabled()
    return addon:IsModuleEnabled("raidframes")
end

local function GetFrames()
    return addon.RaidFramesFrames
end

-- ===============================================================
-- CONSTANTS
-- ===============================================================

local FLAT_FILL = "Interface\\Buttons\\WHITE8X8"

-- Resurrection spells (3.3.5a): Priest, Shaman, Paladin, Druid, Death Knight
local RES_SPELLS = {
    [2008]  = true, -- Ancestral Spirit
    [20484] = true, -- Resurrection
    [50769] = true, -- Revive
    [7328]  = true, -- Redemption
    [61999] = true, -- Raise Ally
}

-- ===============================================================
-- RESURRECT CAST TRACKING (local, no comm library)
-- ===============================================================

local function HandleResCastStart(unitTarget, castGUID, spellID)
    if not RES_SPELLS[spellID] then return end
    if not unitTarget or not UnitExists(unitTarget) then return end
    RaidFrames.resTargets[unitTarget] = true
    RaidFrames.resCasts[castGUID] = unitTarget
    local frames = GetFrames()
    if frames and frames.UpdateAll then frames.UpdateAll() end
end

local function HandleResCastEnd(castGUID)
    local unitTarget = RaidFrames.resCasts[castGUID]
    if unitTarget then
        RaidFrames.resCasts[castGUID] = nil
        RaidFrames.resTargets[unitTarget] = nil
        local frames = GetFrames()
        if frames and frames.UpdateAll then frames.UpdateAll() end
    end
end

-- ===============================================================
-- EDITOR MODE SUPPORT (anchor + simulated preview)
-- ===============================================================
-- The custom raid frame is positioned through a DragonUI anchor, like party
-- frames. In editor mode the anchor shows a simulated 25-man grid when not in
-- a raid, or controls the real frame position in a raid. Dragging saves to
-- widgets.raid and the frame follows it.

local preview = {
    built = false,
    frames = {},
    width = 0,
    height = 0,
}

local PREVIEW_GROUPS = 5     -- 25-man standard for the simulation
local GROUP_TITLE_H = 14
local GROUP_GAP = 8

local PREVIEW_COLORS = {
    { 0.30, 0.60, 0.30 },
    { 0.55, 0.45, 0.85 },
    { 0.85, 0.65, 0.25 },
    { 0.30, 0.55, 0.80 },
    { 0.80, 0.35, 0.35 },
}

local function EnsureRaidAnchor()
    if RaidFrames.anchor then return RaidFrames.anchor end
    RaidFrames.anchor = addon.CreateUIFrame(300, 400, "RaidFrames")
    if RaidFrames.anchor.editorText then
        RaidFrames.anchor.editorText:SetText(L["Raid Frames"])
    end
    return RaidFrames.anchor
end

local function GetPreviewFrameSize()
    local db = addon.db and addon.db.profile and addon.db.profile.unitframe
        and addon.db.profile.unitframe.raid or {}
    return db.frameWidth or 72, db.frameHeight or 36
end

local function BuildPreview()
    if preview.built then return end
    preview.built = true

    local anchor = EnsureRaidAnchor()
    local w, h = GetPreviewFrameSize()
    local horizontal = (addon.db and addon.db.profile and addon.db.profile.unitframe
        and addon.db.profile.unitframe.raid
        and addon.db.profile.unitframe.raid.orientation == "horizontal") or false

    local colorIndex = 0
    for _g = 1, PREVIEW_GROUPS do
        for _m = 1, 5 do
            colorIndex = colorIndex + 1
            local color = PREVIEW_COLORS[((colorIndex - 1) % #PREVIEW_COLORS) + 1]

            local f = CreateFrame("Frame", nil, anchor)
            f:SetSize(w, h)

            local bg = f:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetTexture(FLAT_FILL)
            bg:SetVertexColor(0.04, 0.04, 0.04, 0.9)

            local bar = CreateFrame("StatusBar", nil, f)
            bar:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
            bar:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, 1)
            bar:SetStatusBarTexture(FLAT_FILL)
            bar:SetStatusBarColor(color[1], color[2], color[3], 1)
            bar:SetMinMaxValues(0, 100)
            bar:SetValue(100)

            local nameText = f:CreateFontString(nil, "OVERLAY")
            nameText:SetFont((addon.UF and addon.UF.DEFAULT_FONT) or "Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
            nameText:SetPoint("LEFT", f, "LEFT", 3, 0)
            nameText:SetTextColor(1, 1, 1, 1)
            nameText:SetText("Name")

            tinsert(preview.frames, f)
        end
    end

    -- Groups stacked vertically; horizontal mode -> members side by side
    local totalW, totalH = w, 0
    local y = 0
    local index = 1
    for g = 1, PREVIEW_GROUPS do
        local groupH = horizontal and h or (h * 5)
        for m = 1, 5 do
            local f = preview.frames[index]
            index = index + 1
            f:ClearAllPoints()
            if horizontal then
                f:SetPoint("TOPLEFT", anchor, "TOPLEFT", (m - 1) * w, y - GROUP_TITLE_H)
            else
                f:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, y - GROUP_TITLE_H - (m - 1) * h)
            end
        end
        if horizontal then
            totalW = math.max(totalW, w * 5)
        end
        y = y - GROUP_TITLE_H - groupH - GROUP_GAP
        totalH = math.max(totalH, -y)
    end

    preview.width = totalW
    preview.height = totalH
    anchor:SetSize(preview.width, preview.height)
end

local function ShowPreview()
    BuildPreview()
    for _, f in ipairs(preview.frames) do f:Show() end
end

local function HidePreview()
    for _, f in ipairs(preview.frames) do f:Hide() end
end

local function IsRaidPositionCustomized()
    return addon.IsWidgetCustomPositioned and addon.IsWidgetCustomPositioned("raid") or false
end

local function ApplyRaidWidgetPosition()
    local anchor = EnsureRaidAnchor()
    local cfg = addon.db and addon.db.profile and addon.db.profile.widgets and addon.db.profile.widgets.raid
    local a = (cfg and cfg.anchor) or "BOTTOMLEFT"
    local x = (cfg and cfg.posX) or 4
    local y = (cfg and cfg.posY) or 195
    anchor:ClearAllPoints()
    anchor:SetPoint(a, UIParent, a, x, y)
end

-- Anchor the custom raid frame onto our anchor (position takeover)
local function AnchorRaidFrameToAnchor()
    local frames = GetFrames()
    local raidFrame = frames and frames.GetRaidFrame and frames.GetRaidFrame()
    if not raidFrame or not RaidFrames.anchor then return end
    if InCombatLockdown() then return end
    raidFrame:ClearAllPoints()
    raidFrame:SetPoint("TOPLEFT", RaidFrames.anchor, "TOPLEFT", 0, 0)
end

local function ApplyRaidPosition()
    ApplyRaidWidgetPosition()
    if IsRaidPositionCustomized() then
        AnchorRaidFrameToAnchor()
    end
end

local function ShowRaidFramesTest()
    local anchor = EnsureRaidAnchor()
    local frames = GetFrames()
    local raidFrame = frames and frames.GetRaidFrame and frames.GetRaidFrame()
    local customized = IsRaidPositionCustomized()
    local inRaid = (GetNumRaidMembers() or 0) > 0

    if inRaid and raidFrame then
        -- Real raid frames visible; the anchor controls their position.
        if customized then
            ApplyRaidWidgetPosition()
            AnchorRaidFrameToAnchor()
        else
            anchor:ClearAllPoints()
            anchor:SetPoint("TOPLEFT", raidFrame, "TOPLEFT", 0, 0)
            anchor:SetSize(math.max(raidFrame:GetWidth(), 50), math.max(raidFrame:GetHeight(), 50))
        end
        raidFrame:Show()
        HidePreview()
    else
        -- Not in a raid: show the simulated raid grid at the saved position.
        ApplyRaidWidgetPosition()
        BuildPreview()
        anchor:SetSize(preview.width, preview.height)
        ShowPreview()
        if customized and raidFrame then
            AnchorRaidFrameToAnchor()
        end
    end
end

local function HideRaidFramesTest()
    HidePreview()
end

local function RegisterEditor()
    if RaidFrames.editorRegistered then return end
    if not addon.RegisterEditableFrame then return end
    RaidFrames.editorRegistered = true

    local anchor = EnsureRaidAnchor()

    -- 把真实显示框架（DragonUIRaidFrame）作为 blizzardFrame 注册进统一位置
    -- 稳定器（core/api.lua 位置保护系统）：SetPoint 钩子、锁定、事件重放、
    -- blizzardFrameAnchor 重锚全部由 api.lua 统一管理，编辑模式编辑过位置后
    -- 进出战斗/切图/进出副本不再乱跑。
    -- 时序保证：ApplyRaidFramesSystem 先执行 frames.Apply()（创建 raidFrame）
    -- 再调用 RegisterEditor()，此处 raidFrame 必已存在；若创建失败（pcall
    -- 兜底）则传 nil，InstallFramePositionProtection 判空安全跳过。
    local frames = GetFrames()
    local raidFrame = frames and frames.GetRaidFrame and frames.GetRaidFrame()

    addon:RegisterEditableFrame({
        name = "raid",
        frame = anchor,
        blizzardFrame = raidFrame, -- 真实显示框架纳入统一位置稳定器
        blizzardFrameAnchor = function()
            return "TOPLEFT", "TOPLEFT", 0, 0
        end,
        configPath = {"widgets", "raid"},
        showTest = ShowRaidFramesTest,
        hideTest = HideRaidFramesTest,
        hasTarget = function()
            return (GetNumRaidMembers() or 0) > 0
        end,
        onHide = function()
            -- Editor exit / position replay: after the anchor position has
            -- been saved, anchor the custom frame there (takeover).
            if IsRaidPositionCustomized() then
                ApplyRaidWidgetPosition()
                AnchorRaidFrameToAnchor()
            end
        end,
        module = RaidFrames,
    })
end

-- ===============================================================
-- LIFECYCLE
-- ===============================================================

local function ApplyRaidFramesSystem()
    if RaidFrames.applied then return end
    if addon.RestoreCompactFramesSystem then addon.RestoreCompactFramesSystem() end
    RaidFrames.applied = true

    local frames = GetFrames()
    if frames and frames.Apply then
        frames.Apply()
    end

    RegisterEditor()
    ApplyRaidPosition()
end

local function RestoreRaidFramesSystem()
    if not RaidFrames.applied then return end

    HidePreview()

    local frames = GetFrames()
    if frames and frames.Restore then
        frames.Restore()
    end

    wipe(RaidFrames.resCasts)
    wipe(RaidFrames.resTargets)

    RaidFrames.applied = false
end

local function RefreshRaidFramesSystem()
    if RaidFrames.applied then
        RestoreRaidFramesSystem()
    end
    if IsModuleEnabled() then
        ApplyRaidFramesSystem()
    elseif addon.RefreshCompactFramesSystem then
        addon.RefreshCompactFramesSystem()
    end
end

addon.ApplyRaidFramesSystem = ApplyRaidFramesSystem
addon.RestoreRaidFramesSystem = RestoreRaidFramesSystem
addon.RefreshRaidFramesSystem = RefreshRaidFramesSystem

-- ===============================================================
-- EVENT FRAME
-- ===============================================================

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")

eventFrame:SetScript("OnEvent", function(_, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" and arg1 == "DragonUI" then
        if not IsModuleEnabled() then return end

        -- Apply (which hides the native system) once the whole UI is up.
        addon:After(1, function()
            if not RaidFrames.applied and IsModuleEnabled() then
                ApplyRaidFramesSystem()
            end
        end)
        return
    end

    if not RaidFrames.applied and event ~= "PLAYER_ENTERING_WORLD" then return end

    if event == "PLAYER_ENTERING_WORLD" then
        -- Safety net: self-apply at world enter if the registry apply was
        -- skipped or failed during addon load.
        if not RaidFrames.applied then
            if IsModuleEnabled() then
                ApplyRaidFramesSystem()
            else
                return
            end
        end
        local frames = GetFrames()
        if frames then
            if frames.Layout then frames.Layout() end
            if frames.UpdateVisibility then frames.UpdateVisibility() end
            if frames.UpdateAll then frames.UpdateAll() end
        end
        ApplyRaidPosition()

    elseif event == "GROUP_ROSTER_UPDATE" or event == "RAID_ROSTER_UPDATE"
        or event == "PARTY_MEMBERS_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" then
        local frames = GetFrames()
        if frames then
            if frames.RebindUnits then frames.RebindUnits() end
            if frames.Layout then frames.Layout() end
            if frames.UpdateVisibility then frames.UpdateVisibility() end
            if frames.UpdateAll then frames.UpdateAll() end
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Roster changes during combat were deferred; re-sync now
        local frames = GetFrames()
        if frames then
            if frames.RebindUnits then frames.RebindUnits() end
            if frames.Layout then frames.Layout() end
            if frames.UpdateVisibility then frames.UpdateVisibility() end
            if frames.UpdateAll then frames.UpdateAll() end
        end

    elseif event == "UNIT_SPELLCAST_START" then
        -- arg1 = unitTarget, arg2 = castGUID, arg3 = spellID
        HandleResCastStart(arg1, arg2, arg3)

    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_SUCCEEDED"
        or event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
        -- arg2 = castGUID
        HandleResCastEnd(arg2)
    end
end)
