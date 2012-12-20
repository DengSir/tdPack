
local tdPack = tdCore:NewAddon(...)
local L = tdPack:GetLocale()

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

function tdPack:OnInit()
    self:InitDB('TDDB_TDPACK', self:GetDefault())
    self:RegisterCmd('/tdpack', '/tdp', '/tp')
    self:SetHandle('OnSlashCmd', self.Pack)
    
    self:InitOption({
        type = 'TabWidget',
        {
            type = 'Widget', label = GENERAL,
            {
                type = 'CheckBox', label = L['Reverse pack'],
                profile = {self:GetName(), 'desc'},
            },
            {
                type = 'CheckBox', label = L['Save to bank with packing'],
                profile = {self:GetName(), 'savetobank'},
            },
            {
                type = 'CheckBox', label = L['Load to bag with packing'],
                profile = {self:GetName(), 'loadtobag'},
            },
        },
        {
            type = 'ListWidget', label = 'Order', itemObject = tdCore('GUI')('ListWidgetLinkItem'),
            verticalArgs = {-1, -20, 0, 0}, allowOrder = true, --height = 280, 
            selectMode = 'MULTI',
            profile = {'tdPack', 'Orders', 'CustomOrder'},
        }
    })
end

function tdPack:Pack(...)
    self.savetobank = nil
    self.loadtobag  = nil
    
    local argc = select('#', ...)
    
    if argc > 0 then
        print('with args')
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
        print('without args')
        self:SetReversePack(self:GetProfile().desc)
        self:SetSaveToBank(self:GetProfile().savetobank)
        self:SetLoadToBag(self:GetProfile().loadtobag)
    end
    
    self('Pack'):Start()
end
