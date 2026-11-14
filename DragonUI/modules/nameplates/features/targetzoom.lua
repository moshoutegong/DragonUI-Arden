local addon = select(2, ...)
local NP = addon.Nameplates

-- Nameplates target zoom: the health bar of your current target gets extra
-- width/height (reference 2.0 "Target Selected Enlarge" additional_width/height),
-- restored automatically when the target changes or no target exists.
--
-- The zoom is purely a layout-size change: "is target" is part of the layout
-- signature (gather.BuildLayoutSignature), so the layout pass re-runs whenever
-- the target changes and LayoutMinaStack picks up the new extra size.

NP.targetzoom = NP.targetzoom or {}

local function GetCfg()
    return NP.config and NP.config.GetCfg and NP.config.GetCfg() or nil
end

function NP.targetzoom.IsEnabled()
    local cfg = GetCfg()
    return cfg and cfg.targetZoomEnabled ~= false
end

-- True while this plate is the resolved target plate (and zoom is enabled).
function NP.targetzoom.IsTargetZoomed(plateData)
    if not plateData then return false end
    if not NP.targetzoom.IsEnabled() then return false end
    return NP.module and NP.module.targetPlate == plateData
end

-- Extra width/height applied to the health bar while this plate is the target.
function NP.targetzoom.GetExtraSize(plateData)
    if not NP.targetzoom.IsTargetZoomed(plateData) then
        return 0, 0
    end
    local cfg = GetCfg()
    if not cfg then
        return 0, 0
    end
    local w = tonumber(cfg.targetZoomWidth) or 0
    local h = tonumber(cfg.targetZoomHeight) or 0
    if w < 0 then w = 0 end
    if h < 0 then h = 0 end
    return w, h
end
