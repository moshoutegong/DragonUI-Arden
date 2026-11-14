-- Copyright (c) 2026 NeticSoul. Licensed under the MIT License; see LICENSE.

--[[
================================================================================
DragonUI Options Panel - Quest Tracker Tab
================================================================================
Quest tracker position and behavior.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local LO = addon.LO
local C = addon.PanelControls
local Panel = addon.OptionsPanel

-- ============================================================================
-- QUEST TRACKER TAB BUILDER
-- ============================================================================

local function RefreshQT()
    if addon.RefreshQuestTracker then addon.RefreshQuestTracker() end
end

local function BuildQuesttrackerTab(scroll)
    local section = C:AddSection(scroll, LO["Quest Tracker Module"])

    C:AddDescription(section, LO["Position and display settings for the objective tracker."])

    C:AddToggle(section, {
        label = LO["Show Header Background"],
        desc = LO["Show/hide the decorative header background texture."],
        getFunc = function()
            return C:GetDBValue("questtracker.show_header") ~= false
        end,
        setFunc = function(val)
            C:SetDBValue("questtracker.show_header", val)
            RefreshQT()
        end,
    })

    C:AddSlider(section, {
        label = LO["Font Size"],
        desc = LO["Font size for quest tracker text"],
        dbPath = "questtracker.font_size",
        min = 8, max = 18, step = 1,
        width = 200,
        callback = RefreshQT,
    })

    C:AddToggle(section, {
        label = LO["Custom Height"],
        desc = LO["Limit the tracker to a fixed height. When off, it stops above the bags. Quests that don't fit are hidden until there is room."],
        getFunc = function()
            return C:GetDBValue("questtracker.custom_height") == true
        end,
        setFunc = function(val)
            C:SetDBValue("questtracker.custom_height", val)
        end,
        callback = function()
            RefreshQT()
            Panel:SelectTab("questtracker")
        end,
    })

    C:AddSlider(section, {
        label = LO["Height"],
        desc = LO["Maximum height of the quest tracker."],
        dbPath = "questtracker.height",
        min = 400, max = 1000, step = 10,
        width = 200,
        disabled = function()
            return C:GetDBValue("questtracker.custom_height") ~= true
        end,
        callback = RefreshQT,
    })

    C:AddHeading(section, LO["Visibility"])
    C:AddVisibilityFadeToggles(section, {
        dbPrefix = "questtracker",
        hoverDesc = LO["Fade the quest tracker until you hover over it."],
        combatDesc = LO["Fade the quest tracker until you enter combat."],
        hideInCombat = true,
        hideInCombatDesc = LO["Hide the quest tracker while in combat."],
        callback = function()
            if addon.QuestTrackerModule and addon.QuestTrackerModule.SyncHoverVisibility then
                addon.QuestTrackerModule:SyncHoverVisibility()
            end
        end,
    })

    -- ====================================================================
    -- AUTO QUEST (ported from 2.0)
    -- ====================================================================
    C:AddSpacer(scroll)
    local aqSection = C:AddSection(scroll, LO["Auto Quest"])

    C:AddDescription(aqSection, LO["Automatically complete quests when talking to NPCs. Use /aq for fine-grained control over auto-accept, daily, fate, and repeatable quests."])

    local function AQGet(field)
        return function()
            local m = addon.db.profile.modules
            return m and m.autoquest and m.autoquest[field] == true
        end
    end

    local function AQSet(field)
        return function(val)
            local m = C:EnsureModuleTable("autoquest")
            m[field] = val
            if val then
                m.enabled = true
            end
        end
    end

    C:AddToggle(aqSection, {
        label = LO["Auto-Complete Quests"],
        desc = LO["Automatically turn in completed quests and claim rewards when talking to quest NPCs. Also auto-completes quests from the progress window."],
        getFunc = AQGet("autoComplete"),
        setFunc = AQSet("autoComplete"),
    })

    C:AddToggle(aqSection, {
        label = LO["Auto-Accept All Quests"],
        desc = LO["Automatically accept all quests when talking to NPCs."],
        getFunc = AQGet("autoAccept"),
        setFunc = AQSet("autoAccept"),
    })

    C:AddToggle(aqSection, {
        label = LO["Auto-Accept Daily Quests"],
        desc = LO["Automatically accept daily quests when talking to NPCs."],
        getFunc = AQGet("autoDaily"),
        setFunc = AQSet("autoDaily"),
    })

    C:AddToggle(aqSection, {
        label = LO["Auto-Accept Repeatable Quests"],
        desc = LO["Automatically accept repeatable quests when talking to NPCs."],
        getFunc = AQGet("autoRepeat"),
        setFunc = AQSet("autoRepeat"),
    })

    C:AddToggle(aqSection, {
        label = LO["Auto-Accept Fate Quests"],
        desc = LO["Automatically accept fate quests when talking to NPCs."],
        getFunc = AQGet("autoFate"),
        setFunc = AQSet("autoFate"),
    })

    C:AddToggle(aqSection, {
        label = LO["Auto-Accept High-Risk Quests"],
        desc = LO["Automatically accept high-risk quests when talking to NPCs."],
        getFunc = AQGet("autoHR"),
        setFunc = AQSet("autoHR"),
    })
end

-- Register the tab
Panel:RegisterTab("questtracker", LO["Quest Tracker"], BuildQuesttrackerTab, 10)
