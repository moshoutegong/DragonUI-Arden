-- ===============================================================
-- DRAGONUI RAID DEBUFFS DATA
-- Ported from ElvUI WotLK 7.27 (Settings\Filters\UnitFrame.lua)
-- RaidDebuffs whitelist. 每个条目:
--   [spellID] = { name = "英文技能名", priority = 优先级(越大越优先, 0 默认) }
-- 以 spellID 为主键匹配(UnitDebuff 第 11 个返回值), 模块启动时
-- 用 GetSpellInfo 建立 name -> spellID 反向表作为兜底。
-- ===============================================================
local addon = select(2, ...)

local D = {}

-- Naxxramas
-- Anub'Rekhan
D[54022] = { name = "Locust Swarm", priority = 0 }            -- 蝗虫群
-- Grand Widow Faerlina
D[54098] = { name = "Poison Bolt Volley", priority = 0 }      -- 毒液箭雨
-- Maexxna
D[54121] = { name = "Necrotic Poison", priority = 0 }         -- 死灵毒素
D[54125] = { name = "Web Spray", priority = 0 }               -- 蛛网喷射
-- Gluth
D[29306] = { name = "Infected Wound", priority = 0 }          -- 感染之伤
D[54378] = { name = "Mortal Wound", priority = 0 }            -- 致死重伤
-- Gothik the Harvester
D[27825] = { name = "Shadow Mark", priority = 0 }             -- 暗影印记
D[28679] = { name = "Harvest Soul", priority = 0 }            -- 收割灵魂
D[55645] = { name = "Death Plague", priority = 0 }            -- 死亡瘟疫
-- The Four Horsemen
D[28832] = { name = "Mark of Korth'azz", priority = 0 }       -- 库尔塔兹印记
D[28833] = { name = "Mark of Blaumeux", priority = 0 }        -- 布劳缪克丝印记
D[28834] = { name = "Mark of Rivendare", priority = 0 }       -- 瑞文戴尔印记
D[28835] = { name = "Mark of Zeliek", priority = 0 }          -- 泽里克印记
D[57369] = { name = "Unholy Shadow", priority = 0 }           -- 邪恶暗影
-- Noth the Plaguebringer
D[29212] = { name = "Cripple", priority = 0 }                 -- 残废术
D[29213] = { name = "Curse of the Plaguebringer", priority = 0 } -- 瘟疫使者之咒
D[29214] = { name = "Wrath of the Plaguebringer", priority = 0 } -- 瘟疫使者之怒
-- Heigan the Unclean
D[29310] = { name = "Spell Disruption", priority = 0 }        -- 法术干扰
D[29998] = { name = "Decrepit Fever", priority = 0 }          -- 衰老热疫
-- Loatheb
D[55052] = { name = "Inevitable Doom", priority = 0 }         -- 必然的厄运
D[55053] = { name = "Deathbloom", priority = 0 }              -- 死亡之花
-- Sapphiron
D[28522] = { name = "Icebolt", priority = 0 }                 -- 冰霜箭
D[55665] = { name = "Life Drain", priority = 0 }              -- 吸取生命
D[55699] = { name = "Chill", priority = 0 }                   -- 寒冰刺骨
-- Kel'Thuzad
D[28410] = { name = "Chains of Kel'Thuzad", priority = 0 }    -- 克尔苏加德之链
D[27819] = { name = "Detonate Mana", priority = 0 }           -- 法力爆炸
D[27808] = { name = "Frost Blast", priority = 0 }             -- 寒冰冲击

-- Ulduar
-- Ignis the Furnace Master
D[62717] = { name = "Slag Pot", priority = 0 }                -- 熔渣之罐
-- XT-002
D[63024] = { name = "Gravity Bomb", priority = 0 }            -- 重力炸弹
D[63018] = { name = "Light Bomb", priority = 0 }              -- 光之炸弹
-- The Assembly of Iron
D[61903] = { name = "Fusion Punch", priority = 0 }            -- 熔解拳击
D[61912] = { name = "Static Disruption", priority = 0 }       -- 静电瓦解
-- Kologarn
D[64290] = { name = "Stone Grip", priority = 0 }              -- 石化紧握
-- Thorim
D[62130] = { name = "Unbalancing Strike", priority = 0 }      -- 失衡打击
-- Yogg-Saron
D[63134] = { name = "Sara's Blessing", priority = 0 }         -- 萨拉的祝福
D[64157] = { name = "Curse of Doom", priority = 0 }           -- 厄运诅咒
-- Algalon
D[64412] = { name = "Phase Punch", priority = 0 }             -- 相位拳击

-- Trial of the Crusader
-- Gormok the Impaler
D[66331] = { name = "Impale", priority = 0 }                  -- 穿刺
D[66406] = { name = "Snowbolled!", priority = 0 }             -- 被雪球砸中!
-- Jormungar Behemoth
D[66869] = { name = "Burning Bile", priority = 0 }            -- 燃烧胆汁
D[67618] = { name = "Paralytic Toxin", priority = 0 }         -- 麻痹毒素
-- Icehowl
D[66689] = { name = "Arctic Breathe", priority = 0 }          -- 极地吐息
-- Lord Jaraxxus
D[66237] = { name = "Incinerate Flesh", priority = 0 }        -- 焚烧血肉
D[66197] = { name = "Legion Flame", priority = 0 }            -- 恶魔烈焰
-- Faction Champions
D[65812] = { name = "Unstable Affliction", priority = 0 }     -- 痛苦无常
-- The Twin Val'kyr
D[67309] = { name = "Twin Spike", priority = 0 }              -- 双子尖刺
-- Anub'arak
D[66013] = { name = "Penetrating Cold", priority = 0 }        -- 刺骨之寒
D[67574] = { name = "Pursued by Anub'arak", priority = 0 }    -- 被阿努巴拉克追杀
D[67847] = { name = "Expose Weakness", priority = 0 }         -- 暴露弱点

-- Icecrown Citadel
-- Lord Marrowgar
D[69065] = { name = "Impaled", priority = 0 }                 -- 被骨刺刺穿
-- Lady Deathwhisper
D[72109] = { name = "Death and Decay", priority = 0 }         -- 凋零缠绕
D[71289] = { name = "Dominate Mind", priority = 0 }           -- 精神控制
D[71237] = { name = "Curse of Torpor", priority = 0 }         -- 麻痹诅咒
-- Deathbringer Saurfang
D[72293] = { name = "Mark of the Fallen Champion", priority = 0 } -- 堕落勇士印记
D[72442] = { name = "Boiling Blood", priority = 0 }           -- 沸腾之血
D[72449] = { name = "Rune of Blood", priority = 0 }           -- 鲜血符文
D[72769] = { name = "Scent of Blood", priority = 0 }          -- 血腥气息
-- Festergut
D[71218] = { name = "Vile Gas", priority = 0 }                -- 剧毒气体
D[72219] = { name = "Gastric Bloat", priority = 0 }           -- 胃部膨胀
D[69279] = { name = "Gas Spore", priority = 0 }               -- 气体孢子
-- Rotface
D[71224] = { name = "Mutated Infection", priority = 0 }       -- 突变感染
-- Professor Putricide
D[71278] = { name = "Choking Gas Bomb", priority = 0 }        -- 窒息毒气弹
D[70215] = { name = "Gaseous Bloat", priority = 0 }           -- 气体膨胀
D[72549] = { name = "Malleable Goo", priority = 0 }           -- 可塑软泥
D[70953] = { name = "Plague Sickness", priority = 0 }         -- 瘟疫之疾
D[72856] = { name = "Unbound Plague", priority = 0 }          -- 失控瘟疫
D[70447] = { name = "Volatile Ooze Adhesive", priority = 0 }  -- 挥发软泥粘液
-- Blood Prince Council
D[72796] = { name = "Glittering Sparks", priority = 0 }       -- 闪耀火花
D[71822] = { name = "Shadow Resonance", priority = 0 }        -- 暗影共振
-- Blood-Queen Lana'thel
D[72265] = { name = "Delirious Slash", priority = 0 }         -- 狂乱斩击
D[71473] = { name = "Essence of the Blood Queen", priority = 0 } -- 鲜血女王精华
D[71474] = { name = "Frenzied Bloodthirst", priority = 0 }    -- 疯狂嗜血
D[71340] = { name = "Pact of the Darkfallen", priority = 0 }  -- 暗陨契约
D[71265] = { name = "Swarming Shadows", priority = 0 }        -- 群集暗影
D[70923] = { name = "Uncontrollable Frenzy", priority = 0 }   -- 失控的狂乱
-- Valithria Dreamwalker
D[71733] = { name = "Acid Burst", priority = 0 }              -- 酸性爆破
D[71738] = { name = "Corrosion", priority = 0 }               -- 腐蚀
D[70873] = { name = "Emerald Vigor", priority = 0 }           -- 翡翠活力
D[71283] = { name = "Gut Spray", priority = 0 }               -- 喷吐内脏
-- Sindragosa
D[70106] = { name = "Chilled to the Bone", priority = 0 }     -- 冰冷彻骨
D[70126] = { name = "Frost Beacon", priority = 0 }            -- 冰霜信标
D[70157] = { name = "Ice Tomb", priority = 0 }                -- 冰霜坟墓
D[69766] = { name = "Instability", priority = 0 }             -- 不稳
D[69762] = { name = "Unchained Magic", priority = 0 }         -- 失控魔法
-- The Lich King
D[72762] = { name = "Defile", priority = 0 }                  -- 污染
D[70541] = { name = "Infest", priority = 0 }                  -- 寄生
D[70337] = { name = "Necrotic Plague", priority = 0 }         -- 死灵瘟疫
D[72149] = { name = "Shockwave", priority = 0 }               -- 冲击波
D[69409] = { name = "Soul Reaper", priority = 0 }             -- 灵魂收割者
D[69242] = { name = "Soul Shriek", priority = 0 }             -- 灵魂尖啸

-- The Ruby Sanctum
-- Baltharus the Warborn
D[75887] = { name = "Blazing Aura", priority = 0 }            -- 炽热光环
D[74502] = { name = "Enervating Brand", priority = 0 }        -- 虚弱烙印
-- General Zarithrian
D[74367] = { name = "Cleave Armor", priority = 0 }            -- 破甲斩
-- Halion
D[74562] = { name = "Fiery Combustion", priority = 0 }        -- 炽热燃烧
D[74567] = { name = "Mark of Combustion", priority = 0 }      -- 燃烧印记
D[74792] = { name = "Soul Consumption", priority = 0 }        -- 灵魂吞噬
D[74795] = { name = "Mark of Consumption", priority = 0 }     -- 吞噬印记

addon.RaidDebuffsData = D
