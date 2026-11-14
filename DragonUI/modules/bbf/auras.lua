--[[
  DragonUI - Frame Enhancements: target/focus auras (modules/bbf/auras.lua)

  Basic BetterBlizzFrames aura tweaks:
  * Own-aura size multiplier and "only my debuffs on enemies" are applied by
    the aura layout in unitframes/target.lua (it reads modules.bbf.auras).
  * Purge highlight: enemy buffs with dispel type "Magic" get the stealable
    border. Class-agnostic: any CoA class with an offensive dispel benefits,
    not just mages (UnitBuff's isStealable is mage-only on 3.3.5a).
]]

local addon = select(2, ...)
local BBF = addon.BBF
if not BBF then return end

local MAX_TARGET_BUFFS = _G.MAX_TARGET_BUFFS or 32

local aurasCfg = nil

local function HighlightPurgeable(frame)
    if not aurasCfg or aurasCfg.purge_highlight == false then return end
    if not frame or not frame.unit or not frame.GetName then return end
    local frameName = frame:GetName()
    local key = (frameName == "FocusFrame" and "focus") or (frameName == "TargetFrame" and "target") or nil
    if not key or aurasCfg[key] == false then return end

    local unit = frame.unit
    if not UnitExists(unit) or not UnitCanAttack("player", unit) then return end

    local c = aurasCfg.purge_color or {}
    for i = 1, MAX_TARGET_BUFFS do
        local buff = _G[frameName .. "Buff" .. i]
        if not buff then break end
        local stealable = _G[frameName .. "Buff" .. i .. "Stealable"]
        if stealable and buff:IsShown() then
            local _, _, _, _, dispelType = UnitBuff(unit, i)
            if dispelType == "Magic" then
                local size = buff:GetWidth() + 6
                stealable:SetWidth(size)
                stealable:SetHeight(size)
                stealable:SetVertexColor(c.r or 0.37, c.g or 0.98, c.b or 1, 1)
                stealable:Show()
            else
                -- Slot may still carry our tint from a previous aura.
                stealable:SetVertexColor(1, 1, 1, 1)
            end
        end
    end
end

local hooked = false
local lastState = nil

BBF.RegisterFeature("auras", function(cfg)
    aurasCfg = cfg and cfg.auras and cfg.auras.enabled == true and cfg.auras or nil
    if aurasCfg and not hooked and type(_G.TargetFrame_UpdateAuras) == "function" then
        hooksecurefunc("TargetFrame_UpdateAuras", HighlightPurgeable)
        hooked = true
    end

    -- Re-run the Blizzard aura update so layout (target.lua) and highlight pick up changes.
    local state = aurasCfg and table.concat({
        tostring(aurasCfg.target), tostring(aurasCfg.focus), tostring(aurasCfg.own_scale),
        tostring(aurasCfg.only_mine), tostring(aurasCfg.purge_highlight),
    }, ",") or "off"
    if lastState ~= nil and lastState ~= state and addon.RefreshTargetFocusAuraLayout then
        addon.RefreshTargetFocusAuraLayout()
    end
    lastState = state
end)
