--[[
================================================================================
DragonUI Options Panel - Frame Enhancements Tab
================================================================================
Unit frame features ported from BetterBlizzFrames (modules/bbf in DragonUI).
All settings live in addon.db.profile.modules.bbf; every change calls
addon.RefreshBBF(), so nothing here needs a reload.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local LO = addon.LO
local C = addon.PanelControls
local Panel = addon.OptionsPanel

local ROOT = "modules.bbf."

-- ============================================================================
-- HELPERS
-- ============================================================================

local function Refresh()
    if addon.RefreshBBF then addon.RefreshBBF() end
end

local function Get(path)
    return C:GetDBValue(ROOT .. path)
end

local function MasterOff()
    return Get("enabled") == false
end

-- Disabled-state predicate for a section's sub-options.
local function SectionOff(section)
    return function()
        return MasterOff() or Get(section .. ".enabled") ~= true
    end
end

local function Rebuild()
    Panel:SelectTab("bbf")
end

-- Section on/off switch: rebuilds the tab so sub-options update their disabled state.
local function AddEnable(parent, section, label, desc)
    C:AddToggle(parent, {
        label = LO[label],
        desc = desc and LO[desc],
        dbPath = ROOT .. section .. ".enabled",
        callback = function() Refresh(); Rebuild() end,
        disabled = MasterOff,
    })
end

local function AddSub(parent, path, label, desc, disabled)
    C:AddToggle(parent, {
        label = LO[label],
        desc = desc and LO[desc],
        dbPath = ROOT .. path,
        callback = Refresh,
        disabled = disabled,
        indent = 16,
    })
end

local function AddNumber(parent, path, label, minV, maxV, step, disabled)
    C:AddSlider(parent, {
        label = LO[label],
        dbPath = ROOT .. path,
        min = minV, max = maxV, step = step,
        callback = Refresh,
        disabled = disabled,
    })
end

local function AddColor(parent, path, label, disabled, dr, dg, db)
    C:AddColorPicker(parent, {
        label = LO[label],
        getFunc = function()
            local c = Get(path)
            if type(c) == "table" then return c.r or dr, c.g or dg, c.b or db end
            return dr, dg, db
        end,
        setFunc = function(r, g, b)
            C:SetDBValue(ROOT .. path, { r = r, g = g, b = b })
        end,
        callback = Refresh,
        disabled = disabled,
        hasAlpha = false,
    })
end

-- ============================================================================
-- TAB BUILDER
-- ============================================================================

local function BuildBBFTab(scroll)
    C:AddLabel(scroll, "|cffFFD700" .. LO["Frame Enhancements"] .. "|r", { color = C.Theme.textGold })
    C:AddDescription(scroll, LO["Unit frame features ported from BetterBlizzFrames. Everything is class-agnostic, so all Ascension custom classes work. Features are off by default."])

    C:AddToggle(scroll, {
        label = LO["Enable Frame Enhancements"],
        desc = LO["Master switch for every feature on this page."],
        dbPath = ROOT .. "enabled",
        callback = function() Refresh(); Rebuild() end,
    })
    C:AddSpacer(scroll)

    -- ====================================================================
    -- CAST BARS
    -- ====================================================================
    local cast = C:AddSection(scroll, LO["Cast Bars"])

    AddEnable(cast, "party_castbar", "Party Cast Bars", "Show a cast bar under each party member frame.")
    local partyOff = SectionOff("party_castbar")
    AddSub(cast, "party_castbar.show_icon", "Show Spell Icon", nil, partyOff)
    AddSub(cast, "party_castbar.show_timer", "Show Cast Timer", nil, partyOff)
    AddNumber(cast, "party_castbar.width", "Width", 40, 250, 1, partyOff)
    AddNumber(cast, "party_castbar.height", "Height", 6, 24, 1, partyOff)
    AddNumber(cast, "party_castbar.x", "X Offset", -200, 200, 1, partyOff)
    AddNumber(cast, "party_castbar.y", "Y Offset", -100, 100, 1, partyOff)

    AddEnable(cast, "pet_castbar", "Pet Cast Bar", "Show a cast bar under the pet frame.")
    local petOff = SectionOff("pet_castbar")
    AddSub(cast, "pet_castbar.show_icon", "Show Spell Icon", nil, petOff)
    AddSub(cast, "pet_castbar.show_timer", "Show Cast Timer", nil, petOff)
    AddNumber(cast, "pet_castbar.width", "Width", 40, 250, 1, petOff)
    AddNumber(cast, "pet_castbar.height", "Height", 6, 24, 1, petOff)
    AddNumber(cast, "pet_castbar.x", "X Offset", -200, 200, 1, petOff)
    AddNumber(cast, "pet_castbar.y", "Y Offset", -100, 100, 1, petOff)

    C:AddButton(cast, {
        label = LO["Test Cast Bars (4 sec)"],
        desc = LO["Shows a fake cast on every enabled party/pet cast bar, even without a group, so you can position them."],
        callback = function()
            if addon.BBF and addon.BBF.TestCastbars then addon.BBF.TestCastbars() end
        end,
        disabled = function() return partyOff() and petOff() end,
    })

    C:AddSpacer(cast)
    AddEnable(cast, "cast_target", "Cast Target Name", "Show who the target/focus cast is aimed at, under its cast bar (class-colored).")
    local ctOff = SectionOff("cast_target")
    AddSub(cast, "cast_target.target", "Target Cast Bar", nil, ctOff)
    AddSub(cast, "cast_target.focus", "Focus Cast Bar", nil, ctOff)

    C:AddSpacer(cast)
    AddEnable(cast, "interrupt", "Interrupt Readiness", "Tint the target/focus cast bar by your interrupt's cooldown and show the interrupt icon beside it.")
    local intOff = SectionOff("interrupt")
    C:AddEditBox(cast, {
        label = LO["Interrupt Spells"],
        desc = LO["Comma-separated spell names or IDs, first known one is used. Leave empty to auto-detect common interrupts (Kick, Pummel, Counterspell, Wind Shear...). Press Enter to apply."],
        dbPath = ROOT .. "interrupt.spells",
        callback = function() Refresh(); Rebuild() end,
        disabled = intOff,
    })
    if not intOff() then
        local active = addon.BBF and addon.BBF.GetActiveInterrupt and addon.BBF.GetActiveInterrupt()
        C:AddDescription(cast, LO["Detected interrupt:"] .. " " .. (active and ("|cff00ff00" .. active .. "|r") or ("|cffff4444" .. LO["none"] .. "|r")))
    end
    AddSub(cast, "interrupt.show_icon", "Show Interrupt Icon", nil, intOff)
    AddColor(cast, "interrupt.cd_color", "Interrupt On Cooldown", intOff, 1, 0.25, 0.25)
    AddColor(cast, "interrupt.delayed_color", "Interrupt Ready Before Cast Ends", intOff, 1, 0.48, 0.96)

    C:AddSpacer(scroll)

    -- ====================================================================
    -- INDICATORS
    -- ====================================================================
    local ind = C:AddSection(scroll, LO["Indicators"])

    AddEnable(ind, "combat", "Combat Indicator", "Show a sword icon beside the portrait while the unit is in combat. Nothing is shown out of combat.")
    local combatOff = SectionOff("combat")
    AddSub(ind, "combat.player", "Player", nil, combatOff)
    AddSub(ind, "combat.target", "Target", nil, combatOff)
    AddSub(ind, "combat.focus", "Focus", nil, combatOff)
    AddNumber(ind, "combat.size", "Icon Size", 12, 48, 1, combatOff)
    AddNumber(ind, "combat.x", "X Offset", -100, 100, 1, combatOff)
    AddNumber(ind, "combat.y", "Y Offset", -100, 100, 1, combatOff)

    C:AddSpacer(ind)
    AddEnable(ind, "portrait_cc", "Portrait Crowd Control", "Show crowd control and immunity icons over portraits with a countdown.")
    local ccOff = SectionOff("portrait_cc")
    AddSub(ind, "portrait_cc.target", "Target", nil, ccOff)
    AddSub(ind, "portrait_cc.focus", "Focus", nil, ccOff)
    AddSub(ind, "portrait_cc.party", "Party", nil, ccOff)
    AddSub(ind, "portrait_cc.immunities", "Show Immunities", "Divine Shield, Ice Block, Cloak of Shadows, Hand of Protection...", ccOff)
    C:AddEditBox(ind, {
        label = LO["Extra Crowd Control Spell IDs"],
        desc = LO["Comma-separated spell IDs to treat as crowd control in addition to the built-in list (useful for custom class spells). Press Enter to apply."],
        dbPath = ROOT .. "portrait_cc.extra",
        callback = Refresh,
        disabled = ccOff,
    })

    C:AddSpacer(ind)
    AddEnable(ind, "stealth", "Stealth Indicator", "Glow around the player frame while you are stealthed.")
    AddColor(ind, "stealth.color", "Glow Color", SectionOff("stealth"), 0.35, 0.6, 1)

    C:AddSpacer(ind)
    AddEnable(ind, "quest", "Quest Indicator", "Show a '!' on the target/focus frame when the mob is an active quest objective.")
    local questOff = SectionOff("quest")
    AddSub(ind, "quest.target", "Target", nil, questOff)
    AddSub(ind, "quest.focus", "Focus", nil, questOff)

    C:AddSpacer(scroll)

    -- ====================================================================
    -- APPEARANCE
    -- ====================================================================
    local look = C:AddSection(scroll, LO["Names & Appearance"])

    AddSub(look, "names.class_color", "Class-Colored Names", "Color player, target, focus and party names by class.", MasterOff)
    AddSub(look, "names.remove_realm", "Remove Realm Names", "Drop the realm suffix from cross-realm player names.", MasterOff)
    AddSub(look, "names.name_bg_class_color", "Class-Colored Name Background", "Tint the target/focus name banner with the player's class color.", MasterOff)
    AddSub(look, "smooth.health", "Smooth Health Bars", "Animate health bar changes. Turn off if you ever see 'action blocked' messages.", MasterOff)
    AddSub(look, "smooth.power", "Smooth Power Bars", "Animate mana/rage/energy bar changes.", MasterOff)

    C:AddSpacer(look)
    C:AddLabel(look, LO["Hide Frame Elements"])
    AddSub(look, "hide.group_indicator", "Group Number", nil, MasterOff)
    AddSub(look, "hide.level", "Level Text", nil, MasterOff)
    AddSub(look, "hide.pvp_icon", "PvP Icons", nil, MasterOff)
    AddSub(look, "hide.hit_indicator", "Portrait Damage/Heal Text", nil, MasterOff)
    AddSub(look, "hide.leader_icon", "Leader / Loot Master Icons", nil, MasterOff)
    AddSub(look, "hide.rest_icon", "Resting Icon", nil, MasterOff)

    C:AddSpacer(scroll)

    -- ====================================================================
    -- AURAS
    -- ====================================================================
    local auras = C:AddSection(scroll, LO["Target & Focus Auras"])

    AddEnable(auras, "auras", "Enable Aura Tweaks", "Resize your own auras, filter debuffs and highlight dispellable buffs on target/focus.")
    local aurasOff = SectionOff("auras")
    AddSub(auras, "auras.target", "Target", nil, aurasOff)
    AddSub(auras, "auras.focus", "Focus", nil, aurasOff)
    AddNumber(auras, "auras.own_scale", "Own Aura Size", 0.5, 2.5, 0.05, aurasOff)
    AddSub(auras, "auras.only_mine", "Only My Debuffs on Enemies", "Hide debuffs cast by other players on hostile targets.", aurasOff)
    AddSub(auras, "auras.purge_highlight", "Highlight Dispellable Buffs", "Glow around Magic buffs on hostile targets (purge / dispel / spellsteal candidates).", aurasOff)
    AddColor(auras, "auras.purge_color", "Highlight Color", aurasOff, 0.37, 0.98, 1)
end

-- Register the tab (order 6.2 = right after Unit Frames)
Panel:RegisterTab("bbf", LO["Frame Enhancements"], BuildBBFTab, 6.2)
