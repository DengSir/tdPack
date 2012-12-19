
local tdPack = tdCore(...)

local Weapon, Armor, Container, Consumable, Glyph, Trade, Formula, Jewelry, Misc, Quest, BattlePet = GetAuctionItemClasses()
--local Other, Cloth, Leather, Chain, Plate = GetAuctionItemSubClasses(2)
local FishingRod = select(17, GetAuctionItemSubClasses(1))

function tdPack:GetDefault()
    return {
        SaveToBank = {
            '#'  .. Jewelry,    -- 珠宝
            '##' .. '元素',
            -- '##' .. '金属和矿石',
        },
        LoadFromBank = {
            HEARTHSTONE_ITEM_ID,-- 炉石
            2901,               -- 矿工锄
            5956,               -- 铁匠锤
            7005,               -- 剥皮刀
            20815,              -- 珠宝制作工具
            39505,              -- 学者的书写工具
            40772,              -- 侏儒军刀
            49040,              -- 维斯基
            48933,              -- 虫洞 Northland
            40768,              -- 随身邮箱
            '#'  .. Quest,      -- 任务
            '#'  .. Jewelry,    -- 珠宝
        },
        Orders = {
            CustomOrder = {
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
                '##' .. FishingRod, -- 鱼竿
                '#'  .. BattlePet,  -- 战斗宠物
                '#'  .. Weapon,     -- 武器
                '#'  .. Armor,      -- 护甲
                '#'  .. Container,  -- 容器
                '#'  .. Jewelry,    -- 珠宝
                '#'  .. Glyph,      -- 雕文
                '#'  .. Formula,    -- 配方
                '#'  .. Trade,      -- 商品
                '#'  .. Consumable, -- 消耗品
                '#'  .. Misc,       -- 其它
                '#'  .. Quest,      -- 任务
            },
            EquipLocOrder = {
            },
        }
    }
end

local ipairs, type, format, sort = ipairs, type, format, sort
local GetItemInfo = GetItemInfo
local GetPetInfoBySpeciesID = C_PetJournal.GetPetInfoBySpeciesID

local Rule = tdPack:NewModule('Rule')
Rule.compareStrings = {}

function Rule:New(tbl, default)
    local obj = {}
    
    obj.__unknownOrder = default
    for i, v in ipairs(tbl) do
        obj[v] = default and i or true
    end
    
    return obj
end

------ order

function Rule:GetItemIDOrder(item)
    return self.CustomOrder[item:GetItemID()] or self.CustomOrder[item:GetItemName()]
end

function Rule:GetItemTypeOrder(item)
    return  self.CustomOrder['#'  .. item:GetItemType() .. '##' .. item:GetItemSubType()] or
            self.CustomOrder['##' .. item:GetItemSubType()] or
            self.CustomOrder['#'  .. item:GetItemType()] or
            self.CustomOrder.__unknownOrder
end

function Rule:GetItemEquipLocOrder(item)
    return self.EquipLocOrder[item:GetItemEquipLoc()] or self.EquipLocOrder.__unknownOrder
end

function Rule:GetItemLevelOrder(item)
    return 9999 - item:GetItemLevel()
end

function Rule:GetItemQualityOrder(item)
    return 99 - item:GetItemQuality()
end

function Rule:GetCompareString(item)
    if self.compareStrings[item:GetItemID()] then
        return self.compareStrings[item:GetItemID()]
    end
    
    local idOrder = self:GetItemIDOrder(item)
    local compareString
    if idOrder then
        compareString = format('0%03d', idOrder)
    else
        compareString = ('%d%03d%02d%s%s%04d%02d%s'):format(
            item:GetItemQuality() == 0 and 1 or 0,
            self:GetItemTypeOrder(item),
            self:GetItemEquipLocOrder(item),
            item:GetItemType(),
            item:GetItemSubType(),
            self:GetItemLevelOrder(item),
            self:GetItemQualityOrder(item),
            item:GetItemName()
        )
    end
    
    self.compareStrings[item:GetItemID()] = compareString
    
    return compareString
end

------ bank

function Rule:IsNeed(item, tbl)
    if tbl[item:GetItemID()] then
        return true
    end
    
    return  tbl[item:GetItemName()] or
            tbl['#' .. item:GetItemType() .. '##' .. item:GetItemSubType()] or
            tbl['##' .. item:GetItemSubType()] or
            tbl['#' .. item:GetItemType()]
end

function Rule:NeedSaveToBank(item)
    return Rule:IsNeed(item, self.SaveToBank)
end

function Rule:NeedLoadToBag(item)
    return Rule:IsNeed(item, self.LoadFromBank)
end

------ other

local function sortCompare(a, b)
    return Rule:GetCompareString(a) < Rule:GetCompareString(b)
end

function Rule:SortItems(items)
    sort(items, sortCompare)
end

function Rule:BuildRule()
    local profile = tdPack:GetProfile()
    
    self.CustomOrder   = Rule:New(profile.Orders.CustomOrder, 999)
    self.EquipLocOrder = Rule:New(profile.Orders.EquipLocOrder, 99)
    self.SaveToBank    = Rule:New(profile.SaveToBank)
    self.LoadFromBank  = Rule:New(profile.LoadFromBank)
    
end

function Rule:OnProfileUpdate()
    wipe(self.compareStrings)
    wipe(self.CustomOrder)
    wipe(self.EquipLocOrder)
    wipe(self.SaveToBank)
    wipe(self.LoadFromBank)
    
    self:BuildRule()
end

function Rule:OnInit()
    self:BuildRule()
    self:SetHandle('OnProfileUpdate', self.OnProfileUpdate)
end
