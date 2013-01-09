
local tdPack = tdCore(...)

local L = tdPack:GetLocale()

tdPack.DefaultCustomOrder = {
    HEARTHSTONE_ITEM_ID,-- 炉石
    79104,              -- 水壶
    2901,               -- 矿工锄
    5956,               -- 铁匠锤
    7005,               -- 剥皮刀
    20815,              -- 珠宝制作工具
    39505,              -- 学者的书写工具
    40772,              -- 侏儒军刀
    49040,              -- 维斯基
    48933,              -- 虫洞 Northland
    40768,              -- 随身邮箱
    '##' .. L.FishingRod, -- 鱼竿
    '#'  .. L.BattlePet,  -- 战斗宠物
    '#'  .. L.Weapon,     -- 武器
    '#'  .. L.Armor,      -- 护甲
    '#'  .. L.Container,  -- 容器
    '#'  .. L.Jewelry,    -- 珠宝
    '#'  .. L.Glyph,      -- 雕文
    '#'  .. L.Formula,    -- 配方
    '#'  .. L.Trade,      -- 商品
    '#'  .. L.Consumable, -- 消耗品
    '#'  .. L.Misc,       -- 其它
    '#'  .. L.Quest,      -- 任务
}

tdPack.DefaultEquipLocOrder = {
    'INVTYPE_2HWEAPON',         --双手
    'INVTYPE_WEAPON',           --单手
    'INVTYPE_WEAPONMAINHAND',   --主手
    'INVTYPE_WEAPONOFFHAND',    --副手
    'INVTYPE_SHIELD',           --副手
    'INVTYPE_HOLDABLE',         --副手物品
    'INVTYPE_RANGED',           --远程
    'INVTYPE_RANGEDRIGHT',      --远程
    'INVTYPE_THROWN',           --投掷
    
    'INVTYPE_HEAD',             --头部
    'INVTYPE_SHOULDER',         --肩部
    'INVTYPE_CHEST',            --胸部
    'INVTYPE_ROBE',             --胸部
    'INVTYPE_HAND',             --手
    'INVTYPE_LEGS',             --腿部
    
    'INVTYPE_WRIST',            --手腕
    'INVTYPE_WAIST',            --腰部
    'INVTYPE_FEET',             --脚
    'INVTYPE_CLOAK',            --背部
    
    'INVTYPE_NECK',             --颈部
    'INVTYPE_FINGER',           --手指
    'INVTYPE_TRINKET',          --饰品
    
    'INVTYPE_BODY',             --衬衣
    'INVTYPE_TABARD',           --战袍
    
    --  这些应该不需要了
    --  'INVTYPE_RELIC',                --圣物
    --  'INVTYPE_WEAPONMAINHAND_PET',   --主要攻击
    --  'INVTYPE_AMMO',                 --弹药
    --  'INVTYPE_BAG',                  --背包
    --  'INVTYPE_QUIVER',               --箭袋
}