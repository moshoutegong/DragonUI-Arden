-- Copyright (c) 2026 NeticSoul. Licensed under the MIT License; see LICENSE.

local addon = select(2, ...)
local _G, pairs, select = _G, pairs, select
local class = addon._class

-- ============================================================================
-- STANCE MODULE FOR DRAGONUI
-- ============================================================================

-- Module state tracking
local StanceModule = {
    initialized = false,
    applied = false,
    originalStates = {},     -- Store original states for restoration
    registeredEvents = {},   -- Track registered events
    hooks = {},             -- Track hooked functions
    stateDrivers = {},      -- Track state drivers
    frames = {}             -- Track created frames
}

-- Register with ModuleRegistry (if available)
if addon.RegisterModule then
    addon:RegisterModule("stance", StanceModule,
        addon.L["Stance Bar"],
        addon.L["Stance/shapeshift bar positioning and styling"])
end

-- ============================================================================
-- CONFIGURATION FUNCTIONS
-- ============================================================================

local function IsModuleEnabled()
    return addon:IsModuleEnabled("stance")
end

-- Nil-safe accessor for stance-specific config (addon.db.profile.additional.stance)
-- IMPORTANT: Keep in sync with database.lua → additional.stance
local STANCE_DEFAULTS = {
    x_position = -211,
    y_offset = -55,
    button_size = 31,
    button_spacing = 6,
}
local function GetStanceConfig()
    if addon.db and addon.db.profile and addon.db.profile.additional and addon.db.profile.additional.stance then
        return addon.db.profile.additional.stance
    end
    return STANCE_DEFAULTS
end

-- ============================================================================
-- CONSTANTS AND VARIABLES
-- ============================================================================

local InCombatLockdown, UnitAffectingCombat = InCombatLockdown, UnitAffectingCombat
local GetNumShapeshiftForms, GetShapeshiftFormInfo = GetNumShapeshiftForms, GetShapeshiftFormInfo
local GetShapeshiftFormCooldown = GetShapeshiftFormCooldown
local CreateFrame, UIParent, hooksecurefunc = CreateFrame, UIParent, hooksecurefunc

-- Shadows the global on purpose: the bar always lays out ten slots.
local NUM_SHAPESHIFT_SLOTS = 10

-- CoA: the class gate is gone on purpose. CLASSES_WITH_FORM_BAR only knows the seven
-- vanilla form classes, so on a 21-class server (PROPHET, RANGER, REAPER, SPIRITMAGE,
-- HERO, SONOFARUGAL, BARBARIAN, TINKER, CULTIST) it evaluated to 'hide' and the stance
-- bar never appeared at all. Availability is decided per slot at runtime instead, by
-- GetShapeshiftFormInfo in SyncFormVisibility and by the anchor gate in
-- stancebutton_position -- so the driver only has to honour the vehicle guard.
local STANCE_VISIBILITY = '[vehicleui] hide; show'
local HOLDER_EDGE = 37

-- Module frames (created only when enabled)
local anchor, stancebar

local STANCE_BASE_Y = 200

local function ResolveStancePosition()
    -- READ VALUES FROM DATABASE
    local stanceConfig = GetStanceConfig()
    local x_position = stanceConfig.x_position or -230  -- X position from center
    local y_offset = stanceConfig.y_offset or 0         -- Additional Y offset
    local base_y = STANCE_BASE_Y                        -- Base Y position from bottom
    local final_y = base_y + y_offset                   -- Final Y position
    
    -- XP/rep stack offset, only if stance bar is at its default position (not moved by user)
    -- IMPORTANT: Keep in sync with database.lua → additional.stance
    local defaultYOffset = -55   -- database default for additional.stance.y_offset
    local defaultXPosition = -211  -- database default for additional.stance.x_position
    -- The flag, not the numbers, marks an editor move: a 1px nudge rounds back inside the tolerance.
    local atDefault = not stanceConfig.manual_position
        and math.abs(x_position - defaultXPosition) <= 1
        and math.abs(y_offset - defaultYOffset) <= 1
    if atDefault and addon.GetDualBarVerticalOffset then
        final_y = final_y + addon.GetDualBarVerticalOffset()
    end
    if atDefault and addon.GetFramedStackDrop then
        final_y = final_y - addon.GetFramedStackDrop()
    end
    if atDefault and addon.GetBottomRowDrop then
        final_y = final_y - addon.GetBottomRowDrop()
    end
    return x_position, final_y, atDefault
end

local function updateStanceBar()
    if not IsModuleEnabled() or not anchor then return end
    if InCombatLockdown() then return end  -- Cannot modify secure frame in combat

    local x_position, final_y = ResolveStancePosition()
    anchor:ClearAllPoints()
    anchor:SetPoint('BOTTOM', UIParent, 'BOTTOM', x_position, final_y)
    if addon.UpdatePetbarPosition then
        addon.UpdatePetbarPosition()
    end
end

-- Left edge, bottom and button height of the bar while it sits at its default spot with forms to show.
function addon.GetDefaultStanceRow()
    if not IsModuleEnabled() or not anchor then return end
    if (GetNumShapeshiftForms() or 0) < 1 then return end
    local x_position, final_y, atDefault = ResolveStancePosition()
    if not atDefault then return end
    return x_position - HOLDER_EDGE / 2, final_y, GetStanceConfig().button_size or 31
end

-- The y_offset that reproduces where the bar is drawn now, automatic shifts included, so editing never jumps.
local function GetDrawnYOffset()
    local _, final_y = ResolveStancePosition()
    return final_y - STANCE_BASE_Y
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Simple update function - no queues needed
local function UpdateStanceBar()
    if not IsModuleEnabled() then return end
    updateStanceBar()
end

-- Export for external modules (mainbars.lua calls this when dual-bar offset changes)
addon.UpdateStanceBarPosition = UpdateStanceBar

-- ============================================================================
-- POSITIONING FUNCTIONS
-- ============================================================================


-- ============================================================================
-- FRAME CREATION FUNCTIONS
-- ============================================================================

local function CreateStanceFrames()
    if StanceModule.frames.anchor or not IsModuleEnabled() then return end
    
    local holder = CreateFrame('Frame', 'DragonUI_StanceHolder', UIParent)
    holder:SetSize(HOLDER_EDGE, HOLDER_EDGE)
    local bar = CreateFrame('Frame', 'DragonUI_StanceBar', holder, 'SecureHandlerStateTemplate')
    anchor, stancebar = holder, bar
    StanceModule.frames.anchor, StanceModule.frames.stancebar = holder, bar
    bar:SetAllPoints(holder)
    
    -- Expose globally for compatibility
    _G.DragonUI_StanceBar = stancebar
    
    -- Create editor overlay using centralized CreateUIFrame (with nineslice support)
    -- Initial size is a placeholder; real size is set in showTest based on active forms
    local editorOverlay = addon.CreateUIFrame(100, 31, 'StanceOverlay')
    editorOverlay:SetFrameStrata('FULLSCREEN')
    editorOverlay:SetFrameLevel(100)
    editorOverlay:Hide()
    StanceModule.frames.editorOverlay = editorOverlay
    
    -- Variables to track drag movement (custom drag like multicast)
    local dragStartX, dragStartY = 0, 0
    local configStartX, configStartY = 0, 0
    local isDragging = false

    function editorOverlay:SyncManualOverlayDeltaToStanceConfig()
        if not anchor then
            return
        end

        if not (addon.db and addon.db.profile and addon.db.profile.additional and addon.db.profile.additional.stance) then
            return
        end

        local overlayX, overlayY = self:GetLeft(), self:GetBottom()
        local anchorX, anchorY = anchor:GetLeft(), anchor:GetBottom()
        if not overlayX or not overlayY or not anchorX or not anchorY then
            return
        end

        local deltaX = overlayX - anchorX
        local deltaY = overlayY - anchorY
        if math.abs(deltaX) < 0.5 and math.abs(deltaY) < 0.5 then
            return
        end

        local stanceCfg = addon.db.profile.additional.stance
        stanceCfg.x_position = math.floor((stanceCfg.x_position or -211) + deltaX + 0.5)
        stanceCfg.y_offset = math.floor(GetDrawnYOffset() + deltaY + 0.5)
        stanceCfg.manual_position = true

        updateStanceBar()

        -- Keep overlay glued to the real anchor after applying DB delta.
        self:ClearAllPoints()
        self:SetPoint('BOTTOMLEFT', anchor, 'BOTTOMLEFT', 0, 0)
    end
    
    -- Make draggable with custom behavior (disable built-in movement)
    editorOverlay:SetMovable(false)
    editorOverlay:EnableMouse(true)
    editorOverlay:RegisterForDrag("LeftButton")
    
    editorOverlay:SetScript("OnDragStart", function(self)
        isDragging = true
        
        -- Show dragging state (orange/yellow, like other editor frames).
        if self.NineSlice and addon.SetNinesliceState then
            addon.SetNinesliceState(self, true)
        end
        if addon.ClearSelectionTint then
            addon.ClearSelectionTint(self)
        end
        
        -- Store mouse position when drag starts
        local scale = self:GetEffectiveScale()
        dragStartX = GetCursorPosition() / scale
        dragStartY = select(2, GetCursorPosition()) / scale
        
        -- Store current config values
        if addon.db and addon.db.profile and addon.db.profile.additional and addon.db.profile.additional.stance then
            configStartX = addon.db.profile.additional.stance.x_position or -230
            configStartY = GetDrawnYOffset()
        end
    end)
    
    -- Real-time update during drag
    editorOverlay:SetScript("OnUpdate", function(self, elapsed)
        if not isDragging then
            -- Pixel-perfect editor controls move the overlay directly.
            -- Convert that overlay movement into stance DB coordinates.
            if self.DragonUI_WasAdjustedByEditor or self.DragonUI_WasDragged then
                self:SyncManualOverlayDeltaToStanceConfig()
                self.DragonUI_WasAdjustedByEditor = nil
                self.DragonUI_WasDragged = nil
            end
            return
        end
        
        -- Calculate current delta from mouse movement
        local scale = self:GetEffectiveScale()
        local currentX = GetCursorPosition() / scale
        local currentY = select(2, GetCursorPosition()) / scale
        
        local deltaX = currentX - dragStartX
        local deltaY = currentY - dragStartY
        -- A click without a move must not store the drawn spot, or the bar stops following the bars below.
        if math.abs(deltaX) < 1 and math.abs(deltaY) < 1 then
            return
        end
        
        -- Update config values in real-time
        if addon.db and addon.db.profile and addon.db.profile.additional and addon.db.profile.additional.stance then
            addon.db.profile.additional.stance.x_position = math.floor(configStartX + deltaX + 0.5)
            addon.db.profile.additional.stance.y_offset = math.floor(configStartY + deltaY + 0.5)
            addon.db.profile.additional.stance.manual_position = true
            
            -- Update anchor position in real-time (move the actual stance bar)
            updateStanceBar()
            
            -- Keep overlay aligned to BOTTOMLEFT of anchor (buttons start there)
            self:ClearAllPoints()
            self:SetPoint('BOTTOMLEFT', anchor, 'BOTTOMLEFT', 0, 0)
        end
    end)
    
    editorOverlay:SetScript("OnDragStop", function(self)
        isDragging = false
        
        -- Return to selected highlight state.
        if self.NineSlice and addon.SetNinesliceState then
            addon.SetNinesliceState(self, false)
        end
        if addon.ApplySelectionTint then
            addon.ApplySelectionTint(self)
        end
        -- Overlay is already in correct position from OnUpdate
    end)
    
    -- Apply static positioning immediately
    updateStanceBar()
    
    
end

-- ============================================================================
-- POSITIONING FUNCTIONS
-- ============================================================================

--



-- ============================================================================
-- STANCE BUTTON FUNCTIONS
-- ============================================================================

local STANCE_SPELLS
if (GAME_LOCALE or GetLocale()) == "zhCN" then
	STANCE_SPELLS = {
		"蝰蛇守护",
		"野性守护",
		"野兽守护",
		"豹群守护",
		"猎豹守护",
		"龙鹰守护",
		"雄鹰守护",
		"灵猴守护",
		"熊形态",
		"巨熊形态",
		"猎豹形态",
		"旅行形态",
		"水栖形态",
		"飞行形态",
		"迅捷飞行形态",
		"枭兽形态",
		"生命之树",
		"狂暴",
		"战斗姿态",
		"防御姿态",
		"狂暴姿态",
		"潜行",
		"暗影形态",
		"隐形术",
		"吸血鬼之触",
		"虔诚光环",
		"惩戒光环",
		"专注光环",
		"暗影抗性光环",
		"冰霜抗性光环",
		"火焰抗性光环",
		"十字军光环",
		"正义之怒",
		"冰霜灵气",
		"邪恶灵气",
		"鲜血灵气",
		"恶魔变身",
		"恶魔形态",
		"暗影之怒",
		"灵魂链接",
		"统御",
		"灵界潜行",
		"灵魔潜行",
		"恶魔之力",
		"暗夜守望",
		"暮光领域",
		"月神权威",
		"守望者守护",
		"群星守护",
		"宇宙守护",
		"女猎手的守护",
		"无敌太阳",
		"山之心",
		"甲虫形态",
		"蜘蛛形态",
		"毒翼形态",
		"塔阵形态",
		"战线形态",
		"痛苦气场",
		"诅咒形态",
		"鹰之祝福",
		"狮之祝福",
		"乌之祝福",
		"熊之祝福",
		"狼之祝福",
		"散兵箭袋",
		"毒药箭袋",
		"灼热箭袋",
		"多重箭袋",
		"迅捷箭袋",
		"血咒",
		"洛阿仪式",
		"恩典誓约",
		"光辉誓约",
		"光明誓约",
		"黎明誓约",
		"日蚀誓约",
		"治疗守卫",
		"净化神像",
		"灵魂神像",
		"宁静神像",
		"黑暗神像",
		"模仿守卫",
		"丛林神像",
		"停滞守卫",
		"哨兵守卫",
		"妖术雕像",
		"暗影雕像",
		"毒蛇守卫",
		"雕刻雕像",
		"圣洁形态",
		"瓦格里誓言",
		"月井守护",
	}
else
	STANCE_SPELLS = {
		"Aspect of the Viper",
		"Aspect of the Wild",
		"Aspect of the Beast",
		"Aspect of the Pack",
		"Aspect of the Cheetah",
		"Aspect of the Dragonhawk",
		"Aspect of the Hawk",
		"Aspect of the Monkey",
		"Bear Form",
		"Dire Bear Form",
		"Cat Form",
		"Travel Form",
		"Aquatic Form",
		"Flight Form",
		"Swift Flight Form",
		"Moonkin Form",
		"Tree of Life",
		"Berserking",
		"Battle Stance",
		"Defensive Stance",
		"Berserker Stance",
		"Stealth",
		"Shadowform",
		"Invisibility",
		"Vampiric Touch",
		"Devotion Aura",
		"Retribution Aura",
		"Concentration Aura",
		"Shadow Resistance Aura",
		"Frost Resistance Aura",
		"Fire Resistance Aura",
		"Crusader Aura",
		"Righteous Fury",
		"Frost Presence",
		"Unholy Presence",
		"Blood Presence",
		"Metamorphosis",
		"Demon Form",
		"Shadow Wrath",
		"Soul Link",
		"Dominion",
		"Underwalk",
		"Underwawk",
		"Demonic Power",
		"Divine Stand",
		"Nights Watch",
		"Twilight Domain",
		"Lunar Authority",
		"Sol Invictus",
		"Heart of the Mountain",
		"Beetle Form",
		"Spider Form",
		"Venomwing Form",
		"Tower Formation",
		"Line Formation",
		"Agonizing Presence",
		"Eternal Curse",
		"Boon of the Hawk",
		"Boon of the Lion",
		"Boon of the Turtle",
		"Boon of the Bear",
		"Boon of the Wolf",
		"Skirmisher's Quiver",
		"Poison Quiver",
		"Searing Quiver",
		"Light Quiver",
		"Rite of the Loa",
		"Vow of Grace",
		"Vow of Radiance",
		"Vow of Light",
		"Vow of Dawn",
		"Vow of Eclipse",
		"Healing Ward",
		"Cleansing Idol",
		"Spirit Idol",
		"Serene Idol",
		"Dark Idol",
		"Mimic Ward",
		"Jungle Idol",
		"Stasis Ward",
		"Sentry Ward",
		"Hexing Effigy",
		"Shadow Effigy",
		"Serpent Ward",
		"Graven Effigy",
		"Holy Form",
		"Vow of the Valkyr",
		"Aspect of the Moonwell",
	}
end

local TOGGLE_SPELLS = {}
local _stanceLocale = GAME_LOCALE or GetLocale()
if _stanceLocale == "zhCN" then
	TOGGLE_SPELLS["正义之怒"] = true
elseif _stanceLocale == "zhTW" then
	TOGGLE_SPELLS["正義之怒"] = true
else
	TOGGLE_SPELLS["Righteous Fury"] = true
end

local customStanceButtons = {}
local knownCustomStances = {}

local function GetSpellBookId(spellName)
	local i = 1
	while true do
		local name = GetSpellName(i, BOOKTYPE_SPELL)
		if not name then break end
		if name == spellName then return i end
		i = i + 1
	end
	return nil
end

-- Collect spell names already owned by the native shapeshift slots.
local function ScanCustomStanceSpellbook()
	knownCustomStances = {}
	local numForms = GetNumShapeshiftForms() or 0
	local nativeNames = {}
	for i = 1, numForms do
		local _, name = GetShapeshiftFormInfo(i)
		if name then
			nativeNames[name] = true
		end
	end
	for _, spellName in ipairs(STANCE_SPELLS) do
		if not nativeNames[spellName] and GetSpellBookId(spellName) then
			tinsert(knownCustomStances, spellName)
		end
	end
end

-- Icon via spellbook slot query (returns name, rank, icon) — avoids the
-- string-form GetSpellInfo(name) return-order ambiguity on 3.3.5a.
local function GetCustomStanceIcon(spellName)
	local slot = GetSpellBookId(spellName)
	if slot then
		local _, _, icon = GetSpellInfo(slot, BOOKTYPE_SPELL)
		if icon then return icon end
	end
	return select(1, GetSpellInfo(spellName))
end

local function IsStanceActive(spellName)
	if not spellName then return false end
	local i = 1
	local buffName = UnitBuff("player", i)
	while buffName do
		if buffName == spellName then return true end
		i = i + 1
		buffName = UnitBuff("player", i)
	end
	return false
end

local function UpdateCustomStanceState()
	pcall(function()
		local inCombat = InCombatLockdown()
		for i, btn in ipairs(customStanceButtons) do
			if btn:IsShown() then
				local spellName = btn:GetAttribute("spell")
				local active = IsStanceActive(spellName)

				-- Always safe to update the visual state (SetChecked is not protected)
				if active then
					btn:SetChecked(1)
				else
					btn:SetChecked(0)
				end

				-- Only update attributes outside combat
				if not inCombat and spellName and TOGGLE_SPELLS[spellName] then
					if active then
						pcall(function() btn:SetAttribute("type1", "macro") end)
						pcall(function() btn:SetAttribute("macrotext", "/cancelaura " .. spellName) end)
					else
						pcall(function() btn:SetAttribute("type1", "spell") end)
						pcall(function() btn:SetAttribute("macrotext", nil) end)
					end
				end

				if btn.cooldown and spellName then
					local start, duration, enable = GetSpellCooldown(spellName)
					if start and duration then
						CooldownFrame_SetTimer(btn.cooldown, start, duration, enable)
					end
				end
			end
		end

		-- Attribute switches were skipped in combat; catch up after combat ends
		if inCombat and not StanceModule.pendingCustomUpdate then
			StanceModule.pendingCustomUpdate = true
			local frame = CreateFrame("Frame")
			frame:RegisterEvent("PLAYER_REGEN_ENABLED")
			frame:SetScript("OnEvent", function()
				frame:UnregisterAllEvents()
				StanceModule.pendingCustomUpdate = false
				UpdateCustomStanceState()
			end)
		end
	end)
end

local function CreateCustomStanceButtons()
	if not IsModuleEnabled() or not anchor or not stancebar then return end
	if InCombatLockdown() then
		if not StanceModule.pendingCustomCreate then
			StanceModule.pendingCustomCreate = true
			addon.CombatQueue:Add("stance_custom_buttons_create", function()
				StanceModule.pendingCustomCreate = false
				CreateCustomStanceButtons()
			end)
		end
		return
	end

	-- Recycle existing buttons (hide, detach)
	for _, btn in ipairs(customStanceButtons) do
		btn:Hide()
		btn:SetParent(UIParent)
	end
	customStanceButtons = {}

	ScanCustomStanceSpellbook()
	local numCustom = #knownCustomStances
	if numCustom < 1 then return end

	local stanceConfig = GetStanceConfig()
	local additionalConfig = (addon.db and addon.db.profile and addon.db.profile.additional) or {}
	local btnsize = stanceConfig.button_size or additionalConfig.size or 36
	local nativeSize = 36
	local scale = btnsize / nativeSize

	for i, spellName in ipairs(knownCustomStances) do
		local btnName = "DragonUIStanceButton" .. i
		local btn = _G[btnName]
		if not btn then
			btn = CreateFrame("CheckButton", btnName, stancebar, "SecureActionButtonTemplate, ActionButtonTemplate")
			btn:RegisterForClicks("AnyUp")
			btn.icon = _G[btnName .. "Icon"]
			btn.cooldown = _G[btnName .. "Cooldown"]
			btn.count = _G[btnName .. "Count"]
			if btn.count then btn.count:Hide() end

			-- DragonUI skin, matching native stance buttons (buttons.lua)
			if addon.additional_buttons then
				pcall(addon.additional_buttons, btn)
			end

			-- Tooltip via hook (SetScript on secure frames causes taint)
			if not btn._duiTooltipHooked then
				btn:HookScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					local spell = self:GetAttribute("spell")
					if spell then
						local bookId = GetSpellBookId(spell)
						if bookId then
							GameTooltip:SetSpell(bookId, BOOKTYPE_SPELL)
						else
							GameTooltip:SetText(spell)
						end
					end
					GameTooltip:Show()
				end)
				btn:HookScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				btn._duiTooltipHooked = true
			end
		end

		pcall(function() btn:SetAttribute("type1", "spell") end)
		pcall(function() btn:SetAttribute("spell", spellName) end)
		btn:SetParent(stancebar)
		btn:SetSize(nativeSize, nativeSize)
		btn:SetScale(scale)

		local icon = GetCustomStanceIcon(spellName)
		if btn.icon and icon then
			btn.icon:SetTexture(icon)
		end

		btn:Show()
		tinsert(customStanceButtons, btn)
	end

	-- Hotkey pass (custom names have no bindings; text ends up hidden)
	if addon.actionbuttons_hotkey then
		for _, btn in ipairs(customStanceButtons) do
			pcall(addon.actionbuttons_hotkey, btn)
		end
	end

	UpdateCustomStanceState()

	-- Fade/hover integration: keep custom buttons part of the stancebar hover set
	if addon.VisibilityFade and addon.VisibilityFade.AddHoverFrames then
		addon.VisibilityFade.AddHoverFrames("stancebar", customStanceButtons)
	end
end

-- Lay custom buttons out right after the last visible native button.
local function RepositionCustomStanceButtons()
	if not IsModuleEnabled() or not anchor or not stancebar then return end
	if InCombatLockdown() then return end

	local stanceConfig = GetStanceConfig()
	local additionalConfig = (addon.db and addon.db.profile and addon.db.profile.additional) or {}
	local btnsize = stanceConfig.button_size or additionalConfig.size or 36
	local space = stanceConfig.button_spacing or additionalConfig.spacing or 6
	local nativeSize = 36
	local scale = btnsize / nativeSize

	-- Find the last visible native button
	local lastNative
	for index = NUM_SHAPESHIFT_SLOTS, 1, -1 do
		local button = _G['ShapeshiftButton' .. index]
		if button and button:IsShown() then
			lastNative = button
			break
		end
	end

	for i, btn in ipairs(customStanceButtons) do
		btn:SetParent(stancebar)
		btn:SetSize(nativeSize, nativeSize)
		btn:SetScale(scale)
		btn:ClearAllPoints()
		if i == 1 then
			if lastNative then
				btn:SetPoint('LEFT', lastNative, 'RIGHT', space, 0)
			else
				btn:SetPoint('BOTTOMLEFT', anchor, 'BOTTOMLEFT', 0, 0)
			end
		else
			local prev = customStanceButtons[i - 1]
			if prev then
				btn:SetPoint('LEFT', prev, 'RIGHT', space, 0)
			end
		end
	end
end

local function DestroyCustomStanceButtons()
	for _, btn in ipairs(customStanceButtons) do
		btn:Hide()
		btn:SetParent(UIParent)
	end
	customStanceButtons = {}
	knownCustomStances = {}
end

local function FormSlot(index)
    return _G['ShapeshiftButton' .. index]
end

local function RestyleFormSlots()
    local restyle = addon.StyleStanceButtons
    if restyle then
        restyle()
    end
end

local function LayoutFormSlot(slotButton, index, edge, slotScale, gap)
    slotButton:SetSize(edge, edge)
    slotButton:SetScale(slotScale)
    slotButton:ClearAllPoints()
    if index > 1 then
        local previous = FormSlot(index - 1)
        if previous then
            slotButton:SetPoint('LEFT', previous, 'RIGHT', gap, 0)
        end
    else
        slotButton:SetPoint('BOTTOMLEFT', anchor, 'BOTTOMLEFT', 0, 0)
    end
end

local function SyncFormVisibility(slotButton, index)
    local _, formName = GetShapeshiftFormInfo(index)
    if formName then
        slotButton:Show()
    else
        slotButton:Hide()
    end
end

local refreshStanceButtons = function()
    if not (IsModuleEnabled() and anchor) or InCombatLockdown() then return end
    local lead = FormSlot(1)
    if lead then
        lead:ClearAllPoints()
        lead:SetPoint('BOTTOMLEFT', anchor, 'BOTTOMLEFT', 0, 0)
    end
end

local function positionStanceButtons()
    if not IsModuleEnabled() or not stancebar or not anchor then return end

    -- PLAYER_LOGIN also fires on a mid-combat /reload; reparenting secure buttons there is blocked.
    if InCombatLockdown() then
        addon.CombatQueue:Add("stance_position_buttons", positionStanceButtons)
        return
    end

    -- READ VALUES FROM DATABASE
    local stanceConfig = GetStanceConfig()
    local additionalConfig = (addon.db and addon.db.profile and addon.db.profile.additional) or {}
    local btnsize = stanceConfig.button_size or additionalConfig.size or 36
    local space = stanceConfig.button_spacing or additionalConfig.spacing or 6
    
    -- Use scale for uniform sizing of entire button (icon + border + all textures)
    local nativeSize = 36
    local scale = btnsize / nativeSize
    
    for index = 1, NUM_SHAPESHIFT_SLOTS do
        local slotButton = FormSlot(index)
        if slotButton then
            if slotButton:GetParent() ~= stancebar then
                slotButton:SetParent(stancebar)
            end
            LayoutFormSlot(slotButton, index, nativeSize, scale, space)
            SyncFormVisibility(slotButton, index)
        end
    end

    CreateCustomStanceButtons()
    RepositionCustomStanceButtons()

    local drivers = StanceModule.stateDrivers
    if not drivers.visibility then
        drivers.visibility = { frame = stancebar, state = 'visibility', condition = STANCE_VISIBILITY }
        RegisterStateDriver(stancebar, 'visibility', STANCE_VISIBILITY)
    end

    -- CoA: the anchor itself is gated on the class having forms at all, which is the
    -- part a class-name table cannot answer for custom classes. The user's toggle wins;
    -- otherwise show whenever the client reports at least one shapeshift form, so a
    -- CoA class with stances gets its bar without needing an entry in any table.
    if stanceConfig.show == false then
        anchor:Hide()
    elseif GetNumShapeshiftForms() == 0 and #customStanceButtons == 0 then
        anchor:Hide()
    else
        anchor:Show()
    end

	-- Hover/combat fade layered on top of the state driver above (alpha-only, never Show/Hide).
	if addon.VisibilityFade then
	    local hoverFrames = { stancebar }
        for _, button in ipairs(customStanceButtons) do
            table.insert(hoverFrames, button)
        end
	    for i = 1, NUM_SHAPESHIFT_SLOTS do
	        local btn = _G['ShapeshiftButton' .. i]
	        if btn then table.insert(hoverFrames, btn) end
	    end
	    addon.VisibilityFade.Register("stancebar", stancebar, {
	        dbTable = function() return addon.db and addon.db.profile and addon.db.profile.additional and addon.db.profile.additional.stance end,
	        hoverFrames = hoverFrames,
	        clickThrough = true,
	    })
	    addon.VisibilityFade.Update("stancebar")
	end
end

local CASTABLE_SHADE, BLOCKED_SHADE = 1, 0.4

-- Never touches ShapeshiftBarFrame fields: an insecure write there taints Blizzard's stance code.
local function RefreshFormSlotStates()
    if not IsModuleEnabled() then return end
    local formCount = math.min(NUM_SHAPESHIFT_SLOTS, GetNumShapeshiftForms())
    for index = 1, formCount do
        local slotButton = FormSlot(index)
        if slotButton then
            local slotName = slotButton:GetName()
            local face, swipe = _G[slotName .. 'Icon'], _G[slotName .. 'Cooldown']
            local texture, _, isActive, isCastable = GetShapeshiftFormInfo(index)
            face:SetTexture(texture)
            swipe:SetAlpha(texture and 1 or 0)
            CooldownFrame_SetTimer(swipe, GetShapeshiftFormCooldown(index))
            slotButton:SetChecked(isActive and 1 or 0)
            local shade = isCastable and CASTABLE_SHADE or BLOCKED_SHADE
            face:SetVertexColor(shade, shade, shade)
        end
    end
end

local function RebuildFormSlots()
    if not IsModuleEnabled() or InCombatLockdown() then return end
    RestyleFormSlots()
    positionStanceButtons()
    for index = 1, NUM_SHAPESHIFT_SLOTS do
        local slotButton = FormSlot(index)
        if slotButton then
            SyncFormVisibility(slotButton, index)
        end
    end
    RefreshFormSlotStates()
    -- Gaining or losing the first form decides whether the pet bar stacks above this bar.
    if addon.UpdatePetbarPosition then
        addon.UpdatePetbarPosition()
    end
end

-- Unlisted events only refresh slot states; the form-count events rebuild the whole bar.
local STANCE_EVENT_ACTIONS = {
    PLAYER_LOGIN = positionStanceButtons,
    UPDATE_SHAPESHIFT_FORMS = RebuildFormSlots,
    ACTIVE_TALENT_GROUP_CHANGED = RebuildFormSlots,
    CHARACTER_POINTS_CHANGED = RebuildFormSlots,
    SPELLS_CHANGED = RebuildFormSlots,
}

local function OnEvent(self, event)
    if not IsModuleEnabled() then return end
    local action = STANCE_EVENT_ACTIONS[event] or RefreshFormSlotStates
    action(self, event)
    UpdateCustomStanceState()
end

-- ============================================================================
-- INITIALIZATION FUNCTIONS
-- ============================================================================

-- Simple initialization function
local function InitializeStanceBar()
    if not IsModuleEnabled() then return end
    
    -- IMPORTANT: Apply button textures FIRST (from buttons.lua)
    if addon.StyleStanceButtons then
        addon.StyleStanceButtons()
    end
    
    -- Then position and scale
    positionStanceButtons()
    updateStanceBar()
    
    if stancebar then
        stancebar:Show()
    end
end

-- ============================================================================
-- APPLY/RESTORE FUNCTIONS
-- ============================================================================

local function ApplyStanceSystem()
    if StanceModule.applied or not IsModuleEnabled() then return end
    
    -- Create frames
    CreateStanceFrames()
    
    if not anchor or not stancebar then return end
    
    -- Register only essential events
    local events = {
        'PLAYER_LOGIN',
        'UPDATE_SHAPESHIFT_FORMS',
        'UPDATE_SHAPESHIFT_FORM',
        'UPDATE_SHAPESHIFT_USABLE',   -- Druid: fires when entering/leaving water, flyable zones, etc.
        'UPDATE_SHAPESHIFT_COOLDOWN', -- Cooldown changes
        'SPELLS_CHANGED',
        'SPELL_UPDATE_USABLE',        -- General spell usability changes (zone transitions)
        'ACTIONBAR_UPDATE_USABLE',    -- Action bar usability updates
        'CHARACTER_POINTS_CHANGED',   -- Talent point changes can add/remove forms.
        'ACTIVE_TALENT_GROUP_CHANGED',-- Dual spec swap can add/remove forms.
    }
    
    for _, eventName in ipairs(events) do
        stancebar:RegisterEvent(eventName)
        StanceModule.registeredEvents[eventName] = stancebar
    end
    stancebar:SetScript('OnEvent', OnEvent)
    
    -- Simple hook for Blizzard updates - REGISTER ONLY ONCE
    if not StanceModule.hooks.ShapeshiftBar_Update then
        StanceModule.hooks.ShapeshiftBar_Update = true
        hooksecurefunc('ShapeshiftBar_Update', function()
            if IsModuleEnabled() then
                refreshStanceButtons()
            end
        end)
    end
    
    -- Initial setup
    InitializeStanceBar()
    
    StanceModule.applied = true
    
    -- Register with editor mode system
    if addon.RegisterEditableFrame and StanceModule.frames.editorOverlay then
        local editorOverlay = StanceModule.frames.editorOverlay
        
        addon:RegisterEditableFrame({
            name = "stance",
            frame = editorOverlay,
            configPath = {"additional", "stance"},
            
            showTest = function()
                -- Only show overlay if the player actually has stance/shapeshift forms
                local numForms = GetNumShapeshiftForms() or 0
                if numForms < 1 or not anchor then return end
                
                -- Position overlay at anchor location, matching the visual button area
                local stanceConfig = GetStanceConfig()
                local btnSize = stanceConfig.button_size or 31
                local spacing = stanceConfig.button_spacing or 6
                -- Buttons use SetScale(btnSize/36) so visual size = btnSize
                local totalWidth = numForms * btnSize + (numForms - 1) * spacing
                totalWidth = math.max(totalWidth, btnSize)
                editorOverlay:SetSize(totalWidth, btnSize)
                
                -- Buttons start at BOTTOMLEFT of anchor, so align overlay there
                editorOverlay:ClearAllPoints()
                editorOverlay:SetPoint('BOTTOMLEFT', anchor, 'BOTTOMLEFT', 0, 0)
                editorOverlay:Show()
                
                -- Show nineslice overlay
                if addon.ShowNineslice then
                    addon.SetNinesliceState(editorOverlay, false)
                    addon.ShowNineslice(editorOverlay)
                end
                if editorOverlay.editorText then
                    editorOverlay.editorText:Show()
                end
            end,
            
            resetPosition = function()
                local stanceConfig = GetStanceConfig()
                if stanceConfig == STANCE_DEFAULTS then return end
                stanceConfig.x_position = STANCE_DEFAULTS.x_position
                stanceConfig.y_offset = STANCE_DEFAULTS.y_offset
                stanceConfig.manual_position = nil
                updateStanceBar()
            end,
            isDefaultPosition = function()
                return (select(3, ResolveStancePosition()))
            end,

            hideTest = function()
                -- Ensure manual editor adjustments are persisted before hiding.
                if editorOverlay and editorOverlay.SyncManualOverlayDeltaToStanceConfig then
                    editorOverlay:SyncManualOverlayDeltaToStanceConfig()
                end
                editorOverlay:Hide()
                -- Hide nineslice overlay
                if addon.HideNineslice then
                    addon.HideNineslice(editorOverlay)
                end
                if editorOverlay.editorText then
                    editorOverlay.editorText:Hide()
                end
            end,

            onHide = function()
                if editorOverlay and editorOverlay.SyncManualOverlayDeltaToStanceConfig then
                    editorOverlay:SyncManualOverlayDeltaToStanceConfig()
                end
                if editorOverlay then
                    editorOverlay.DragonUI_WasAdjustedByEditor = nil
                    editorOverlay.DragonUI_WasDragged = nil
                end
            end,
            
            module = StanceModule
        })
    end
    
end

local function RestoreStanceSystem()
    if not StanceModule.applied then return end
    
    DestroyCustomStanceButtons()

    -- Unregister all events
    for eventName, frame in pairs(StanceModule.registeredEvents) do
        if frame and frame.UnregisterEvent then
            frame:UnregisterEvent(eventName)
        end
    end
    StanceModule.registeredEvents = {}
    
    -- Unregister all state drivers
    for name, data in pairs(StanceModule.stateDrivers) do
        if data.frame then
            UnregisterStateDriver(data.frame, data.state)
        end
    end
    StanceModule.stateDrivers = {}
    
    -- Hide custom frames
    if anchor then anchor:Hide() end
    if stancebar then stancebar:Hide() end
    
    -- Reset stance button parents to default
    for index=1, NUM_SHAPESHIFT_SLOTS do
        local button = _G['ShapeshiftButton'..index]
        if button then
            button:SetParent(ShapeshiftBarFrame or UIParent)
            button:ClearAllPoints()
            -- Don't reset positions here - let Blizzard handle it
        end
    end
    
    -- Clear global reference
    _G.DragonUI_StanceBar = nil

    StanceModule.applied = false
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

-- Enhanced refresh function with module control
function addon.RefreshStanceSystem()
    if IsModuleEnabled() then
        ApplyStanceSystem()
        -- Call original refresh for settings
        if addon.RefreshStance then
            addon.RefreshStance()
        end
    else
        if addon:ShouldDeferModuleDisable("stance", StanceModule) then
            return
        end
        RestoreStanceSystem()
    end
end

-- Original refresh function for configuration changes
function addon.RefreshStance()
    if not IsModuleEnabled() then return end
    
	if InCombatLockdown() or UnitAffectingCombat('player') then 
		return 
	end
	
	-- Ensure frames exist
	if not anchor or not stancebar then
	    return
	end
	
	-- First apply button textures (from buttons.lua)
	if addon.StyleStanceButtons then
	    addon.StyleStanceButtons()
	end
	
	-- Update button size and spacing (scale-based - matching positionStanceButtons)
	local stanceConfig = GetStanceConfig()
	local additionalConfig = (addon.db and addon.db.profile and addon.db.profile.additional) or {}
	local btnsize = stanceConfig.button_size or additionalConfig.size or 36
	local space = stanceConfig.button_spacing or additionalConfig.spacing or 6
	
	-- Reposition stance buttons with scale for proper texture sizing
	-- Native Blizzard button size is 36x36
	local nativeSize = 36
	local scale = btnsize / nativeSize
	
	for index = 1, NUM_SHAPESHIFT_SLOTS do
		local slotButton = FormSlot(index)
		if slotButton then
			LayoutFormSlot(slotButton, index, nativeSize, scale, space)
		end
	end
	
	-- Update position
	updateStanceBar()

	if addon.VisibilityFade then
		addon.VisibilityFade.Update("stancebar")
	end
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

local function Initialize()
    if StanceModule.initialized then return end
    
    -- Only apply if module is enabled
    if IsModuleEnabled() then
        ApplyStanceSystem()
    end
    
    StanceModule.initialized = true
end

-- Auto-initialize when addon loads
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "DragonUI" then
        -- Just mark as loaded, don't initialize yet
        self.addonLoaded = true
    elseif event == "PLAYER_LOGIN" and self.addonLoaded then
        -- Initialize after both addon is loaded and player is logged in
        Initialize()
        self:UnregisterAllEvents()
    end
end)
-- End of stance module