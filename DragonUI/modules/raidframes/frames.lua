-- ===============================================================
-- DRAGONUI RAID FRAMES - CUSTOM FRAME IMPLEMENTATION
-- ===============================================================
-- Fully replaces the client's compact raid frame system
-- (CompactRaidFrameManager + CompactRaidFrameContainer).
--
-- Design (zero-dependency on this client's quirks):
--   * 40 buttons created manually from SecureUnitButtonTemplate
--     (confirmed present in SecureTemplates.xml), each bound to a fixed
--     unit token "raid1".."raid40" via SetAttribute.
--   * Grouping/layout computed from GetRaidRosterInfo on roster events
--     (manual SetPoint; deferred out of combat).
--   * Button visibility managed manually (out of combat); the whole frame's
--     visibility is driven by plain Lua on the normal (non-secure) raidFrame.
--   * NO SecureGroupHeaderTemplate (button auto-creation is unreliable on
--     this client), NO RegisterUnitWatch (the function does not exist in
--     this client's FrameXML), NO RegisterStateDriver.
-- The native compact system is moved under a hidden parent frame.
-- ===============================================================
local addon = select(2, ...)
local L = addon.L
local UF = addon.UF

local RaidFrames = addon.RaidFrames

-- ===============================================================
-- CONSTANTS
-- ===============================================================

local FLAT_FILL = "Interface\\Buttons\\WHITE8X8"
local RAID_TARGET_ICONS = "Interface\\TargetingFrame\\UI-RaidTargetingIcons"
local RES_ICON = "Interface\\RaidFrame\\Raid-Icon-Rez"
local READY_READY_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-Ready"
local READY_NOT_READY_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-NotReady"
local READY_WAITING_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-Waiting"

local RAID_DEBUFFS = addon.RaidDebuffsData or {}
local RAID_DEBUFFS_BY_NAME = {}

local UPDATE_INTERVAL = 0.2

-- Out-of-range fade: members beyond the interact distance (28 yards,
-- CheckInteractDistance index 4) get their frame dimmed.
local RANGE_FADE_ALPHA = 0.6

-- Mute the vivid class colors to match the compact raid frame look
-- (same multiplier as compactframes.lua's COLOR_MULTIPLIER)
local CLASS_COLOR_MULTIPLIER = 0.75

local MAX_RAID_MEMBERS = 40
local MAX_GROUPS = 8

-- ===============================================================
-- STATE
-- ===============================================================

local raidFrame          -- main frame (parent of buttons)
local allButtons = {}    -- [1..40] unit buttons
local groupTitles = {}   -- [1..8] group number labels (container frames)
local nativeHidden = false
local hiddenParent       -- hidden parent for the native compact system

-- ===============================================================
-- DB ACCESS
-- ===============================================================

local function GetDB()
    if addon.db and addon.db.profile and addon.db.profile.unitframe then
        return addon.db.profile.unitframe.raid or {}
    end
    return {}
end

-- ===============================================================
-- RIGHT-CLICK MENU (ElvUI/oUF-style popup)
-- ===============================================================
-- This client's SECURE_ACTIONS table has no "togglemenu" handler, so the
-- button must provide a `menu` method itself (SecureActionButton_OnClick
-- falls back to rawget(self, "togglemenu")). oUF does exactly this: a shared
-- UIDropDownMenuTemplate popup.
--
-- "Set Focus" is restricted on this client ("only available to the Blizzard
-- UI" when called from third-party menus). The Blizzard way to set focus is a
-- SecureActionButton with type="focus" (SECURE_ACTIONS.focus -> FocusUnit in
-- the secure environment), so each raid button gets a hidden focus button and
-- the menu item clicks it.

local secureDropdown

local RAID_ICON_TEX = "Interface\\TargetingFrame\\UI-RaidTargetingIcons"

local function RaidIconString(index)
    local left = ((index - 1) % 4) * 16
    local top = math.floor((index - 1) / 4) * 16
    return string.format(
        "|T%s:16:16:0:0:64:64:%d:%d:%d:%d|t",
        RAID_ICON_TEX, left, left + 16, top, top + 16)
end

local function InitializeRaidMenu(self, level)
    local unit = self.unit
    if not unit then return end
    level = level or 1

    if level == 1 then
        -- NOTE: each item gets its OWN info table — reusing one table makes
        -- UIDropDownMenu_AddButton carry stale fields across items on this
        -- client (e.g. the Cancel item inheriting the raid-icon item's text).

        local info = UIDropDownMenu_CreateInfo()
        info.text = INVITE
        info.func = function() InviteUnit(unit) end
        UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
        info.text = UNINVITE
        info.func = function() UninviteUnit(unit) end
        UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
        info.text = TRADE
        info.func = function() TradeUnit(unit) end
        UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
        info.text = FOLLOW
        info.func = function() FollowUnit(unit) end
        UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
        info.text = INSPECT
        info.func = function() InspectUnit(unit) end
        UIDropDownMenu_AddButton(info, level)

        -- Raid target icon submenu
        info = UIDropDownMenu_CreateInfo()
        info.text = RAID_TARGET_ICON
        info.hasArrow = true
        info.func = function() end
        UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
        info.text = CANCEL
        info.func = function() CloseDropDownMenus() end
        UIDropDownMenu_AddButton(info, level)

    elseif level == 2 then
        for i = 1, 8 do
            local info = UIDropDownMenu_CreateInfo()
            info.text = RaidIconString(i)
            info.func = function() SetRaidTargetIcon(unit, i) end
            UIDropDownMenu_AddButton(info, level)
        end

        local info = UIDropDownMenu_CreateInfo()
        info.text = RAID_TARGET_NONE
        info.func = function() SetRaidTargetIcon(unit, 0) end
        UIDropDownMenu_AddButton(info, level)
    end
end

local function RaidButtonToggleMenu(self, unit)
    if not secureDropdown then
        secureDropdown = CreateFrame("Frame", "DragonUIRaidDropdown", UIParent, "UIDropDownMenuTemplate")
        secureDropdown:SetID(1)
        tinsert(UnitPopupFrames, secureDropdown:GetName())
        UIDropDownMenu_Initialize(secureDropdown, InitializeRaidMenu, "MENU")
    end

    if secureDropdown.openedFor and secureDropdown.openedFor ~= self then
        CloseDropDownMenus()
    end

    secureDropdown.unit = string.lower(unit or "")
    secureDropdown.openedFor = self

    ToggleDropDownMenu(1, nil, secureDropdown, "cursor")
end

-- ===============================================================
-- BUTTON ELEMENTS (called from the XML template OnLoad)
-- ===============================================================

function DragonUIRaidButton_OnLoad(button)
    if button.DragonUI_Built then return end
    button.DragonUI_Built = true

    local db = GetDB()
    local powerHeight = db.powerBarHeight or 4

    -- Background
    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(FLAT_FILL)
    bg:SetVertexColor(0.03, 0.03, 0.03, 0.5)
    button.background = bg

    -- Health bar (fills the frame minus the power strip, ElvUI raid style)
    local health = CreateFrame("StatusBar", nil, button)
    health:SetStatusBarTexture(FLAT_FILL)
    health:SetStatusBarColor(0.2, 0.6, 0.2, 1)
    health:SetMinMaxValues(0, 1)
    health:SetValue(1)
    health:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
    -- BOTTOMRIGHT y offset is POSITIVE (up): bottom edge sits powerHeight+1
    -- above the button's bottom edge — flush with the power bar's top edge.
    health:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, powerHeight + 1)
    button.healthBar = health

    -- Power bar (thin bottom strip, ElvUI raid style; height == powerHeight,
    -- top edge meets the health bar's bottom edge)
    local power = CreateFrame("StatusBar", nil, button)
    power:SetStatusBarTexture(FLAT_FILL)
    power:SetStatusBarColor(0.02, 0.32, 0.71, 1)
    power:SetMinMaxValues(0, 1)
    power:SetValue(1)
    power:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 1, powerHeight + 1)
    power:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    button.powerBar = power

    -- Text/icon frame: child frames render ABOVE the button's own layers,
    -- so every FontString/Texture that must sit on top of the bars lives
    -- here with a raised frame level (bar child frames use the parent level).
    local textFrame = CreateFrame("Frame", nil, button)
    textFrame:SetAllPoints(button)
    textFrame:SetFrameLevel(button:GetFrameLevel() + 5)
    button.textFrame = textFrame

    -- Name (inside the health bar, left-aligned, ElvUI raid style)
    local name = textFrame:CreateFontString(nil, "OVERLAY")
    name:SetFont(UF.DEFAULT_FONT, 10, "OUTLINE")
    name:SetShadowOffset(1, -1)
    name:SetShadowColor(0, 0, 0, 1)
    name:SetPoint("LEFT", textFrame, "LEFT", 3, 0)
    name:SetPoint("RIGHT", textFrame, "RIGHT", -22, 0)
    name:SetJustifyH("LEFT")
    name:SetTextColor(1, 1, 1, 1)
    button.name = name

    -- Health percentage text (right side of the health bar)
    local healthText = textFrame:CreateFontString(nil, "OVERLAY")
    healthText:SetFont(UF.DEFAULT_FONT, 9, "OUTLINE")
    healthText:SetShadowOffset(1, -1)
    healthText:SetShadowColor(0, 0, 0, 1)
    healthText:SetPoint("RIGHT", textFrame, "RIGHT", -3, 0)
    healthText:SetJustifyH("RIGHT")
    healthText:SetTextColor(1, 1, 1, 1)
    button.healthText = healthText

    -- Raid target icon (top-right corner)
    local raidIcon = textFrame:CreateTexture(nil, "OVERLAY")
    raidIcon:SetTexture(RAID_TARGET_ICONS)
    raidIcon:SetSize(14, 14)
    raidIcon:SetPoint("TOPRIGHT", textFrame, "TOPRIGHT", -2, -2)
    raidIcon:Hide()
    button.raidIcon = raidIcon

    -- Resurrect icon (bottom-right corner)
    local resIcon = textFrame:CreateTexture(nil, "OVERLAY")
    resIcon:SetTexture(RES_ICON)
    resIcon:SetSize(14, 14)
    resIcon:SetPoint("BOTTOMRIGHT", textFrame, "BOTTOMRIGHT", -2, 2)
    resIcon:Hide()
    button.resIcon = resIcon

    -- Ready check icon (center)
    local ready = textFrame:CreateTexture(nil, "OVERLAY")
    ready:SetSize(14, 14)
    ready:SetPoint("CENTER", textFrame, "CENTER", 0, 0)
    ready:Hide()
    button.readyIcon = ready

    -- Boss debuff icon (right-middle; child frame created AFTER the bars so
    -- it renders above them; raise its level to be safe)
    local rdb = CreateFrame("Frame", nil, button)
    rdb:SetFrameLevel(button:GetFrameLevel() + 3)
    local rsize = 26
    local rdbCfg = db.raidDebuffs
    if rdbCfg and rdbCfg.size then rsize = rdbCfg.size end
    rdb:SetSize(rsize, rsize)
    rdb:SetPoint("RIGHT", button, "RIGHT",
        (rdbCfg and rdbCfg.xOffset) or -4,
        (rdbCfg and rdbCfg.yOffset) or 8)
    rdb.icon = rdb:CreateTexture(nil, "ARTWORK")
    rdb.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    rdb.icon:SetPoint("TOPLEFT", rdb, "TOPLEFT", 1, -1)
    rdb.icon:SetPoint("BOTTOMRIGHT", rdb, "BOTTOMRIGHT", -1, 1)
    rdb.count = rdb:CreateFontString(nil, "OVERLAY")
    rdb.count:SetFont(UF.DEFAULT_FONT, 9, "OUTLINE")
    rdb.count:SetPoint("BOTTOMRIGHT", rdb, "BOTTOMRIGHT", 0, 1)
    rdb.count:SetTextColor(1, 0.9, 0, 1)
    rdb.count:SetJustifyH("RIGHT")
    rdb.time = rdb:CreateFontString(nil, "OVERLAY")
    rdb.time:SetFont(UF.DEFAULT_FONT, 9, "OUTLINE")
    rdb.time:SetPoint("CENTER", rdb, "CENTER", 0, 0)
    rdb.time:SetTextColor(1, 0.9, 0, 1)
    rdb.time:SetJustifyH("CENTER")
    rdb:Hide()
    button.rdebuff = rdb

    -- Secure clicks: target on click, right-click opens the unit menu
    -- (SecureUnitButton_OnClick exists in this client's SecureTemplates.lua;
    -- the "menu" action resolves to button.menu, oUF-style)
    button:SetAttribute("*type1", "target")
    button:SetAttribute("*type2", "menu")
    button:RegisterForClicks("AnyUp")
    button.menu = RaidButtonToggleMenu
end

-- ===============================================================
-- ELEMENT UPDATES
-- ===============================================================

-- Out-of-range fade: dim the whole frame while the member is farther than
-- the interact distance. This client's CheckInteractDistance only accepts
-- numeric distIndex (no "loot"/"raid1" strings); measured mapping (see
-- LibRangeCheck-2.0): 2 ~= 9 yd, 3 ~= 8-10 yd, 4 = 28 yd (interact, the
-- same range the native compact raid frames use for out-of-range fading).
-- Dead/offline members keep their full opacity so they stay visible; only
-- connected living members get faded. Re-reads the alpha every call so
-- live slider changes apply.
local function UpdateRangeState(button)
    local db = GetDB()
    if db.rangeFade == false then
        if button.rangeFaded then
            button.rangeFaded = false
            button:SetAlpha(1)
        end
        return
    end

    local unit = button:GetAttribute("unit")
    local faded = false
    if unit and UnitExists(unit) and UnitIsConnected(unit)
        and not UnitIsDeadOrGhost(unit) then
        faded = not CheckInteractDistance(unit, 4)
    end

    if faded ~= button.rangeFaded then
        button.rangeFaded = faded
        button:SetAlpha(faded and (db.rangeFadeAlpha or RANGE_FADE_ALPHA) or 1)
    elseif faded and button:GetAlpha() ~= (db.rangeFadeAlpha or RANGE_FADE_ALPHA) then
        -- Slider moved while the member is faded: apply the new opacity
        button:SetAlpha(db.rangeFadeAlpha or RANGE_FADE_ALPHA)
    end
end

local function UpdateRaidDebuff(button, unit)
    local rdb = button.rdebuff
    local db = GetDB()
    local rdbCfg = db.raidDebuffs

    if not rdbCfg or not rdbCfg.enable then
        rdb:Hide()
        return
    end

    local bestName, bestIcon, bestCount, bestTimeLeft
    local bestPriority = -1

    for i = 1, 40 do
        local name, _, icon, count, _, duration, expirationTime, _, _, _, spellID =
            UnitDebuff(unit, i, "RAID")
        if not name then break end

        local info = RAID_DEBUFFS[spellID]
        if not info then
            info = RAID_DEBUFFS_BY_NAME[name]
        end
        if info and info.priority > bestPriority then
            bestPriority = info.priority
            bestName = name
            bestIcon = icon
            bestCount = count
            if duration and duration > 0 and expirationTime then
                bestTimeLeft = expirationTime - GetTime()
            end
        end
    end

    if not bestName then
        rdb:Hide()
        return
    end

    rdb.icon:SetTexture(bestIcon)
    rdb.icon:Show()

    if bestCount and bestCount > 1 then
        rdb.count:SetText(bestCount)
        rdb.count:Show()
    else
        rdb.count:SetText("")
        rdb.count:Hide()
    end

    if bestTimeLeft and bestTimeLeft > 0 then
        local text
        if bestTimeLeft >= 60 then
            text = string.format("%d:%02d", math.floor(bestTimeLeft / 60), math.floor(bestTimeLeft % 60))
        else
            text = string.format("%.0f", bestTimeLeft)
        end
        rdb.time:SetText(text)
        rdb.time:Show()
    else
        rdb.time:SetText("")
        rdb.time:Hide()
    end

    rdb:Show()
end

local function UpdateRaidIcon(button, unit)
    local icon = button.raidIcon
    local db = GetDB()
    local ri = db.raidIcon

    local index = GetRaidTargetIndex(unit) or 0
    if not ri or not ri.enable or index == 0 then
        icon:Hide()
        return
    end

    -- ElvUI/oUF style: delegate the texcoords to the client's own helper
    -- (4x4 grid of 64px icons on the 256px UI-RaidTargetingIcons atlas,
    -- see FrameXML TargetFrame.lua SetRaidTargetIconTexture). Fall back to
    -- the equivalent math (mod(index-1,4)*0.25, floor((index-1)/4)*0.25)
    -- if the private server lacks the API.
    if SetRaidTargetIconTexture then
        SetRaidTargetIconTexture(icon, index)
    else
        local left = math.fmod((index - 1) / 4, 1)
        local top = math.floor((index - 1) / 4) * 0.25
        icon:SetTexCoord(left, left + 0.25, top, top + 0.25)
    end
    icon:Show()
end

local function UpdateResurrect(button, unit)
    local icon = button.resIcon
    local db = GetDB()
    local ri = db.resurrectIcon

    -- Clear the pending flag once the target is alive again
    if RaidFrames.resTargets[unit] and not UnitIsDeadOrGhost(unit) then
        RaidFrames.resTargets[unit] = nil
    end

    if not ri or not ri.enable or not RaidFrames.resTargets[unit] then
        icon:Hide()
    else
        icon:Show()
    end
end

local function UpdateReadyCheck(button, unit)
    local icon = button.readyIcon
    local db = GetDB()

    if not db.readyCheck then
        icon:Hide()
        return
    end

    local status = GetReadyCheckStatus(unit)
    if status == "ready" then
        icon:SetTexture(READY_READY_TEXTURE)
        icon:Show()
    elseif status == "notready" then
        icon:SetTexture(READY_NOT_READY_TEXTURE)
        icon:Show()
    elseif status == "waiting" then
        icon:SetTexture(READY_WAITING_TEXTURE)
        icon:Show()
    else
        icon:Hide()
    end
end

local function UpdateButton(button)
    local unit = button:GetAttribute("unit")
    if not unit or not UnitExists(unit) then return end

    local db = GetDB()

    -- Health
    local health, healthMax = UnitHealth(unit), UnitHealthMax(unit)
    button.healthBar:SetMinMaxValues(0, healthMax)
    button.healthBar:SetValue(health)

    -- Health color: offline gray > dead gray > class color / green
    if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
        -- Same dark gray ElvUI uses for dead/offline health bars (0.25)
        button.healthBar:SetStatusBarColor(0.25, 0.25, 0.25, 1)
        -- UnitHealth is 0 while dead, which empties the bar and leaves only
        -- the dark background. Show a full gray bar instead so dead/offline
        -- members stay clearly visible at a glance.
        button.healthBar:SetValue(healthMax > 0 and healthMax or 1)
    elseif db.classcolor and UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        local color = UF.GetClassColor(class)
        if color then
            -- Dimmed to match the compact system's muted class colors
            button.healthBar:SetStatusBarColor(
                color.r * CLASS_COLOR_MULTIPLIER,
                color.g * CLASS_COLOR_MULTIPLIER,
                color.b * CLASS_COLOR_MULTIPLIER, 1)
        else
            button.healthBar:SetStatusBarColor(0.5, 0.5, 0.5, 1)
        end
    else
        button.healthBar:SetStatusBarColor(0.2, 0.6, 0.2, 1)
    end

    -- Name
    local name = UnitName(unit)
    button.name:SetText(name or "")
    if not UnitIsConnected(unit) then
        button.name:SetTextColor(0.5, 0.5, 0.5, 1)
    else
        button.name:SetTextColor(1, 0.82, 0, 1)
    end

    -- Health percentage text
    if db.healthText and healthMax > 0 then
        local pct = math.floor(health / healthMax * 100)
        button.healthText:SetText(pct .. "%")
        button.healthText:Show()
    else
        button.healthText:Hide()
    end

    -- Power bar
    local powerBar = button.powerBar
    if db.showPower then
        local _, powerToken = UnitPowerType(unit)
        local power, powerMax = UnitPower(unit), UnitPowerMax(unit)
        powerBar:SetMinMaxValues(0, powerMax)
        powerBar:SetValue(power)
        local pcolor = PowerBarColor[powerToken] or PowerBarColor["MANA"]
        -- Dimmed to match the muted compact system colors (same as health)
        powerBar:SetStatusBarColor(
            pcolor.r * CLASS_COLOR_MULTIPLIER,
            pcolor.g * CLASS_COLOR_MULTIPLIER,
            pcolor.b * CLASS_COLOR_MULTIPLIER, 1)
        powerBar:Show()
    else
        powerBar:Hide()
    end

    -- Elements
    UpdateRaidDebuff(button, unit)
    UpdateRaidIcon(button, unit)
    UpdateResurrect(button, unit)
    UpdateReadyCheck(button, unit)
end

local function UpdateAllButtons()
    if not raidFrame or not raidFrame:IsShown() then return end
    for i = 1, MAX_RAID_MEMBERS do
        local button = allButtons[i]
        if button then
            UpdateRangeState(button)
            UpdateButton(button)
        end
    end
end

-- ===============================================================
-- BUTTON VISIBILITY (manual; secure buttons cannot be Show/Hidden in
-- combat lockdown, so we only touch them out of combat — during combat the
-- whole raidFrame parent controls visibility)
-- ===============================================================

local function UpdateButtonVisibility()
    if InCombatLockdown() then return end
    for i = 1, MAX_RAID_MEMBERS do
        local button = allButtons[i]
        if button then
            local unit = button:GetAttribute("unit")
            if unit and UnitExists(unit) then
                button:Show()
            else
                button:Hide()
            end
        end
    end
end

-- ===============================================================
-- LAYOUT (fixed ElvUI-style grid: 8 groups side by side, 5 members
-- stacked per group; button positions never change, only unit bindings)
-- ===============================================================

local function Layout()
    if not raidFrame then return end
    -- Manual SetPoint on secure buttons is forbidden in combat lockdown
    if InCombatLockdown() then return end

    local db = GetDB()
    local width = db.frameWidth or 76
    local height = db.frameHeight or 28
    local spacingX = db.spacingX or 2
    local spacingY = db.spacingY or 0
    local groupSpacing = db.groupSpacing or 4
    local horizontal = db.orientation == "horizontal"
    local powerHeight = db.powerBarHeight or 4

    -- Fixed positions: group g, member j -> button (g-1)*5 + j
    -- vertical:   members stacked, groups side by side
    -- horizontal: members side by side, groups stacked (one row per group)
    -- TITLE_HEIGHT reserves space above each column in vertical mode for its
    -- number label. In horizontal mode no extra band is reserved — the group
    -- number is drawn to the left of the row's first health bar instead.
    local TITLE_HEIGHT = 14
    local ROW_SPACING = groupSpacing
    for g = 1, MAX_GROUPS do
        for j = 1, 5 do
            local b = allButtons[(g - 1) * 5 + j]
            if b then
                b:SetSize(width, height)
                b:ClearAllPoints()
                if horizontal then
                    if j == 1 then
                        b:SetPoint("TOPLEFT", raidFrame, "TOPLEFT",
                            0, -(g - 1) * (height + ROW_SPACING))
                    else
                        b:SetPoint("TOPLEFT", allButtons[(g - 1) * 5 + j - 1], "TOPRIGHT", spacingX, 0)
                    end
                else
                    if j == 1 then
                        b:SetPoint("TOPLEFT", raidFrame, "TOPLEFT",
                            (g - 1) * (width + groupSpacing), -TITLE_HEIGHT)
                    else
                        b:SetPoint("TOPLEFT", allButtons[(g - 1) * 5 + j - 1], "BOTTOMLEFT", 0, -spacingY)
                    end
                end
            end
        end
    end

    -- Group number labels (shown only for groups with members).
    -- NOTE: the frame's TOP anchor is its horizontal CENTER, so vertical mode
    -- anchors to TOPLEFT (x relative to the left edge) and centers the text
    -- via the FontString's TOP point; horizontal mode is TOPLEFT-anchored.
    local showTitles = db.showGroupTitles ~= false
    for g = 1, MAX_GROUPS do
        local t = groupTitles[g]
        if t then
            t:ClearAllPoints()
            if horizontal then
                -- Left of the row's first health bar, vertically centered
                t:SetPoint("RIGHT", allButtons[(g - 1) * 5 + 1], "LEFT", -6, 0)
            else
                -- Centered on the group column, then shifted left 20px
                t:SetPoint("TOP", raidFrame, "TOPLEFT",
                    (g - 1) * (width + groupSpacing) + width / 2 - 20, -1)
            end
            if not showTitles then
                t:Hide()
            end
        end
    end

    -- Size the main frame to contain the full grid
    local totalW, totalH
    if horizontal then
        totalW = width * 5 + spacingX * 4
        totalH = height * MAX_GROUPS + ROW_SPACING * (MAX_GROUPS - 1)
    else
        totalW = width * MAX_GROUPS + groupSpacing * (MAX_GROUPS - 1)
        totalH = height * 5 + spacingY * 4 + TITLE_HEIGHT
    end
    raidFrame:SetSize(totalW, totalH)

    -- Element geometry depends on frame size
    for i = 1, MAX_RAID_MEMBERS do
        local b = allButtons[i]
        if b then
            if b.healthBar then
                b.healthBar:SetPoint("TOPLEFT", b, "TOPLEFT", 1, -1)
                b.healthBar:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -1, powerHeight + 1)
            end
            if b.powerBar then
                b.powerBar:SetPoint("TOPLEFT", b, "BOTTOMLEFT", 1, powerHeight + 1)
                b.powerBar:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -1, 1)
            end
        end
    end
end

-- ===============================================================
-- UNIT BINDINGS (ElvUI-style: grid slots are fixed, roster members are
-- bound into the slots on roster events, out of combat)
-- ===============================================================

local function RebindUnits()
    if InCombatLockdown() then return end

    -- Collect roster indices per raid group (GetRaidRosterInfo order)
    local numRaid = GetNumRaidMembers() or 0
    local groups = {}
    for i = 1, numRaid do
        local _, _, subgroup = GetRaidRosterInfo(i)
        subgroup = subgroup or 1
        groups[subgroup] = groups[subgroup] or {}
        tinsert(groups[subgroup], i)
    end

    -- Bind slot (g, j) to the j-th member of group g
    local showTitles = GetDB().showGroupTitles ~= false
    for g = 1, MAX_GROUPS do
        for j = 1, 5 do
            local button = allButtons[(g - 1) * 5 + j]
            if button then
                local rosterIndex = groups[g] and groups[g][j]
                if rosterIndex then
                    button:SetAttribute("unit", "raid" .. rosterIndex)
                else
                    button:SetAttribute("unit", nil)
                end
            end
        end
        -- Group number labels only for groups that actually have members
        local title = groupTitles[g]
        if title then
            if showTitles and groups[g] and #groups[g] > 0 then
                title:Show()
            else
                title:Hide()
            end
        end
    end
end

-- ===============================================================
-- VISIBILITY (plain Lua — this client lacks RegisterStateDriver /
-- SecureHandlerStateTemplate, so we drive the frame directly. raidFrame is a
-- plain frame, but its secure unit-button children make it protected, so
-- Show/Hide is blocked in combat: defer until combat ends.)
-- ===============================================================

local function IsInRaidInstance()
    local inInstance, instanceType = IsInInstance()
    return inInstance and instanceType == "raid"
end

local function UpdateVisibility()
    if not raidFrame then return end
    if InCombatLockdown() then
        if addon.CombatQueue then
            addon.CombatQueue:Add("raidframes_visibility", UpdateVisibility)
        end
        return
    end

    local db = GetDB()
    local mode = db.smartVisibility or "auto"
    local show

    if mode == "never" then
        show = false
    elseif mode == "always" then
        show = (GetNumRaidMembers() or 0) > 0
    else -- auto
        local numRaid = GetNumRaidMembers() or 0
        local minMembers = math.max(2, math.min(40, db.minRaidMembers or 6))
        show = numRaid >= minMembers or IsInRaidInstance()
    end

    if show then
        raidFrame:Show()
    else
        raidFrame:Hide()
    end
    UpdateButtonVisibility()
end

-- ===============================================================
-- HIDE NATIVE COMPACT SYSTEM
-- ===============================================================
-- The container is a CHILD of the manager (SetParent in its OnLoad), so
-- re-parenting the manager under a hidden frame hides the whole system.
-- CompactPartyFrame is hidden too, and useCompactPartyFrames is forced off
-- so the classic party frames (styled by party.lua) keep working.

local function HideNativeCompactSystem()
    if nativeHidden then return end
    nativeHidden = true

    if not hiddenParent then
        hiddenParent = CreateFrame("Frame")
        hiddenParent:Hide()
    end

    local manager = _G.CompactRaidFrameManager
    if manager then
        manager:SetParent(hiddenParent)
    end

    local compactParty = _G.CompactPartyFrame
    if compactParty then
        compactParty:SetParent(hiddenParent)
    end

    if GetCVar and SetCVar and GetCVar("useCompactPartyFrames") == "1" then
        SetCVar("useCompactPartyFrames", "0")
    end
end

local function RestoreNativeCompactSystem()
    if not nativeHidden then return end

    local manager = _G.CompactRaidFrameManager
    if manager then
        manager:SetParent(UIParent)
    end

    local compactParty = _G.CompactPartyFrame
    if compactParty then
        compactParty:SetParent(UIParent)
    end

    nativeHidden = false
end

-- ===============================================================
-- CREATE / DESTROY
-- ===============================================================

local function CreateFrames()
    if raidFrame then return end

    -- Main frame (plain frame; buttons are its children)
    raidFrame = CreateFrame("Frame", "DragonUIRaidFrame", UIParent)
    raidFrame:Hide()
    raidFrame:SetFrameStrata("MEDIUM")
    raidFrame:SetFrameLevel(2)

    -- 40 unit buttons, each bound to a fixed unit token
    for i = 1, MAX_RAID_MEMBERS do
        local button = CreateFrame("Button", "DragonUIRaidButton" .. i, raidFrame,
            "DragonUIRaidButtonTemplate")
        button:SetID(i)
        button:SetAttribute("unit", "raid" .. i)
        button:Hide()
        allButtons[i] = button
    end

    -- Group number labels above each column/row (compact system style).
    -- They live in the TITLE_HEIGHT band above the buttons, so plain
    -- FontStrings on raidFrame are visible there (not covered by buttons).
    for g = 1, MAX_GROUPS do
        local t = raidFrame:CreateFontString(nil, "OVERLAY")
        t:SetFont(UF.DEFAULT_FONT, 11, "OUTLINE")
        t:SetShadowOffset(1, -1)
        t:SetShadowColor(0, 0, 0, 1)
        t:SetTextColor(1, 0.82, 0, 1)
        t:SetText(L["Group"] .. " " .. g)
        t:SetJustifyH("CENTER")
        groupTitles[g] = t
    end

    -- Polled updates + out-of-combat visibility sync
    local updateFrame = CreateFrame("Frame")
    updateFrame:SetScript("OnUpdate", function(self, elapsed)
        self.t = (self.t or 0) + elapsed
        if self.t >= UPDATE_INTERVAL then
            self.t = 0
            UpdateButtonVisibility()
            UpdateAllButtons()
        end
    end)
    RaidFrames.updateFrame = updateFrame
end

local function ApplyFrames()
    local ok, err = pcall(CreateFrames)
    if not ok then
        -- Do not let a frame-creation failure kill the whole module silently
        addon:Error(L["RaidFrames"] .. ": frame creation failed - " .. tostring(err))
        return
    end
    HideNativeCompactSystem()
    Layout()
    RebindUnits()
    -- Default position: ElvUI raid anchor (bottom-left, 195 up)
    if raidFrame:GetNumPoints() == 0 then
        raidFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 4, 195)
    end
    UpdateVisibility()
end

local function RestoreFrames()
    if raidFrame then
        if InCombatLockdown() then
            -- Protected (secure children): fade now, hide once combat ends.
            raidFrame:SetAlpha(0)
            if addon.CombatQueue then
                addon.CombatQueue:Add("raidframes_restore_hide", function()
                    raidFrame:Hide()
                    raidFrame:SetAlpha(1)
                end)
            end
        else
            raidFrame:Hide()
        end
    end
    for i = 1, MAX_RAID_MEMBERS do
        local b = allButtons[i]
        if b then
            b:SetAlpha(1)
            b.rangeFaded = false
        end
    end
    if RaidFrames.updateFrame then
        RaidFrames.updateFrame:SetScript("OnUpdate", nil)
        RaidFrames.updateFrame = nil
    end
    RestoreNativeCompactSystem()
end

-- ===============================================================
-- DEBUG STATUS (paste output when reporting issues)
-- ===============================================================

local function DebugStatus()
    local lines = {}
    tinsert(lines, "applied=" .. tostring(RaidFrames.applied))
    tinsert(lines, "raidFrame=" .. tostring(raidFrame ~= nil))
    if raidFrame then
        tinsert(lines, "raidFrameShown=" .. tostring(raidFrame:IsShown()))
    end
    tinsert(lines, "numRaidMembers=" .. tostring(GetNumRaidMembers() or 0))
    local numButtons = 0
    for i = 1, MAX_RAID_MEMBERS do
        if allButtons[i] then numButtons = numButtons + 1 end
    end
    tinsert(lines, "buttons=" .. numButtons)
    local db = GetDB()
    tinsert(lines, "smartVisibility=" .. tostring(db.smartVisibility or "auto"))
    tinsert(lines, "minRaidMembers=" .. tostring(db.minRaidMembers or 6))
    return table.concat(lines, " | ")
end

-- ===============================================================
-- EXPORTS (used by raidframes.lua)
-- ===============================================================

addon.RaidFramesFrames = {
    Apply = ApplyFrames,
    Restore = RestoreFrames,
    Layout = Layout,
    RebindUnits = RebindUnits,
    UpdateVisibility = UpdateVisibility,
    GetRaidFrame = function() return raidFrame end,
    UpdateAll = UpdateAllButtons,
    DebugStatus = DebugStatus,
}
