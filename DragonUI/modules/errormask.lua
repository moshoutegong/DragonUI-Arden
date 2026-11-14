--[[
================================================================================
DragonUI Error Mask Module (ported from 2.0)
================================================================================
Suppresses red error spam from the middle of the screen (e.g. "You are too far
away!") and filters Blizzard addon-error notices out of the chat frame.
================================================================================
]]

local addon = select(2, ...)

if addon.RegisterModule then
    addon:RegisterModule("errormask", {},
        (addon.L and addon.L["Error Mask"]) or "Error Mask",
        (addon.L and addon.L["Suppress common spam errors from the middle of your screen"]) or "Suppress common spam errors from the middle of your screen")
end

local eventFrame = CreateFrame("Frame")

-- Suppress Blizzard addon-error notifications posted to the chat frame:
--   "插件导致界面行为失效"      -> ERR_ADDON_ACTION_FORBIDDEN
--   "用户界面错误：某个插件发生错误" -> Script error reminder
local SUPPRESSED_ADDON_ERRORS = {
    "插件导致界面行为失效",
    "用户界面错误",
    "某个插件发生错误",
    "an interface error occurred",
    "UI Error",
}

local function ShouldSuppress(msg)
    if type(msg) ~= "string" then return false end
    for i = 1, #SUPPRESSED_ADDON_ERRORS do
        if msg:find(SUPPRESSED_ADDON_ERRORS[i], 1, true) then
            return true
        end
    end
    return false
end

-- UI_ERROR_MESSAGE handler: swallow the red error spam (e.g. "You are too far
-- away!"). UIErrorsFrame has been unregistered from the event, so the message
-- is simply not re-displayed. (2.0 kept an unfinished per-message filter here;
-- the shipped behavior was to suppress all of them, which we keep.)
eventFrame:SetScript("OnEvent", function(self, event, error)
    -- intentionally empty: consume the event, do not forward to UIErrorsFrame
end)

-- Event-based chat filter (covers messages dispatched via CHAT_MSG_SYSTEM / SYSMSG)
local function FilterAddonErrorChatMessage(self, eventName, msg, ...)
    if ShouldSuppress(msg) then return true end
end

-- Direct AddMessage hook (covers messages written straight to the chat frame,
-- bypassing the event/filter pipeline — e.g. forwarding by other addons)
local hookedAddMessage = {}

local function HookChatFrame(cf)
    if not cf or not cf.AddMessage then return end
    if hookedAddMessage[cf] then return end -- already hooked
    hookedAddMessage[cf] = cf.AddMessage
    cf.AddMessage = function(self, msg, ...)
        if ShouldSuppress(msg) then return end
        return hookedAddMessage[cf](self, msg, ...)
    end
end

local function UnhookChatFrame(cf)
    if not cf or not hookedAddMessage[cf] then return end
    cf.AddMessage = hookedAddMessage[cf]
    hookedAddMessage[cf] = nil
end

function addon.ApplyErrorMask()
    UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
    eventFrame:RegisterEvent("UI_ERROR_MESSAGE")
    -- Filter addon error notices out of the chat frame via event pipeline
    for _, evt in ipairs({ "CHAT_MSG_SYSTEM", "SYSMSG" }) do
        ChatFrame_AddMessageEventFilter(evt, FilterAddonErrorChatMessage)
    end
    -- Hook each chat window's AddMessage to catch direct writes
    for i = 1, NUM_CHAT_WINDOWS do
        HookChatFrame(_G["ChatFrame" .. i])
    end
end

function addon.RestoreErrorMask()
    eventFrame:UnregisterEvent("UI_ERROR_MESSAGE")
    UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
    for _, evt in ipairs({ "CHAT_MSG_SYSTEM", "SYSMSG" }) do
        ChatFrame_RemoveMessageEventFilter(evt, FilterAddonErrorChatMessage)
    end
    for i = 1, NUM_CHAT_WINDOWS do
        UnhookChatFrame(_G["ChatFrame" .. i])
    end
end

-- Apply once the addon is fully loaded (db.profile.modules is initialized by then)
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, arg1)
    if arg1 ~= "DragonUI" then return end
    if addon:IsModuleEnabled("errormask") then
        addon.ApplyErrorMask()
    end
end)
