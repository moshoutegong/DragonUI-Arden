-- Copyright (c) 2026 NeticSoul. Licensed under the MIT License; see LICENSE.

--[[
================================================================================
DragonUI_Options - English Locale (Default)
================================================================================
Base locale for the options panel: labels, descriptions, section headers,
dropdown values, print messages, popup text.

When adding new strings:
1. Add L[<your key>] = true here
2. Use L["Your String"] in your options code
3. Add translations to other locale files
================================================================================
]]

local L = LibStub("AceLocale-3.0-DragonUI"):NewLocale("DragonUI_Options", "enUS", true)
if not L then return end

-- ============================================================================
-- GENERAL / PANEL
-- ============================================================================

L["DragonUI"] = true
L["Core"] = true
L["Frames"] = true
L["Interface"] = true
L["Editor Mode"] = true
L["Cannot open options during combat."] = true
L["Options closed for combat."] = true
L["Open DragonUI Settings"] = true
L["Open the DragonUI configuration panel."] = true
L["Use /dragonui to open the full settings panel."] = true

-- Quick Actions
L["Quick Actions"] = true
L["Jump to popular settings sections."] = true
L["Action Bar Layout"] = true
L["Configure dark tinting for all UI chrome."] = true
L["Full-width health bar that fills the entire player frame."] = true
L["Add a decorative dragon to your player frame."] = true
L["Heal prediction, absorb shields and animated health loss."] = true
L["Change columns, rows, and buttons shown per action bar."] = true
L["Switch micro menu icons between colored and grayscale style."] = true
L["About"] = true
L["Bringing the retail WoW look to 3.3.5a."] = true
L["Bringing the retail WoW look to 3.3.5a, inspired by Dragonflight UI."] = true
L["Created and maintained by NeticSoul, with community contributions."] = true
L["Use the tabs on the left to configure modules, action bars, unit frames, minimap, and more."] = true

-- Language
L["Language"] = true
L["Choose the language used by the DragonUI interface."] = true
L["Follow the client language"] = true
L["Number Abbreviations"] = true
L["How unit frames, nameplates and the resource display shorten large numbers."] = true

-- Loot Roll
L["Auto Greed/DE"] = true
L["Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level."] = true

-- Settings window
L["Settings Window"] = true
L["Size of this window on top of your UI scale; 1.0 matches the other panels. It never grows past the screen."] = true

-- UI scale
L["UI Scale"] = true
L["Custom UI Scale"] = true
L["Lets the interface go smaller than Blizzard's 0.64. Replaces the UI Scale in Video options."] = true
L["Size of the whole interface. Lower values fit more on screen."] = true
L["Auto Scale"] = true
L["Use the scale that draws one interface pixel per screen pixel at your resolution."] = true

L["Commands: /dragonui, /dui, /pi \226\128\148 /dragonui edit (editor) \226\128\148 /dragonui help"] = true
L["GitHub (select and Ctrl+C to copy):"] = true
L["Help me on GitHub (select and Ctrl+C to copy):"] = true
L["New version available! (v%s)"] = true
L["All"] = true
L["Error:"] = true
L["Error: DragonUI addon not found!"] = true

-- ============================================================================
-- STATIC POPUPS
-- ============================================================================

L["Changing this setting requires a UI reload to apply correctly."] = true
L["Reload UI"] = true
L["Not Now"] = true
L["Reload Now"] = true
L["Cancel"] = true
L["Yes"] = true
L["No"] = true

-- ============================================================================
-- TAB NAMES
-- ============================================================================

L["General"] = true
L["Modules"] = true
L["Action Bars"] = true
L["Additional Bars"] = true
L["Minimap"] = true
L["Profiles"] = true
L["Unit Frames"] = true
L["XP & Rep Bars"] = true
L["Chat"] = true
L["BNet Toast"] = true
L["Bags"] = true
L["Appearance"] = true

-- ============================================================================
-- MODULES TAB
-- ============================================================================

-- Headers & descriptions
L["Toggle individual modules on or off. Disabled modules revert to the default Blizzard UI."] = true
L["Warning:"] = true
L["Individual overrides. The grouped toggles above take priority."] = true
L["Advanced - Individual Module Control"] = true

-- Section headers
L["Cast Bars"] = true
L["UI Systems"] = true
L["Enable All Action Bar Modules"] = true
L["Cast Bar"] = true

-- Toggle labels
L["Action Bars System"] = true
L["Micro Menu & Bags"] = true
L["Cooldown Timers"] = true
L["Minimap System"] = true
L["Buff Frame System"] = true
L["Dark Mode"] = true
L["Item Quality Borders"] = true
-- Character Panel
L["Character Panel"] = true
L["Modern reskin of the Blizzard character window."] = true
L["Enable Character Panel"] = true
L["Apply the DragonUI reskin to the character window."] = true
L["Class Portrait"] = true
L["Portrait"] = true
L["Class Icon"] = true
L["Specialization Icon"] = true
L["Class-Colored Level Text"] = true
L["Color the class name in the \"Level X Race Class\" line."] = true
-- Pets & Mounts
L["Pets & Mounts"] = true
L["A dedicated window for your mounts and companion pets, replacing the old Pet tab of the character window."] = true
L["Enable Pets & Mounts"] = true
L["Add the Pets & Mounts micro menu button and its window."] = true
L["Enable Enhanced Tooltips"] = true
L["KeyBind Mode"] = true
L["Quest Tracker"] = true
L["Version Check"] = true

-- Farm mode
L["Farm Mode"] = true
L["Extra scale"] = true
L["Bigger minimap with the surrounding clutter hidden."] = true
L["Extra scale applied on top of the minimap scale."] = true

-- Module toggle descriptions
L["Enable DragonUI player castbar styling."] = true
L["Enable DragonUI target castbar styling."] = true
L["Enable DragonUI focus castbar styling."] = true
L["Hide Blizzard's Castbar"] = true
L["With this cast bar off, hide Blizzard's too, so none is shown."] = true
L["Master toggle for the complete action bars system."] = true
L["Includes main bars, vehicle, stance, pet, totem bars, and button styling."] = true
L["Micro menu and bags styling."] = true
L["Show cooldown timers on action buttons."] = true
L["Minimap styling, tracking icons, and calendar."] = true
L["Buff frame styling and toggle button."] = true
L["Separate Weapon Enchants"] = true
L["Detach weapon enchant icons (poisons, sharpening stones, etc.) from the buff bar into their own independently moveable frame. Position it freely using Editor Mode."] = true

-- Auras tab
L["Show Toggle Button"] = true
L["Show a collapse/expand button next to the buff icons."] = true
L["Vanity Buffs"] = true
L["Vanity buffs are cosmetic auras consolidated by Conquest of Azeroth (mounts, toys, transmog effects). The consolidated container is provided by the Ascension_VanityCollection addon."] = true
L["Hide Vanity Buffs"] = true
L["Hide the Conquest of Azeroth vanity-buff consolidated container and its contained auras from the buff frame. Existing buff order and positioning are preserved."] = true
L["Weapon Enchants"] = true
L["Weapon enchant icons include rogue poisons, sharpening stones, wizard oils, and similar temporary weapon enhancements."] = true
L["Aura Borders"] = true
L["Enable Aura Borders"] = true
L["Show modern borders around buff and debuff icons."] = true
L["Buff Border Color"] = true
L["Detailed"] = true
L["Rounded"] = true
L["Square"] = true
L["DragonUI Square"] = true
L["Forever Square"] = true
L["Square Border"] = true
L["Forever Frame"] = true
L["Thin Line"] = true
L["Top Arrow"] = true
L["Rounded Corners"] = true
L["When enabled, a 'Weapon Enchants' mover appears in Editor Mode that you can drag to any position on screen."] = true
L["Positions"] = true
L["Player Buffs & Debuffs"] = true
L["Layout settings for the player buff and debuff bar. These do not affect target or focus auras."] = true
L["Show your debuffs on the player aura bar."] = true
L["Buff Order"] = true
L["Default (Blizzard)"] = true
L["How to sort player buff icons on the buff bar."] = true
L["Player Buffs First"] = true
L["Other Player Buffs First"] = true
L["Duration Buffs First"] = true
L["Buffs Per Row"] = true
L["Debuffs Per Row"] = true
L["How many buff icons to show in each row."] = true
L["How many debuff icons to show in each row."] = true
L["Max Buff Rows"] = true
L["Max Debuff Rows"] = true
L["Maximum number of buff rows to display. Use 0 for no limit."] = true
L["Maximum number of debuff rows to display. Use 0 for no limit."] = true
L["Buff Horizontal Gap"] = true
L["Debuff Horizontal Gap"] = true
L["Buff Vertical Gap"] = true
L["Debuff Vertical Gap"] = true
L["Space between buff rows."] = true
L["Space between debuff rows."] = true
L["Debuff Attached Offset Y"] = true
L["Vertical gap below the buff bar when debuffs are attached (not detached in Editor Mode)."] = true
L["Layout Preview"] = true
L["Shows fake buff and debuff icons so you can tune scale, rows, and spacing without needing real auras. Turn this off when finished."] = true
L["Enable Layout Preview"] = true
L["Preview Buff Count"] = true
L["Preview Debuff Count"] = true
L["Reset Buff Frame Position"] = true
L["Reset Weapon Enchant Position"] = true
L["Reset Debuff Position"] = true
L["Buff frame position reset."] = true
L["Weapon enchant position reset."] = true
L["Debuff position reset."] = true
L["Debuffs detached - positioned freely via Editor Mode"] = true
L["Debuffs attached - follow buff row"] = true
L["Target & Focus Aura Customization"] = true
L["Customize target/focus aura icons and timers."] = true
L["Aura Timers"] = true
L["Show aura timers on Target and Focus independently."] = true
L["Aura Icon Customization"] = true
L["Customize icon size, scale, and stack text for target/focus auras."] = true
L["Customize Aura Icons"] = true
L["Enable custom icon styling for target/focus aura icons."] = true
L["Target Aura Timer Settings"] = true
L["Enable Target Aura Timers"] = true
L["Target Aura Timer Size"] = true
L["Target Aura Minimum Duration (Seconds)"] = true
L["Target Aura Maximum Duration (Minutes)"] = true
L["Ignore Keeper's Aura from Target"] = true
L["Hide all buffs on the target whose name starts with 'Keeper's'."] = true
L["Focus Aura Timer Settings"] = true
L["Enable Focus Aura Timers"] = true
L["Focus Aura Timer Size"] = true
L["Focus Aura Minimum Duration (Seconds)"] = true
L["Focus Aura Maximum Duration (Minutes)"] = true
L["Only show aura timers when remaining duration is above this value (seconds)."] = true
L["Only show aura timers when remaining duration is below this value (minutes). Use 0 to disable this limit."] = true
L["Timer Text Settings"] = true
L["Aura Buffs"] = true
L["Aura Debuffs"] = true
L["Duration Text Anchor"] = true
L["Duration X Offset"] = true
L["Duration Y Offset"] = true
L["Stack Text Settings"] = true
L["Stack Text Anchor"] = true
L["Stack X Offset"] = true
L["Stack Y Offset"] = true
L["Duration Font"] = true
L["Stack Font"] = true
L["Actionbar Font"] = true
L["Primary Font"] = true
L["Narrow Font"] = true
L["Arial Font"] = true
L["System Font"] = true
L["Aura Size"] = true
L["Auras Per Row"] = true
L["Discrete size steps: how many auras fit in a full-width row. 6 is the Blizzard default (17px). Your own auras render slightly larger, and rows beside a visible Target-of-Target are narrower, so fewer may fit there."] = true
L["Buff Icon Size"] = true
L["Buff Icon Scale"] = true
L["Buff Stack Font Size"] = true
L["Debuff Icon Size"] = true
L["Debuff Icon Scale"] = true
L["Debuff Stack Font Size"] = true
L["Background Plates Opacity"] = true
L["Controls the opacity of non-target nameplates while fade is active (0.0 - 1.0)."] = true
L["No Target: Full Opacity"] = true
L["When you have no target, show all nameplates at full opacity."] = true
L["Party/Raid: Full Opacity"] = true
L["Always show party and raid member nameplates at full opacity, regardless of target or fade settings. Does not affect pets or NPCs."] = true
L["Level Format"] = true
L["Show Debuff Position Debug Box"] = true
L["Displays a box showing where the debuff icon row starts and ends, even when no debuffs are active."] = true
L["Shade Fill"] = true
L["Quadrant Sweep"] = true
L["Square Radial Sweep"] = true
L["Reset Aura Customization"] = true
L["Reset Aura Timers"] = true
L["Aura timer settings reset."] = true
L["Aura icon customization settings reset."] = true

L["DragonUI quest tracker positioning and styling."] = true
L["LibKeyBound integration for intuitive hover + key press binding."] = true
L["Broadcast and detect addon version updates across group members."] = true

-- Toggle keybinding mode description

-- Enable/disable dynamic descriptions
L["Enable/disable "] = true

-- Dark Mode
L["Light (subtle)"] = true
L["Medium (balanced)"] = true
L["Dark (maximum)"] = true
L["Apply darker tinted textures to all UI elements."] = true
L["Darkens UI borders and chrome only: action bar borders, unit frame borders, minimap border, bag slot borders, micro menu, castbar borders, and decorative elements. Icons, portraits, and abilities are never affected."] = true
L["Enable Dark Mode"] = true

-- Dark Mode - Custom Color
L["Custom Color"] = true
L["Override presets with a custom tint color."] = true
L["Tint Color"] = true
L["Intensity"] = true

-- Range Indicator
L["Tints action button icons based on range and usability: red = out of range, blue = not enough mana, gray = unusable."] = true
L["Enable Range Indicator"] = true
L["Color action button icons when target is out of range or ability is unusable."] = true
L["Out of Range Color"] = true
L["Not Enough Mana Color"] = true

-- Key Press
L["Key Press"] = true
L["Fires action bar abilities the instant you press a key instead of when you release it, shaving reaction-time latency. Most useful for interrupts, dispels, and PvP."] = true
L["Enable Key Press"] = true
L["Fire abilities on key press instead of key release."] = true

-- Item Quality Borders
L["Enable Item Quality Borders"] = true
L["Show quality-colored borders on items in bags, character panel, bank, merchant, and inspect frames."] = true
L["Adds quality-colored glow borders to items in your bags, character panel, bank, merchant, and inspect frames: green = uncommon, blue = rare, purple = epic, orange = legendary."] = true
L["Character Item Counts"] = true
L["Show Character Item Counts"] = true
L["Automatic Equipment Comparison"] = true
L["Compare equippable items with your equipped gear without holding Shift, including item links opened from chat. Hold Ctrl to suppress it."] = true
L["Shows how many of the hovered item each of your characters on this realm holds, split into bags, bank and equipped."] = true
L["Minimum Quality"] = true
L["Poor"] = true
L["Common"] = true
L["Uncommon"] = true
L["Rare"] = true
L["Epic"] = true
L["Legendary"] = true

-- Loot Window
L["Loot Window"] = true
L["Configure the DragonUI loot window."] = true
L["Auto-Hide Empty Loot"] = true
L["Close the loot window when there is nothing left to loot."] = true
L["Enable Loot Window"] = true
L["Apply the DragonUI skin to the Blizzard loot window."] = true
L["Open at Cursor"] = true
L["Open the loot window at the cursor instead of its saved position."] = true
L["Disable Open at Cursor, then drag the loot window to save its position."] = true
L["If auto loot is on, hold your auto loot key (Shift by default) while looting, then drag the window to save its position."] = true
L["Animate Loot Reflow"] = true
L["Smoothly close gaps and resize the loot window after collecting items."] = true
L["Auto Loot Hold"] = true
L["Seconds auto-looted items stay in the loot window before sliding out. Clicks pass through while they wait. 0 slides them out at once."] = true
L["Reset Loot Window Position"] = true
L["Clear the saved position. The Blizzard default will be used next time you open the loot window."] = true

-- Item Level
L["Item Level"] = true
L["Enable Item Level"] = true
L["Show the item level on gear icons across bags, bank, character panel and more."] = true
L["Size of the item level number on the icon."] = true
L["Font"] = true
L["Default (Arial Narrow)"] = true
L["Outline"] = true
L["Thickness of the black outline. WoW 3.3.5a has no real bold, so a thicker outline is what makes the number look heavier."] = true
L["Thick"] = true
L["Vertical position of the item level number on the icon."] = true
L["Average Item Level"] = true
L["Show the average item level of equipped gear on the character and inspect panels."] = true
L["Durability on Character Slots"] = true
L["Show Repair Cost"] = true
L["Show the total repair cost of your equipped items in the character window."] = true
L["Show each equipped item's durability percentage on its character panel slot, opposite the item level."] = true
L["Show in Tooltip"] = true
L["Also enable Blizzard's own item level line in item tooltips."] = true
L["Choose where the number appears:"] = true
L["Guild Bank"] = true
L["Inspect"] = true
L["Merchant"] = true
L["Retail-style vendor window chrome"] = true
L["Merchant Auto Services"] = true
L["Automatically repair items and sell junk when you open a merchant window. Requires the Merchant module."] = true
L["Auto Repair"] = true
L["Automatically repair all your items when a merchant window opens."] = true
L["Use Guild Funds"] = true
L["Pay for automatic repairs with guild bank money when you have the right and the guild can cover the cost."] = true
L["Auto Sell Junk"] = true
L["Automatically sell grey (junk) items when a merchant window opens."] = true
L["Quest Dialog"] = true
L["Retail-style quest and gossip window chrome"] = true
L["Trade"] = true
L["Loot"] = true
L["Mail"] = true
L["Auction House"] = true

-- Enhanced Tooltips
L["Enhanced Tooltips"] = true
L["Improves GameTooltip with class-colored borders, class-colored names, target-of-target info, and styled health bars."] = true
L["Activate all tooltip improvements. Sub-options below control individual features."] = true
L["Class-Colored Border"] = true
L["Color the tooltip border by the unit's class (players) or reaction (NPCs)."] = true
L["Class-Colored Name"] = true
L["Color the unit name text in the tooltip by class color (players only)."] = true
L["Add a 'Targeting: <name>' line showing who the unit is targeting."] = true
L["Styled Health Bar"] = true
L["Restyle the tooltip health bar with class/reaction colors and slimmer look."] = true
L["Anchor to Cursor"] = true
L["Make the tooltip follow the cursor position instead of the default anchor."] = true
L["Cursor Anchor Offset X"] = true
L["Horizontal offset from the cursor."] = true
L["Cursor Anchor Offset Y"] = true
L["Vertical offset from the cursor."] = true
L["Show Aura Source"] = true
L["Show the caster's name (class-colored) on buff and debuff tooltips."] = true
L["Aura Tooltips"] = true
L["Show Spell IDs"] = true
L["Show spell IDs on aura, spell and chat-link tooltips. Requires the Tooltip module."] = true

-- Chat Mods
L["Enable Chat Mods"] = true
L["Enables or disables Chat Mods."] = true
L["Show Link Tooltips on Hover"] = true
L["Show tooltips for supported chat links without holding Alt."] = true
L["Class Colored Names"] = true
L["Color player names by class in every chat type and channel. Turning it off removes the class colors from this character's chat settings."] = true
L["Editbox Position"] = true
L["Choose where the chat editbox is positioned."] = true
L["Top"] = true
L["Bottom"] = true
L["Left"] = true
L["Right"] = true
L["Anchor"] = true
L["Middle"] = true
L["Tab & Button Fade"] = true
L["How visible chat tabs are when not hovered. 0 = fully hidden, 1 = fully visible."] = true
L["Chat Style Opacity"] = true
L["Minimum opacity of the custom chat background. At 0 it fades with tabs; above 0 it stays partially visible when idle."] = true
L["Text Box Min Opacity"] = true
L["Minimum opacity of the text input box when idle. At 0 it fades with tabs; above 0 it stays partially visible."] = true
L["Chat Style"] = true
L["Visual style for the chat frame background."] = true
L["Editbox Style"] = true
L["Visual style for the chat input box background."] = true
L["Vanilla Editbox"] = true
L["Use the default chat input appearance."] = true
L["Dark"] = true
L["DragonUI Style"] = true
L["Nocturne"] = true

-- Chat Tab - Recommended Addon
L["Recommended Addon"] = true
L["For a smoother, more polished chat experience, check out CleanerChat-WotLK — it adds chat filter tweaks, improved chat styling, and Glass UI overlays."] = true
L["Download (select and Ctrl+C to copy):"] = true

-- Bagster
L["Enable Bagster"] = true
L["All-in-one bag replacement with item filtering, search, quality indicators, and bank integration."] = true

-- Item usability tint
L["Item Usability"] = true
L["Tint Unusable Items"] = true
L["Color icons red for gear and usable items your character cannot equip or use (wrong armor type, level, class, etc.)."] = true

-- Alt Gold
L["Alt Gold"] = true
L["Enable Alt Gold"] = true
L["Hover the coins in your bags to list the gold of every character that has logged in with DragonUI."] = true
L["Show a tooltip with your other characters' gold when hovering the money in bags."] = true
L["Show All Realms"] = true
L["List characters from every realm instead of only the realm you are playing on."] = true
L["Forget Character"] = true
L["Delete the selected character's saved gold, item counts and offline bank. Your current character is never listed."] = true
L["Forget all saved data of %s?"] = true

-- Bag Sort
L["Bag Sort"] = true
L["Enable Bag Sort"] = true
L["Sort buttons for bags and bank. Sorts items by type, rarity, level, and name."] = true
L["Add sort buttons to bag and bank frames. Also enables /sort and /sortbank slash commands."] = true
L["Fill Bank Stacks from Bags"] = true
L["Pull matching items from your bags into partial bank stacks when sorting the bank."] = true
L["Lock Toggle Hotkey"] = true
L["Choose the modifier + mouse button used to lock or unlock a bag slot while hovering it."] = true
L["Use /sortlock to lock or unlock the currently hovered slot from chat."] = true
L["Lock Icon Color"] = true
L["Color used to tint the padlock icon shown on locked bag/bank slots."] = true
L["Reverse Stack Order"] = true
L["Stack sorted items from the end of each bag so empty slots stay at the top."] = true
L["Alt + Left Click"] = true
L["Ctrl + Left Click"] = true
L["Shift + Left Click"] = true
L["Alt + Right Click"] = true
L["Ctrl + Right Click"] = true
L["Shift + Right Click"] = true
L["Alt + Middle Click"] = true
L["Ctrl + Middle Click"] = true
L["Shift + Middle Click"] = true

L["Show 'All' Tab"] = true
L["Show the 'All' category tab that displays all items without filtering."] = true
L["Equipment"] = true
L["Usable"] = true
L["Show Equipment Tab"] = true
L["Show the Equipment category tab for armor and weapons."] = true
L["Show Usable Tab"] = true
L["Show the Usable category tab for consumables and devices."] = true
L["Show Quest Tab"] = true
L["Show the Quest items category tab."] = true
L["Show Trade Goods Tab"] = true
L["Show the Trade Goods category tab (includes gems and recipes)."] = true
L["Show Miscellaneous Tab"] = true
L["Show the Miscellaneous items category tab."] = true
L["Left Side Tabs"] = true
L["Place category filter tabs on the left side of the bag frame instead of the right."] = true
L["Place category filter tabs on the left side of the bank frame instead of the right."] = true
L["Subtabs"] = true
L["Configure which bottom subtabs appear within each category tab. Applies to both inventory and bank."] = true
L["Normal"] = true
L["Trade Bags"] = true
L["Show the Normal bags subtab (non-profession bags)."] = true
L["Show the Trade bags subtab (profession bags)."] = true
L["Show the Armor subtab."] = true
L["Show the Weapon subtab."] = true
L["Show the Trinket subtab."] = true
L["Show the Consumable subtab."] = true
L["Show the Devices subtab."] = true
L["Show the Trade Goods subtab."] = true
L["Show the Gem subtab."] = true
L["Show the Recipe subtab."] = true
L["Configure Bagster bag replacement settings."] = true
L["Inventory Tabs"] = true
L["Bank Tabs"] = true
L["Inventory"] = true
L["Bank"] = true
L["Choose which category tabs appear on the inventory bag frame."] = true
L["Choose which category tabs appear on the bank frame."] = true
L["Gold Display"] = true
L["Text Only"] = true
L["Gold Icons"] = true
L["(disabled by Colorblind Mode)"] = true
L["Item Scale"] = true
L["Maximum size of item slots. The grid still shrinks them to fit the frame."] = true
L["Item Spacing"] = true
L["Gap between item slots in the grid."] = true
L["Quality Glow"] = true
L["Show a colored ring on uncommon and better items."] = true
L["Quest Item Glow"] = true
L["Highlight quest items with a golden border."] = true
L["Glow Intensity"] = true
L["Opacity of the quality ring on item slots."] = true
L["Item Count in Tooltip"] = true
L["Show how many of the hovered item you own in total, across your bags and bank."] = true
L["Quality Filter Row"] = true
L["Show the rarity filter dots at the bottom of the bag frame."] = true
L["New Items"] = true
L["Highlight New Items"] = true
L["Make items you just looted, bought, crafted or received glow in the inventory until you hover them."] = true
L["Glow Style"] = true
L["Border"] = true
L["Starburst"] = true
L["Glow Color"] = true
L["Item Quality"] = true
L["Custom"] = true
L["Custom Glow Color"] = true
L["Clear When Bags Close"] = true
L["Closing a bag removes its new-item glows. When off, a glow only goes away when you hover the item."] = true
L["Ignore Poor Quality Items"] = true
L["Never mark gray (poor quality) items as new."] = true

-- Advanced modules - Fallback display names
L["Main Bars"] = true
L["Vehicle"] = true
L["Multicast"] = true
L["Buttons"] = true
L["Hide Blizzard Elements"] = true
L["Buffs"] = true
L["KeyBinding"] = true
L["Cooldowns"] = true

-- Advanced modules - RegisterModule display names (from module files)
L["Micro Menu"] = true
L["Loot Roll"] = true
L["Key Binding"] = true

-- Advanced modules - RegisterModule descriptions (from module files)
L["Chat Mods"] = true
L["Bagster"] = true

-- ============================================================================
-- ACTION BARS TAB
-- ============================================================================

-- Sub-tabs
L["Layout"] = true
L["Visibility"] = true

-- Scales section
L["Action Bar Scales"] = true
L["Main Bar Scale"] = true
L["Right Bar Scale"] = true
L["Left Bar Scale"] = true
L["Bottom Left Bar Scale"] = true
L["Bottom Right Bar Scale"] = true
L["Extra Bar Scale"] = true
L["Bar"] = true
L["Reset All Scales"] = true
L["All action bar scales reset to 0.9"] = true

-- Positions section
L["Action Bar Positions"] = true
L["Left Bar Horizontal"] = true
L["Make the left secondary bar horizontal instead of vertical."] = true
L["Right Bar Horizontal"] = true
L["Make the right secondary bar horizontal instead of vertical."] = true

-- Button Appearance section
L["Button Appearance"] = true
L["Hide Secondary Bar Background"] = true
L["Hide the background of secondary bar buttons (stance, pet, totem, etc.)."] = true
L["Hide Main Bar Button Background"] = true
L["Hide the background of main action bar buttons."] = true
L["Main Bar Only Background"] = true
L["Only the main action bar buttons will have a background."] = true
L["Hide Main Bar Art"] = true
L["Hide Button Backgrounds"] = true
L["Hide the slot background of every action bar button, leaving only the frames."] = true
L["Hide the main bar's art and gryphons, leaving only the buttons."] = true
L["Button Tooltips"] = true
L["When to show tooltips on action, pet and stance buttons."] = true
L["Always"] = true
L["Never"] = true

-- Behavior section
L["Behavior"] = true
L["Disable Form Page Switching"] = true
L["When enabled, the main action bar stays on the same page regardless of stance/form changes. Useful for druids, warriors, and CoA Classes who prefer manual page management."] = true

-- Text visibility
L["Text Visibility"] = true
L["Show Count Text"] = true
L["Show Hotkey Text"] = true
L["Range Indicator"] = true
L["Show range indicator dot on buttons."] = true
L["Show Macro Names"] = true
L["Show Page Numbers"] = true

-- Cooldown text
L["Cooldown Text"] = true
L["Min Duration"] = true
L["Minimum duration for cooldown text to appear."] = true
L["Whole Seconds"] = true
L["Show cooldown text in whole seconds, without the tenths under 5 seconds."] = true
L["Cooldown Text Color"] = true
L["Size of cooldown text."] = true

-- Colors
L["Colors"] = true
L["Macro Text Color"] = true
L["Hotkey Text Color"] = true
L["Hotkey Font Size"] = true
L["Hotkey Shadow Color"] = true
L["Border Color"] = true

-- Gryphons
L["Gryphons"] = true
L["End-cap ornaments flanking the main action bar."] = true
L["Style"] = true
L["Gryphon Scale"] = true
L["Gryphon Offset X"] = true
L["Gryphon Offset Y"] = true
L["Moves both gryphons inward or outward, mirrored left/right."] = true
L["Flying"] = true
L["Classic"] = true
L["Dragonflight"] = true
L["Hidden"] = true
L["Dragonflight (Wyvern)"] = true
L["Dragonflight (Gryphon)"] = true

-- Layout section
L["Main Bar Layout"] = true
L["Bottom Left Bar Layout"] = true
L["Bottom Right Bar Layout"] = true
L["Right Bar Layout"] = true
L["Left Bar Layout"] = true
L["Configure the main action bar grid layout. Rows are determined automatically from columns and buttons shown."] = true
L["Page by Form (Classless Servers)"] = true
L["The main bar changes page with your stance or form, whatever your class. Only for classless servers."] = true
L["Columns"] = true
L["Buttons Shown"] = true
L["Change Button Order"] = true
L["Button Order"] = true
L["Quick Presets"] = true
L["Apply layout presets to multiple bars at once."] = true
L["Both 1x12"] = true
L["Both 2x6"] = true
L["Reset All"] = true
L["All bar layouts reset to defaults."] = true

-- Visibility section
L["Control when action bars are visible. Bars can show only on hover, only in combat, or both. When no option is checked the bar is always visible."] = true
L["Enable / Disable Bars"] = true
L["Bottom Left Bar"] = true
L["Bottom Right Bar"] = true
L["Right Bar"] = true
L["Left Bar"] = true
L["Main Bar"] = true
L["Always Hidden"] = true
L["Show on Hover Only"] = true
L["Show in Combat Only"] = true
L["Hide the main bar until you hover over it."] = true
L["Hide the main bar until you enter combat."] = true
L["Hide the main bar while in combat."] = true
L["Hover/Combat Logic"] = true
L["When both hover and combat are enabled, choose whether both are required (AND) or either condition is enough (OR)."] = true
L["Fade the quest tracker until you hover over it."] = true
L["Fade the quest tracker until you enter combat."] = true
L["Hide the quest tracker while in combat."] = true
L["Fade the XP and Reputation bars until you hover over them."] = true
L["Fade the XP and Reputation bars until you enter combat."] = true
L["Hide the XP and Reputation bars while in combat."] = true
L["Fade the player frame until you hover over it."] = true
L["Fade the player frame until you enter combat."] = true
L["Also fades the Target of Target and target cast bar, attached or not."] = true
L["Fade the target frame group until you hover over it."] = true
L["Fade the target frame group until you enter combat."] = true
L["Also fades the Target of Focus and focus cast bar, attached or not."] = true
L["Fade the focus frame group until you hover over it."] = true
L["Fade the focus frame group until you enter combat."] = true
L["Fade the pet frame until you hover over it."] = true
L["Fade the pet frame until you enter combat."] = true
L["Fade party frames until you hover over them."] = true
L["Fade party frames until you enter combat."] = true
L["Buff Tooltip"] = true
L["When to show the box of buffs and debuffs that opens as you hover a party member."] = true
L["Hide the party frames at all times."] = true
L["Fade boss frames until you hover over them."] = true
L["Fade boss frames until you enter combat."] = true
L["Boss"] = true
L["Fade the stance bar until you hover over it."] = true
L["Fade the stance bar until you enter combat."] = true
L["Fade the pet bar until you hover over it."] = true
L["Fade the pet bar until you enter combat."] = true
L["Show the button frame on pet slots with no ability assigned."] = true
L["Fade the totem bar until you hover over it."] = true
L["Fade the totem bar until you enter combat."] = true
L["Fade the minimap until you hover over it."] = true
L["Fade the minimap until you enter combat."] = true
L["Experimental:"] = true
L["Fading the minimap can occasionally cause tracking icons to stop updating until you /reload. Use at your own risk."] = true
L["Has no effect while SexyMap controls the minimap (SexyMap or Hybrid mode)."] = true
L["Hide in Combat"] = true
L["Hide the minimap while in combat."] = true
L["AND (both required)"] = true
L["OR (either condition)"] = true
L["Bag Bar"] = true

-- ============================================================================
-- ADDITIONAL BARS TAB
-- ============================================================================

L["Bars that appear based on your class and situation."] = true

-- Common settings
L["Button Size"] = true
L["Button Spacing"] = true

-- Stance Bar
L["Stance Bar"] = true
L["Warriors, Druids, Death Knights"] = true
L["Show Stance Bar"] = true
L["X Position"] = true
L["Horizontal position of stance bar from screen center. Negative values move left, positive values move right."] = true
L["Y Position"] = true

-- Pet Bar
L["Pet Bar"] = true
L["Pet Bar Layout"] = true
L["Hunters, Warlocks, Death Knights - Use editor mode to move"] = true
L["Show Empty Slots"] = true

-- Vehicle Bar
L["Vehicle Bar"] = true
L["Blizzard Art Style"] = true
L["Use Blizzard vehicle bar art with health/power display. Requires reload."] = true

-- Totem Bar
L["Totem Bar (Shaman)"] = true
L["Show Totem Bar"] = true
L["Shamans only - Totem multicast bar. Position is controlled via Editor Mode."] = true
L["TIP: Use Editor Mode to position the totem bar (type /dragonui edit)."] = true

-- Extra Bar (issue #330)
L["Extra Bar"] = true
L["A 12-button action bar independent of every class's bonus bar (stance/stealth/vehicle)."] = true
L["Fade the extra bar until you hover over it."] = true
L["Fade the extra bar until you enter combat."] = true

-- ============================================================================
-- CAST BARS TAB
-- ============================================================================

L["Player Castbar"] = true
L["Target Castbar"] = true
L["Focus Castbar"] = true

-- Sub-tabs
L["Player"] = true
L["Target"] = true
L["Focus"] = true

-- Common options
L["Width"] = true
L["Height"] = true
L["Size scale of the cast bar"] = true
L["Hide Castbar"] = true
L["Hide Castbar Desc"] = "Hides this castbar completely: both the DragonUI bar and the default Blizzard bar."
L["Show Icon"] = true
L["Icon Size"] = true
L["Modern Icon Border"] = true
L["Modern Icon Border Desc"] = "Frame the spell icon with the DragonUI action-bar border instead of the classic ring."
L["Spell Icon Left of Bar"] = true
L["Modern style: show the spell icon to the left of the cast bar instead of under it."] = true
L["Modern Icon Border Debuff Desc"] = "Frame aura icons with the DragonUI action-bar border."
L["Text Mode"] = true
L["Simple (Name Only)"] = true
L["Detailed (Name + Time)"] = true
L["Time Precision"] = true
L["Decimal places for remaining time."] = true
L["Max Time Precision"] = true
L["Decimal places for total time."] = true
L["Hold Time (Success)"] = true
L["How long the bar stays after a successful cast."] = true
L["Hold Time (Interrupt)"] = true
L["How long the bar stays after being interrupted."] = true
L["Shake on Interrupt"] = true
L["Shake the cast bar briefly when it gets interrupted."] = true
L["Show Interrupter"] = true
L["Show the name of whoever interrupted the cast."] = true
L["Reset Position"] = true
L["Player castbar position reset."] = true
L["Castbar detached - positioned freely via Editor Mode"] = true
L["Castbar attached - follows Target frame"] = true
L["Castbar attached - follows Focus frame"] = true
L["Re-attach Castbar to Target"] = true
L["Re-attach Castbar to Focus"] = true

-- Width/height descriptions for target/focus

-- Latency indicator (player only)
L["Latency Indicator"] = true
L["Enable Latency Indicator"] = true
L["Show a safe-zone overlay based on real cast latency."] = true
L["Latency Color"] = true
L["Latency Alpha"] = true
L["Opacity of the latency indicator."] = true

-- Global cooldown indicator (player only)
L["Global Cooldown"] = true
L["Enable GCD Indicator"] = true
L["Show a global cooldown readout above the player cast bar."] = true
L["GCD Height"] = true
L["Thickness of the GCD bar in pixels."] = true
L["GCD Width"] = true
L["Width of the GCD bar as a percentage of the cast bar."] = true
L["GCD Color"] = true
L["Always Show GCD Track"] = true
L["Keep the empty GCD bar visible while no global cooldown is running."] = true
L["Reset GCD Position"] = true
L["GCD indicator reset to the cast bar."] = true
L["GCD Style"] = true
L["Fill texture of the GCD bar."] = true
L["GCD Background"] = true
L["What is drawn behind the GCD bar."] = true
L["Show GCD Spark"] = true
L["Show a spark on the moving edge of the GCD bar."] = true
L["Flat"] = true
L["Framed"] = true

-- ============================================================================
-- BNET TOAST TAB
-- ============================================================================

L["Configure how DragonUI notifies you when friends come online or go offline."] = true
L["Enable BNet Toast"] = true
L["Display Battle.net friend online/offline notifications via toast popup and/or chat messages."] = true
L["Notification Type"] = true
L["Guild Notifications"] = true
L["Show notifications for guild members coming online or going offline. Turn off to only receive friend notifications."] = true
L["Show Toast Popup"] = true
L["Display the Battle.net toast frame when a friend comes online or goes offline."] = true
L["Show Chat Notification"] = true
L["Display a chat message when a friend comes online or goes offline."] = true
L["Position & Scale"] = true
L["Scale of the BNet toast frame."] = true
L["Horizontal position of the BNet toast from the screen center. Negative values move left, positive values move right."] = true
L["Vertical offset of the BNet toast frame. Negative values move down, positive values move up."] = true

-- ============================================================================
-- ENHANCEMENTS TAB
-- ============================================================================

L["Enhancements"] = true
L["Visual enhancements that add Dragonflight-style polish to the UI. These are optional \226\128\148 disable any you don't want."] = true

-- (Dark Mode, Range Indicator, Item Quality, Tooltips defined above in MODULES section)

-- Low HP Alert
L["Low HP Alert"] = true
L["Plays a sound and flashes the screen edges when your HP drops below the configured threshold."] = true
L["Enable Low HP Alert"] = true
L["Warning Sound (every 3 sec)"] = true
L["Plays a warning sound every 3 seconds while HP is below threshold."] = true
L["Screen Edge Flash"] = true
L["Flashes red at the edges of the screen while HP is below threshold."] = true
L["HP Warning Threshold"] = true
L["Percentage of HP at which the warning triggers."] = true
L["Test Warning (3 sec)"] = true
L["Triggers a 3-second preview of the warning state to help you adjust the threshold."] = true
L["Flash Color"] = true
L["Color of the screen edge flash effect."] = true
L["Use Class Color"] = true
L["Use your class color (e.g. orange for Druid, yellow for Rogue) instead of the custom color."] = true
L["Flash Opacity"] = true
L["Maximum opacity of the flash effect."] = true
L["Flash Extent"] = true
L["How far the flash extends from the screen edges toward the center, in pixels."] = true

-- ============================================================================
-- MICRO MENU TAB
-- ============================================================================

L["Grayscale Icons"] = true
L["Use grayscale icons instead of colored icons."] = true
L["Menu Scale"] = true
L["Icon Spacing"] = true
L["Padding between micromenu buttons."] = true
L["Number of micromenu button columns. Set to 1 for a vertical stack."] = true
L["Invert Button Order"] = true
L["Reverse the order of micromenu buttons in the grid."] = true
L["Hide on Vehicle"] = true
L["Hide micromenu and bags while in a vehicle."] = true
L["Show Latency Indicator"] = true
L["Show a colored bar below the Help button indicating connection quality (green/yellow/red)."] = true

-- Bags
L["Bags"] = true
L["Bag Bar Scale"] = true

-- XP & Rep Bars
L["XP Bar"] = true
L["XP & Rep Bars (Legacy Offsets)"] = true
L["Main XP & Rep bar options have moved to the XP & Rep Bars tab."] = true
L["These offset options are for advanced positioning adjustments."] = true
L["Both Bars Offset"] = true
L["Y offset when XP & reputation bar are shown"] = true
L["Single Bar Offset"] = true
L["Y offset when XP or reputation bar is shown"] = true
L["No Bar Offset"] = true
L["Y offset when no XP or reputation bar is shown"] = true
L["Rep Bar Above XP Offset"] = true
L["Y offset for reputation bar when XP bar is shown"] = true
L["Rep Bar Offset"] = true
L["Y offset when XP bar is not shown"] = true

-- ============================================================================
-- MINIMAP TAB
-- ============================================================================

L["Minimap Buttons Collector"] = true
L["Circle"] = true
L["Arrow"] = true
L["Basic Settings"] = true
L["Border Alpha"] = true
L["Top border alpha (0 to hide)."] = true
L["Square Minimap"] = true
L["Use a square minimap with a square border instead of the round DragonUI border."] = true
L["Addon Button Skin"] = true
L["Apply DragonUI border styling to addon icons."] = true
L["Addon Button Fade"] = true
L["Addon icons fade out when not hovered."] = true
L["Player Arrow Size"] = true
L["Addon Button Distance"] = true
L["Moves LibDBIcon addon buttons out from the minimap's edge, or in with a negative value."] = true
L["New Blip Style"] = true
L["Use newer-style minimap blip icons."] = true
L["Show Ping Sender"] = true
L["Show who pinged the minimap, in their class color."] = true
L["Minimap Decorations"] = true
L["Border presets from SexyMap by funkydude, used with permission."] = true
L["Adds decorative animated texture layers around the DragonUI minimap."] = true
L["Enable Minimap Decorations"] = true
L["Animated Effects"] = true
L["Rotate preset layers when the selected preset includes animation."] = true
L["Hide DragonUI Border"] = true

-- Time & Calendar
L["Time & Calendar"] = true
L["Show Clock"] = true
L["Show Calendar"] = true
L["Clock Font Size"] = true

-- Display Settings
L["Display Settings"] = true
L["Tracking Icons"] = true
L["Show current tracking icons (old style)."] = true
L["Zoom Buttons"] = true
L["Show zoom buttons (+/-)."] = true
L["Zone Text Font Size"] = true
L["Font size of the zone text above the minimap."] = true

-- Position
L["Position"] = true

-- ============================================================================
-- QUEST TRACKER TAB
-- ============================================================================

L["Position and display settings for the objective tracker."] = true
L["Show Header Background"] = true
L["Show/hide the decorative header background texture."] = true
L["Top Right"] = true
L["Top Left"] = true
L["Bottom Right"] = true
L["Bottom Left"] = true
L["Center"] = true
L["Font size for quest tracker text"] = true
L["Custom Height"] = true
L["Limit the tracker to a fixed height. When off, it stops above the bags. Quests that don't fit are hidden until there is room."] = true
L["Maximum height of the quest tracker."] = true

-- ============================================================================
-- UNIT FRAMES TAB
-- ============================================================================

-- Sub-tabs
L["Pet"] = true
L["ToT / ToF"] = true
L["Party"] = true

-- Common options
L["Class Color Health"] = true
L["Class Color Name"] = true
L["Center Name"] = true
L["Center the unit name above the health bar."] = true
L["Show Group Indicator"] = true
L["Show the raid subgroup indicator (e.g. Group 2) above the player frame."] = true
L["Show Buffs"] = true
L["Show buff icons on the target frame."] = true
L["Show buff icons on the focus frame."] = true
L["Show Debuffs"] = true
L["Show debuff icons on the target frame."] = true
L["Show debuff icons on the focus frame."] = true
L["Use class color for health bar"] = true
L["Use class color for health bars in party frames"] = true
L["Show class icon instead of 3D portrait"] = true
L["Show class icon instead of 3D portrait (only for players)"] = true
L["Class icon instead of 3D model for players."] = true
L["Alternative Class Icons"] = true
L["Race Portrait"] = true
L["Race icon instead of 3D model for players."] = true
L["No Portrait"] = true
L["Hides the portrait: the frame closes where it was and the bars keep their place."] = true
L["No Portrait (All Frames)"] = true
L["Player, target, focus, ToT and ToF at once."] = true
L["Use DragonUI alternative class icons instead of Blizzard's class icon atlas."] = true
L["Format Large Numbers"] = true
L["Text Format"] = true

-- Text format values
L["Current Value"] = true
L["Percentage"] = true
L["Numbers + %"] = true
L["Current / Max"] = true

-- Party text format values

-- Health/Mana text
L["Always Show Health Text"] = true
L["Always Show Mana Text"] = true

-- Player frame specific
L["Player Frame"] = true
L["Dragon Decoration"] = true
L["Show PvP Icon"] = true
L["PvP Icon Style"] = true
L["Forever"] = true
L["Unit Frame Art"] = true
L["Art of the player, target, focus, ToT, ToF, pet and party frames."] = true
L["Level Style"] = true
L["Auto follows the unit frame art. Forever shows the level in a circle and moves the name to the left."] = true
L["Center Names"] = true
L["Center the player, target and focus names instead of aligning them to the left."] = true
L["Auto follows the unit frame art: the Forever badge with the Forever art, the classic icon with the DragonUI art."] = true
L["Elite Dragons"] = true
L["Elite Dragons (Target)"] = true
L["Auto follows the unit frame art. Dragons around elite and rare portraits; the player picks its own in Dragon Decoration."] = true
L["None"] = true
L["Elite (Retail)"] = true
L["RareElite (Retail)"] = true
L["Elite (Forever)"] = true
L["RareElite (Forever)"] = true
L["World Boss (Forever)"] = true
L["Glow Effects"] = true
L["Show Rest Glow"] = true
L["Golden glow around the player frame when resting (inn or city). Works with all frame modes."] = true
L["Show Combat Flash"] = true
L["Pulsing glow effect when entering combat. Works with all frame modes."] = true
L["Combat Flash Opacity"] = true
L["Maximum opacity of the combat flash pulse effect."] = true
L["Alternate Mana (Druid)"] = true
L["Always Show"] = true
L["Druid mana text visible at all times, not just on hover."] = true
L["Percentage + Current/Max"] = true

-- Fat Health Bar
L["Fat Health Bar"] = true
L["Enable"] = true
L["Full-width health bar. Auto-disabled in vehicles."] = true
L["Hide Mana Bar"] = true
L["Completely hide the mana bar when Fat Health Bar is active."] = true
L["Mana Bar Width"] = true
L["Mana Bar Height"] = true
L["Mana Bar Texture"] = true
L["Choose the texture style for the power/mana bar. Only applies in Fat Health Bar mode."] = true
L["DragonUI (Default)"] = true
L["Blizzard Classic"] = true
L["Flat Solid"] = true
L["Smooth"] = true
L["Aluminium"] = true
L["LiteStep"] = true

-- Power Bar Colors
L["Power Bar Colors"] = true
L["Mana"] = true
L["Rage"] = true
L["Energy"] = true
-- L["Focus"] = true  -- Already defined above
L["Runic Power"] = true
L["Happiness"] = true
L["Runes"] = true
L["Reset Colors to Default"] = true

-- Target frame
L["Target Frame"] = true
L["Threat Glow"] = true
L["Show Name Background"] = true
L["Show the colored name background behind the target name."] = true
L["Show Buffs"] = true
L["Show the buffs under the target frame."] = true
L["Show Debuffs"] = true
L["Show the debuffs under the target frame."] = true

-- Focus frame
L["Focus Frame"] = true
L["Show the colored name background behind the focus name."] = true
L["Show Buff/Debuff on Focus"] = true
L["Uses the native large focus frame mode to show buffs and debuffs on the focus frame."] = true
L["Override Position"] = true
L["Move the pet frame independently from the player frame."] = true

-- Pet frame
L["Pet Frame"] = true

-- Target of Target
L["Target of Target"] = true
-- Player Stats
L["Player Stats"] = true
L["Add item level, PvE/PvP power and prestige for player units."] = true
L["Follows the Target frame by default. Move it in Editor Mode (/dragonui edit) to detach and position freely."] = true
L["Detached \226\128\148 positioned freely via Editor Mode"] = true
L["Attached \226\128\148 follows Target frame"] = true
L["Re-attach to Target"] = true

-- Target of Focus
L["Target of Focus"] = true
L["Follows the Focus frame by default. Move it in Editor Mode (/dragonui edit) to detach and position freely."] = true
L["Attached \226\128\148 follows Focus frame"] = true
L["Re-attach to Focus"] = true

-- Party Frames
L["Party Frames"] = true

-- Boss Frames
L["Boss Frames"] = true
L["Enabled"] = true

L["Orientation"] = true
L["Vertical"] = true
L["Horizontal"] = true
L["Vertical Padding"] = true
L["Space between party frames in vertical mode."] = true
L["Horizontal Padding"] = true
L["Space between party frames in horizontal mode."] = true

-- ============================================================================
-- XP & REP BARS TAB
-- ============================================================================

L["Bar Style"] = true
L["XP / Rep Bar Style"] = true
L["DragonflightUI: fully custom bars with rested XP background.\nRetailUI: atlas-based reskin of Blizzard bars.\n\nChanging style requires a UI reload."] = true
L["DragonflightUI"] = true
L["RetailUI"] = true
L["XP bar style changed to "] = true
L["A UI reload is required to apply this change."] = true

-- Size & Scale
L["Size & Scale"] = true
L["Height of the XP and Reputation bars (in pixels)."] = true
L["Width of the XP and Reputation bars (in pixels)."] = true
L["Experience Bar Scale"] = true
L["Scale of the experience bar."] = true
L["Reputation Bar Scale"] = true
L["Scale of the reputation bar."] = true

-- Rested XP
L["Rested XP"] = true
L["Show Rested XP Background"] = true
L["Display a translucent bar showing the total available rested XP range.\n(DragonflightUI style only)"] = true
L["Show Exhaustion Tick"] = true
L["Show the exhaustion tick indicator on the XP bar, marking where rested XP ends."] = true

-- Text Display
L["Text Display"] = true
L["Always Show Text"] = true
L["Always display XP/Rep text instead of only on hover."] = true
L["Show XP Percentage"] = true
L["Display XP percentage alongside the value text."] = true

-- ============================================================================
-- PROFILES TAB
-- ============================================================================

L["Database not available."] = true
L["Save and switch between different configurations per character."] = true
L["Current Profile"] = true
L["Active: "] = true
L["Switch or Create Profile"] = true
L["Select Profile"] = true
L["New Profile Name"] = true
L["Default Profile"] = true
L["New characters will use this profile."] = true
L["New characters will get their own profile."] = true
L["New characters will start on profile: "] = true
L["Copy From"] = true
L["Copies all settings from the selected profile into your current one."] = true
L["Copied profile: "] = true
L["Delete Profile"] = true
L["Warning: Deleting a profile is permanent and cannot be undone."] = true
L["Delete"] = true
L["Deleted profile: "] = true
L["Are you sure you want to delete the profile '%s'? This cannot be undone."] = true
L["Profile Manager"] = true
L["Manage your current profile: reset to defaults, export/import as text, or share in-game."] = true
L["Restores the current profile to defaults."] = true
L["Export your current profile as a text string."] = true

L["Reset Profile"] = true
L["All changes will be lost and the UI will be reloaded.\nAre you sure you want to reset your profile?"] = true
L["Profile reset to defaults."] = true

-- UNIT FRAME LAYERS MODULE
L["Unit Frame Layers"] = true
L["Enable Unit Frame Layers"] = true
L["Heal prediction bars, absorb shields, and animated health loss overlays on unit frames."] = true
L["Show heal prediction, absorb shields, and animated health loss on all unit frames."] = true
L["Animated Health Loss"] = true
L["Show animated red health loss bar on player frame when taking damage."] = true
L["Missing Health Text"] = true
L["Show the health deficit (missing health) as red text on health bars. Useful for healers."] = true

-- Preset (used by minimap tab)
L["Preset"] = true
L["Save"] = true
L["Load"] = true
L["Load preset '%s'? This will overwrite your current layout settings."] = true
L["Load position preset '%s'? This will overwrite your current element positions."] = true
L["Load Preset"] = true
L["Delete preset '%s'? This cannot be undone."] = true
L["Delete position preset '%s'? This cannot be undone."] = true
L["Delete Preset"] = true
L["Duplicate Preset"] = true
L["Preset saved: "] = true
L["Preset loaded: "] = true
L["Preset deleted: "] = true
L["Preset duplicated: "] = true
L["Also delete all saved layout presets?"] = true
L["Also delete all saved position presets?"] = true
L["Presets kept."] = true
L["Position presets kept."] = true

-- PRESET IMPORT / EXPORT
L["Position Presets"] = true
L["Position Preset"] = true
L["Export Preset"] = true
L["Import Preset"] = true
L["Import a preset from a text string shared by another player."] = true
L["Export Position Preset"] = true
L["Import Position Preset"] = true
L["No position presets saved yet. Save one in Edit Mode (/dragonui edit) first."] = true
L["Position presets not available."] = true
L["Failed to export position preset."] = true
L["Invalid position preset string."] = true
L["Not a valid DragonUI position preset string."] = true
L["Import"] = true
L["Select All"] = true
L["Close"] = true

-- Fade / hover settings (actionbars, micromenu, bags)
L["Hover Fade"] = true
L["Visible Alpha"] = true
L["Opacity when a bar is considered visible by hover/combat rules."] = true
L["Hidden Alpha"] = true
L["Opacity when a bar is hidden by hover/combat rules. Set above 0 to keep bars faintly visible."] = true
L["Fade In Duration"] = true
L["Seconds used to fade bars in when they become visible."] = true
L["Fade Out Duration"] = true
L["Seconds used to fade bars out when they become hidden."] = true
L["Fade Out Delay"] = true
L["Delay before hover-out starts fading, useful to avoid flicker between buttons."] = true

-- PROFILE IMPORT/EXPORT
L["Import Profile"] = true
L["Import"] = true
L["Export Profile"] = true
L["Exporting..."] = true
L["Enter profile name"] = true
L["Sending..."] = true
L["Failed to export profile."] = true
L["Import a profile from a text string shared by another user."] = true
L["Invalid profile string."] = true
L["Not a valid DragonUI profile string."] = true
L["Profile imported: "] = true
L["Enter a name for the imported profile:"] = true
L["Imported Profile"] = true

-- Profile sharing
L["Share to:"] = true
L["Whisper"] = true
L["Party"] = true
L["Raid"] = true
L["Guild"] = true
L["Share"] = true
L["Enter a target player name for whisper."] = true
L["Profile shared with"] = true

L["This Fork is maintained by PentSec for Conquest of Azeroth, based on the original work by NeticSoul."] = true
L["Close"] = true
L["Enter a name for the imported preset:"] = true
L["Enter a name for this preset:"] = true
L["Imported Preset"] = true
L["Preset imported: "] = true
L["Invalid preset string."] = true
L["Not a valid DragonUI preset string."] = true
L["Failed to export preset."] = true

-- ============================================================================
-- NAMEPLATES
-- ============================================================================

L["Nameplates"] = true
L["Enable Nameplates Module"] = true
L["Apply DragonUI nameplate styling."] = true
L["Plate Style"] = true
L["Nameplate Art"] = true
L["Heritage is the DragonUI art. Modern draws the current World of Warcraft nameplate chrome."] = true
L["Modern"] = true
L["Heritage"] = true
L["Mouseover Highlight"] = true
L["Wash the health bar with a bright overlay while the cursor is over the nameplate."] = true
L["Target Selection Border"] = true
L["Draw the white glowing border around the current target's health bar."] = true
L["Dim Non-Target Plates"] = true
L["Lay the retail dim overlay over every nameplate that is not your target."] = true
L["Retail Threat Colors"] = true
L["Use retail's yellow and orange threat steps instead of the yellow, orange and red set."] = true
L["Unit Nameplates"] = true
L["Friendly Units"] = true
L["Enemy Units"] = true
L["Pets"] = true
L["Guardians"] = true
L["Totems"] = true
L["Offset X"] = true
L["Offset Y"] = true
L["Bar Width"] = true
L["Bar Height"] = true
L["Font Size"] = true
L["Health Text"] = true
L["What the health text shows. With both, the value comes first."] = true
L["Percent"] = true
L["Value"] = true
L["Value and Percent"] = true
L["After the name, the name is shortened so the two never overlap. With the name inside the health bar, the text always sits at the bar's right end."] = true
L["After the Name"] = true
L["Inside the Bar, Centered"] = true
L["Inside the Bar, Right"] = true
L["Inside the Bar, Value Left and Percent Right"] = true
L["Center Name"] = true
L["Center the name in the space the health text leaves free."] = true
L["Font size of the name, and of the health text when it follows the name (1-10, default 2)."] = true
L["Inset the name, level, and health text from the left and right edges of the health bar. Does not affect the elite icon."] = true
L["Show"] = true
L["Always (anyone's)"] = true
L["Follow 'Only My Debuffs'"] = true
L["Only Mine"] = true
L["Each listed spell can decide whose casts it shows, whatever 'Only My Debuffs' says."] = true
L["Click an entry to select it."] = true
L["Click to select."] = true
L["Click to select"] = true
L["Remove Spell"] = true
L["Select a spell above to choose whose casts it shows."] = true
L["Name & Health"] = true
L["Name"] = true
L["Level"] = true
L["Name Position"] = true
L["Above the Health Bar"] = true
L["Inside the Health Bar"] = true
L["Moves the name up or down while it sits inside the health bar."] = true
L["The name is inside the health bar, so the health text sits at the bar's right end, after the name."] = true
L["The Modern style draws its own bar background."] = true
L["Name Text"] = true
L["Color friendly player names by class. Needs Party Class Colors or Friendly Class Colors."] = true
L["Color enemy player names by class. Needs Enemy Player Class Colors."] = true
L["Font size of the health text inside the bar (1-10). After the name, or in the Modern style, it matches the name."] = true
L["Text Outline"] = true
L["Black outline on the name and health text."] = true
L["Gray Tapped Units"] = true
L["Grays the health bar when a unit is tapped by another player or group."] = true
L["Friendly Player Color"] = true
L["Friendly NPC Color"] = true
L["Party Class Colors"] = true
L["Use class colors for party member nameplates instead of the friendly player color."] = true
L["Friendly Class Colors"] = true
L["Class-color every friendly player, not just your group. Party and raid show automatically; others fill in when you target or mouse over them, or instantly with awesome_wotlk."] = true
L["Remember Players and NPCs"] = true
L["Remember the class, guild and title of players you have seen and the titles of NPCs you have hovered, so they show at once next time. Used only by the class color, guild and title options. When off, everything learned is forgotten at logout."] = true
L["Forget Learned Players and NPCs"] = true
L["Delete the players learned on this realm and every learned NPC title."] = true
L["Forget every player and NPC title that nameplates have learned?"] = true
L["Headline Mode"] = true
L["Enable Headline Mode"] = true
L["Hide health, power and cast bars on friendly nameplates, showing only the name."] = true
L["Name Text Color"] = true
L["Friendly Players"] = true
L["Class colors, title, guild and AFK read from the unit: party/raid show automatically; others fill in when you target or mouse over them, or instantly with awesome_wotlk."] = true
L["Party / Raid Members"] = true
L["Apply headline mode to your party and raid members."] = true
L["All Friendly Players"] = true
L["Apply headline mode to all friendly players, not just your group."] = true
L["Show Class Colors"] = true
L["Show friendly player names in their class color."] = true
L["Show Player Title"] = true
L["Show the player's title with their name (e.g. \"Arthas Jenkins\")."] = true
L["Show Guild Name"] = true
L["Show the player's guild name below their name."] = true
L["Show AFK Status"] = true
L["Show an <AFK> tag for away players."] = true
L["Friendly NPCs"] = true
L["NPC titles fill in when you target or mouse over the NPC, or instantly with awesome_wotlk."] = true
L["Headline Mode for NPCs"] = true
L["Apply headline mode to friendly NPCs."] = true
L["Show NPC Title"] = true
L["Show the NPC's title or occupation below its name (e.g. <General Supplies>)."] = true
L["Show Full Plate on Target"] = true
L["When headline mode is active, show health, power and cast bars on your current target."] = true
L["Enemy Player Class Colors"] = true
L["Use class colors for enemy player nameplates."] = true
L["Show Level Always"] = true
L["Show Level In Name When Targeted"] = true
L["Show Level on Hover"] = true
L["Name Reaction Colors"] = true
L["Tint name text with the health bar reaction color (red/yellow/green/blue)."] = true
L["Class Colors on Friendly Names"] = true
L["Class Colors on Enemy Names"] = true

L["Show Target Highlight"] = true
L["Show Target Arrows"] = true
L["Only Show Target Nameplate"] = true
L["Show only your target's hostile nameplate. In combat, also show hostile NPCs attacking you. Friendly plates are never hidden by this."] = true
L["Left/right arrows on the targeted nameplate."] = true
L["Opacity"] = true
L["Disable Non-Target Fade"] = true
L["Only Show on Target & Focus"] = true
L["Only My Debuffs"] = true
L["Only show debuffs you applied yourself."] = true
L["Debuff List Mode"] = true
L["Whitelist"] = true
L["Blacklist"] = true
L["Add Debuff by Name"] = true
L["Add Debuff by ID"] = true
L["Export/Import Spell IDs"] = true
L["Enter a spell ID"] = true
L["Enter a spell name"] = true
L["Paste spell IDs separated by commas."] = true
L["Invalid spell name or ID"] = true
L["Click an entry to remove it."] = true
L["Click to remove."] = true
L["Spell filter list is empty."] = true
L["Spell ID: %d"] = true
L["Unknown"] = true
L["Power Bar"] = true
L["Debuffs"] = true
L["Auras"] = true
L["Max Aura Icons"] = true
L["Always Show Others' Crowd Control"] = true
L["Enemy Buffs"] = true
L["Show Enemy Buffs"] = true
L["Which Buffs"] = true
L["Purgeable & Defensive"] = true
L["Time Remaining"] = true
L["Colored Aura Borders"] = true
L["Friendly Plates"] = true
L["Show Auras on Allies"] = true
L["Show All Debuffs"] = true
L["Stuns, fears and polymorphs on an ally, listed or not."] = true
L["Every debuff, not just crowd control. Useful for spotting what to dispel."] = true
L["Always Show Defensive Cooldowns"] = true
L["Uses the defensive buff list from the Enemy Buffs section."] = true
L["Importance: crowd control first, then enemy defensives, then your own debuffs."] = true
L["Time Remaining: whatever expires soonest goes first."] = true
L["Highlighted auras draw larger than the rest."] = true
L["Always Highlight These Spells"] = true
L["Blizzard's dispel colors, editable below."] = true
L["Debuff List"] = true
L["Buff List"] = true
L["Shows buffs you can dispel or steal, plus the defensive cooldowns listed here."] = true
L["Stuns, fears, roots and polymorphs are detected automatically. Add anything the game does not flag."] = true
L["Icon Order"] = true
L["Order Icons By"] = true
L["Importance"] = true
L["Defensive Buff List"] = true
L["Always Show Crowd Control"] = true
L["Highlighted Auras"] = true
L["What Gets Highlighted"] = true
L["Crowd Control + List"] = true
L["Spell List Only"] = true
L["Nothing"] = true
L["Highlight Size"] = true
L["Multiplier over the base icon size."] = true
L["Magic"] = true
L["Curse"] = true
L["Disease"] = true
L["Poison"] = true
L["Enrage"] = true
L["No Dispel Type"] = true
L["Separate Color for Crowd Control"] = true
L["Aura Row"] = true
L["Show Auras"] = true
L["Show buffs and debuffs above nameplates."] = true
L["Buffs and debuffs share these slots."] = true
L["Aura Icon Size"] = true
L["Aura Horizontal Offset"] = true
L["Aura Vertical Offset"] = true
L["Timers"] = true
L["Show Cooldown Text"] = true
L["Time left on each icon."] = true
L["Cooldown Font Size"] = true
L["Cooldown Text Position"] = true
L["Show Cooldown Swipe"] = true
L["Radial sweep over the icon as it runs out."] = true
L["Cooldown Swipe Style"] = true
L["Border Colors"] = true
L["Crowd Control"] = true
L["Hide auras on every nameplate except your target and focus."] = true
L["Enemy crowd control matters no matter who cast it."] = true
L["Buffs share the row with debuffs, ordered by priority."] = true
L["Show Threat Glow"] = true
L["Show Power Bar"] = true
L["Show Power Bar Text"] = true
L["Show numeric values (current / percent) on the power bar."] = true
L["Show Cast Bars"] = true
L["Show Spell Name"] = true
L["Show the spell name text on the cast bar."] = true
L["Spell Name Font Size"] = true
L["Spell Name Offset X"] = true
L["Spell Name Offset Y"] = true
L["Cast Bar Height"] = true
L["Bar Stack Gap"] = true
L["Vertical spacing between health, power, and cast bars (pixels)."] = true
L["Show Party/Raid Cast Bars"] = true
L["Hide Pet Casts"] = true
L["Hide Pet Casts Desc"] = "Hide cast bars on player pets and guardians (Water Elemental, mirror images, etc.)."
L["Show cast bars when the unit is known for sure: your target, focus, mouseover, arena enemies, or a group member's target."] = true
L["Also show cast bars on party and raid allies, even when you are not targeting them."] = true
L["Off-Target Cast Bars"] = true
L["Enable Off-Target Detection"] = "Enable safe off-target detection"
L["Enable Off-Target Detection Desc"] = "Show cast bars on units you are not targeting, after you have used target, focus, or mouseover on them."
L["Off-Target Aggressive Mode"] = "Aggressive mode"
L["Off-Target Aggressive Mode Desc"] = "Show off-target casts without needing target, focus, or mouseover first."
L["Off-Target Players Only"] = "Players only"
L["Off-Target Players Only Desc"] = "Aggressive mode for players only. World mobs stay on safe mode."
L["Off-Target Aggressive Warning"] = "|cffffffffWarning:|r\n- If a cast is cancelled by moving or jumping (fake cast), the bar still runs to the end.\n- Same-name mobs may show the bar on the wrong nameplate."
L["Off-Target Players Only Warning"] = "|cffffffffWarning:|r\n- If a cast is cancelled by moving or jumping (fake cast), the bar still runs to the end."
L["Off-Target Aggressive Ignored"] = "Not used with awesome_wotlk or with a client that shows cast bars on every nameplate. Those already know who is casting, so safe mode is used instead."
L["Icons"] = true
L["Quest"] = true
L["Show Raid Markers"] = true
L["Show raid target markers (skull, cross, star, etc.) on nameplates."] = true
L["Beside Bar Layout"] = true
L["Place the raid marker beside the bar (as with DragonUI debuffs). Useful with other aura addons."] = true
L["Color Health Bar by Raid Marker"] = true
L["Colors the health bar with the raid marker's color, on both allies and enemies."] = true
L["Show Elite Icon"] = true
L["Show elite/rare dragon icon on nameplates."] = true
L["Elite Icon Style"] = true
L["Choose dragon or star style for elite and rare nameplate icons."] = true
L["Dragon"] = true
L["Star"] = true
L["Show Combo Points"] = true
L["Show combo points on the current target nameplate."] = true
L["Combo Points"] = true
L["Anchor Position"] = true
L["Choose where the combo widget is anchored on the target nameplate health bar."] = true
L["Scale of the combo widget (0.5 - 2.0)."] = true
L["Horizontal offset from the chosen anchor point. Negative moves left, positive moves right."] = true
L["Vertical offset from the chosen anchor point. Negative moves down, positive moves up."] = true
L["Combos Per Row"] = true
L["Maximum combo segments per row on custom-class resources (Reaper, Demonhunter, Ranger, ...). Rogue and Druid use a single combined icon and are not affected. Wrap to a second row when exceeded."] = true
L["Quest Icons"] = true
L["Show Quest Icons"] = true
L["Show kill/loot icons over your quest-objective mobs. Without awesome_wotlk, only your target, mouseover and focus show them."] = true
L["Resolve By Name"] = true
L["Match plate names to your active objectives so icons show on every plate without awesome_wotlk. Kill objectives work on their own; loot needs a quest addon below."] = true
L["Loot Database"] = true
L["Which quest addon supplies loot data (which mob drops a quest item). Auto picks the best loaded one."] = true
L["Auto"] = true
L["Icons With Questie"] = true
L["Who draws quest icons on plates when Questie is loaded with its own nameplate icons on. DragonUI disables Questie's (needs reload); Questie hides DragonUI's."] = true
L["Ask"] = true
L["Pointer Mode"] = true
L["Show a single quest marker on any objective mob instead of separate kill/loot icons."] = true
L["Reset Learned Quest Loot"] = true
L["Forget which mobs nameplates learned drop your quest items. They are learned again as you play."] = true
L["Forget every quest item source that nameplates have learned?"] = true
L["Kill Icon"] = true
L["Choose the icon shown for kill objectives."] = true
L["Sword"] = true
L["Skull"] = true
L["Elite"] = true
L["Elite Kill Icon"] = true
L["Show a distinct icon on elite and rare kill objectives."] = true
L["Loot Icon"] = true
L["Choose the icon shown for loot/collect objectives."] = true
L["Bag"] = true
L["Chest"] = true
L["Pointer"] = true
L["Pointer Icon"] = true
L["Off"] = true
L["Size"] = true
L["Icon"] = true
L["Test Preview"] = true
L["Preview Icon"] = true
L["Force one icon on all enemy nameplates so you can position and size it. Set to Off when done."] = true
L["Show Totem Icons"] = true
L["Totem Icon Only"] = true
L["Hide the totem's nameplate entirely and show only its icon."] = true
L["Show Totem Life Timer"] = true
L["Show remaining life on your own totems (requires their icon to be known)."] = true
L["Totems Without Icon"] = true
L["Comma-separated, exact totem names (as shown in-game) that should never get a totem icon and render as a normal nameplate instead."] = true
L["Totem Icon Position"] = true
L["Choose where the totem icon is anchored around the nameplate."] = true

-- New / reorganized sections (nameplates tab UX refresh)
L["Size & Position"] = true
L["Health Bar"] = true
L["Health Bar Background"] = true
L["Choose the background texture used behind the health bar fill."] = true
L["Power Bar Background"] = true
L["Choose the background texture used behind the power bar fill."] = true
L["Black"] = true
L["Same as Castbar"] = true
L["Elite Icon Vertical Offset"] = true
L["Fine-tune the elite/rare icon's vertical position."] = true
L["Target & Threat"] = true
L["Icons & Markers"] = true
L["Power Bar \226\128\148 Players Only"] = true
L["Always show the unit level next to the name."] = true
L["White border glow on the current target nameplate."] = true
L["Tank Mode"] = true
L["Inverts threat colors for a tank: green means you hold aggro, red means you lost it."] = true
L["DPS Mode"] = true
L["In combat, colors by threat for DPS: green = no aggro, yellow = transition, red = you have aggro."] = true
L["Keep all nameplates fully opaque when you have a target."] = true

L["Behavior"] = true
L["Retail-like Stacking"] = true
L["Simulates Retail's nameplate stacking for enemies."] = true
L["May increase CPU use with many visible nameplates."] = true
L["Depth Ordering"] = true
L["Order overlapping nameplates by depth."] = true
L["(Requires Allow Nameplate Overlap.)"] = true
L["Collider Width"] = true
L["Collider Height"] = true
L["Sets the width of the virtual collider centered on each nameplate used to detect overlaps."] = true
L["Sets the height of the virtual collider centered on each nameplate used to detect overlaps."] = true
L["Vertical Offset"] = true
L["Vertical offset baseline for Retail-like stacking."] = true
L["Freeze Mouseover"] = true
L["Keeps the hovered nameplate fixed while stacking updates around it."] = true
L["Disable in Open World"] = true
L["BG Healer Icon"] = true
L["BattleGroundHealers Compatibility"] = true
L["Keep BG healer marks attached to DragonUI nameplates."] = true
L["Override BattleGroundHealers icon position on DragonUI nameplates."] = true
L["This feature is available only when BattleGroundHealers is loaded."] = true
L["Enable Test Mode"] = true
L["Enable manual marking for BattleGroundHealers compatibility checks."] = true
L["Mark Target"] = true
L["Toggle BattleGroundHealers mark on your current target while test mode is enabled."] = true
L["Allow Nameplate Overlap"] = true
L["Addon Compatibility"] = true
L["Enable this if you use an external nameplate addon (PlateBuffs, Crosshairs, ...) that isn't detecting DragonUI's nameplates correctly."] = true
L["Nameplate Addon Compatibility"] = true
L["Stops overriding the nameplate's native transparency/visibility, which some external addons rely on to find their target. Non-target nameplates will dim like vanilla."] = true
L["Enable this if you use an addon (Icicle, ...) that attaches its own widgets to DragonUI's nameplate health bar."] = true
L["Nameplate Health Bar Compatibility"] = true
L["Hides the native health bar by fading its individual textures instead of the whole bar, for addons that attach widgets directly to it."] = true

L["Totem Click Padding"] = true
L["Extra clickable padding on totem nameplates (easier to click)."] = true
L["Clamp Target to Screen"] = true
L["Keep the target nameplate visible at the top of the screen. Extends WorldFrame height when enabled."] = "Keep the target nameplate visible on screen."
L["Clamp Bosses to Screen"] = true
L["Clamp Top Inset"] = true
L["Distance below the top edge where clamped nameplates stop."] = true
L["Bars"] = true
L["Clickbox"] = true
L["Clickbox Width Factor"] = true
L["Clickbox Height Factor"] = true
L["Show Clickbox"] = true
L["Displays the box selection space (clickbox) of nameplates."] = true


-- Nameplates: production-complete descriptions
L["Allow native nameplates to overlap. Retail-like Stacking enables this automatically because its custom stacking algorithm requires overlap."] = true
L["Color the glow and health bar by threat status (red = tanking, orange = losing, yellow = gaining)."] = true
L["Color the glow and health bar by threat status (orange = tanking, yellow = gaining or losing)."] = true
L["Keep hostile boss and world-boss nameplates visible at the top of the screen wherever they appear."] = true
L["Only apply Retail-like stacking inside party and raid instances. It remains disabled in the open world, battlegrounds, and arenas."] = true
L["Scales the nameplate clickbox relative to its original size. Changes made during combat are applied when combat ends."] = true
L["Show icons for recognized shaman totems. DragonUI uses localized spell names and automatically learns your own active totems."] = true

-- Version Check
L["Version Check"] = true
L["Broadcast and detect addon version updates across group members."] = true

-- Search

L["Search settings..."] = true
L["Type to find a setting"] = true
L["No settings match '%s'."] = true
L["Showing top %d results. Type at least 3 characters for the full list."] = true

-- Transmog Collector
L["Transmog Collector"] = true
L["Enable Transmog Collector"] = true
L["Automatically collect transmog appearances when looting new items. Works with Conquest of Azeroth's Ctrl+Alt+Click appearance system."] = true
L["On loot, auto-collects appearances for items you haven't learned yet."] = true

L["Shows swing timers for your main hand, off hand, ranged attacks, and enemy target melee swings."] = true
L["Show swing timer bars for melee and ranged attacks."] = true
L["Show the main hand melee swing timer."] = true
L["Show the off hand melee swing timer (dual-wield)."] = true
L["Show the ranged attack timer (Hunter shots, Throw, Aimed Shot)."] = true
L["Show the enemy target melee swing timer."] = true
L["Show the countdown timer text on bars."] = true
L["Show spell name, damage range, and time remaining text."] = true
L["Choose the border style for the swing timer bars."] = true
L["Standard"] = true
L["Thin"] = true
L["Scale of the swing timer bars."] = true

L["Swing Timer Module"] = true
L["Shows main hand, off hand, ranged, and enemy target swing timers."] = true
L["An ally carries dozens of auras, so you pick below what earns a slot."] = true
L["Debuffs on the Ally"] = true
L["Buffs the Ally Carries"] = true
L["Also Show These Spells"] = true
L["Listed spells always show, buff or debuff, on top of everything above."] = true

-- ============================================================================
-- PANELS TAB / GEAR SUMMARY
-- ============================================================================

L["Panels"] = true
L["Character"] = true
L["Stats Sidebar"] = true
L["The headline numbers above the stat categories."] = true
L["Show Item Level"] = true
L["Show the average item level of your equipped gear."] = true
L["Show GearScore"] = true
L["Show the GearScore of your equipped gear."] = true
L["Set which stat and which combat panel lead the list:"] = true
L["Highlight Main Stat"] = true
L["The attribute your class is built around."] = true
L["Auto (by class)"] = true
L["Combat Statistics"] = true
L["Which one leads the list: Melee, Ranged, or Spell."] = true
L["Equipment Sets"] = true
L["Equip a set automatically when you switch talent specialization. Saved per character."] = true
L["Opens the window without the micro menu."] = true
L["Toggle Pets & Mounts"] = true
L["Click, then press the key to bind. Press Escape to clear it."] = true
L["Key bindings cannot be changed in combat."] = true
L["Hide Model Controls"] = true
L["Hide the rotate, zoom and reset buttons over the character model."] = true
L["Keep the Reset Button"] = true
L["Leave the reset button on its own while the rest of the model controls stay hidden."] = true

-- World Map
L["World Map"] = true
L["Retail-style world map with breadcrumb navigation and a quest log side panel."] = true
L["Retail-styled world map with breadcrumb navigation, drag-to-resize and quest log side panel. Requires a full /reload after toggling."] = true
L["Enable World Map"] = true
L["Activates the modern world map frame. Requires /reload to take effect."] = true
L["Enable Fog Reveal"] = true
L["Draw grey tint over undiscovered zones using account-wide exploration data. Each alt sees your main's exploration immediately."] = true
L["Enable Wheel Zoom"] = true
L["Mouse wheel zooms and pans the map canvas."] = true
L["Apply the DragonUI reskin to the world map."] = true
L["Show Undiscovered Areas"] = true
L["Draw the map art of areas you have not explored yet, dimmed."] = true
L["Show Landmarks"] = true
L["Show Map Coordinates"] = true
L["Show your coordinates and the cursor's in the corner of the map."] = true
L["Show Zone Levels"] = true
L["Show the recommended level range next to zone names and instance pins."] = true
L["Fade Map While Moving"] = true
L["Dim the map while you move, unless the cursor is over it."] = true
L["Group Member Pins"] = true
L["How party and raid members show on the world map and the battlefield map. Class colors and class icons also color their names in the tooltip and add their health."] = true
L["Class Colors"] = true
L["Class Icons"] = true
L["Moving Map Alpha"] = true
L["How visible the map stays while you move."] = true
L["Show towns, flight points and other landmark pins on the map."] = true
L["Show Dungeon Entrances"] = true
L["Show dungeon and raid entrance pins on zone maps."] = true
L["Show Graveyards"] = true
L["Show graveyard pins on zone maps."] = true
L["Show Flight Points"] = true
L["Show flight master pins on zone maps."] = true
L["Show Inns"] = true
L["Show innkeeper pins on zone maps, marking the inn your hearthstone is set to."] = true

-- ============================================================================
-- LOW HP ALERT MODULE (added by DragonUI)
-- ============================================================================

L["Low HP Alert"] = true
L["Plays a sound and flashes the screen edges when your HP drops below the configured threshold."] = true
L["Enable Low HP Alert"] = true
L["Warning Sound (every 3 sec)"] = true
L["Plays a warning sound every 3 seconds while HP is below threshold."] = true
L["Screen Edge Flash"] = true
L["Flashes red at the edges of the screen while HP is below threshold."] = true
L["Flash Color"] = true
L["Use Class Color"] = true
L["Use your class color (e.g. orange for Druid, yellow for Rogue) instead of the custom color."] = true
L["Flash Opacity"] = true
L["Maximum opacity of the flash effect."] = true
L["Flash Extent"] = true
L["How far the flash extends from the screen edges toward the center, in pixels."] = true
L["HP Warning Threshold"] = true
L["Percentage of HP at which the warning triggers."] = true
L["Test Warning (3 sec)"] = true
L["Triggers a 3-second preview of the warning state to help you adjust the threshold."] = true
L["Personal Resource Display"] = true
L["Add Health and Resource below your Character."] = true
L["Swing Timer"] = true
L["Show a bar with the time left until each weapon's next swing."] = true
L["Level Up Enhance"] = true
L["Animated level-up banner that lists what each new level unlocks: abilities, features, dungeons, raids and battlegrounds."] = true
L["Enable Level-Up Banner"] = true
L["Size of the banner and its list."] = true
L["Show Unlocks"] = true
L["Show what the new level unlocks, such as new abilities, features and dungeons."] = true
L["Unlock Style"] = true
L["One at a Time"] = true
L["List"] = true
L["One at a time shows each unlock inside the banner in turn, as retail does. List shows them all together under the banner."] = true
L["Open the List Automatically"] = true
L["Open the list as soon as the banner appears. Otherwise, click the dot under the banner."] = true
L["Unlocks in Chat"] = true
L["Print the unlocks after the level-up message in chat."] = true
L["Pet Level-Up Banner"] = true
L["Show a banner when your hunter pet reaches a new level."] = true
L["Test Banner"] = true
L["Show the banner for your next level (or /lvltest <level>)."] = true
L["Show Bar Title"] = true
L["Show Time"] = true

-- Talents
L["Talents"] = true
L["Retail-style talent window"] = true
L["Enable Talent Window"] = true
L["Replace Blizzard's talent and glyph window."] = true
L["Size of the talent window on top of your UI scale; 1.0 matches the other panels. It never grows past the screen."] = true
L["Show Glyph Names"] = true
L["Name each inscribed glyph beside its socket."] = true
L["Show Glyph Effects"] = true
L["List what your inscribed glyphs do beside the sockets."] = true

-- ============================================================================
-- SPELLBOOK MODULE
-- ============================================================================
L["Spellbook"] = true
L["Scale the spellbook window."] = true
L["Enable Spellbook"] = true
L["Enable the DragonUI spellbook module."] = true
L["Spellbook Content Scale"] = true
L["Scales the pages, cards and controls inside the spellbook; its frame keeps its size."] = true
L["Show Lower Rank Selector"] = true
L["Spell cards with lower ranks offer them through the selector chosen below."] = true
L["Lower rank selector"] = true
L["How a spell card offers its lower ranks: a menu under the icon or a side flyout."] = true
L["Menu under the icon"] = true
L["Side flyout"] = true

-- ============================================================================
-- PROFESSIONS
-- ============================================================================
L["Professions"] = true
L["Forever-style professions window with side tabs and an overview page."] = true
L["Enable Professions"] = true
L["Use the Forever professions window instead of the stock one."] = true
L["Professions Window Scale"] = true
L["Scales the whole professions window; the room it takes beside other panels follows its size."] = true
L["Side Tabs Scale"] = true
L["Scales only the profession tabs beside the window, on top of the window scale."] = true
L["Professions Micro Button"] = true
L["Show the Professions button in the micro menu. It opens the professions overview."] = true

-- ============================================================================
-- Layout Presets & remaining option strings (default locale)
-- ============================================================================
L["Layout Presets"] = true
L["Save and restore complete UI layouts. Each preset captures all positions, scales, and settings."] = true
L["Save New Preset"] = true
L["Save your current UI layout as a new preset."] = true
L["No presets saved yet."] = true
L["Scale"] = true
L["Border Style"] = true
L["Display"] = true
L["Bar Visibility"] = true
L["Combo Points"] = true
L["Combo points as orbs under the player frame and/or on the target frame."] = true
L["Location"] = true
L["Auto follows the unit frame art: under the player with the DragonUI art, on the target with the Forever art."] = true
L["Player + Target"] = true
L["Orb Style"] = true
L["Auto follows the unit frame art. Forever uses its bronze orbs for rogues and druids alike."] = true
L["Hide When Empty"] = true
L["Hide the orbs at 0 points instead of showing them empty."] = true

-- Auto-Accept
L["Auto-Accept"] = true
L["Party invites from the players you pick below are accepted for you; anyone else is left for you to answer."] = true
L["Accept Invites from Friends"] = true
L["Automatically accept party invites from players on your friends list."] = true
L["Accept Invites from Guild Members"] = true
L["Automatically accept party invites from members of your guild."] = true
L["Camera"] = true
L["Max Camera Distance"] = true
L["Let the camera zoom out further than the game's own slider allows."] = true
L["Camera Distance"] = true
L["Error Messages"] = true
L["The red errors in the middle of the screen. Yellow quest updates always show."] = true

-- ============================================================================
-- MISSING STRINGS SYNCED FROM enUS
-- ============================================================================

L["Choose how DragonUI and SexyMap share the minimap."] = true
L["Hybrid"] = true
L["Minimap Mode"] = true
L["SexyMap"] = true
L["SexyMap Compatibility"] = true
L["SexyMap visuals with DragonUI editor and positioning."] = true
L["Uses DragonUI for the minimap."] = true
L["Uses SexyMap for the minimap."] = true

-- Feisheng integration
L["Exit Editor Mode"] = true
L["KeyBind Mode Active"] = true
L["Move UI Elements"] = true
L["Created and maintained by Neticsoul, with community contributions."] = true
L["Kook (select and Ctrl+C to copy):"] = true
L["Module Control"] = true
L["Enable or disable specific DragonUI modules"] = true
L["Visual enhancements that add Dragonflight-style polish to the UI."] = true
L["Warning: These are individual module controls. The options above may control multiple modules at once. Changes here will be reflected above and vice versa."] = true
L["Other Modules"] = true
L["Custom player, target, and focus cast bars"] = true
L["Cooldown text on action buttons"] = true
L["Shaman totem bar positioning and styling"] = true
L["Dragonflight-styled player unit frame"] = true
L["Dragonflight-styled boss target frames"] = true
L["Delete Confirm"] = true
L["Show your class icon in the portrait instead of your character's face."] = true
L["Enable DragonUI player castbar. When disabled, shows default Blizzard castbar."] = true
L["Enable DragonUI target castbar. When disabled, shows default Blizzard castbar."] = true
L["Enable DragonUI focus castbar. When disabled, shows default Blizzard castbar."] = true
L["Enable the complete DragonUI action bars system. This controls: Main action bars, vehicle interface, stance/shapeshift bars, pet action bars, multicast bars (totems/possess), button styling, and hide Blizzard elements. When disabled, all action bar related features will use default Blizzard interface."] = true
L["Apply DragonUI micro menu and bags system styling and positioning. Includes character button, spellbook, talents, etc. and bag management. When disabled, these elements will use default Blizzard positioning and styling."] = true
L["Show cooldown timers on action buttons. When disabled, cooldown timers will be hidden and the system will be completely deactivated."] = true
L["Enable DragonUI minimap enhancements including custom styling, positioning, tracking icons, and calendar. When disabled, uses default Blizzard minimap appearance and positioning."] = true
L["Enable DragonUI buff frame with custom styling, positioning, and toggle button functionality. When disabled, uses default Blizzard buff frame appearance and positioning."] = true
L["Auto-fill the DELETE confirmation text for good (bind-on-pickup) items."] = true
L["Vanity buffs are cosmetic auras consolidated by Ascension (mounts, toys, transmog effects). The consolidated container is provided by the Ascension_VanityCollection addon."] = true
L["Hide the Ascension vanity-buff consolidated container and its contained auras from the buff frame. Existing buff order and positioning are preserved."] = true
L["Size of debuff icons on nameplates."] = true
L["Show Debuff Cooldown Text"] = true
L["Show remaining debuff time on each debuff icon."] = true
L["Show Debuff Cooldown Swipe"] = true
L["Also show a radial cooldown sweep on each debuff icon."] = true
L["Debuff Horizontal Offset"] = true
L["Shifts the debuff icon row left or right relative to its default position."] = true
L["Debuff Vertical Offset"] = true
L["Shifts the debuff icon row up or down relative to its default position."] = true
L["Debuff Cooldown Swipe Style"] = true
L["Choose the visual style of the cooldown sweep. These texture-based styles stay aligned while the nameplate is moving."] = true
L["Debuff Cooldown Font Size"] = true
L["Font size for debuff remaining time text."] = true
L["Debuff Cooldown Text Position"] = true
L["Choose where the debuff cooldown text is anchored on the icon."] = true
L["Toggle keybinding mode. Hover over action buttons and press keys to bind them instantly. Press ESC to clear bindings."] = true
L["Dark Mode Intensity"] = true
L["Apply darker tinted textures to all UI chrome: action bars, unit frames, minimap, bags, micro menu, and more."] = true
L["Tint action button icons when target is out of range (red), not enough mana (blue), or unusable (gray)."] = true
L["Show colored glow borders on action buttons containing items, colored by item quality (green = uncommon, blue = rare, purple = epic, etc.)."] = true
L["Only show colored borders for items at or above this quality level."] = true
L["Add a 'Targeting: <name>' line to the tooltip showing who the unit is targeting."] = true
L["Restyle the tooltip health bar with class/reaction colors."] = true
L["Show the caster's name (class-colored) and spell ID on buff and debuff tooltips."] = true
L["Opacity of tabs, buttons and chat background when not hovered. 0 = hidden, 1 = always visible."] = true
L["Bagster Settings"] = true
L["Sort bags and bank items with buttons"] = true
L["Automatically sell all gray (poor) items when you open a merchant. Hold Shift while opening the merchant to skip."] = true
L["Show Consumable Tab"] = true
L["Show the Consumable category tab."] = true
L["Changes require closing and reopening bags to take effect."] = true
L["Category Tabs"] = true
L["Choose which category tabs appear on the bag frame. Changes require closing and reopening bags to take effect."] = true
L["Hide Blizzard"] = true
L["Tooltip"] = true
L["Micro menu and bags system styling and positioning"] = true
L["Quest tracker positioning and styling"] = true
L["Enhanced tooltip styling with class colors and health bars"] = true
L["Hide default Blizzard UI elements"] = true
L["Custom minimap styling, positioning, tracking icons and calendar"] = true
L["Main action bars, status bars, scaling and positioning"] = true
L["LibKeyBound integration for intuitive keybinding"] = true
L["Color item borders by quality in bags, character panel, bank, and merchant"] = true
L["Darken UI borders and chrome"] = true
L["Action button styling and enhancements"] = true
L["Vehicle interface enhancements"] = true
L["Stance/shapeshift bar positioning and styling"] = true
L["Pet action bar positioning and styling"] = true
L["Multicast (totem/possess) bar positioning and styling"] = true
L["KK_Chat Features"] = true
L["Enable Timestamp"] = true
L["Show message timestamps in chat."] = true
L["Timestamp Seconds"] = true
L["Show seconds in timestamps (e.g. 12:30:45 instead of 12:30)."] = true
L["Enable Emotion Icons"] = true
L["Enable emotion/emoji icons in chat."] = true
L["Use English Emotion Tags"] = true
L["Send emotion tags in English (e.g. {smile} instead of {微笑}) so players without the addon or on an English client can read them."] = true
L["Enable Tab Channel Switch"] = true
L["Use Tab key to cycle through chat channels."] = true
L["Enable Channel Button Bar"] = true
L["Show a floating channel switching button bar above the chat editbox."] = true
L["Allow Moving Button Bar"] = true
L["Allow dragging the channel button bar to reposition it."] = true
L["Chat enhancements: hide buttons, editbox position, URL copy, chat copy, link hover, tell target"] = true
L["All-in-one bag replacement with filtering and search"] = true
L["Scale for main action bar"] = true
L["Scale for right action bar (MultiBarRight)"] = true
L["Scale for left action bar (MultiBarLeft)"] = true
L["Scale for bottom left action bar (MultiBarBottomLeft)"] = true
L["Scale for bottom right action bar (MultiBarBottomRight)"] = true
L["Reset all action bar scales to their default values (0.9)"] = true
L["All action bar scales reset to default values (0.9)"] = true
L["Tip: Use the Move UI Elements button above to reposition action bars with your mouse."] = true
L["Hide Main Bar Background"] = true
L["Hide the background texture of the main action bar (makes it completely transparent)"] = true
L["Hide the background texture of the main action bar."] = true
L["Count Text"] = true
L["Show Count"] = true
L["Hotkey Text"] = true
L["Show Hotkey"] = true
L["Show small range indicator point on buttons"] = true
L["Macro Text"] = true
L["Page Numbers"] = true
L["Show Pages"] = true
L["Minimum duration for text triggering"] = true
L["Text Color"] = true
L["Color for macro text"] = true
L["Shadow color for hotkey text"] = true
L["Border color for buttons"] = true
L["Gryphon Style"] = true
L["Display style for the action bar end-cap gryphons."] = true
L["Gryphon previews are hidden while D3D9Ex is active to avoid client crashes."] = true
L["Old"] = true
L["New"] = true
L["Hide Gryphons"] = true
L["Specialized bars that appear when needed (stance/pet/vehicle/totems)"] = true
L["Auto-show bars: Stance (Warriors/Druids/DKs) \226\128\162 Pet (Hunters/Warlocks/DKs) \226\128\162 Vehicle (All classes) \226\128\162 Totem (Shamans)"] = true
L["Common Settings"] = true
L["Size of buttons for all additional bars"] = true
L["Space between buttons for all additional bars"] = true
L["Y Offset"] = true
L["Display empty action slots on pet bar"] = true
L["All classes (vehicles/special mounts)"] = true
L["Custom Art Style"] = true
L["Use custom vehicle bar art style with health/power bars and themed skin. Requires UI reload to apply."] = true
L["Totem Bar"] = true
L["Width of the cast bar"] = true
L["Height of the cast bar"] = true
L["Show the spell icon next to the cast bar"] = true
L["Show Spell Icon"] = true
L["Show the spell icon next to the target castbar"] = true
L["Size of the spell icon"] = true
L["Choose how to display spell text: Simple (centered spell name only) or Detailed (spell name + time)"] = true
L["Simple (Centered Name Only)"] = true
L["Simple"] = true
L["How long the bar stays visible after a successful cast."] = true
L["How long to show the castbar after successful completion"] = true
L["How long the bar stays visible after being interrupted."] = true
L["How long to show the castbar after interruption/failure"] = true
L["Auto-Adjust for Auras"] = true
L["Automatically adjust position based on target auras (CRITICAL FEATURE)"] = true
L["Shift castbar when buff/debuff rows are showing."] = true
L["Automatically adjust position based on focus auras"] = true
L["Resets the X and Y position to default."] = true
L["Reset target castbar position to default"] = true
L["Reset focus castbar position to default"] = true
L["Target castbar position reset."] = true
L["Focus castbar position reset."] = true
L["Width of the target castbar"] = true
L["Height of the target castbar"] = true
L["Scale of the target castbar"] = true
L["Width of the focus castbar"] = true
L["Height of the focus castbar"] = true
L["Scale of the focus castbar"] = true
L["Show the spell icon next to the focus castbar"] = true
L["Time to show the castbar after successful cast completion"] = true
L["Time to show the castbar after cast interruption"] = true
L["Gray Scale Icons"] = true
L["Use grayscale icons instead of colored icons for the micro menu"] = true
L["Grayscale Icons Settings"] = true
L["Normal Icons Settings"] = true
L["Hide micromenu and bags if you sit on vehicle"] = true
L["Show a colored bar below the Help button indicating connection quality (green/yellow/red). Requires UI reload."] = true
L["Configure the position and scale of the bag bar independently from the micro menu."] = true
L["Collector"] = true
L["Apply DragonUI border styling to addon icons (e.g., bag addons)"] = true
L["Size of the player arrow on the minimap"] = true
L["Use new DragonUI object icons on the minimap. When disabled, uses classic Blizzard icons."] = true
L["Animated Border"] = true
L["Enable Animated Border"] = true
L["Show/hide the minimap clock"] = true
L["Show/hide the calendar frame"] = true
L["Font size for the clock numbers on the minimap"] = true
L["Zone Text Size"] = true
L["Zone text font size on top border"] = true
L["Reset minimap to default position (top-right corner)"] = true
L["Reset Minimap Position"] = true
L["Minimap position reset to default"] = true
L["Minimap position reset."] = true
L["Configures the quest objective tracker position and behavior."] = true
L["Anchor Point"] = true
L["Screen anchor point for the quest tracker."] = true
L["Horizontal position offset"] = true
L["Vertical position offset"] = true
L["Reset quest tracker to default position"] = true
L["Global Scale"] = true
L["Global scale for all unit frames"] = true
L["Scale of the player frame"] = true
L["Scale of the target frame"] = true
L["Scale of the focus frame"] = true
L["Scale of the pet frame"] = true
L["Scale of the target of target frame"] = true
L["Scale of the focus of target frame"] = true
L["Scale of party frames"] = true
L["Class Color"] = true
L["Large Numbers"] = true
L["Format large numbers (1k, 1m)"] = true
L["How to display health and mana values"] = true
L["Choose how to display health and mana text"] = true
L["Current Value Only"] = true
L["Percentage Only"] = true
L["Both (Numbers + Percentage)"] = true
L["Current/Max Values"] = true
L["Current Value Only (2345)"] = true
L["Formatted Current (2.3k)"] = true
L["Percentage Only (75%)"] = true
L["Percentage + Current (75% | 2.3k)"] = true
L["Show health text always (true) or only on hover (false)"] = true
L["Always show health text on party frames (instead of only on hover)"] = true
L["Always display health text (otherwise only on mouseover)"] = true
L["Show mana/power text always (true) or only on hover (false)"] = true
L["Always show mana text on party frames (instead of only on hover)"] = true
L["Always display mana/energy/rage text (otherwise only on mouseover)"] = true
L["Add decorative dragon to your player frame for a premium look"] = true
L["Elite Dragon (Golden)"] = true
L["Elite (Golden)"] = true
L["RareElite Dragon (Winged)"] = true
L["RareElite (Winged)"] = true
L["Show a golden glow around the player frame when resting (in an inn or city). Works with all frame modes: normal, elite, fat health bar, and vehicle."] = true
L["Combat Flash"] = true
L["Always Show Alternate Mana Text"] = true
L["Show mana text always visible (default: hover only)"] = true
L["Alternate Mana Text Format"] = true
L["Choose text format for alternate mana display"] = true
L["Health Bar Style"] = true
L["Full-width health bar that fills the entire frame area. Uses modified border texture that removes the inner divider line. Compatible with Dragon Decoration (requires fat variant textures). Note: Automatically disabled during vehicle UI."] = true
L["Hide Mana Bar (Fat Mode)"] = true
L["Mana Bar Width (Fat Mode)"] = true
L["Width of the mana bar when Fat Health Bar is active. Movable via Editor Mode."] = true
L["Mana Bar Height (Fat Mode)"] = true
L["Height of the mana bar when Fat Health Bar is active."] = true
L["Show threat glow effect"] = true
L["Override default positioning"] = true
L["Allows the pet frame to be moved freely. When unchecked, it will be positioned relative to the player frame."] = true
L["Horizontal position (only active if Override is checked)"] = true
L["Vertical position (only active if Override is checked)"] = true
L["Party Frames Configuration"] = true
L["Custom styling for party member frames with automatic health/mana text display and class colors."] = true
L["Party frame orientation"] = true
L["Heal prediction, absorb shields, and animated health loss on unit frames"] = true
L["Builder/Spender Feedback"] = true
L["Show mana gain/loss glow feedback on player mana bar (experimental)."] = true
L["Raid Frames"] = true
L["This Fork is maintained by Zhuantou for AscensionWow, based on the original work by PentSec and Neticsoul."] = true
L["Enable Nameplates"] = true
L["Enable or disable the DragonUI nameplate module."] = true
L["DragonUI-style health bars on Blizzard nameplates (30300)."] = true
L["Show Level in Name"] = true
L["Bar Size"] = true
L["Width of the nameplate health bar."] = true
L["Height of the nameplate health bar."] = true
L["Name and health percent font scale (1-10)."] = true
L["Stack Offset X"] = true
L["Horizontal offset for the nameplate stack."] = true
L["Stack Offset Y"] = true
L["Vertical offset for the nameplate stack."] = true
L["Show Health Percent"] = true
L["Show Health Number"] = true
L["Shows HP as a number (e.g. 22k) and percent on the health bar."] = true
L["Health Number Font Size"] = true
L["Health number font scale (1-10)."] = true
L["Center Name Only"] = true
L["Centers the unit name and hides the health percent."] = true
L["Hides level text and health percent, and centers the unit name on the nameplate."] = true
L["Show Health Bar When Damaged"] = true
L["In headline mode, hide the health bar while the unit is at full health and show a compact bar while it is damaged."] = true
L["Damage Bar Color"] = true
L["Choose the color of the compact health bar shown while a headline-mode unit is damaged."] = true
L["Reaction Color"] = true
L["Traffic Light (by HP)"] = true
L["Custom Damage Bar Color"] = true
L["Use class colors for friendly player name text."] = "Use class colors for friendly player name text. Requires Friendly Class Colors or Party Class Colors enabled in Health Bar."
L["Use class colors for enemy player name text."] = "Use class colors for enemy player name text. Requires Enemy Player Class Colors enabled in Health Bar."
L["Highlight texture on the targeted nameplate."] = true
L["Keep all nameplates fully opaque when targeting."] = true
L["Non-Target Opacity"] = true
L["Opacity for non-target nameplates when fade is enabled (0.0-1.0)."] = true
L["Max Debuff Icons"] = true
L["Hide debuffs on every nameplate except your current target and focus."] = true
L["Choose whether the spell list below shows only listed debuffs or hides them."] = true
L["Spell List"] = true
L["Spell IDs separated by commas."] = true
L["Highlight Crowd Control"] = true
L["Adds a colored border to stuns, fears, polymorphs, silences, and other crowd control."] = true
L["Filtering"] = true
L["Priority Highlight"] = true
L["Total icons in the row. Buffs and debuffs share these slots, lowest priority drops first."] = true
L["Lets stuns, fears and polymorphs from anyone through the Only My Debuffs filter. Enemy crowd control matters no matter who cast it."] = true
L["Show buffs on enemy plates in the same row as debuffs. They compete for the same slots, ordered by priority."] = true
L["Purgeable shows what you can spellsteal or dispel, plus defensive cooldowns worth waiting out. No list to maintain."] = true
L["Only My Buffs"] = true
L["Only show buffs you applied yourself."] = true
L["Priority"] = true
L["Sort Order"] = true
L["Priority puts your crowd control first, then anyone's crowd control, enemy defensives, your debuffs and the rest. Chronological sorts by time left only."] = true
L["Scale Icons by Priority"] = true
L["Draws higher-priority auras larger. Icons stay bottom-aligned, so the big ones grow upward without shifting the row."] = true
L["Tints the icon frame by category: crowd control, enemy defensives, purgeable buffs, and dispel type for everything else."] = true
L["Color by Dispel Type"] = true
L["Any other buff has to be listed here, or an ally in a raid fills the screen."] = true
L["Show All Debuffs on Allies"] = true
L["An ally carries dozens of auras, so only what you list here is shown."] = true
L["Decides which icons come first, and which drop off when there is no room. Importance puts crowd control first, then enemy defensives, then your own debuffs."] = true
L["Extra Crowd Control Spells"] = true
L["Show stuns, fears and polymorphs on allies even when they are not in the list."] = true
L["Ally Aura List"] = true
L["An ally in a raid carries dozens of auras, so nothing is shown unless you ask for it below."] = true
L["Highlighted auras draw larger than the rest. Everything else uses the base icon size."] = true
L["Same rule as the Blizzard target frame: each debuff takes the colour of its dispel type, and one without a type uses None."] = true
L["Crowd control uses its own colour instead of its dispel type."] = true
L["Order: your crowd control, others' crowd control, enemy defensives, your debuffs, purgeable buffs, others' debuffs."] = true
L["Higher priority draws larger."] = true
L["Tint the icon frame by category."] = true
L["Enemy Defensives"] = true
L["Purgeable"] = true
L["Everything else uses its Magic, Curse, Disease or Poison color."] = true
L["Purgeable means Magic or Enrage, plus the defensive list below."] = true
L["Categories"] = true
L["These lists decide which auras count as defensive or as crowd control, for both sorting and border color."] = true
L["Extra Crowd Control"] = true
L["Added on top of the built-in crowd control list."] = true
L["Only the spells listed below are shown, never anything else."] = true
L["Show auras on friendly nameplates. Only the spells listed below are ever shown: an ally in a raid carries dozens and any other rule fills the screen."] = true
L["Tints plain debuffs by their dispel type (Magic, Curse, Disease, Poison). Crowd control and defensives keep their own color."] = true
L["Power Bar Players Only"] = true
L["Hide mana/power on NPC nameplates when unit is known."] = true
L["On 3.3.5a, enemy cast bars appear on the targeted plate only."] = true
L["Show Cast Bar"] = true
L["Show Party Cast Bars"] = true
L["Show cast bars on party member nameplates even when not targeted."] = true
L["Show Enemy Player Cast Bars in PvP"] = true
L["In PvP, show enemy player cast bars without needing target or mouseover."] = true
L["Uses the combat log to guess casts on units you are not targeting. Less accurate than target, focus, mouseover, and arena enemies above."] = true
L["Off-Target Combat Log Mode"] = true
L["Off-Target Mode Off"] = "Disabled"
L["Off-Target Mode Hybrid"] = "Hybrid (Recommended)"
L["Off-Target Mode Aggressive"] = "Aggressive"
L["Off-Target Mode When Safe"] = "When Safe"
L["Off-Target Mode Off Desc"] = "Do not use the combat log for off-target casts."
L["Off-Target Mode Hybrid Desc"] = "Smart default: enemy and ally players use the Aggressive technique (their names are always unique), while NPCs use the safer When Safe technique (their names can repeat). Combines both for the best result in every situation."
L["Off-Target Mode Aggressive Desc"] = "Try to show more off-target casts. Fake casts do not show as interrupted; the bar may appear on the wrong nameplate."
L["Off-Target Mode When Safe Desc"] = "Show fewer off-target casts, only when the match is likely correct."
L["Aggressive Filters"] = true
L["When Safe Filters"] = true
L["Hostile Units Only"] = true
L["Safe Hostile Only Desc"] = "Skip friendly and neutral units in the combat log."
L["Enemy Players Only"] = true
L["Limit to enemy player cast bars. Useful in PvP."] = "Limit off-target casts to enemy players only."
L["Safe Enemy Players Only Desc"] = "Enemy players only. Requires Hostile Units Only."
L["Ignore Friendly Casts"] = true
L["Skip party, allies, and neutral units in the combat log."] = true
L["Sync From Native Cast Bar"] = true
L["On supported clients, use the game's built-in nameplate cast bar for better timing. Safe to leave enabled."] = true
L["Native Progress Sync for Off-Target Casts"] = true
L["When available, off-target combat-log castbars sync their progress from Blizzard's native castbar."] = true
L["showVKeyCastbar Mode"] = true
L["auto: keep client value. force_on/off: DragonUI sets showVKeyCastbar while nameplates module is active."] = true
L["Auto (Do Not Force)"] = true
L["Force On"] = true
L["Force Off"] = true
L["Show totem icon on shaman totem nameplates."] = true
L["Name and health percent font scale (1-10, default 2)."] = true
L["Side arrows on the targeted nameplate."] = true
L["Overlay Name On Health Bar"] = true
L["Anchor the name, level, health percent, and elite icon centered on the health bar instead of above it."] = true
L["Overlay Vertical Offset"] = true
L["Fine-tune the vertical position when 'Overlay Name On Health Bar' is enabled."] = true
L["Name Row Horizontal Padding"] = true
L["Inset the name, level, and health percent from the left and right edges of the health bar. Does not affect the elite icon."] = true
L["Name & Level"] = true
L["Colored glow indicating aggro status (red = tanking, orange = losing, yellow = gaining)."] = true
L["Opacity for non-target nameplates when fade is enabled (0.1 - 1.0)."] = "Opacity for non-target nameplates when fade is enabled (0.0 - 1.0)."
L["Show enemy cast bar on the targeted nameplate."] = true
L["Name Font"] = true
L["Behavior Mode"] = true
L["Only apply Retail-like stacking inside instances."] = true
L["DragonUI (Custom)"] = true
L["Allow plates to overlap instead of stacking."] = true
L["Keep boss nameplates visible at the top of the screen inside party and raid instances."] = "Keeps Boss (skull-lvl / ??) nameplates visible on screen."
L["Scales the nameplate clickbox relative to its original size. Recommended to change this setting while out of combat."] = true
L["Target Zoom"] = true
L["Enlarge your target's nameplate health bar (extra width/height)."] = true
L["Target Zoom Extra Width"] = true
L["Target Zoom Extra Height"] = true
L["Extra width added to the health bar of your target."] = true
L["Extra height added to the health bar of your target."] = true
L["Use Target Opacity When No Target Exists"] = true
L["When no target exists, use target opacity instead of non-target opacity."] = true
L["When no target exists, use full opacity instead of Non-Target Opacity."] = true
L["Automatically collect transmog appearances when looting new items. Works with Ascension's Ctrl+Alt+Click appearance system."] = true
L["Attack Bar"] = true
L["Enable Attack Bar"] = true
L["Main Hand Bar"] = true
L["Off Hand Bar"] = true
L["Ranged Bar"] = true
L["Enemy Bar"] = true
L["Show Timer"] = true
L["Show Info"] = true
L["Consolidate Buffs"] = true
L["Gather only the specified scroll buff names (whitelist: starting with '守护者卷轴', '守护者的卷轴' or \"Keeler's\") into a '+N' button. All other buffs remain in the main row and matching auras move back there shortly before they expire."] = true
L["Layout settings for the player buff and debuff bar (DragonUI aura frame). These do not affect target or focus auras."] = true
L["Show temporary weapon enchant icons (poisons, oils, etc.) at the start of the buff row."] = true
L["Size of each buff icon in pixels."] = true
L["Buff Growth Direction"] = true
L["Direction in which buff icons grow as they are added."] = true
L["Buff Wrap After"] = true
L["Number of icons per row/column before wrapping."] = true
L["Buff Max Wraps"] = true
L["Maximum number of rows/columns."] = true
L["Buff Horizontal Spacing"] = true
L["Horizontal spacing between buff icons in pixels."] = true
L["Buff Vertical Spacing"] = true
L["Vertical spacing between buff icons in pixels."] = true
L["Debuff Growth Direction"] = true
L["Debuff Wrap After"] = true
L["Debuff Max Wraps"] = true
L["Debuff Horizontal Spacing"] = true
L["Debuff Vertical Spacing"] = true
L["Buff Sort Method"] = true
L["Debuff Sort Method"] = true
L["Buff Sort Direction"] = true
L["Debuff Sort Direction"] = true
L["Buff Separate Own"] = true
L["Debuff Separate Own"] = true
L["Buff No Duration Last"] = true
L["Debuff No Duration Last"] = true
L["Show Duration Text"] = true
L["Duration Font Size"] = true
L["Count Font Size"] = true
L["Show Weapon Enchants"] = true
L["Index"] = true
L["Expiration Time"] = true
L["Right then Down"] = true
L["Right then Up"] = true
L["Left then Down"] = true
L["Left then Up"] = true
L["Down then Right"] = true
L["Down then Left"] = true
L["Up then Right"] = true
L["Up then Left"] = true
L["Disabled"] = true
L["Own First"] = true
L["Own Last"] = true
L["Ascending"] = true
L["Descending"] = true
L["How buffs are sorted."] = true
L["How debuffs are sorted."] = true
L["Ascending or descending sort order."] = true
L["Show your own buffs first, last, or mixed with others."] = true
L["Move auras with no duration to the end of the list. Unchecked: move to the beginning."] = true
L["Show remaining duration text below buff/debuff icons."] = true
L["Font size for duration text."] = true
L["Font size for stack count text."] = true
L["Sorting"] = true
L["Size of each debuff icon in pixels."] = true
L["Direction in which debuff icons grow as they are added."] = true
L["Horizontal spacing between debuff icons in pixels."] = true
L["Vertical spacing between debuff icons in pixels."] = true
L["Show your own debuffs first, last, or mixed with others."] = true
L["Auto Quest"] = true
L["Auto-Complete Quests"] = true
L["Automatically complete quests when talking to NPCs. Use /aq for fine-grained control over auto-accept, daily, fate, and repeatable quests."] = true
L["Automatically turn in completed quests and claim rewards when talking to quest NPCs. Also auto-completes quests from the progress window."] = true
L["Auto-Accept All Quests"] = true
L["Auto-Accept Daily Quests"] = true
L["Auto-Accept Repeatable Quests"] = true
L["Automatically accept all quests when talking to NPCs."] = true
L["Automatically accept daily quests when talking to NPCs."] = true
L["Automatically accept repeatable quests when talking to NPCs."] = true
L["Auto-Accept Fate Quests"] = true
L["Auto-Accept High-Risk Quests"] = true
L["Automatically accept fate quests when talking to NPCs."] = true
L["Automatically accept high-risk quests when talking to NPCs."] = true
L["Nameplate Display Distance"] = true
L["Nameplate Max Distance"] = true
L["Set the maximum distance at which nameplates are visible (30-60 yards)."] = true
L["Quest Tracker Module"] = "Quest Tracker"
L["Error Mask"] = true
L["Blocks the Red Error spam from the middle of your screen, such as 'You are too far away!'."] = true
L["Enable Error Mask"] = true
L["Suppress common spam errors from the middle of your screen."] = true
L["Master switch for the DragonUI raid frames module."] = true
L["Frame Geometry"] = true
L["Power Bar Height"] = true
L["Spacing X"] = true
L["Spacing Y"] = true
L["Group Spacing"] = true
L["How members inside a group are arranged."] = true
L["Show health percentage text on the frames."] = true
L["Show Ready Check Icons"] = true
L["Auto mode: show raid frames when the raid has at least this many members."] = true
L["Minimum Raid Members"] = true
L["Smart Visibility"] = true
L["When to show the raid frames. Auto: show when in a raid with enough members or inside a raid instance."] = true
L["Enable Raid Frames"] = true
L["Frame Width"] = true
L["Frame Height"] = true
L["Show Health Text"] = true
L["Show the power/mana bar under the health bar."] = true
L["Raid Debuffs"] = true
L["Enable Raid Debuffs"] = true
L["Boss debuff icons (Naxxramas / Ulduar / Trial of the Crusader / Icecrown Citadel / Ruby Sanctum)."] = true
L["X Offset"] = true
L["Raid Target Icons"] = true
L["Show Raid Target Icons"] = true
L["Show the raid target marker (star, circle, skull, ...) on each frame."] = true
L["Resurrect Indicator"] = true
L["Show Resurrect Indicator"] = true
L["Shows when someone is casting a resurrection spell on a dead member. Tracked locally (this client has no UnitHasIncomingResurrection API)."] = true
L["Text"] = true
L["Show Group Titles"] = true
L["Fade Out-of-Range Members"] = true
L["Fade raid member frames when they are out of range (28 yards)."] = true
L["Faded Opacity"] = true
L["Opacity of raid frames whose member is out of range."] = true
L["Show the group number label above each raid group."] = true
L["Frame Enhancements"] = true
L["Unit frame features ported from BetterBlizzFrames. Everything is class-agnostic, so all Ascension custom classes work. Features are off by default."] = true
L["Enable Frame Enhancements"] = true
L["Master switch for every feature on this page."] = true
L["Party Cast Bars"] = true
L["Show a cast bar under each party member frame."] = true
L["Show Cast Timer"] = true
L["Pet Cast Bar"] = true
L["Show a cast bar under the pet frame."] = true
L["Test Cast Bars (4 sec)"] = true
L["Shows a fake cast on every enabled party/pet cast bar, even without a group, so you can position them."] = true
L["Cast Target Name"] = true
L["Show who the target/focus cast is aimed at, under its cast bar (class-colored)."] = true
L["Target Cast Bar"] = true
L["Focus Cast Bar"] = true
L["Interrupt Readiness"] = true
L["Tint the target/focus cast bar by your interrupt's cooldown and show the interrupt icon beside it."] = true
L["Interrupt Spells"] = true
L["Comma-separated spell names or IDs, first known one is used. Leave empty to auto-detect common interrupts (Kick, Pummel, Counterspell, Wind Shear...). Press Enter to apply."] = true
L["Detected interrupt:"] = true
L["none"] = true
L["Show Interrupt Icon"] = true
L["Interrupt On Cooldown"] = true
L["Interrupt Ready Before Cast Ends"] = true
L["Indicators"] = true
L["Combat Indicator"] = true
L["Show a sword icon beside the portrait while the unit is in combat. Nothing is shown out of combat."] = true
L["Portrait Crowd Control"] = true
L["Show crowd control and immunity icons over portraits with a countdown."] = true
L["Show Immunities"] = true
L["Divine Shield, Ice Block, Cloak of Shadows, Hand of Protection..."] = true
L["Extra Crowd Control Spell IDs"] = true
L["Comma-separated spell IDs to treat as crowd control in addition to the built-in list (useful for custom class spells). Press Enter to apply."] = true
L["Stealth Indicator"] = true
L["Glow around the player frame while you are stealthed."] = true
L["Quest Indicator"] = true
L["Show a '!' on the target/focus frame when the mob is an active quest objective."] = true
L["Names & Appearance"] = true
L["Class-Colored Names"] = true
L["Color player, target, focus and party names by class."] = true
L["Remove Realm Names"] = true
L["Drop the realm suffix from cross-realm player names."] = true
L["Class-Colored Name Background"] = true
L["Tint the target/focus name banner with the player's class color."] = true
L["Smooth Health Bars"] = true
L["Animate health bar changes. Turn off if you ever see 'action blocked' messages."] = true
L["Smooth Power Bars"] = true
L["Animate mana/rage/energy bar changes."] = true
L["Hide Frame Elements"] = true
L["Group Number"] = true
L["Level Text"] = true
L["PvP Icons"] = true
L["Portrait Damage/Heal Text"] = true
L["Leader / Loot Master Icons"] = true
L["Resting Icon"] = true
L["Target & Focus Auras"] = true
L["Enable Aura Tweaks"] = true
L["Resize your own auras, filter debuffs and highlight dispellable buffs on target/focus."] = true
L["Own Aura Size"] = true
L["Only My Debuffs on Enemies"] = true
L["Hide debuffs cast by other players on hostile targets."] = true
L["Highlight Dispellable Buffs"] = true
L["Glow around Magic buffs on hostile targets (purge / dispel / spellsteal candidates)."] = true
L["Highlight Color"] = true
L["Health Bar on Monsters"] = true
L["Also show the health bar on NPC and monster tooltips. Off = only players get one."] = true
L["Always Show Chat Buttons"] = true
L["Keep the buttons beside the chat (scroll, menu, friends) visible instead of fading them out with the tabs."] = true
L["Show DragonUI's countdown numbers on action buttons. Turn off if another addon (e.g. OmniCC) already shows them."] = true
L["Untimed Buffs"] = true
L["Untimed Buffs First"] = true
L["Untimed Buffs Last"] = true
L["FPS / Latency"] = true
