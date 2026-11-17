-- Copyright (c) 2026 NeticSoul. Licensed under the MIT License; see LICENSE.
-- Portions adapted from KPack ChatMods by bkader (MIT/X); see THIRD_PARTY_NOTICES.

    local addon = select(2, ...)

    -- ============================================================================
    -- CHAT MODS MODULE FOR DRAGONUI
    -- Features: hide chat buttons, editbox positioning, mousewheel scroll,
    -- tell target (/tt), URL detection & copy, link hover tooltips,
    -- chat copy (double-click tab), unlimited resizing, AFK/DND dedup.
    -- ============================================================================

    local _G = _G
    local format, gsub, find = string.format, string.gsub, string.find
    local abs = math.abs
    local ipairs, select, tostring = ipairs, select, tostring
    local tinsert, table_concat = table.insert, table.concat
    local NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS or 10
    local CHAT_FRAME_LIMIT = 10
    local CHAT_EDITBOX_PARTS = {"Left", "Mid", "Right"}

    -- Module state tracking
    local ChatModsModule = {
        initialized = false,
        applied = false,
        originalStates = {},
        hooks = {},
        frames = {}
    }

    -- Register with ModuleRegistry
    if addon.RegisterModule then
        addon:RegisterModule("chatmods", ChatModsModule,
            (addon.L and addon.L["Chat Mods"]) or "Chat Mods",
            (addon.L and addon.L["Chat enhancements: hide buttons, editbox position, URL copy, chat copy, link hover, tell target"]) or "Chat enhancements: hide buttons, editbox position, URL copy, chat copy, link hover, tell target")
    end

    -- ============================================================================
    -- CONFIGURATION FUNCTIONS
    -- ============================================================================

    local function GetModuleConfig()
        return addon:GetModuleConfig("chatmods")
    end

    local function IsModuleEnabled()
        return addon:IsModuleEnabled("chatmods")
    end

    -- alwaysShowButtons: keep the chat side buttons (scroll, menu, friends) fully
    -- visible instead of fading them with the chat tabs.
    local function ButtonsAlwaysShown()
        local cfg = GetModuleConfig()
        return cfg and cfg.alwaysShowButtons == true
    end

    -- ============================================================================
    -- BUTTON HIDING & CHAT FRAME TWEAKS
    -- ============================================================================

    local ALPHA_EPSILON = 0.01
    local HOVER_UPDATE_THROTTLE = 0.1
    local HOVER_IDLE_TICKS_TO_SLEEP = 3

    local function IsAlphaChanged(current, target)
        return abs((current or 0) - (target or 0)) > ALPHA_EPSILON
    end

    local function SetMouseIfChanged(frame, enabled)
        if not frame or not frame.EnableMouse then return end
        if frame.IsMouseEnabled and frame:IsMouseEnabled() == enabled then
            return
        end
        frame:EnableMouse(enabled)
    end

    local function SetButtonAlpha(button, alpha)
        if not button or not button:IsShown() then return end
        if UIFrameFadeRemoveFrame then UIFrameFadeRemoveFrame(button) end
        if IsAlphaChanged(button:GetAlpha(), alpha) then
            button:SetAlpha(alpha)
        end
        SetMouseIfChanged(button, alpha >= 0.95)
    end

    local function GetOverflowButton()
        return (_G.GENERAL_CHAT_DOCK and _G.GENERAL_CHAT_DOCK.overflowButton)
            or _G.GeneralDockManagerOverflowButton
    end

    local function GetSelectedChatIndex()
        local selected = _G.SELECTED_CHAT_FRAME
        if _G.FCFDock_GetSelectedWindow and _G.GENERAL_CHAT_DOCK and (not selected or selected.isDocked) then
            selected = _G.FCFDock_GetSelectedWindow(_G.GENERAL_CHAT_DOCK) or selected
        end
        return selected and selected:GetID() or 1
    end

    local function SetDockButtonsAlpha(alpha)
        SetButtonAlpha(_G.ChatFrameMenuButton, alpha)
        SetButtonAlpha(_G.FriendsMicroButton, alpha)
        SetButtonAlpha(GetOverflowButton(), alpha)
    end

local function StripButtonFrameBackground(buttonFrame)
    if not buttonFrame then return end

    for idx = 1, select("#", buttonFrame:GetRegions()) do
        local region = select(idx, buttonFrame:GetRegions())
        if region and region:GetObjectType() == "Texture" then
            region:SetAlpha(0)
        end
    end

    if buttonFrame.SetBackdropColor then
        buttonFrame:SetBackdropColor(0, 0, 0, 0)
    end
    if buttonFrame.SetBackdropBorderColor then
        buttonFrame:SetBackdropBorderColor(0, 0, 0, 0)
    end

    buttonFrame.DragonUIBackgroundStripped = true
end

local function SetChatHoverButtonsAlpha(i, alpha, entry)
    local bf = (entry and entry.bf) or _G["ChatFrame" .. i .. "ButtonFrame"]
    SetButtonAlpha(bf, alpha)
    SetButtonAlpha((entry and entry.upBtn) or _G["ChatFrame" .. i .. "ButtonFrameUpButton"], alpha)
    SetButtonAlpha((entry and entry.downBtn) or _G["ChatFrame" .. i .. "ButtonFrameDownButton"], alpha)
    SetButtonAlpha((entry and entry.bottomBtn) or _G["ChatFrame" .. i .. "ButtonFrameBottomButton"], alpha)
end

    local function GetTabIdleAlpha(config)
        return (config and config.tabIdleAlpha ~= nil) and config.tabIdleAlpha or 0
    end

    local function GetStyleIdleAlpha(config)
        return (config and config.chatBgIdleAlpha ~= nil) and config.chatBgIdleAlpha or 0
    end

    local function GetEditboxIdleAlpha(config)
        return (config and config.editboxIdleAlpha ~= nil) and config.editboxIdleAlpha or 0
    end

    local function IsChatRegionHovered(frame)
        return frame and frame:IsVisible() and frame:IsMouseOver()
    end

    local function IsVisibleButtonHovered(button)
        return button and button:GetAlpha() >= 0.95 and IsChatRegionHovered(button)
    end

    local function IsChatButtonsHovered(cf, tab, bf, eb, selected)
        local overflow = selected and GetOverflowButton()
        local dockHovered = selected and (IsVisibleButtonHovered(_G.ChatFrameMenuButton)
            or IsVisibleButtonHovered(_G.FriendsMicroButton) or IsVisibleButtonHovered(overflow)
            or (overflow and overflow.list and overflow.list:IsVisible()))
        return dockHovered or IsChatRegionHovered(cf) or IsChatRegionHovered(tab)
            or (eb and (IsChatRegionHovered(eb) or eb:HasFocus()))
            or IsVisibleButtonHovered(bf)
    end

    local StartChatButtonsHoverUpdater
    local StopChatButtonsHoverUpdater

    local function RefreshChatFadeState()
        if not ChatModsModule.applied then return end

        local cfg = GetModuleConfig()
        local tabIdleAlpha = GetTabIdleAlpha(cfg)
        local styleIdleAlpha = GetStyleIdleAlpha(cfg)
        local ebIdleAlpha = GetEditboxIdleAlpha(cfg)
        local selectedIndex = GetSelectedChatIndex()
        local alwaysShow = ButtonsAlwaysShown()

        for i = 1, CHAT_FRAME_LIMIT do
            local cf = _G["ChatFrame" .. i]
            local tab = _G["ChatFrame" .. i .. "Tab"]
            local bf = _G["ChatFrame" .. i .. "ButtonFrame"]
            local eb = _G["ChatFrame" .. i .. "EditBox"]

            local hovered = IsChatButtonsHovered(cf, tab, bf, eb, i == selectedIndex)

            local tabAlpha = hovered and 1 or tabIdleAlpha
            if tab then
                tab.noMouseAlpha = tabIdleAlpha
                if IsAlphaChanged(tab:GetAlpha(), tabAlpha) then
                    tab:SetAlpha(tabAlpha)
                end
            end

            local buttonAlpha = (alwaysShow or hovered) and 1 or 0
            SetChatHoverButtonsAlpha(i, buttonAlpha)
            if i == selectedIndex then SetDockButtonsAlpha(buttonAlpha) end

            if cf and cf._dragonUIBgFrame and cf._dragonUIBgFrame:IsShown() then
                local bgAlpha = styleIdleAlpha
                if IsAlphaChanged(cf._dragonUIBgFrame:GetAlpha(), bgAlpha) then
                    cf._dragonUIBgFrame:SetAlpha(bgAlpha)
                end
            end

            if eb then
                if eb:GetBackdrop() then
                    local ebAlpha = eb:HasFocus() and 1 or ebIdleAlpha
                    if IsAlphaChanged(eb:GetAlpha(), ebAlpha) then
                        eb:SetAlpha(ebAlpha)
                    end
                else
                    if IsAlphaChanged(eb:GetAlpha(), 1) then
                        eb:SetAlpha(1)
                    end
                end
            end
        end

        StartChatButtonsHoverUpdater(true)
    end

local function OnChatHoverInteraction()
    if not ChatModsModule.applied then return end
    StartChatButtonsHoverUpdater(true)
end

local function AttachChatHoverRefreshHooks(frame)
    if not frame or frame.DragonUIHoverRefreshHooked then return end
    frame:HookScript("OnEnter", OnChatHoverInteraction)
    frame:HookScript("OnLeave", OnChatHoverInteraction)
    frame.DragonUIHoverRefreshHooked = true
end

StopChatButtonsHoverUpdater = function()
    local updater = ChatModsModule.hooks.chatButtonsHoverUpdater
    if updater and updater:GetScript("OnUpdate") then
        updater:SetScript("OnUpdate", nil)
    end
    ChatModsModule.frames.chatHoverForceUpdate = nil
    ChatModsModule.frames.chatHoverIdleTicks = 0
end

StartChatButtonsHoverUpdater = function(forceUpdate)
    local updater = ChatModsModule.hooks.chatButtonsHoverUpdater
    local onUpdate = ChatModsModule.frames.chatHoverOnUpdate
    if not updater or not onUpdate then return end

    if forceUpdate then
        ChatModsModule.frames.chatHoverForceUpdate = true
    end
    ChatModsModule.frames.chatHoverIdleTicks = 0

    if not updater:GetScript("OnUpdate") then
        updater:SetScript("OnUpdate", onUpdate)
    end
end

local function EnsureChatButtonsHoverUpdater()
    if ChatModsModule.hooks.chatButtonsHoverUpdater then
        return
    end

    local updater = CreateFrame("Frame")
    local _throttle = 0

    ChatModsModule.frames.chatHoverOnUpdate = function(_, elapsed)
        _throttle = _throttle + elapsed
        if _throttle < HOVER_UPDATE_THROTTLE then return end
        _throttle = 0

        if not ChatModsModule.applied then
            StopChatButtonsHoverUpdater()
            return
        end

        local entries = ChatModsModule.frames.chatHoverEntries
        if not entries or #entries == 0 then
            StopChatButtonsHoverUpdater()
            return
        end

        -- Cache config once per tick, outside the loop
        local cfg = GetModuleConfig()
        local idleAlpha = GetStyleIdleAlpha(cfg)
        local ebIdleAlpha = GetEditboxIdleAlpha(cfg)
        local forceUpdate = ChatModsModule.frames.chatHoverForceUpdate
        ChatModsModule.frames.chatHoverForceUpdate = nil

        local selectedIndex = GetSelectedChatIndex()
        local hasActiveTransition = false
        local wroteVisualState = false

        for _, entry in ipairs(entries) do
            -- StripButtonFrameBackground is NOT called here - it's handled by the
            -- OnShow hook set in ApplyChatFrameTweaks. Calling it on a throttle
            -- causes a visible flicker when Blizzard restores textures between ticks.

            local selected = entry.index == selectedIndex
            local hovered = IsChatButtonsHovered(entry.cf, entry.tab, entry.bf, entry.eb, selected)
            local targetAlpha = (hovered or cfg and cfg.alwaysShowButtons == true) and 1 or 0
            local currentAlpha = entry.bf:GetAlpha()
            local buttonAlpha = targetAlpha == 1 and 1 or math.max(0, currentAlpha - 0.25)
            if forceUpdate or IsAlphaChanged(currentAlpha, buttonAlpha) then
                wroteVisualState = true
            end
            SetChatHoverButtonsAlpha(entry.index, buttonAlpha, entry)
            if selected then SetDockButtonsAlpha(buttonAlpha) end
            if hovered or IsAlphaChanged(buttonAlpha, targetAlpha) then
                hasActiveTransition = true
            end

            -- Sync style background frame with tab fade.
            local cf = entry.cf
            if cf and cf._dragonUIBgFrame and cf._dragonUIBgFrame:IsShown() then
                local bgAlpha = idleAlpha
                if forceUpdate or entry.lastBgAlpha == nil or IsAlphaChanged(entry.lastBgAlpha, bgAlpha) then
                    cf._dragonUIBgFrame:SetAlpha(bgAlpha)
                    entry.lastBgAlpha = bgAlpha
                    wroteVisualState = true
                end
            else
                entry.lastBgAlpha = nil
            end

            -- Sync editbox style backdrop: independent from hover.
            local eb = entry.eb
            if eb and eb:GetBackdrop() then
                local ebAlpha = eb:HasFocus() and 1 or ebIdleAlpha
                if forceUpdate or entry.lastEditboxAlpha == nil or IsAlphaChanged(entry.lastEditboxAlpha, ebAlpha) then
                    eb:SetAlpha(ebAlpha)
                    entry.lastEditboxAlpha = ebAlpha
                    wroteVisualState = true
                end
            else
                entry.lastEditboxAlpha = nil
            end

        end

        if hasActiveTransition then
            ChatModsModule.frames.chatHoverIdleTicks = 0
            return
        end

        if wroteVisualState then
            ChatModsModule.frames.chatHoverIdleTicks = 1
            return
        end

        ChatModsModule.frames.chatHoverIdleTicks = (ChatModsModule.frames.chatHoverIdleTicks or 0) + 1
        if ChatModsModule.frames.chatHoverIdleTicks >= HOVER_IDLE_TICKS_TO_SLEEP then
            StopChatButtonsHoverUpdater()
        end
    end

    ChatModsModule.hooks.chatButtonsHoverUpdater = updater
end

-- Saves the Blizzard-default editbox border textures before we clear them,
-- so we can restore them when vanillaEditbox is toggled on at runtime.
local function SaveEditboxTextures()
    if ChatModsModule.originalStates.editboxTextures then return end
    local saved = {}
    for i = 1, CHAT_FRAME_LIMIT do
        saved[i] = {}
        for _, part in ipairs(CHAT_EDITBOX_PARTS) do
            local tex = _G["ChatFrame" .. i .. "EditBox" .. part]
            if tex then
                saved[i][part] = tex:GetTexture()
            end
            local focus = _G["ChatFrame" .. i .. "EditBoxFocus" .. part]
            if focus then
                saved[i]["Focus" .. part] = {focus:GetTexture(), focus:GetHeight()}
            end
        end
    end
    ChatModsModule.originalStates.editboxTextures = saved
end

-- Applies or removes the DragonUI transparent editbox border textures.
-- vanillaMode=true → restore saved Blizzard originals; false → apply transparent style.
local function ApplyEditboxBorderTextures(vanillaMode)
    local saved = ChatModsModule.originalStates.editboxTextures
    for i = 1, CHAT_FRAME_LIMIT do
        for _, part in ipairs(CHAT_EDITBOX_PARTS) do
            local tex = _G["ChatFrame" .. i .. "EditBox" .. part]
            local focus = _G["ChatFrame" .. i .. "EditBoxFocus" .. part]
            if vanillaMode then
                local s = saved and saved[i]
                if tex and s and s[part] then
                    tex:SetTexture(s[part])
                end
                if focus and s and s["Focus" .. part] then
                    focus:SetTexture(s["Focus" .. part][1])
                    focus:SetHeight(s["Focus" .. part][2])
                end
            else
                if tex then tex:SetTexture(0, 0, 0, 0) end
                if focus then
                    focus:SetTexture(0, 0, 0, 0.8)
                    focus:SetHeight(18)
                end
            end
        end
    end
end

local function ApplyChatFrameTweaks()

    ChatModsModule.frames.chatHoverEntries = ChatModsModule.frames.chatHoverEntries or {}
    wipe(ChatModsModule.frames.chatHoverEntries)
    local tabIdleAlpha = GetTabIdleAlpha(GetModuleConfig())

    -- Save original editbox border textures before any style changes.
    SaveEditboxTextures()

    for i = 1, CHAT_FRAME_LIMIT do
        local cf = _G[format("ChatFrame%d", i)]
        if cf then
            -- Fix tab fading
            local tab = _G["ChatFrame" .. i .. "Tab"]
            local eb = _G["ChatFrame" .. i .. "EditBox"]
            if tab then
                tab:SetAlpha(1)
                tab.noMouseAlpha = tabIdleAlpha
            end
            cf:SetFading(true)

            -- Unlimited resizing
            cf:SetMinResize(0, 0)
            cf:SetMaxResize(0, 0)

            -- Allow chat frame to reach screen edges
            cf:SetClampedToScreen(true)
            cf:SetClampRectInsets(0, 0, 0, 0)

            -- Transparent editbox
            for _, part in ipairs(CHAT_EDITBOX_PARTS) do
                local tex = _G["ChatFrame" .. i .. "EditBox" .. part]
                if tex then tex:SetTexture(0, 0, 0, 0) end
                local focus = _G["ChatFrame" .. i .. "EditBoxFocus" .. part]
                if focus then
                    focus:SetTexture(0, 0, 0, 0.8)
                    focus:SetHeight(18)
                end
            end

            local bf = _G["ChatFrame" .. i .. "ButtonFrame"]
            if bf then
                StripButtonFrameBackground(bf)
                if not bf.DragonUIBackgroundHooked then
                    bf:HookScript("OnShow", function(self)
                        StripButtonFrameBackground(self)
                        OnChatHoverInteraction()
                    end)
                    bf.DragonUIBackgroundHooked = true
                end
                local entry = {
                    index = i,
                    cf = cf,
                    tab = tab,
                    bf = bf,
                    eb = eb,
                    upBtn = _G["ChatFrame" .. i .. "ButtonFrameUpButton"],
                    downBtn = _G["ChatFrame" .. i .. "ButtonFrameDownButton"],
                    bottomBtn = _G["ChatFrame" .. i .. "ButtonFrameBottomButton"],
                    lastBgAlpha = nil,
                    lastEditboxAlpha = nil,
                }
                SetChatHoverButtonsAlpha(i, ButtonsAlwaysShown() and 1 or 0, entry)

                tinsert(ChatModsModule.frames.chatHoverEntries, entry)
            end

            AttachChatHoverRefreshHooks(cf)
            AttachChatHoverRefreshHooks(tab)
            AttachChatHoverRefreshHooks(bf)
            AttachChatHoverRefreshHooks(eb)
            if eb and not eb.DragonUIFocusRefreshHooked then
                eb:HookScript("OnEditFocusGained", OnChatHoverInteraction)
                eb:HookScript("OnEditFocusLost", OnChatHoverInteraction)
                eb.DragonUIFocusRefreshHooked = true
            end
        end
    end

    AttachChatHoverRefreshHooks(_G.ChatFrameMenuButton)
    AttachChatHoverRefreshHooks(_G.FriendsMicroButton)
    local overflow = GetOverflowButton()
    AttachChatHoverRefreshHooks(overflow)
    if overflow then AttachChatHoverRefreshHooks(overflow.list) end

    EnsureChatButtonsHoverUpdater()
    if ChatModsModule.applied then
        StartChatButtonsHoverUpdater(true)
    end

    -- Keep toast frame on screen
    if BNToastFrame then
        BNToastFrame:SetClampedToScreen(true)
    end
end

-- ============================================================================
-- CHAT FRAME STYLE (background skin)
-- ============================================================================

local BD_CHATBG = {
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = false, edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
}

-- style name -> { bg r/g/b/a, border r/g/b/a or nil }
local CHAT_STYLES = {
    dark = {
        bg     = {0.03, 0.03, 0.04, 0.80},
        border = nil,
    },
    dragon = {
        bg     = {0.05, 0.05, 0.08, 0.88},
        border = {0.30, 0.30, 0.40, 0.85},
    },
    midnight = {
        bg     = {0.00, 0.00, 0.00, 0.95},
        border = {0.75, 0.62, 0.18, 0.85},
    },
}

-- Extra pixels the background frame extends beyond ChatFrame's edges.
-- Tune these constants manually to adjust coverage.
local CHATBG_LEFT_PAD     = 3  -- extends left past frame edge
local CHATBG_TOP_EXTEND   = 3  -- extends above frame top edge
local CHATBG_RIGHT_EXTEND = 2  -- extends right past frame edge
local CHATBG_BOTTOM_EXTEND = 6 -- extends below frame bottom edge

local function ApplyChatStyle()
    local config = GetModuleConfig()
    local style = (config and config.chatStyle) or "none"
    local def = CHAT_STYLES[style]

    for i = 1, CHAT_FRAME_LIMIT do
        local cf = _G["ChatFrame" .. i]
        if cf then
            -- Always clear cf's native Blizzard backdrop so our bgFrame
            -- (which sits behind cf at level-1) isn't obscured by it.
            cf:SetBackdrop(nil)

            if not def then
                if cf._dragonUIBgFrame then
                    cf._dragonUIBgFrame:Hide()
                end
            else
                -- Create a dedicated backdrop frame as a child of cf.
                -- It sits at level-1 (behind cf's text) with cf's backdrop
                -- cleared above, so it's fully visible.
                if not cf._dragonUIBgFrame then
                    local bg = CreateFrame("Frame", nil, cf)
                    bg:SetFrameLevel(cf:GetFrameLevel() - 1)
                    cf._dragonUIBgFrame = bg
                end
                local bg = cf._dragonUIBgFrame
                -- Always update anchor in case extend constants changed.
                bg:ClearAllPoints()
                bg:SetPoint("TOPLEFT",     cf, "TOPLEFT",     -CHATBG_LEFT_PAD,   CHATBG_TOP_EXTEND)
                bg:SetPoint("BOTTOMRIGHT", cf, "BOTTOMRIGHT",  CHATBG_RIGHT_EXTEND, -CHATBG_BOTTOM_EXTEND)
                bg:SetBackdrop(BD_CHATBG)
                local r, g, b, a = unpack(def.bg)
                bg:SetBackdropColor(r, g, b, a)
                if def.border then
                    local br, bg2, bb, ba = unpack(def.border)
                    bg:SetBackdropBorderColor(br, bg2, bb, ba)
                else
                    bg:SetBackdropBorderColor(0, 0, 0, 0)
                end
                bg:SetAlpha(GetStyleIdleAlpha(config))
                bg:Show()
            end
        end
    end

    RefreshChatFadeState()
end

-- Editbox backdrop: slightly larger insets so the skin fills the full editbox
-- including the bottom edge that Blizzard's default textures leave exposed.
local BD_EDITBOX = {
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = false, edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
}

local function ApplyEditboxStyle()
    local config = GetModuleConfig()
    local vanillaEditbox = config and config.vanillaEditbox

    if vanillaEditbox then
        -- Restore Blizzard's default editbox textures; opacity still follows editboxIdleAlpha, applied below.
        ApplyEditboxBorderTextures(true)
        for i = 1, CHAT_FRAME_LIMIT do
            local eb = _G["ChatFrame" .. i .. "EditBox"]
            if eb then
                eb:SetBackdrop(nil)
            end
        end
        RefreshChatFadeState()
        return
    end

    local style = (config and config.editboxStyle) or "none"
    local def = CHAT_STYLES[style]
    local ebIdleAlpha = GetEditboxIdleAlpha(config)

    -- Re-apply transparent border textures in case vanilla mode was previously active.
    ApplyEditboxBorderTextures(false)

    for i = 1, CHAT_FRAME_LIMIT do
        local eb = _G["ChatFrame" .. i .. "EditBox"]
        if eb then
            -- Focus textures (Left/Mid/Right) render a solid black input indicator.
            -- When our custom style is active they overlap it, so we hide them;
            -- when no custom style is set we keep them hidden to avoid a stale dark line.
            local focusAlpha = 0
            for _, part in ipairs(CHAT_EDITBOX_PARTS) do
                local focus = _G["ChatFrame" .. i .. "EditBoxFocus" .. part]
                if focus then focus:SetTexture(0, 0, 0, focusAlpha) end
            end

            if not def then
                eb:SetBackdrop(nil)
                eb:SetAlpha(1)
            else
                eb:SetBackdrop(BD_EDITBOX)
                local r, g, b, a = unpack(def.bg)
                eb:SetBackdropColor(r, g, b, a)
                if def.border then
                    local br, bg2, bb, ba = unpack(def.border)
                    eb:SetBackdropBorderColor(br, bg2, bb, ba)
                else
                    eb:SetBackdropBorderColor(0, 0, 0, 0)
                end
                eb:SetAlpha(eb:HasFocus() and 1 or ebIdleAlpha)
            end
        end
    end

    RefreshChatFadeState()
end

-- ============================================================================
-- EDITBOX POSITIONING
-- ============================================================================

-- Height of the chat editbox in pixels. Default Blizzard is ~32; reduce for compact look.
local EDITBOX_HEIGHT = 22
-- Vertical gap between the chat frame bottom and the editbox. Increase to move it down.
local EDITBOX_Y_OFFSET = -6

local function ApplyEditBoxPosition()
    local config = GetModuleConfig()
    local pos = config and config.editbox or "bottom"

    for i = 1, CHAT_FRAME_LIMIT do
        local cf = _G[format("ChatFrame%d", i)]
        local eb = _G["ChatFrame" .. i .. "EditBox"]
        if cf and eb then
            eb:SetAltArrowKeyMode(false)
            eb:ClearAllPoints()
            eb:EnableMouse(false)
            eb:SetHeight(EDITBOX_HEIGHT)

            if pos == "middle" then
                eb:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", -200 - (CHATBG_LEFT_PAD - 1), 150)
                eb:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 200, 150)
            elseif pos == "top" then
                eb:SetPoint("BOTTOMLEFT", cf, "TOPLEFT", 2 - (CHATBG_LEFT_PAD - 0), 22)
                eb:SetPoint("BOTTOMRIGHT", cf, "TOPRIGHT", -2, 22)
            else -- bottom: place just below the chat frame with no gap
                eb:SetPoint("TOPLEFT", cf, "BOTTOMLEFT", -(CHATBG_LEFT_PAD - 0), EDITBOX_Y_OFFSET)
                eb:SetPoint("TOPRIGHT", cf, "BOTTOMRIGHT", 2, EDITBOX_Y_OFFSET)
            end
        end
    end
end

-- ============================================================================
-- TELL TARGET (/tt)
-- ============================================================================

local function TellTarget(msg)
    if not UnitExists("target") then return end
    if not (msg and msg:len() > 0) then return end
    if not UnitIsFriend("player", "target") then return end
    local name, realm = UnitName("target")
    if realm and not UnitIsSameServer("player", "target") then
        name = format("%s-%s", name, realm)
    end
    SendChatMessage(msg, "WHISPER", nil, name)
end

-- ============================================================================
-- MOUSEWHEEL SCROLL ENHANCEMENTS
-- ============================================================================

local function OnMouseScroll(self, dir)
    if dir > 0 then
        if IsShiftKeyDown() then
            self:ScrollToTop()
        elseif IsControlKeyDown() then
            self:ScrollUp()
            self:ScrollUp()
        end
    elseif dir < 0 then
        if IsShiftKeyDown() then
            self:ScrollToBottom()
        elseif IsControlKeyDown() then
            self:ScrollDown()
            self:ScrollDown()
        end
    end
end

-- ============================================================================
-- EDITBOX MOUSE TOGGLE (enable on open, disable on send)
-- ============================================================================

local function OnChatFrameOpenChat()
    for i = 1, CHAT_FRAME_LIMIT do
        local box = _G["ChatFrame" .. i .. "EditBox"]
        if box then box:EnableMouse(true) end
    end
end

local function OnChatEditSendText()
    for i = 1, CHAT_FRAME_LIMIT do
        local box = _G["ChatFrame" .. i .. "EditBox"]
        if box then box:EnableMouse(false) end
    end
end

-- ============================================================================
-- LINK HOVER TOOLTIPS (Alt + hover)
-- ============================================================================

local HOVERABLE_LINK_TYPES = {
    achievement = true, enchant = true, glyph = true, item = true,
    quest = true, spell = true, talent = true, unit = true
}

local function IsLinkHoverTooltipEnabled()
    local config = GetModuleConfig()
    return config and config.linkHoverTooltip == true
end

local function OnHyperlinkEnter(self, data, link)
    if not ChatModsModule.applied or not data then return end

    local linkType = data:match("^(.-):")
    if HOVERABLE_LINK_TYPES[linkType]
        and (IsLinkHoverTooltipEnabled() or IsAltKeyDown()) then
        ShowUIPanel(GameTooltip)
        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
        ChatModsModule.frames.linkHoverTooltipShown = true
    end
end

local function OnHyperlinkLeave(self, data, link)
    if not ChatModsModule.applied or not data then return end

    local linkType = data:match("^(.-):")
    if HOVERABLE_LINK_TYPES[linkType] and ChatModsModule.frames.linkHoverTooltipShown then
        HideUIPanel(GameTooltip)
        ChatModsModule.frames.linkHoverTooltipShown = nil
    end
end

addon.RefreshChatLinkHover = function()
    if ChatModsModule.frames.linkHoverTooltipShown
        and not IsLinkHoverTooltipEnabled() then
        HideUIPanel(GameTooltip)
        ChatModsModule.frames.linkHoverTooltipShown = nil
    end
end

local function ApplyLinkHover()
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame" .. i]
        if frame then
            frame:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)
            frame:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
        end
    end
end

-- ============================================================================
-- AFK / DND MESSAGE DEDUP
-- ============================================================================

local afkDndCache = {}
local function FilterAfkDnd(arg1, arg2)
    if afkDndCache[arg2] and afkDndCache[arg2] == arg1 then
        return true
    end
    afkDndCache[arg2] = arg1
end

-- ============================================================================
-- CHANNEL BUTTON BAR (Ported from KK_Chat)
-- Floating channel switching buttons anchored near the chat editbox
-- ============================================================================

-- Button text creation helper
local function KK_CreateBtnText(button, text, r, g, b)
    if not button.kkTextObj then
        local obj = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        obj:SetFont("Fonts\\ARIALN.ttf", 16, "OUTLINE")
        obj:SetTextColor(r, g, b)
        obj:SetText(text)
        obj:SetPoint("CENTER", 0, 0)
        obj:Show()
        button.kkTextObj = obj
    else
        button.kkTextObj:SetText(text)
        button.kkTextObj:SetTextColor(r, g, b)
        button.kkTextObj:Show()
    end
end

-- Button icon creation helper
local function KK_CreateBtnIcon(button, iconPath, size)
    size = size or 18
    if not button.kkIconObj then
        local tex = button:CreateTexture(nil, "ARTWORK")
        tex:SetTexture(iconPath)
        tex:SetSize(size, size)
        tex:SetPoint("CENTER", 0, 0)
        tex:Show()
        button.kkIconObj = tex
        if button.kkTextObj then
            button.kkTextObj:Hide()
        end
        if button:GetText() then
            button:SetText("")
        end
    else
        button.kkIconObj:SetTexture(iconPath)
        button.kkIconObj:SetSize(size, size)
        button.kkIconObj:Show()
        if button.kkTextObj then
            button.kkTextObj:Hide()
        end
    end
end

-- Channel color based on type
local function KK_GetChanColor(chatType)
    if chatType == "SAY" then
        return 1, 1, 1
    elseif chatType == "PARTY" then
        return 0.65, 0.65, 1
    elseif chatType == "RAID" or chatType == "RAID_LEADER" then
        return 0.77, 0.6, 0.4
    elseif chatType == "BATTLEGROUND" then
        return 1, 0.3, 0.1
    elseif chatType == "GUILD" then
        return 0, 0.6, 0
    elseif chatType == "YELL" then
        return 1, 0.5, 0
    elseif chatType == "WHISPER" then
        return 1, 0.5, 1
    elseif chatType == "OFFICER" then
        return 0.3, 0.5, 0
    elseif chatType == "RAID_WARNING" then
        return 1, 0.7, 0.1
    elseif chatType == "TRADE" then
        return 0.4, 0.7, 1
    end
    return 0, 1, 1
end

-- Set chat type (switch the editbox to the selected channel)
local function KK_SetChatType(chatType, index)
    local editBox = DEFAULT_CHAT_FRAME.editBox

    if string.find(chatType, "CHANNEL") then
        editBox:Show()
        if editBox:GetAttribute("chatType") == "CHANNEL" and editBox:GetAttribute("channelTarget") == index then
            ChatFrame_OpenChat("", DEFAULT_CHAT_FRAME)
        else
            editBox:SetAttribute("chatType", "CHANNEL")
            editBox:SetAttribute("channelTarget", index)
            ChatEdit_UpdateHeader(editBox)
        end
    elseif chatType == "WHISPER" then
        ChatFrame_ReplyTell(DEFAULT_CHAT_FRAME)
        ChatFrame_OpenChat("/w ", DEFAULT_CHAT_FRAME)
    else
        editBox:Show()
        editBox:SetText("")
        editBox:SetAttribute("chatType", chatType)
        ChatEdit_UpdateHeader(editBox)
    end
    editBox:SetFocus()
end

-- Create a channel button
local function KK_CreateChanButton(name, text, chatType, showFunc, index, prevBtn, parent)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(25, 24)
    btn:SetFrameStrata("MEDIUM")
    btn:SetAlpha(0.8)
    btn:RegisterForDrag("LeftButton")
    btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

    local r, g, b = KK_GetChanColor(chatType)
    KK_CreateBtnText(btn, text, r, g, b)

    -- Lock/unlock dragging based on channel bar movable state
    btn:SetScript("OnDragStart", function()
        if parent.kkMovable then
            parent:StartMoving()
        end
    end)
    btn:SetScript("OnDragStop", function()
        if parent.kkMovable then
            parent:StopMovingOrSizing()
        end
    end)

    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            if index and index > 0 then
                local channelNum = GetChannelName(index)
                if channelNum == 0 then
                    print("|cffff0000Ch "..index.."|r: 未加入")
                    return
                end
            end
            KK_SetChatType(chatType, index or 0)
        end
    end)

    if prevBtn then
        btn:SetPoint("LEFT", prevBtn, "RIGHT", 3, 0)
    else
        btn:SetPoint("LEFT", parent, "LEFT", 0, 0)
    end

    if showFunc() then
        btn:Show()
        return btn
    else
        btn:Hide()
        return false
    end
end

-- Channel button definitions (KK_Chat order: 说 → 喊 → 中 → 队 → 团 → 警 → 战 → 会 → 密 → 官)
local KK_ChanButtons = {
    { text = "说", chatType = "SAY", show = function() return true end },
    { text = "喊", chatType = "YELL", show = function() return true end },
    { text = "中", chatType = "CHINA_CHANNEL", show = function() return true end, isChina = true },
    { text = "队", chatType = "PARTY", show = function() return true end },
    { text = "团", chatType = "RAID", show = function() return true end },
    { text = "警", chatType = "RAID_WARNING", show = function() return true end },
    { text = "战", chatType = "BATTLEGROUND", show = function() return true end },
    { text = "会", chatType = "GUILD", show = function() return IsInGuild() end },
    { text = "交", chatType = "TRADE", show = function()
        for c = 1, 10 do
            local num, name = GetChannelName(c)
            if num ~= 0 and name then
                local lower = strlower(name)
                if strfind(lower, "handel") or strfind(lower, "交易") then
                    return true
                end
            end
        end
        return false
    end },
    { text = "密", chatType = "WHISPER", show = function() return true end },
    { text = "官", chatType = "OFFICER", show = function() return CanEditOfficerNote() end },
}

-- Quick chat phrases
-- Chinese quick chat phrases (for smile button)
local KK_QuickChatPhrasesCN = {
    {"谢谢", "谢谢"},
    {"你好", "你好"},
    {"好的", "好的"},
    {"再见", "再见"},
    {"等一下", "等一下"},
    {"准备好了", "准备好了"},
    {"感谢大家", "感谢大家"},
    {"救命", "救命"},
    {"求组", "求组"},
    {"加油", "加油"},
}

-- English quick chat phrases (for 英 button - show Chinese text, send English)
local KK_QuickChatPhrasesEN = {
    {"谢谢", "tks"},
    {"你好", "hi"},
    {"好的", "ok"},
    {"再见", "bb"},
    {"等一下", "wait"},
    {"准备好了", "rdy"},
    {"感谢大家", "thanks all"},
    {"救命", "help"},
    {"求组", "inv"},
    {"加油", "go"},
}

local KK_QuickChatMenu = nil
local KK_CustomEditFrame = nil  -- 自定义编辑框

-- 自定义编辑框（添加/编辑自定义快捷短语）
local function KK_CreateCustomEditFrame(existingIndex, existingName, existingText)
    if KK_CustomEditFrame then
        KK_CustomEditFrame:Show()
        KK_CustomEditFrame.editName:SetText(existingName or "")
        KK_CustomEditFrame.editText:SetText(existingText or "")
        KK_CustomEditFrame.editingIndex = existingIndex
        -- Update title and delete button visibility on show
        KK_CustomEditFrame.title:SetText(existingIndex and "编辑自定义按钮" or "添加自定义按钮")
        if existingIndex then
            KK_CustomEditFrame.deleteBtn:Show()
        else
            KK_CustomEditFrame.deleteBtn:Hide()
        end
        return
    end

    local frame = CreateFrame("Frame", "DUICustomQuickChatEdit", UIParent, "BackdropTemplate")
    frame:SetFrameStrata("DIALOG")
    frame:SetSize(300, 220)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    frame:SetBackdropColor(0, 0, 0, 0.95)

    -- 标题
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -15)
    title:SetText(existingIndex and "编辑自定义按钮" or "添加自定义按钮")
    frame.title = title

    -- 按钮名称标签
    local nameLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -50)
    nameLabel:SetText("按钮名称(中文):")

    -- 按钮名称输入框
    local editName = CreateFrame("EditBox", nil, frame)
    editName:SetSize(240, 30)
    editName:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -5)
    editName:SetAutoFocus(false)
    editName:SetFontObject(ChatFontNormal)
    editName:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    editName:SetText(existingName or "")
    editName:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    editName:SetBackdropColor(0, 0, 0, 1)
    editName:SetTextInsets(8, 8, 0, 0)

    -- 输出文字标签
    local textLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textLabel:SetPoint("TOPLEFT", editName, "BOTTOMLEFT", 0, -15)
    textLabel:SetText("输出英文:")

    -- 输出文字输入框
    local editText = CreateFrame("EditBox", nil, frame)
    editText:SetSize(240, 30)
    editText:SetPoint("TOPLEFT", textLabel, "BOTTOMLEFT", 0, -5)
    editText:SetAutoFocus(false)
    editText:SetFontObject(ChatFontNormal)
    editText:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    editText:SetText(existingText or "")
    editText:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    editText:SetBackdropColor(0, 0, 0, 1)
    editText:SetTextInsets(8, 8, 0, 0)

    -- 保存按钮
    local saveBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    saveBtn:SetSize(80, 25)
    saveBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 30, 10)
    saveBtn:SetText("保存")
    saveBtn:SetScript("OnClick", function()
        local name = editName:GetText()
        local text = editText:GetText()
        if name ~= "" and text ~= "" then
            if not addon.db.profile.customQuickChat then
                addon.db.profile.customQuickChat = {}
            end
            local idx = frame.editingIndex
            if idx then
                addon.db.profile.customQuickChat[idx] = {name, text}
            else
                tinsert(addon.db.profile.customQuickChat, {name, text})
            end
            -- 刷新菜单
            if KK_QuickChatMenu then
                KK_QuickChatMenu:Hide()
                KK_QuickChatMenu = nil
            end
            frame:Hide()
        end
    end)

    -- 删除按钮（仅编辑时显示）
    local deleteBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    deleteBtn:SetSize(80, 25)
    deleteBtn:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
    deleteBtn:SetText("删除")
    deleteBtn:SetScript("OnClick", function()
        local idx = frame.editingIndex
        if idx and addon.db.profile.customQuickChat then
            tremove(addon.db.profile.customQuickChat, idx)
            -- Shift remaining indices
            frame.editingIndex = nil
            if KK_QuickChatMenu then
                KK_QuickChatMenu:Hide()
                KK_QuickChatMenu = nil
            end
            frame:Hide()
        end
    end)
    if not existingIndex then
        deleteBtn:Hide()
    end
    frame.deleteBtn = deleteBtn

    -- 取消按钮
    local cancelBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    cancelBtn:SetSize(80, 25)
    cancelBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)
    cancelBtn:SetText("取消")
    cancelBtn:SetScript("OnClick", function()
        frame:Hide()
    end)

    frame.editName = editName
    frame.editText = editText
    frame.editingIndex = existingIndex
    KK_CustomEditFrame = frame
end

-- Create the quick chat dropdown menu
local function KK_CreateQuickChatMenu(anchorBtn, phraseList)
    if KK_QuickChatMenu then
        KK_QuickChatMenu:Hide()
        KK_QuickChatMenu = nil
    end

    local menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    menu:SetFrameStrata("DIALOG")
    menu:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    menu:SetBackdropColor(0, 0, 0, 0.9)
    menu:EnableMouse(true)
    menu:SetScript("OnMouseDown", function() end)

    local btnWidth = 60
    local btnHeight = 22
    local cols = 3
    local padding = 5
    local startX = 10
    local startY = -10
    local wideBtnWidth = btnWidth * cols + (cols - 1) * padding

    -- 合并默认短语和自定义短语
    local allMessages = {}
    for _, v in ipairs(phraseList) do
        tinsert(allMessages, {v[1], v[2], false})  -- false = 不是自定义
    end
    local customList = addon.db.profile.customQuickChat or {}
    for i, v in ipairs(customList) do
        tinsert(allMessages, {v[1], v[2], true, i})  -- true = 是自定义, i = 索引
    end

    local currentRow = 0
    local currentCol = 0

    -- 先处理普通短按钮（3列布局）
    for i, msg in ipairs(allMessages) do
        local textLen = #msg[1]
        local isWideBtn = textLen > 15

        if not isWideBtn then
            local btn = CreateFrame("Button", nil, menu)
            btn:SetSize(btnWidth, btnHeight)
            btn:SetPoint("TOPLEFT", menu, "TOPLEFT", startX + currentCol * (btnWidth + padding), startY - currentRow * (btnHeight + padding))

            currentCol = currentCol + 1
            if currentCol >= cols then
                currentCol = 0
                currentRow = currentRow + 1
            end

            local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            btnText:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
            btnText:SetTextColor(1, 1, 1)
            btnText:SetText(msg[1])
            btnText:SetPoint("LEFT", btn, "LEFT", 8, 0)
            btnText:Show()

            btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
            btn:RegisterForClicks("LeftButtonDown", "RightButtonDown")

            btn:SetScript("OnClick", function(self, button)
                if button == "LeftButton" then
                    if ChatFrame1.editBox:IsVisible() then
                        ChatFrame1.editBox:Insert(msg[2])
                    else
                        SendChatMessage(msg[2], "SAY")
                    end
                    menu:Hide()
                elseif button == "RightButton" and msg[3] then
                    -- 自定义按钮支持右键编辑
                    KK_CreateCustomEditFrame(msg[4], msg[1], msg[2])
                end
            end)
        end
    end

    -- 普通按钮最后一行可能未满，跳转到下一行
    if currentCol > 0 then
        currentRow = currentRow + 1
    end
    currentCol = 0

    -- 再处理宽按钮（单列显示）
    for i, msg in ipairs(allMessages) do
        local textLen = #msg[1]
        local isWideBtn = textLen > 15

        if isWideBtn then
            local btn = CreateFrame("Button", nil, menu)
            btn:SetSize(wideBtnWidth, btnHeight)
            btn:SetPoint("TOPLEFT", menu, "TOPLEFT", startX, startY - currentRow * (btnHeight + padding))
            currentRow = currentRow + 1

            local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            btnText:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
            btnText:SetTextColor(1, 1, 1)
            btnText:SetText(msg[1])
            btnText:SetPoint("LEFT", btn, "LEFT", 8, 0)
            btnText:Show()

            btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
            btn:RegisterForClicks("LeftButtonDown", "RightButtonDown")

            btn:SetScript("OnClick", function(self, button)
                if button == "LeftButton" then
                    if ChatFrame1.editBox:IsVisible() then
                        ChatFrame1.editBox:Insert(msg[2])
                    else
                        SendChatMessage(msg[2], "SAY")
                    end
                    menu:Hide()
                elseif button == "RightButton" and msg[3] then
                    KK_CreateCustomEditFrame(msg[4], msg[1], msg[2])
                end
            end)
        end
    end

    -- 添加"添加自定义"按钮
    local addBtn = CreateFrame("Button", nil, menu)
    addBtn:SetSize(wideBtnWidth, btnHeight)
    addBtn:SetPoint("TOPLEFT", menu, "TOPLEFT", startX, startY - currentRow * (btnHeight + padding))
    currentRow = currentRow + 1

    local addBtnText = addBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    addBtnText:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
    addBtnText:SetTextColor(0, 1, 0)
    addBtnText:SetText("+ 添加自定义")
    addBtnText:SetPoint("LEFT", addBtn, "LEFT", 8, 0)
    addBtnText:Show()

    addBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    addBtn:SetScript("OnClick", function()
        KK_CreateCustomEditFrame()
        menu:Hide()
    end)

    local totalRows = currentRow
    local menuWidth = startX * 2 + cols * btnWidth + (cols - 1) * padding
    local menuHeight = -startY + totalRows * (btnHeight + padding) + 20
    menu:SetSize(menuWidth, menuHeight)
    menu:SetPoint("BOTTOMLEFT", anchorBtn, "TOPRIGHT", -30, 5)

    menu:Show()

    -- Click outside to close
    local closeHandler = CreateFrame("Frame", nil, menu)
    closeHandler:SetAllPoints(menu)
    closeHandler:SetScript("OnMouseDown", function() end)
    menu.closeHandler = closeHandler

    menu:SetScript("OnHide", function(self)
        if self.closeHandler then
            self.closeHandler:Hide()
        end
    end)

    KK_QuickChatMenu = menu
end

-- Toggle quick chat menu
local function KK_ToggleQuickChat(btn, phraseList)
    phraseList = phraseList or KK_QuickChatPhrasesEN
    if KK_QuickChatMenu and KK_QuickChatMenu:IsShown() then
        KK_QuickChatMenu:Hide()
    else
        KK_CreateQuickChatMenu(btn, phraseList)
    end
end

-- Click on world frame hides quick chat menu (only hook once)
local KK_WorldClickHooked = false
local function KK_HookWorldClick()
    if KK_WorldClickHooked then return end
    KK_WorldClickHooked = true

    local oldScript = WorldFrame:GetScript("OnMouseUp")
    if oldScript then
        WorldFrame:HookScript("OnMouseUp", function()
            if KK_QuickChatMenu then
                KK_QuickChatMenu:Hide()
            end
        end)
    else
        WorldFrame:SetScript("OnMouseUp", function()
            if KK_QuickChatMenu then
                KK_QuickChatMenu:Hide()
            end
        end)
    end
end

-- ============================================================================
-- Emotion Icon Frame (ported from KK_Chat icon frame)
-- ============================================================================

local KK_IconData = {
    {"{rt1}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1", "星1"},
    {"{rt2}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2", "星2"},
    {"{rt3}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3", "星3"},
    {"{rt4}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4", "星4"},
    {"{rt5}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5", "星5"},
    {"{rt6}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6", "星6"},
    {"{rt7}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7", "星7"},
    {"{rt8}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8", "星8"},
    {"{天使}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\angel.tga", "天使"},
    {"{生气}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\angry.tga", "生气"},
    {"{大笑}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\biglaugh.tga", "大笑"},
    {"{鼓掌}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\clap.tga", "鼓掌"},
    {"{酷}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\cool.tga", "酷"},
    {"{哭}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\cry.tga", "哭"},
    {"{可爱}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\cutie.tga", "可爱"},
    {"{鄙视}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\despise.tga", "鄙视"},
    {"{美梦}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\dreamsmile.tga", "美梦"},
    {"{尴尬}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\embarrass.tga", "尴尬"},
    {"{邪恶}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\evil.tga", "邪恶"},
    {"{兴奋}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\excited.tga", "兴奋"},
    {"{晕}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\faint.tga", "晕"},
    {"{打架}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\fight.tga", "打架"},
    {"{流感}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\flu.tga", "流感"},
    {"{呆}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\freeze.tga", "呆"},
    {"{皱眉}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\frown.tga", "皱眉"},
    {"{致敬}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\greet.tga", "致敬"},
    {"{鬼脸}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\grimace.tga", "鬼脸"},
    {"{龇牙}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\growl.tga", "龇牙"},
    {"{开心}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\happy.tga", "开心"},
    {"{心}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\heart.tga", "心"},
    {"{恐惧}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\horror.tga", "恐惧"},
    {"{生病}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\ill.tga", "生病"},
    {"{无辜}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\innocent.tga", "无辜"},
    {"{功夫}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\kongfu.tga", "功夫"},
    {"{花痴}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\love.tga", "花痴"},
    {"{邮件}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\mail.tga", "邮件"},
    {"{化妆}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\makeup.tga", "化妆"},
    {"{马里奥}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\mario.tga", "马里奥"},
    {"{沉思}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\meditate.tga", "沉思"},
    {"{可怜}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\miserable.tga", "可怜"},
    {"{好}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\okay.tga", "好"},
    {"{漂亮}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\pretty.tga", "漂亮"},
    {"{吐}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\puke.tga", "吐"},
    {"{握手}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\shake.tga", "握手"},
    {"{喊}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\shout.tga", "喊"},
    {"{闭嘴}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\shuuuu.tga", "闭嘴"},
    {"{害羞}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\shy.tga", "害羞"},
    {"{睡觉}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\sleep.tga", "睡觉"},
    {"{微笑}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\smile.tga", "微笑"},
    {"{吃惊}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\suprise.tga", "吃惊"},
    {"{失败}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\surrender.tga", "失败"},
    {"{流汗}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\sweat.tga", "流汗"},
    {"{流泪}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\tear.tga", "流泪"},
    {"{悲剧}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\tears.tga", "悲剧"},
    {"{想}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\think.tga", "想"},
    {"{偷笑}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\titter.tga", "偷笑"},
    {"{猥琐}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\ugly.tga", "猥琐"},
    {"{胜利}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\victory.tga", "胜利"},
    {"{雷锋}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\volunteer.tga", "雷锋"},
    {"{委屈}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\wronged.tga", "委屈"},
}

local KK_IconFrameName = "DUIEmotionIconFrame"
local KK_ICON_SIZE = 23
local KK_ICON_COLS = 10
local KK_ICON_ROWS = 6

local function KK_IconButton_OnClick(self)
    local editBox = ChatFrame1EditBox or SELECTED_CHAT_FRAME.editBox
    if not editBox:IsShown() then
        editBox:Show()
    end
    editBox:SetFocus()
    -- Insert the plain text tag directly (2.0 behavior). The EmotionIconFilter
    -- then renders it as an icon on send, which works reliably in every channel
    -- (raid included); a raw |Ttexture|t tag instead depends on the editbox
    -- reverse-parser and can be sent as literal text in some paths.
    -- When enableEnglishEmotion is on, insert the English tag ({smile} instead
    -- of {微笑}) so the outgoing message is readable by players without the addon.
    if self.kkTag then
        local curText = editBox:GetText() or ""
        local tag = self.kkTag
        local cfg = GetModuleConfig()
        if cfg and cfg.enableEnglishEmotion then
            tag = (ChatModsModule.englishMap and ChatModsModule.englishMap[tag]) or tag
        end
        editBox:SetText(curText .. tag)
    end
    local frame = _G[KK_IconFrameName]
    if frame then frame:Hide() end
end

local function KK_IconButton_OnEnter(self)
    local frame = _G[KK_IconFrameName]
    if frame then
        GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
        GameTooltip:SetText(self.kkDisplayName)
        GameTooltip:Show()
    end
end

local function KK_IconButton_OnLeave()
    GameTooltip:Hide()
end

local function KK_CreateIconFrame()
    local frame = _G[KK_IconFrameName]
    if frame then
        frame.Show = nil  -- Remove re-show fixup, just create fresh
        frame:Hide()
        frame = nil
    end

    local parentFrame = CreateFrame("Frame", KK_IconFrameName, UIParent)
    parentFrame:SetFrameStrata("MEDIUM")
    parentFrame:SetSize(260, 160)
    parentFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
        tile = true, tileSize = 32,
        edgeSize = 7,
    })
    parentFrame:EnableMouse(true)
    parentFrame:Hide()

    parentFrame:SetScript("OnHide", function(self)
        for _, btn in ipairs(self.kkButtons or {}) do
            btn:Hide()
        end
    end)
    parentFrame:SetScript("OnShow", function(self)
        for _, btn in ipairs(self.kkButtons or {}) do
            btn:Show()
        end
    end)

    local buttons = {}
    for idx, data in ipairs(KK_IconData) do
        local btn = CreateFrame("Button", nil, parentFrame)
        btn:SetSize(KK_ICON_SIZE, KK_ICON_SIZE)
        btn:SetNormalTexture(data[2])
        btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
        btn:RegisterForClicks("LeftButtonUp")

        local col = (idx - 1) % KK_ICON_COLS
        local row = math.floor((idx - 1) / KK_ICON_COLS)
        btn:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", col * KK_ICON_SIZE + 5, -row * KK_ICON_SIZE - 5)

        btn.kkDisplayName = data[3]
        btn.kkTexture = data[2]:gsub("%.tga$", "")  -- Strip .tga to match KK_ReverseIconMap
        btn.kkTag = data[1]  -- Save text tag (e.g., {rt1}, {开心})

        btn:SetScript("OnClick", KK_IconButton_OnClick)
        btn:SetScript("OnEnter", KK_IconButton_OnEnter)
        btn:SetScript("OnLeave", KK_IconButton_OnLeave)
        btn:Hide()

        buttons[idx] = btn
    end
    parentFrame.kkButtons = buttons

    -- Click outside to close
    parentFrame:SetScript("OnMouseDown", function() end)
    WorldFrame:HookScript("OnMouseUp", function()
        if _G[KK_IconFrameName] then
            _G[KK_IconFrameName]:Hide()
        end
    end)
end

local function KK_ToggleIconFrame(anchorBtn)
    local frame = _G[KK_IconFrameName]
    if not frame then
        KK_CreateIconFrame()
        frame = _G[KK_IconFrameName]
    end
    if frame:IsShown() then
        frame:Hide()
    else
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMLEFT", anchorBtn, "TOPRIGHT", -30, 5)
        frame:Show()
    end
end

-- Build the channel button bar
local function KK_BuildChanBar()
    local cfg = GetModuleConfig()
    if not cfg.enableChanBar then return end

    -- Create container frame
    local containerName = "DUIChanBarFrame"
    local container = _G[containerName]
    if not container then
        container = CreateFrame("Frame", containerName, UIParent, "BackdropTemplate")
        container:SetFrameStrata("MEDIUM")
        container:SetSize(400, 28)
        container:SetClampedToScreen(true)
        container:EnableMouse(true)
        container:SetMovable(true)
        container:RegisterForDrag("LeftButton")
        container:SetScript("OnDragStart", function(self)
            if self.kkMovable then
                self:StartMoving()
            end
        end)
        container:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
        end)
        container:Hide()
    end

    container.kkMovable = cfg.enableChanBarMove or false
    container.buttons = {}
    container:Hide()

    local prevBtn = nil

    -- Create smile/emotion button (first button)
    local smileBtn = container.smileBtn
    if not smileBtn then
        smileBtn = CreateFrame("Button", nil, container)
        smileBtn:SetSize(20, 20)
        smileBtn:SetAlpha(0.8)
        smileBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
        smileBtn:RegisterForDrag("LeftButton")
        smileBtn:SetScript("OnDragStart", function()
            if container.kkMovable then
                container:StartMoving()
            end
        end)
        smileBtn:SetScript("OnDragStop", function()
            if container.kkMovable then
                container:StopMovingOrSizing()
            end
        end)
        smileBtn:SetScript("OnClick", function()
            KK_ToggleIconFrame(smileBtn)
        end)
        container.smileBtn = smileBtn
    end

    -- Use SetNormalTexture with DragonUI path
    smileBtn:SetNormalTexture("Interface\\AddOns\\DragonUI\\Textures\\Chat\\smile.tga")
    smileBtn:SetPoint("LEFT", container, "LEFT", 2, 0)
    smileBtn:Show()
    prevBtn = smileBtn
    tinsert(container.buttons, smileBtn)

    -- Create first 3 channel buttons (说/喊/中)
    for i = 1, 3 do
        local def = KK_ChanButtons[i]
        local btn = container["btn_"..i]
        if not btn then
            btn = CreateFrame("Button", nil, container)
            btn:SetSize(25, 24)
            btn:SetFrameStrata("MEDIUM")
            btn:SetAlpha(0.8)
            btn:RegisterForDrag("LeftButton")
            btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
            btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

            btn:SetScript("OnDragStart", function()
                if container.kkMovable then
                    container:StartMoving()
                end
            end)
            btn:SetScript("OnDragStop", function()
                if container.kkMovable then
                    container:StopMovingOrSizing()
                end
            end)

            btn:SetScript("OnClick", function(self, button)
                if self.kkIsChina then
                    -- Special handling for "中" (China) channel
                    if button == "RightButton" then
                        JoinChannelByName("china")
                    elseif button == "LeftButton" then
                        local found = false
                        for c = 1, 10 do
                            local num, name = GetChannelName(c)
                            if num ~= 0 and strfind(strlower(name or ""), "china") then
                                KK_SetChatType("CHANNEL"..c, c)
                                found = true
                                break
                            end
                        end
                        if not found then
                            print("|cffff0000未加入频道: china |cffcccccc(右键加入)|r")
                        end
                    end
                elseif self.kkChatType == "TRADE" then
                    -- Special handling for "交" (Trade) channel
                    if button == "RightButton" then
                        JoinChannelByName("交易")
                    elseif button == "LeftButton" then
                        local found = false
                        for c = 1, 10 do
                            local num, name = GetChannelName(c)
                            if num ~= 0 and name then
                                local lower = strlower(name)
                                if strfind(lower, "handel") or strfind(lower, "交易") then
                                    KK_SetChatType("CHANNEL"..c, c)
                                    found = true
                                    break
                                end
                            end
                        end
                        if not found then
                            print("|cffff0000未加入交易频道 |cffcccccc(右键加入)|r")
                        end
                    end
                elseif button == "LeftButton" then
                    if self.kkIndex and self.kkIndex > 0 then
                        local channelNum = GetChannelName(self.kkIndex)
                        if channelNum == 0 then return end
                    end
                    KK_SetChatType(self.kkChatType, self.kkIndex or 0)
                end
            end)

            container["btn_"..i] = btn
        end

        btn.kkChatType = def.chatType
        btn.kkIndex = def.index or 0
        btn.kkIsChina = def.isChina or false

        local r, g, b
        if def.isChina then
            r, g, b = 1, 0.84, 0  -- Gold color for China channel
        else
            r, g, b = KK_GetChanColor(def.chatType)
        end
        KK_CreateBtnText(btn, def.text, r, g, b)

        btn:ClearAllPoints()
        btn:SetPoint("LEFT", prevBtn, "RIGHT", 2, 0)

        if def.show() then
            btn:Show()
            prevBtn = btn
        else
            btn:Hide()
        end
        tinsert(container.buttons, btn)
    end

    -- Create quick chat button (英) — after "中", before "队"
    local qcBtn = container.qcBtn
    if not qcBtn then
        qcBtn = CreateFrame("Button", nil, container)
        qcBtn:SetSize(24, 24)
        qcBtn:SetAlpha(0.8)
        qcBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
        qcBtn:RegisterForDrag("LeftButton")
        qcBtn:SetScript("OnDragStart", function()
            if container.kkMovable then
                container:StartMoving()
            end
        end)
        qcBtn:SetScript("OnDragStop", function()
            if container.kkMovable then
                container:StopMovingOrSizing()
            end
        end)
        qcBtn:SetScript("OnClick", function(self)
            KK_ToggleQuickChat(self)
        end)
        container.qcBtn = qcBtn
    end

    KK_CreateBtnText(qcBtn, "英", 0, 1, 0)
    qcBtn:ClearAllPoints()
    qcBtn:SetPoint("LEFT", prevBtn, "RIGHT", 2, 0)
    qcBtn:Show()
    tinsert(container.buttons, qcBtn)
    prevBtn = qcBtn

    -- Create remaining channel buttons (队/团/警/战/会/密/官/交)
    for i = 4, #KK_ChanButtons do
        local def = KK_ChanButtons[i]
        local btn = container["btn_"..i]
        if not btn then
            btn = CreateFrame("Button", nil, container)
            btn:SetSize(25, 24)
            btn:SetFrameStrata("MEDIUM")
            btn:SetAlpha(0.8)
            btn:RegisterForDrag("LeftButton")
            btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
            btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

            btn:SetScript("OnDragStart", function()
                if container.kkMovable then
                    container:StartMoving()
                end
            end)
            btn:SetScript("OnDragStop", function()
                if container.kkMovable then
                    container:StopMovingOrSizing()
                end
            end)

            btn:SetScript("OnClick", function(self, button)
                if self.kkIsChina then
                    if button == "RightButton" then
                        JoinChannelByName("china")
                    elseif button == "LeftButton" then
                        local found = false
                        for c = 1, 10 do
                            local num, name = GetChannelName(c)
                            if num ~= 0 and strfind(strlower(name or ""), "china") then
                                KK_SetChatType("CHANNEL"..c, c)
                                found = true
                                break
                            end
                        end
                        if not found then
                            print("|cffff0000未加入频道: china |cffcccccc(右键加入)|r")
                        end
                    end
                elseif self.kkChatType == "TRADE" then
                    if button == "RightButton" then
                        JoinChannelByName("交易")
                    elseif button == "LeftButton" then
                        local found = false
                        for c = 1, 10 do
                            local num, name = GetChannelName(c)
                            if num ~= 0 and name then
                                local lower = strlower(name)
                                if strfind(lower, "handel") or strfind(lower, "交易") then
                                    KK_SetChatType("CHANNEL"..c, c)
                                    found = true
                                    break
                                end
                            end
                        end
                        if not found then
                            print("|cffff0000未加入交易频道 |cffcccccc(右键加入)|r")
                        end
                    end
                elseif button == "LeftButton" then
                    if self.kkIndex and self.kkIndex > 0 then
                        local channelNum = GetChannelName(self.kkIndex)
                        if channelNum == 0 then return end
                    end
                    KK_SetChatType(self.kkChatType, self.kkIndex or 0)
                end
            end)

            container["btn_"..i] = btn
        end

        btn.kkChatType = def.chatType
        btn.kkIndex = def.index or 0
        btn.kkIsChina = def.isChina or false

        local r, g, b
        if def.isChina then
            r, g, b = 1, 0.84, 0
        else
            r, g, b = KK_GetChanColor(def.chatType)
        end
        KK_CreateBtnText(btn, def.text, r, g, b)

        btn:ClearAllPoints()
        btn:SetPoint("LEFT", prevBtn, "RIGHT", 2, 0)

        if def.show() then
            btn:Show()
            prevBtn = btn
        else
            btn:Hide()
        end
        tinsert(container.buttons, btn)
    end

    -- Create dice roll button (🎲) — last
    local diceBtn = container.diceBtn
    if not diceBtn then
        diceBtn = CreateFrame("Button", nil, container)
        diceBtn:SetSize(20, 20)
        diceBtn:SetAlpha(0.8)
        diceBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
        diceBtn:RegisterForDrag("LeftButton")
        diceBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        diceBtn:SetScript("OnDragStart", function()
            if container.kkMovable then
                container:StartMoving()
            end
        end)
        diceBtn:SetScript("OnDragStop", function()
            if container.kkMovable then
                container:StopMovingOrSizing()
            end
        end)
        diceBtn:SetScript("OnClick", function()
            RandomRoll("1", "100")
        end)
        container.diceBtn = diceBtn
    end

    -- SetNormalTexture with Blizzard dice icon (same as KK_Chat)
    diceBtn:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
    diceBtn:ClearAllPoints()
    diceBtn:SetPoint("LEFT", prevBtn, "RIGHT", 2, 0)
    diceBtn:Show()
    tinsert(container.buttons, diceBtn)
    prevBtn = diceBtn

    -- Update container size
    local numVisible = 0
    for _, btn in ipairs(container.buttons) do
        if btn:IsShown() then
            numVisible = numVisible + 1
        end
    end
    local totalWidth = numVisible * 26 + 4 -- 26px per button (24 + 2 spacing) + margins
    container:SetWidth(math.max(totalWidth, 50))

    -- Position container above the chat frame (only on first creation)
    if not container._hasPosition then
        container:ClearAllPoints()
        container:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 15, 30)
        container._hasPosition = true
    end

    container:Show()
    ChatModsModule.chanBar = container

    -- Hook world click for quick chat menu
    KK_HookWorldClick()
end

-- Remove/destroy the channel button bar
local function KK_DestroyChanBar()
    if KK_QuickChatMenu then
        KK_QuickChatMenu:Hide()
        KK_QuickChatMenu = nil
    end
    if ChatModsModule.chanBar then
        ChatModsModule.chanBar:Hide()
        ChatModsModule.chanBar = nil
    end
end

-- ============================================================================
-- KK_CHAT FEATURES (Ported from KK_Chat by bkader)
-- Features: Timestamp, Emotion Icons, Tab Channel Switch, Chat Channel Window
-- ============================================================================

-- Emotion icon table (tags from KK_Chat locale)
local KK_IconTable = {
    -- Raid target icons
    {"{rt1}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1"},
    {"{rt2}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2"},
    {"{rt3}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3"},
    {"{rt4}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4"},
    {"{rt5}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5"},
    {"{rt6}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6"},
    {"{rt7}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7"},
    {"{rt8}", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8"},
    -- Emotion icons (Chinese text tags)
    {"{天使}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\angel"},
    {"{生气}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\angry"},
    {"{大笑}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\biglaugh"},
    {"{鼓掌}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\clap"},
    {"{酷}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\cool"},
    {"{哭}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\cry"},
    {"{可爱}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\cutie"},
    {"{鄙视}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\despise"},
    {"{美梦}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\dreamsmile"},
    {"{尴尬}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\embarrass"},
    {"{邪恶}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\evil"},
    {"{兴奋}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\excited"},
    {"{晕}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\faint"},
    {"{打架}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\fight"},
    {"{流感}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\flu"},
    {"{呆}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\freeze"},
    {"{皱眉}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\frown"},
    {"{致敬}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\greet"},
    {"{鬼脸}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\grimace"},
    {"{龇牙}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\growl"},
    {"{开心}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\happy"},
    {"{心}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\heart"},
    {"{恐惧}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\horror"},
    {"{生病}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\ill"},
    {"{无辜}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\innocent"},
    {"{功夫}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\kongfu"},
    {"{花痴}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\love"},
    {"{邮件}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\mail"},
    {"{化妆}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\makeup"},
    {"{马里奥}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\mario"},
    {"{沉思}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\meditate"},
    {"{可怜}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\miserable"},
    {"{好}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\okay"},
    {"{漂亮}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\pretty"},
    {"{吐}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\puke"},
    {"{握手}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\shake"},
    {"{喊}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\shout"},
    {"{闭嘴}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\shuuuu"},
    {"{害羞}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\shy"},
    {"{睡觉}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\sleep"},
    {"{微笑}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\smile"},
    {"{吃惊}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\suprise"},
    {"{失败}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\surrender"},
    {"{流汗}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\sweat"},
    {"{流泪}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\tear"},
    {"{悲剧}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\tears"},
    {"{想}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\think"},
    {"{偷笑}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\titter"},
    {"{猥琐}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\ugly"},
    {"{胜利}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\victory"},
    {"{雷锋}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\volunteer"},
    {"{委屈}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\wronged"},
    {"{呲牙}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\growl"},
    {"{惊恐}", "Interface\\AddOns\\DragonUI\\Textures\\Chat\\horror"},
}

local KK_IconMap = {}
local KK_ReverseIconMap = {}
for _, v in ipairs(KK_IconTable) do
    KK_IconMap[v[1]] = v[2]
    KK_ReverseIconMap[v[2]] = v[1]
end

-- English tag map (Chinese tag -> English tag, e.g. {微笑} -> {smile}).
-- Built from the texture file name so players without the addon (or on an
-- English client) can read the emotion as plain text. Raid-target tags
-- ({rt1}..{rt8}) are already ASCII and are skipped.
local KK_EnglishMap = {}
for _, v in ipairs(KK_IconTable) do
    local cn = v[1]
    local tex = v[2]
    if cn and not cn:find("[%w]") then
        local name = tex:match("([^\\]+)$")
        if name then
            KK_EnglishMap[cn] = "{" .. name .. "}"
        end
    end
end
-- Render English tags as icons too (own sends after translation, and
-- English-tag messages received from other clients).
for cn, en in pairs(KK_EnglishMap) do
    if not KK_IconMap[en] then
        KK_IconMap[en] = KK_IconMap[cn]
    end
end
-- Expose for KK_IconButton_OnClick (defined earlier in the file, so it cannot
-- see this local directly — Lua lexical scoping).
ChatModsModule.englishMap = KK_EnglishMap

-- ============================================================================
-- ENGLISH EMOTION TAGS (optional send-time translation)
-- When enableEnglishEmotion is on, Chinese tags like {微笑} are rewritten to
-- {smile} before the message is sent, so players without the addon (or on an
-- English client) can read them. The English tag still renders as an icon for
-- us (KK_IconMap includes English tags), and other DragonUI users render it
-- too — it only falls back to plain text for clients without the addon.
-- ============================================================================

local function TranslateEmotionsToEnglish(msg)
    if not msg or msg == "" then return msg end
    local cfg = GetModuleConfig()
    if not (cfg and cfg.enableEnglishEmotion) then return msg end
    local newmsg = msg
    for cn, en in pairs(KK_EnglishMap) do
        newmsg = newmsg:gsub(cn, en)
    end
    return newmsg
end

local function InstallSendTranslateHook()
    if ChatModsModule.hooks.sendTranslate then return end

    -- TAINT FIX (was: replaced the global ChatEdit_SendText):
    -- ChatEdit_SendText is on the macro-execution path too. The client runs
    -- bound-key macros by firing EXECUTE_CHAT_LINE into a private
    -- MacroEditBox, which calls ChatEdit_SendText -> ChatEdit_ParseText ->
    -- SecureCmdList[...]. Replacing that global with an addon function puts
    -- DragonUI code on the protected call chain, so a macro containing
    -- /startattack fails with ADDON_ACTION_FORBIDDEN:
    --   "插件'DragonUI'污染了安全函数'StartAttack()'的调用"
    -- (2.0 only hooked ChatEdit_SendText via hooksecurefunc, which is safe.)
    --
    -- Translate instead via a secure hook on each chat editbox's SetText
    -- (i.e. as the text is being typed). The private MacroEditBox used for
    -- macro execution is not a chat-frame editbox, so macros are never
    -- touched and the protected macro path stays clean.
    for i = 1, CHAT_FRAME_LIMIT do
        local box = _G["ChatFrame" .. i .. "EditBox"]
        if box and not box._dragonUISendTranslateHooked then
            box._dragonUISendTranslateHooked = true
            hooksecurefunc(box, "SetText", function(editBox, text)
                if not ChatModsModule.applied then return end
                local cfg = GetModuleConfig()
                if not (cfg and cfg.enableEnglishEmotion) then return end
                if not text or text == "" then return end
                if editBox._dragonUITranslating then return end
                editBox._dragonUITranslating = true
                local ok, translated = pcall(TranslateEmotionsToEnglish, text)
                if ok and translated and translated ~= text then
                    editBox:SetText(translated)
                end
                editBox._dragonUITranslating = nil
            end)
        end
    end

    ChatModsModule.hooks.sendTranslate = true
end

local function UninstallSendTranslateHook()
    -- Secure hooks cannot be removed in 3.3.5a; the SetText hook checks
    -- ChatModsModule.applied and enableEnglishEmotion itself, so nothing has
    -- to be restored here. (Previously this restored the replaced
    -- ChatEdit_SendText global, which is no longer replaced.)
    if ChatModsModule.originalStates.ChatEdit_SendText then
        ChatModsModule.originalStates.ChatEdit_SendText = nil
    end
    ChatModsModule.hooks.sendTranslate = nil
end

-- Register event filters for KK_Chat features
local kkChatFiltersRegistered = false

local function KK_RegisterFilters()
    if kkChatFiltersRegistered then return end

    -- Timestamp filter
    local function TimestampFilter(self, event, msg, ...)
        if not ChatModsModule.applied then return end
        local cfg = GetModuleConfig()
        if not cfg.enableTimestamp then return end
        if not msg then return end

        local hour = tonumber(date("%H"))
        local minute = tonumber(date("%M"))
        local second = tonumber(date("%S"))

        local ts = format("|cff33CCFF[%02d:%02d", hour, minute)
        if cfg.timestampSeconds then
            ts = format("|cff33CCFF[%02d:%02d:%02d", hour, minute, second)
        end
        ts = ts.."]|r "

        return false, ts..msg, ...
    end

    -- Emotion icons filter (forward direction: text -> icon textures in chat display)
    local function EmotionIconFilter(self, event, msg, ...)
        if not ChatModsModule.applied then return end
        local cfg = GetModuleConfig()
        if not cfg.enableEmotionIcons then return end
        if not msg then return end

        local newmsg = msg
        for tag, texture in pairs(KK_IconMap) do
            local _, font = DEFAULT_CHAT_FRAME:GetFont()
            font = math.floor(font or 12)
            local resIndex = GetCurrentResolution()
            local resolution = select(resIndex or 1, GetScreenResolutions())
            if resolution then
                local w, h = strmatch(resolution, "(%d+)x(%d+)")
                if w and h then
                    local myfont = (font * 1.5) * h / 768
                    -- Match 2.0: halve and floor the size so the inline icon is a
                    -- sane integer. Fractional |T|t sizes fail to render in some
                    -- chat paths (e.g. raid), leaving the emotion tag as raw text.
                    myfont = math.max(1, math.floor(myfont * 0.5))
                    newmsg = newmsg:gsub(tag, "|T"..texture..":"..myfont.."|t", 1)
                end
            end
        end

        if newmsg ~= msg then
            return false, newmsg, ...
        end
    end

    -- Register all filters
    local chatEvents = {
        "CHAT_MSG_CHANNEL", "CHAT_MSG_YELL", "CHAT_MSG_GUILD",
        "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_SAY",
        "CHAT_MSG_WHISPER", "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_CONVERSATION",
        "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_AFK", "CHAT_MSG_DND",
        "CHAT_MSG_BATTLEGROUND", "CHAT_MSG_BATTLEGROUND_LEADER",
        "CHAT_MSG_RAID_WARNING",
    }

    for _, event in ipairs(chatEvents) do
        ChatFrame_AddMessageEventFilter(event, TimestampFilter)
        ChatFrame_AddMessageEventFilter(event, EmotionIconFilter)
    end

    kkChatFiltersRegistered = true
end

-- Tab key channel switching
-- In WoW 3.3.5a, Tab in the chat editbox is handled via the global
-- ChatEdit_CustomTabPressed function, NOT via OnKeyDown.
local KK_OrigCustomTabPressed = nil
local function KK_OnCustomTabPressed(...)
    -- Call original first (handles auto-complete)
    if KK_OrigCustomTabPressed then
        local result = KK_OrigCustomTabPressed(...)
        -- If original returned true, it handled Tab — don't switch
        if result then return true end
    end

    -- Cycle through chat types
    local self = ChatEdit_GetActiveWindow() or DEFAULT_CHAT_FRAME.editBox
    if not self then return end

    local chatType = self:GetAttribute("chatType")
    local channelTarget = self:GetAttribute("channelTarget")

    -- Check if currently on "china" channel
    local isChina = false
    if chatType == "CHANNEL" and channelTarget then
        local _, name = GetChannelName(channelTarget)
        if name and strfind(strlower(name), "china") then
            isChina = true
        end
    end

    -- Custom cycle: 说(SAY) → 队(PARTY) → 团(RAID) → 会(GUILD) → china → 喊(YELL)
    if isChina then
        -- china → 喊(YELL)
        self:SetAttribute("chatType", "YELL")
        self:SetAttribute("channelTarget", nil)
        self:SetAttribute("tellTarget", nil)
        ChatEdit_UpdateHeader(self)
        return true
    elseif chatType == "GUILD" then
        -- 会(GUILD) → china channel
        local found = false
        for c = 1, 15 do
            local num, name = GetChannelName(c)
            if num ~= 0 and name and strfind(strlower(name), "china") then
                self:SetAttribute("chatType", "CHANNEL")
                self:SetAttribute("channelTarget", num)
                self:SetAttribute("tellTarget", nil)
                ChatEdit_UpdateHeader(self)
                found = true
                return true
            end
        end
        if not found then
            -- China channel not joined, skip to YELL
            self:SetAttribute("chatType", "YELL")
            self:SetAttribute("channelTarget", nil)
            self:SetAttribute("tellTarget", nil)
            ChatEdit_UpdateHeader(self)
        end
        return true
    elseif chatType == "YELL" then
        -- 喊(YELL) → 说(SAY)
        self:SetAttribute("chatType", "SAY")
        self:SetAttribute("channelTarget", nil)
        self:SetAttribute("tellTarget", nil)
        ChatEdit_UpdateHeader(self)
        return true
    end

    -- Standard chat type cycle
    local types = {"SAY", "PARTY", "RAID"}
    for idx, t in ipairs(types) do
        if t == chatType then
            local nextType = types[idx + 1]
            if nextType then
                self:SetAttribute("chatType", nextType)
            else
                -- Last standard type (RAID) → GUILD
                self:SetAttribute("chatType", "GUILD")
            end
            self:SetAttribute("channelTarget", nil)
            self:SetAttribute("tellTarget", nil)
            ChatEdit_UpdateHeader(self)
            return true
        end
    end

    -- Default to SAY
    self:SetAttribute("chatType", "SAY")
    self:SetAttribute("channelTarget", nil)
    self:SetAttribute("tellTarget", nil)
    ChatEdit_UpdateHeader(self)
    return true
end

local function KK_SetupTabSwitch()
    local cfg = GetModuleConfig()
    if not cfg.enableTabSwitch then return end

    if not ChatModsModule.hooks.customTabPressed then
        KK_OrigCustomTabPressed = ChatEdit_CustomTabPressed
        ChatEdit_CustomTabPressed = KK_OnCustomTabPressed
        ChatModsModule.hooks.customTabPressed = true
    end
end

local function KK_RemoveTabSwitch()
    if ChatModsModule.hooks.customTabPressed then
        ChatEdit_CustomTabPressed = KK_OrigCustomTabPressed
        KK_OrigCustomTabPressed = nil
        ChatModsModule.hooks.customTabPressed = nil
    end
end

-- Emotion icon reverse parsing (editbox input: icon textures -> {tag})
local function KK_SetupEmotionIconParsing()
    local cfg = GetModuleConfig()
    if not cfg.enableEmotionIcons then return end

    for i = 1, NUM_CHAT_WINDOWS do
        local eb = _G["ChatFrame"..i.."EditBox"]
        if eb and not eb.KK_EmotionHooked then
            eb:HookScript("OnTextChanged", function(self)
                if not GetModuleConfig().enableEmotionIcons then return end
                local text = self:GetText()
                if not text then return end
                -- Check if text contains icon textures and reverse them
                -- Use KK_ReverseIconMap for efficient lookup
                for texPath, tag in pairs(KK_ReverseIconMap) do
                    -- Escape backslashes in path for Lua pattern matching (2.0 behavior)
                    local escapedPath = texPath:gsub("\\", "\\\\")
                    local pattern = "|T"..escapedPath..":%d+|t"
                    local newtext = text:gsub(pattern, tag, 1)
                    if newtext ~= text then
                        self:SetText(newtext)
                        return
                    end
                end
            end)
            eb.KK_EmotionHooked = true
        end
    end
end

-- Apply KK_Chat features
local function ApplyKKChatFeatures()
    local cfg = GetModuleConfig()

    -- Register message filters
    KK_RegisterFilters()

    -- Setup tab switch
    if cfg.enableTabSwitch then
        KK_SetupTabSwitch()
    end

    -- Setup emotion icon parsing
    if cfg.enableEmotionIcons then
        KK_SetupEmotionIconParsing()
    end

    -- Build channel button bar
    if cfg.enableChanBar then
        KK_BuildChanBar()
    end

    -- Register events for channel bar rebuild
    if not ChatModsModule.hooks.kkChatEvents then
        local kkEventFrame = CreateFrame("Frame")
        kkEventFrame:RegisterEvent("PLAYER_GUILD_UPDATE")
        kkEventFrame:RegisterEvent("UPDATE_WORLD_STATES")

        kkEventFrame:SetScript("OnEvent", function(self, event, ...)
            if not ChatModsModule.applied then return end
            local cfg = GetModuleConfig()
            if cfg.enableChanBar then
                KK_DestroyChanBar()
                KK_BuildChanBar()
            end
        end)

        ChatModsModule.hooks.kkChatEvents = kkEventFrame
    end
end

-- Remove KK_Chat feature filters
local function RemoveKKChatFilters()
    -- Filters are registered once and cannot be removed via ChatFrame_RemoveMessageEventFilter
    -- (the filter API in Wrath doesn't support unregistering individual filter functions).
    -- All filter functions check config flags internally (cfg.enableTimestamp, etc.),
    -- so they will safely no-op when the module or individual features are disabled.
    -- We keep kkChatFiltersRegistered = true to prevent duplicate registration on re-enable.

    -- Restore original ChatEdit_CustomTabPressed (Tab key)
    KK_RemoveTabSwitch()

    -- Destroy channel button bar (this frame CAN be removed)
    KK_DestroyChanBar()
end

local URL_TLDs = {
    "[Cc][Oo][Mm]", "[Uu][Kk]", "[Nn][Ee][Tt]", "[Dd][Ee]", "[Ff][Rr]",
    "[Ee][Ss]", "[Bb][Ee]", "[Cc][Cc]", "[Uu][Ss]", "[Kk][Oo]", "[Cc][Hh]",
    "[Tt][Ww]", "[Cc][Nn]", "[Rr][Uu]", "[Gg][Rr]", "[Gg][Gg]", "[Ii][Tt]",
    "[Ee][Uu]", "[Tt][Vv]", "[Nn][Ll]", "[Hh][Uu]", "[Oo][Rr][Gg]"
}

local URL_TLD_PATTERNS = {}
for i = 1, #URL_TLDs do
    URL_TLD_PATTERNS[i] = "(%S-%." .. URL_TLDs[i] .. "/?%S*)"
end

local URL_IP_PATTERN = "(%d+%.%d+%.%d+%.%d+:?%d*/?%S*)"
local URL_HYPERLINK_TEMPLATE = "|cffffffff|Hurl:%1|h[%1]|h|r"

local function URLFilter(self, event, msg, ...)
    if not msg then return end
    if not find(msg, ".", 1, true) then
        return
    end

    for i = 1, #URL_TLD_PATTERNS do
        local newmsg, found = gsub(msg, URL_TLD_PATTERNS[i], URL_HYPERLINK_TEMPLATE)
        if found > 0 then
            return false, newmsg, ...
        end
    end
    -- IP address pattern
    local newmsg, found = gsub(msg, URL_IP_PATTERN, URL_HYPERLINK_TEMPLATE)
    if found > 0 then
        return false, newmsg, ...
    end
end

local function ApplyURLDetection()
    local chatEvents = {
        "CHAT_MSG_CHANNEL", "CHAT_MSG_YELL", "CHAT_MSG_GUILD",
        "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_SAY",
        "CHAT_MSG_WHISPER", "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_CONVERSATION",
    }
    for _, event in ipairs(chatEvents) do
        ChatFrame_AddMessageEventFilter(event, URLFilter)
    end

    local currentLink
    local origOnHyperlinkShow = _G.ChatFrame_OnHyperlinkShow

    -- Store original for restore
    if not ChatModsModule.originalStates.ChatFrame_OnHyperlinkShow then
        ChatModsModule.originalStates.ChatFrame_OnHyperlinkShow = origOnHyperlinkShow
    end

    _G.ChatFrame_OnHyperlinkShow = function(self, link, text, button)
        if not StaticPopupDialogs["DRAGONUI_URLCOPY_DIALOG"] then
            StaticPopupDialogs["DRAGONUI_URLCOPY_DIALOG"] = {
                text = "URL",
                button2 = CLOSE or "Close",
                hasEditBox = 1,
                hasWideEditBox = 1,
                showAlert = 1,
                OnShow = function(frame)
                    local editBox = _G[frame:GetName() .. "WideEditBox"]
                    editBox:SetText(currentLink)
                    currentLink = nil
                    editBox:SetFocus()
                    editBox:HighlightText(0)
                    local btn = _G[frame:GetName() .. "Button2"]
                    btn:ClearAllPoints()
                    btn:SetWidth(200)
                    btn:SetPoint("CENTER", editBox, "CENTER", 0, -30)
                    _G[frame:GetName() .. "AlertIcon"]:Hide()
                end,
                EditBoxOnEscapePressed = function(frame)
                    frame:GetParent():Hide()
                end,
                timeout = 0,
                whileDead = 1,
                hideOnEscape = 1
            }
        end

        if link and link:sub(1, 3) == "url" then
            currentLink = link:sub(5)
            StaticPopup_Show("DRAGONUI_URLCOPY_DIALOG")
            return
        end

        origOnHyperlinkShow(self, link, text, button)
    end
end

-- ============================================================================
-- CHAT COPY (double-click tab)
-- ============================================================================

local copyFrame

local function CreateCopyFrame()
    copyFrame = CreateFrame("Frame", "DragonUI_ChatCopyFrame", UIParent)
    copyFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 5, bottom = 3 }
    })
    copyFrame:SetBackdropColor(0, 0, 0, 1)
    copyFrame:SetWidth(500)
    copyFrame:SetHeight(400)
    copyFrame:SetPoint("CENTER", UIParent, "CENTER")
    copyFrame:Hide()
    copyFrame:SetFrameStrata("DIALOG")

    local label = copyFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", copyFrame, "TOPLEFT", 12, -8)
    label:SetText("使用Ctrl+C来复制文字")
    label:SetTextColor(1, 1, 1)

    local scrollArea = CreateFrame("ScrollFrame", "DragonUI_ChatCopyScroll", copyFrame, "UIPanelScrollFrameTemplate")
    scrollArea:SetPoint("TOPLEFT", copyFrame, "TOPLEFT", 8, -30)
    scrollArea:SetPoint("BOTTOMRIGHT", copyFrame, "BOTTOMRIGHT", -30, 8)

    local editBox = CreateFrame("EditBox", "DragonUI_ChatCopyBox", copyFrame)
    editBox:SetMultiLine(true)
    editBox:SetMaxLetters(99999)
    editBox:EnableMouse(true)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(ChatFontNormal)
    editBox:SetWidth(400)
    editBox:SetHeight(270)
    editBox:SetScript("OnEscapePressed", function(self)
        self:GetParent():GetParent():Hide()
        self:SetText("")
    end)
    scrollArea:SetScrollChild(editBox)

    local close = CreateFrame("Button", "DragonUI_ChatCopyClose", copyFrame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", copyFrame, "TOPRIGHT")
    tinsert(UISpecialFrames, "DragonUI_ChatCopyFrame")
end

-- When CleanerChat / Glass UI is active, the Blizzard ChatFrame is hidden
-- (alpha=0, disabled mouse) and messages live in Glass's SlidingMessageFrame
-- as MessageLine frames with their own FontStrings. Returns the joined text,
-- or nil if Glass isn't active/usable for this tab.
-- Wrapped in pcall by the caller: Glass's internal state shape isn't part of
-- its public API and could change, and we want to fall back to reading the
-- Blizzard ChatFrame instead of erroring out when that happens.
local function ReadGlassChatText(id)
    local Glass = _G.LibStub and _G.LibStub("AceAddon-3.0", true)
    if not Glass then return nil end
    Glass = Glass:GetAddon("Glass", true)
    if not Glass then return nil end

    local uiManager = Glass:GetModule("UIManager")
    if not (uiManager and uiManager.state and uiManager.state.frames[id]) then return nil end

    local smf = uiManager.state.frames[id]
    -- Combat Log (ChatFrame2) renders natively — skip Glass path
    if smf.state.isCombatLog then return nil end

    local lines = {}
    for _, message in ipairs(smf.state.messages or {}) do
        if message.text and message.text.GetText then
            local line = message.text:GetText()
            if line and line ~= "" then
                lines[#lines + 1] = tostring(line)
            end
        end
    end
    if #lines == 0 then return nil end
    return table_concat(lines, "\n", 1, #lines)
end

local function ChatCopyFunc(frame)
    local id = frame:GetID()
    local cf = _G[format("ChatFrame%d", id)]
    if not cf then return end

    local ok, glassText = pcall(ReadGlassChatText, id)
    if not ok then
        -- Surface the error (visible with Lua errors on / BugSack) instead of
        -- failing silently, while still falling back to the Blizzard reader below.
        geterrorhandler()(glassText)
    end
    local text = ok and glassText or nil

    -- Fallback: read from the Blizzard ChatFrame (original behavior).
    -- This handles: Glass not installed, combat log, error reading Glass's
    -- state, or any other case.
    if not text then
        local _, size = cf:GetFont()
        FCF_SetChatWindowFontSize(cf, cf, 0.01)

        local lines = {}
        local ct = 1
        local regionCount = select("#", cf:GetRegions())
        for i = regionCount, 1, -1 do
            local region = select(i, cf:GetRegions())
            if region:GetObjectType() == "FontString" then
                lines[ct] = tostring(region:GetText())
                ct = ct + 1
            end
        end

        text = table_concat(lines, "\n", 1, ct - 1)
        FCF_SetChatWindowFontSize(cf, cf, size)
    end

    DragonUI_ChatCopyFrame:Show()
    DragonUI_ChatCopyBox:SetText(text or "")
    DragonUI_ChatCopyBox:HighlightText(0)
end

local function ChatCopyHint(frame)
    GameTooltip:SetOwner(frame, "ANCHOR_TOP")
    if SHOW_NEWBIE_TIPS == "1" then
        GameTooltip:AddLine(CHAT_OPTIONS_LABEL, 1, 1, 1)
        GameTooltip:AddLine(NEWBIE_TOOLTIP_CHATOPTIONS, nil, nil, nil, 1)
    end
    GameTooltip:AddLine((SHOW_NEWBIE_TIPS == "1" and "\n" or "") .. (addon.L["Double-Click to Copy"] or "Double-Click to Copy"))
    GameTooltip:Show()
end

local function ApplyChatCopy()
    if not copyFrame then
        CreateCopyFrame()
    end

    local copyLabel = (addon.L and addon.L["Copy Text"]) or "Copy Text"

    if not ChatModsModule.hooks.chatTabMenuCopyText then
        hooksecurefunc("FCF_Tab_OnClick", function(tab, button)
            if not ChatModsModule.applied then return end
            if button ~= "RightButton" then return end
            if not tab or not tab.GetID or tab:GetID() ~= 1 then return end
            if not UIDropDownMenu_CreateInfo or not UIDropDownMenu_AddButton then return end

            local info = UIDropDownMenu_CreateInfo()
            info.text = copyLabel
            info.notCheckable = 1
            info.value = "DRAGONUI_COPY_TEXT"
            info.func = function()
                ChatCopyFunc(tab)
            end
            UIDropDownMenu_AddButton(info)
        end)
        ChatModsModule.hooks.chatTabMenuCopyText = true
    end

    for i = 1, CHAT_FRAME_LIMIT do
        local tab = _G[format("ChatFrame%dTab", i)]
        if tab then
            if not tab.DragonUIChatCopyDoubleClickHooked then
                tab:HookScript("OnDoubleClick", ChatCopyFunc)
                tab.DragonUIChatCopyDoubleClickHooked = true
            end
            if not tab.DragonUIChatCopyHintHooked then
                tab:HookScript("OnEnter", ChatCopyHint)
                tab.DragonUIChatCopyHintHooked = true
            end

            -- Keep hover wake-up robust even if other addons rewire tab scripts.
            AttachChatHoverRefreshHooks(tab)
        end
    end

    -- Create a copy button anchored to the top-right of each chat frame (KK_Chat style)
    for i = 1, CHAT_FRAME_LIMIT do
        local cf = _G[format("ChatFrame%d", i)]
        if cf and not cf.DragonUICopyBtn then
            local btn = CreateFrame("Button", format("DragonUICopyBtn%d", i), cf)
            btn:SetFrameStrata("BACKGROUND")
            btn:SetWidth(18)
            btn:SetHeight(18)
            btn:SetNormalTexture("Interface\\AddOns\\DragonUI\\Textures\\Chat\\prat-chatcopy2")
            btn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollEnd-Down")
            btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
            btn:SetPoint("TOPRIGHT", cf, "TOPRIGHT", -2, -2)
            btn:SetAlpha(0.3)
            btn:SetScript("OnClick", function()
                ChatCopyFunc(cf)
            end)
            btn:SetScript("OnEnter", function(self) self:SetAlpha(0.9) end)
            btn:SetScript("OnLeave", function(self) self:SetAlpha(0.3) end)

            cf.DragonUICopyBtn = btn
        end
    end
end

-- ============================================================================
-- STICKY CHANNELS
-- ============================================================================

local function ApplyStickyChannels()
    ChatTypeInfo.BN_WHISPER.sticky = 0
    ChatTypeInfo.EMOTE.sticky = 0
    ChatTypeInfo.OFFICER.sticky = 1
    ChatTypeInfo.RAID_WARNING.sticky = 0
    ChatTypeInfo.WHISPER.sticky = 1
    ChatTypeInfo.YELL.sticky = 0

    _G.CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
    _G.CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
end

-- ============================================================================
-- CLASS COLORED NAMES
-- ============================================================================

-- The chat types Blizzard's chat settings offer "class colors" for, plus the numbered channels.
local function SetClassColorNames(enabled)
    for _, entry in ipairs(CHAT_CONFIG_CHAT_LEFT or {}) do
        if not entry.noClassColor then
            ToggleChatColorNamesByClassGroup(enabled, entry.type)
        end
    end
    for i = 1, MAX_WOW_CHAT_CHANNELS or 10 do
        ToggleChatColorNamesByClassGroup(enabled, "CHANNEL" .. i)
    end
end

-- On: re-applied each login (the setting is per character). Off: Blizzard's own per-type choice stays.
local function ApplyClassColorNames()
    local config = GetModuleConfig()
    if config and config.classColorNames then
        SetClassColorNames(true)
    end
end

addon.SetChatClassColorNames = SetClassColorNames

-- ============================================================================
-- APPLY / RESTORE SYSTEM
-- ============================================================================

local function ApplyChatModsSystem()
    if ChatModsModule.applied then return end

    -- Expand available chat font sizes (default WoW only has a few)
    ChatModsModule.originalStates.CHAT_FONT_HEIGHTS = CHAT_FONT_HEIGHTS
    CHAT_FONT_HEIGHTS = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

    ApplyChatFrameTweaks()
    ApplyEditBoxPosition()
    ApplyChatStyle()
    ApplyEditboxStyle()
    ApplyLinkHover()

    ApplyURLDetection()
    ApplyChatCopy()
    ApplyStickyChannels()
    -- After the login chat settings have loaded, so they can't overwrite it.
    addon:After(1, ApplyClassColorNames)


    -- AFK/DND dedup filters
    if not ChatModsModule.hooks.afkDndFilter then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", FilterAfkDnd)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", FilterAfkDnd)
        ChatModsModule.hooks.afkDndFilter = true
    end

    -- Tell Target slash command
    SlashCmdList["DRAGONUI_TELLTARGET"] = TellTarget
    SLASH_DRAGONUI_TELLTARGET1 = "/tt"
    SLASH_DRAGONUI_TELLTARGET2 = "/wt"

    -- Mousewheel scroll hook
    if not ChatModsModule.hooks.mouseScroll then
        hooksecurefunc("FloatingChatFrame_OnMouseScroll", OnMouseScroll)
        ChatModsModule.hooks.mouseScroll = true
    end

    -- Editbox mouse toggle hooks
    if not ChatModsModule.hooks.chatOpen then
        hooksecurefunc("ChatFrame_OpenChat", OnChatFrameOpenChat)
        ChatModsModule.hooks.chatOpen = true
    end
    if not ChatModsModule.hooks.chatSend then
        hooksecurefunc("ChatEdit_SendText", OnChatEditSendText)
        ChatModsModule.hooks.chatSend = true
    end

    if not ChatModsModule.hooks.chatFadeWake then
        hooksecurefunc("FCF_FadeInChatFrame", OnChatHoverInteraction)
        hooksecurefunc("FCF_FadeOutChatFrame", OnChatHoverInteraction)
        ChatModsModule.hooks.chatFadeWake = true
    end

    -- Apply KK_Chat features (timestamp, class color, level, short names, emotion icons, tab switch)
    ApplyKKChatFeatures()

    -- Optional send-time Chinese -> English emotion tag translation
    InstallSendTranslateHook()

    ChatModsModule.applied = true
    StartChatButtonsHoverUpdater(true)
end

local function RestoreChatModsSystem()
    if not ChatModsModule.applied then return end

    StopChatButtonsHoverUpdater()
    if ChatModsModule.frames.linkHoverTooltipShown then
        HideUIPanel(GameTooltip)
    end
    ChatModsModule.frames.linkHoverTooltipShown = nil

    -- Remove filters on disable so re-enable does not stack duplicate handlers.
    if ChatModsModule.hooks.afkDndFilter and ChatFrame_RemoveMessageEventFilter then
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_AFK", FilterAfkDnd)
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_DND", FilterAfkDnd)
        ChatModsModule.hooks.afkDndFilter = nil
    end

    -- Remove KK_Chat filters
    RemoveKKChatFilters()

    -- Restore the send-time emotion translation hook
    UninstallSendTranslateHook()

    -- Restore chat frame and editbox backdrops
    for i = 1, CHAT_FRAME_LIMIT do
        local cf = _G["ChatFrame" .. i]
        if cf then
            if cf._dragonUIBgFrame then
                cf._dragonUIBgFrame:Hide()
            end
        end
        local eb = _G["ChatFrame" .. i .. "EditBox"]
        if eb then eb:SetBackdrop(nil) end
    end

    -- Restore original chat font heights
    if ChatModsModule.originalStates.CHAT_FONT_HEIGHTS then
        CHAT_FONT_HEIGHTS = ChatModsModule.originalStates.CHAT_FONT_HEIGHTS
        ChatModsModule.originalStates.CHAT_FONT_HEIGHTS = nil
    end

    -- Restore URL handler
    if ChatModsModule.originalStates.ChatFrame_OnHyperlinkShow then
        _G.ChatFrame_OnHyperlinkShow = ChatModsModule.originalStates.ChatFrame_OnHyperlinkShow
        ChatModsModule.originalStates.ChatFrame_OnHyperlinkShow = nil
    end

    -- Restore right-click chat tab menu initializer
    if ChatModsModule.originalStates.ChatFrame_Initialize then
        _G.ChatFrame_Initialize = ChatModsModule.originalStates.ChatFrame_Initialize
        ChatModsModule.originalStates.ChatFrame_Initialize = nil
    end

    -- Hide copy frame
    if copyFrame then
        copyFrame:Hide()
    end

    -- Hooks installed via hooksecurefunc can't be removed, but they'll be
    -- guarded by ChatModsModule.applied check if we wrap them.
    -- For a full disable, a /reload is recommended.

    ChatModsModule.applied = false
end

-- ============================================================================
-- PROFILE CHANGE HANDLER
-- ============================================================================

local function OnProfileChanged()
    if IsModuleEnabled() then
        if not ChatModsModule.applied then
            ApplyChatModsSystem()
        end
        ApplyEditBoxPosition()
        ApplyChatStyle()
        ApplyEditboxStyle()
        RefreshChatFadeState()
    else
        if addon:ShouldDeferModuleDisable("chatmods", ChatModsModule) then
            return
        end
        RestoreChatModsSystem()
    end
end

-- Public API for options panel
addon.ApplyChatStyle = function()
    if ChatModsModule.applied then
        ApplyChatStyle()
    end
end

addon.ApplyEditBoxPosition = function()
    if ChatModsModule.applied then
        ApplyEditBoxPosition()
        RefreshChatFadeState()
    end
end

addon.ApplyEditboxStyle = function()
    if ChatModsModule.applied then
        ApplyEditboxStyle()
    end
end

addon.RefreshChatFadeState = function()
    if ChatModsModule.applied then
        RefreshChatFadeState()
    end
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "DragonUI" then
        if not IsModuleEnabled() then return end

        -- Register profile callbacks
        addon:After(0.5, function()
            if addon.db and addon.db.RegisterCallback then
                addon.db.RegisterCallback(addon, "OnProfileChanged", OnProfileChanged)
                addon.db.RegisterCallback(addon, "OnProfileCopied", OnProfileChanged)
                addon.db.RegisterCallback(addon, "OnProfileReset", OnProfileChanged)
            end
        end)

    elseif event == "PLAYER_ENTERING_WORLD" then
        if not IsModuleEnabled() then return end
        ApplyChatModsSystem()
        -- Re-apply tab noMouseAlpha after a short delay so it isn't overwritten
        -- by Blizzard's FCFManager_UpdateChatFrameListAlpha which fires after PEW.
        addon:After(1, function()
            if not ChatModsModule.applied then return end
            RefreshChatFadeState()
        end)
    end
end)

-- Export for external use
addon.ApplyChatModsSystem = ApplyChatModsSystem
addon.RestoreChatModsSystem = RestoreChatModsSystem

-- Only our click handler knows url: links (SetItemRef doesn't), so print plain text without it.
function addon:ChatURL(url, label)
    if ChatModsModule.applied and ChatModsModule.originalStates.ChatFrame_OnHyperlinkShow then
        return format("|cffffffff|Hurl:%s|h[%s]|h|r", url, label or url)
    end
    return url
end
