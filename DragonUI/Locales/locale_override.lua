-- Copyright (c) 2026 NeticSoul. Licensed under the MIT License; see LICENSE.

local addon = select(2, ...)
if not addon then return end

-- Set of locales DragonUI ships translations for.
local SUPPORTED = {
    enUS = true, esES = true, esMX = true, ptBR = true,
    deDE = true, frFR = true, ruRU = true,
    zhCN = true, zhTW = true, koKR = true,
}

-- Default UI language when no preference is stored (SavedVariables locale = nil/"auto")
-- or the client locale is unusable. The Ascension client ships a full GBK Chinese font
-- (Fonts\FRIZQT__.TTF is 方正粗圆_GBK), so zhCN renders correctly even though the client
-- reports enUS.
local DEFAULT_LOCALE = "zhCN"

local CLIENT_LOCALE = GetLocale()
if CLIENT_LOCALE == "enGB" then
    CLIENT_LOCALE = "enUS"
end
-- Private-server clients report locales we ship nothing for (enCN, enTW, itIT); without this
-- GetLocale would resolve to nil and every addon.L lookup would error.
if not SUPPORTED[CLIENT_LOCALE] then
    CLIENT_LOCALE = "enUS"
end

-- core/fonts.lua picks the UI font from the *active* locale, and a Latin client font carries no
-- Cyrillic or CJK glyphs, so those languages would render the whole UI as "?".
-- On this client, however, Fonts\FRIZQT__.TTF is 方正粗圆_GBK (full GBK coverage), so Simplified
-- Chinese renders correctly regardless of what GetLocale() reports.
local SCRIPT = { ruRU = "cyrillic", zhCN = "hans", zhTW = "hant", koKR = "hangul" }

function addon.CanRenderLocale(locale)
    local needs = SCRIPT[locale]
    if not needs then
        return true
    end
    -- The Ascension client ships a full CJK font as its default system font, so zhCN always renders.
    if needs == "hans" then
        return true
    end
    return needs == SCRIPT[CLIENT_LOCALE]
end

-- SavedVariables load *after* the addon's files (see ADDON_LOADED), so at file scope this can only
-- return the default; addon.RefreshLocale() re-resolves it from AceDB in OnInitialize.
function addon.GetActiveLocale()
    local pref
    if addon.db and addon.db.global then
        pref = addon.db.global.locale
    else
        local sv = _G.DragonUIDB
        pref = sv and sv.global and sv.global.locale
    end
    if type(pref) == "string" and SUPPORTED[pref] then
        return pref
    end
    -- "auto" / nil / unsaved preference resolves to the default (Simplified Chinese).
    return DEFAULT_LOCALE
end

-- Exposed for the options panel / dropdown UI.
addon.SUPPORTED_LOCALES = SUPPORTED
addon.CLIENT_LOCALE = CLIENT_LOCALE
addon.DEFAULT_LOCALE = DEFAULT_LOCALE
