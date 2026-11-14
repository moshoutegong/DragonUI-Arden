local addon = select(2, ...)

-- Auto-fill the delete confirmation text for good (bind-on-pickup) items
-- Hooks the DELETE_GOOD_ITEM dialog to automatically type the confirmation
-- string, saving the user from having to type "DELETE" manually.

-- Fallback confirmation string in case the global constant is not defined
local CONFIRM_STRING = DELETE_ITEM_CONFIRM_STRING or "DELETE"

local function ApplyDeleteConfirm()
    local dialog = StaticPopupDialogs["DELETE_GOOD_ITEM"]
    if not dialog then return end

    -- Hook the OnShow function to auto-fill the edit box
    hooksecurefunc(dialog, "OnShow", function(s)
        if s.editBox then
            s.editBox:SetText(CONFIRM_STRING)
        end
    end)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == "DragonUI" then
        if addon.db.profile.modules.deleteconfirm
        and addon.db.profile.modules.deleteconfirm.enabled then
            ApplyDeleteConfirm()
        end
    end
end)