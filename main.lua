
local tdPack = tdCore:NewAddon(...)
local L = tdPack:GetLocale()

L.Weapon, L.Armor, L.Container, L.Consumable, L.Glyph, L.Trade, L.Formula, L.Jewelry, L.Misc, L.Quest, L.BattlePet = GetAuctionItemClasses()
L.FishingRod = select(17, GetAuctionItemSubClasses(1))

function tdPack:ShowMessage(text, r, g, b)
    local profile = self:GetProfile()
    
    if profile.showmessage then
        (profile.messageframe == 1 and DEFAULT_CHAT_FRAME or UIErrorsFrame):AddMessage(text, r or 1, g or 1, b or 1, 1)
    end
end

function tdPack:GetDefault()
    return {
        showmessage = true,
        messageframe = 2,
        
        SaveToBank = {
            '#'  .. L.Jewelry,    -- 珠宝
            '##' .. '元素',
        },
        LoadFromBank = {
            '#'  .. L.Quest,      -- 任务
            '#'  .. L.Jewelry,    -- 珠宝
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
            },
            EquipLocOrder = {
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
            },
        }
    }
end

tdPack:RegisterEmbed('Base', {
    GetParent = function(obj) 
        return obj.parent
    end,
    SetParent = function(obj, parent)
        obj.parent = parent
    end,
})

local select = select

local GetItemInfo = GetItemInfo
local PickupContainerItem = PickupContainerItem
local GetContainerItemID = GetContainerItemID
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumFreeSlots = GetContainerNumFreeSlots

---- bag slot

function tdPack:GetBagSlotLink(bag, slot)
    return GetContainerItemLink(bag, slot)
end

function tdPack:GetBagSlotID(bag, slot)
    local itemLink = GetContainerItemLink(bag, slot)
    if not itemLink then
        return
    end
    
    if itemLink:find('battlepet') then
        local id, level, quality = itemLink:match('battlepet:(%d+):(%d+):(%d+)')
        
        return (('battlepet:%d:%d:%d'):format(id, level, quality))
    else
        return (GetContainerItemID(bag, slot))
    end
end

function tdPack:GetBagSlotFamily(bag, slot)
    local itemID = self:GetBagSlotID(bag, slot)
    if not itemID then
        return 0
    end
    
    return type(itemID) == 'string' and 0 or GetItemFamily(itemID)
end

function tdPack:IsBagSlotEmpty(bag, slot)
    return not GetContainerItemID(bag, slot)
end

function tdPack:IsBagSlotFull(bag, slot)
    local itemID = GetContainerItemID(bag, slot)
    if not itemID then
        return false
    end
    
    local stackCount = select(8, GetItemInfo(itemID))
    if stackCount == 1 then
        return true
    end
    
    return stackCount == (select(2, GetContainerItemInfo(bag, slot)))
end

function tdPack:IsBagSlotLocked(bag, slot)
    return (select(3, GetContainerItemInfo(bag, slot)))
end

function tdPack:PickupBagSlot(bag, slot)
    PickupContainerItem(bag, slot)
end

---- bag

function tdPack:GetBagFamily(bag)
    return (select(2, GetContainerNumFreeSlots(bag)))
end

function tdPack:GetBagNumSlots(bag)
    return (GetContainerNumSlots(bag))
end

function tdPack:FindSlot(item, tarSlot)
    return self:GetModule('Pack'):FindSlot(item, tarSlot)
end

function tdPack:IsReversePack()
    return self.desc
end

function tdPack:SetReversePack(desc)
    self.desc = desc
end

function tdPack:SetLoadToBag(en)
    self.loadtobag = en
end

function tdPack:SetSaveToBank(en)
    self.savetobank = en
end

function tdPack:IsSaveToBank()
    return self.savetobank
end

function tdPack:IsLoadToBag()
    return self.loadtobag
end

local GUI = tdCore('GUI')

local function OnAdd(self)
    GUI:ShowMenu('DialogMenu', self, self,
        {
            label = L['Please input new rule:'],
            buttons = {GUI.DialogButton.Okay, GUI.DialogButton.Cancel},
            text = true,
            func = function(result, text)
                if result == GUI.DialogButton.Okay and text:trim() ~= '' then
                    tinsert(tdPack:GetProfile().Orders.CustomOrder, text:trim())
                    tdPack:UpdateOption()
                end
            end
        })
end

function tdPack:OnInit()
    self:InitDB('TDDB_TDPACK', self:GetDefault())
    self:RegisterCmd('/tdpack', '/tdp', '/tp')
    self:SetHandle('OnSlashCmd', self.Pack)
    
    self:InitOption({
        type = 'TabWidget',
        {
            type = 'Widget', label = GENERAL,
            {
                type = 'CheckBox', label = L['Pack desc on default'],
                profile = {self:GetName(), 'desc'},
            },
            {
                type = 'CheckBox', label = L['Save to bank on default'],
                profile = {self:GetName(), 'savetobank'},
            },
            {
                type = 'CheckBox', label = L['Load to bag on default'],
                profile = {self:GetName(), 'loadtobag'},
            },
            {
                type = 'CheckBox', label = L['Show tdPack message'], name = 'ShowMessageToggle',
                profile = {self:GetName(), 'showmessage'},
            },
            {
                type = 'ComboBox', label = L['Message frame'],
                profile = {self:GetName(), 'messageframe'}, depend = 'ShowMessageToggle',
                itemList = {
                    { value = 1, text = L['Show message in chat frame']},
                    { value = 2, text = L['Show message in error frame']}
                }
            }
        },
        {
            type = 'Widget', label = L['Custom order'],
            {
                type = 'Button', label = ADD,
                scripts = {
                    OnClick = OnAdd
                }
            },
            {
                type = 'ListWidget', label = L['Custom order'], itemObject = tdCore('GUI')('ListWidgetLinkItem'),
                verticalArgs = {-1, 0, 0, 0}, allowOrder = true,
                selectMode = 'MULTI',
                profile = {self:GetName(), 'Orders', 'CustomOrder'},
            }
        }
    })
end

function tdPack:Pack(...)
    self.savetobank = nil
    self.loadtobag  = nil
    
    local argc = select('#', ...)
    
    if argc > 0 then
        for i = 1, select('#', ...) do
            local arg = select(i, ...)
            if arg == 'asc' then
                self:SetReversePack(nil)
            elseif arg == 'desc' then
                self:SetReversePack(true)
            elseif arg == 'load' then
                self:SetLoadToBag(true)
            elseif arg == 'save' then
                self:SetSaveToBank(true)
            end
        end
    else
        self:SetReversePack(self:GetProfile().desc)
        self:SetSaveToBank(self:GetProfile().savetobank)
        self:SetLoadToBag(self:GetProfile().loadtobag)
    end
    
    self:GetModule('Pack'):Start()
end
