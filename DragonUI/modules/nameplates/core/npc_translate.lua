-- ============================================================================
-- Nameplates: NPC 名称中文化（共享翻译模块）
-- 数据源优先级：ItemTranslator 的全局 NPC_Name_Map > DragonUI 本地后备表
-- DragonUI_NPC_Name_Map（modules/NPC_Name_Map.lua，toc 加载）。
-- 仅 DragonUI 姓名版显示层使用：只替换命中表项的 NPC 名，
-- 玩家名 / PvP 头衔名不会命中，保持原文；表均不存在时静默跳过。
-- ============================================================================

local addon = select(2, ...)
local NP = addon.Nameplates

NP.translate = NP.translate or {}

-- 惰性解析数据源：首次翻译调用时（进入世界后，所有 AddOn 已加载）确定
local function GetNPCNameMap()
    return _G.NPC_Name_Map or _G.DragonUI_NPC_Name_Map
end

-- 转义 Lua 模式特殊字符（NPC 名可能含 "-"、"."、"'" 等）
local function EscapePattern(str)
    return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

-- 翻译姓名版显示名（2.0 对齐）：先精确查表（原样匹配），
-- 失败再剥离颜色码/等级前缀后查表；命中则替换原名并保留原格式
function NP.translate.TranslateDisplayName(text)
    if not text or text == "" then return text end
    local map = GetNPCNameMap()
    if not map then return text end
    -- 无英文（已是中文/纯数字等）不处理
    if not text:find("[A-Za-z]") then return text end

    -- ① 精确匹配（2.0 TranslateName 方式）
    local zh = map[text]
    if zh then return zh end

    -- ② 剥离颜色码 |cAARRGGBB / |r 后查
    local plain = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    zh = map[plain]
    if zh then
        if plain == text then
            return zh
        end
        return text:gsub(EscapePattern(plain), zh, 1)
    end

    -- ③ 再剥离等级前缀后查（支持 [62]、[62+]、(62)、(62+)、62 等 levelTextFormat 格式）；
    --    命中时若原文本带格式则替换原名保留格式，纯名则直接返回
    local name = plain:match("^[%[%(]?%d+%+?[%]%)]?%s*(.*)$") or plain
    zh = map[name]
    if zh then
        if name == text then
            return zh
        end
        return text:gsub(EscapePattern(name), zh, 1)
    end
    return text
end

-- 为原生姓名版名称 FontString 安装翻译钩子：
-- Blizzard 每次 SetText 名称后，命中表项即替换为中文（_dragonuiApplying 防递归）
function NP.translate.HookNameFontString(fs)
    if not fs or not fs.SetText or fs._dragonuiNameTranslated then return end
    fs._dragonuiNameTranslated = true
    hooksecurefunc(fs, "SetText", function(self, text)
        if not text or text == "" then return end
        if self._dragonuiApplying then return end
        local translated = NP.translate.TranslateDisplayName(text)
        if translated ~= text then
            self._dragonuiApplying = true
            self:SetText(translated)
            self._dragonuiApplying = nil
        end
    end)
end
