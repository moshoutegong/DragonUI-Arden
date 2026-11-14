-- Copyright (c) 2026 NeticSoul. Licensed under the MIT License; see LICENSE.

-- ============================================================================
-- DragonUI - Centralized Font System
-- Single source of truth for locale-aware font selection.
-- Loaded early (via DragonUI.xml) so config.lua, database.lua, and all modules
-- can reference addon.Fonts instead of hardcoding font paths.
-- ============================================================================
--
-- WoW 3.3.5a ships different fonts per locale:
--   enUS/deDE/frFR/esES/esMX/ptBR : Fonts\FRIZQT__.TTF  + Fonts\ARIALN.TTF
--   ruRU                           : Fonts\FRIZQT__.TTF (the ruRU build carries Cyrillic)
--   koKR                           : Fonts\2002.TTF (Korean CJK glyphs)
--   zhCN                           : Fonts\ZYKai_T.TTF (Simplified Chinese)
--   zhTW                           : Fonts\bLEI00D.TTF (Traditional Chinese)
--   (Ascension client: Fonts\FRIZQT__.TTF is replaced with 方正粗圆_GBK, so it carries full
--    Simplified-Chinese coverage and is used for zhCN here instead of the missing ZYKai_T.TTF.)
--
-- Custom fonts (expressway.ttf, PTSansNarrow.ttf) cover Latin-1, Eastern European
-- and Cyrillic, but carry no CJK glyphs. This module selects the correct system
-- font for each locale, falling back to the custom font when safe.
-- ============================================================================

local addon = select(2, ...)

-- Fonts must follow the *active* UI locale (set via the options panel / defaulted to zhCN),
-- not the raw client locale, or a Chinese UI would still get Latin-only custom fonts.
local _locale = addon.GetActiveLocale and addon.GetActiveLocale() or GetLocale()

-- ============================================================================
-- FONT TABLES PER LOCALE
-- ============================================================================

-- CJK/Cyrillic font map: locale -> system font that contains the required glyphs.
-- zhCN points at Fonts\FRIZQT__.TTF on purpose: the Ascension client replaces that file with
-- 方正粗圆_GBK (full GBK coverage), while the vanilla zhCN font ZYKai_T.TTF is not shipped here.
local LOCALE_SYSTEM_FONTS = {
    koKR = "Fonts\\2002.TTF",
    zhCN = "Fonts\\FRIZQT__.TTF",
    zhTW = "Fonts\\bLEI00D.TTF",
    -- FRIZQT___CYR.TTF only exists from Cataclysm on; SetFont with it fails on a 3.3.5a ruRU client.
    ruRU = "Fonts\\FRIZQT__.TTF",
}

-- Only CJK is beyond the bundled fonts; forcing the client font on ruRU would strip the
-- Latin accents every other shipped language needs, so ruRU is deliberately absent here.
local LOCALE_CJK_FONTS = {
    koKR = LOCALE_SYSTEM_FONTS.koKR,
    zhCN = LOCALE_SYSTEM_FONTS.zhCN,
    zhTW = LOCALE_SYSTEM_FONTS.zhTW,
}

-- Does this locale need a system font instead of custom Latin-only fonts?
local _needsSystemFont = (LOCALE_SYSTEM_FONTS[_locale] ~= nil)

-- ============================================================================
-- RESOLVED FONT PATHS
-- ============================================================================

local Fonts = {}

--- Primary UI font (unit frames, tooltips, game menu, general text).
-- Uses FRIZQT__.TTF on Latin locales, locale-specific font on CJK/Cyrillic.
Fonts.PRIMARY = LOCALE_SYSTEM_FONTS[_locale] or "Fonts\\FRIZQT__.TTF"

--- Action bar font (hotkeys, macros, cooldowns, page numbers).
-- Uses expressway.ttf on Latin and Cyrillic locales for a modern Dragonflight look,
-- falls back to the locale system font on CJK.
Fonts.ACTIONBAR = LOCALE_CJK_FONTS[_locale]
    or [[Interface\AddOns\DragonUI\Fonts\expressway.ttf]]

--- Narrow UI font (options panel, editor mode labels).
-- PTSansNarrow.ttf on Latin and Cyrillic locales, locale system font on CJK.
Fonts.NARROW = LOCALE_CJK_FONTS[_locale]
    or [[Interface\AddOns\DragonUI_Options\fonts\PTSansNarrow.ttf]]

--- ARIALN replacement: used where database defaults previously hardcoded ARIALN.
-- On Latin locales ARIALN is fine; on CJK/Cyrillic we substitute the system font.
Fonts.ARIALN = LOCALE_SYSTEM_FONTS[_locale] or "Fonts\\ARIALN.TTF"

--- Whether the current locale requires a system font (CJK or Cyrillic).
Fonts.needsSystemFont = _needsSystemFont

--- The raw locale string (e.g. "enUS", "koKR").
Fonts.locale = _locale

-- ============================================================================
-- EXPORT
-- ============================================================================

addon.Fonts = Fonts
