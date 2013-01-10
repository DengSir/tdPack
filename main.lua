
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
    GUI:ShowMenu('DialogMenu', nil, nil,
        {
            label = L['Please input new rule:'],
            buttons = {GUI.DialogButton.Okay, GUI.DialogButton.Cancel},
            text = true,
            func = function(result, text)
                if result == GUI.DialogButton.Okay and text:trim() ~= '' then
                    self:GetItemList():InsertItem(text:trim())
                    self:SetProfileValue(self:GetItemList(), true)
                    self:Refresh()
                end
            end
        })
end

local function ImportFromJPack(button)
    if not IsAddOnLoaded('JPack') then
        GUI:ShowMenu('DialogMenu', button, button, L['JPack not loaded.'])
        return
    end
    
    GUI:ShowMenu('DialogMenu', button, button,
        {
            label = L['Import JPack rules will |cffff0000clear the current rules|r and |cffff0000reload addons|r, continue?'],
            buttons = {GUI.DialogButton.Okay, GUI.DialogButton.Cancel},
            func = function(result)
                if result == GUI.DialogButton.Okay then
                    tdPack:GetProfile().Orders.CustomOrder = JPACK_ORDER
                    tdPack:GetProfile().SaveToBank = JPACK_DEPOSIT
                    tdPack:GetProfile().LoadFromBank = JPACK_DRAW
                    ReloadUI()
                end
            end
        })
end

function tdPack:OnInit()
    self:RegisterCmd('/tdpack', '/tdp', '/tp')
    self:SetHandle('OnSlashCmd', self.Pack)
    
    self:InitDB('TDDB_TDPACK', {
        showmessage = true,
        messageframe = 2,
        
        SaveToBank = {},
        LoadFromBank = {},
        Orders = {
            CustomOrder = {},
            EquipLocOrder = {},
        }
    })
    
    do
        local profile = self:GetProfile()
        
        if #profile.Orders.CustomOrder == 0 then
            profile.Orders.CustomOrder = self.DefaultCustomOrder or {}
        end
        if #profile.Orders.EquipLocOrder == 0 then
            profile.Orders.EquipLocOrder = self.DefaultEquipLocOrder or {}
        end
        
        self.DefaultCustomOrder = nil
        self.DefaultEquipLocOrder = nil
    end
    
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
            },
            {
                type = 'Button', label = L['Import config from JPack'],
                width = 250,
                scripts = {
                    OnClick = ImportFromJPack
                },
            },
        },
        {
            type = 'ListWidget', label = L['Custom order'], itemObject = tdCore('GUI')('ListWidgetLinkItem'),
            verticalArgs = {-1, 0, 0, 0}, allowOrder = true,
            selectMode = 'MULTI', extraButtons = {GUI.ListButton.Add, GUI.ListButton.Delete, GUI.ListButton.SelectAll, GUI.ListButton.SelectNone},
            profile = {self:GetName(), 'Orders', 'CustomOrder'},
            scripts = {
                OnAdd = OnAdd,
            },
        },
        {
            type = 'ListWidget', label = L['EquipLoc order'], itemObject = tdCore('GUI')('ListWidgetLinkItem'),
            verticalArgs = {-1, 0, 0, 0}, allowOrder = true,
            profile = {self:GetName(), 'Orders', 'EquipLocOrder'},
        },
        {
            type = 'ListWidget', label = L['Save to bank rule'], itemObject = tdCore('GUI')('ListWidgetLinkItem'),
            verticalArgs = {-1, 0, 0, 0},
            selectMode = 'MULTI', extraButtons = {GUI.ListButton.Add, GUI.ListButton.Delete, GUI.ListButton.SelectAll, GUI.ListButton.SelectNone},
            profile = {self:GetName(), 'SaveToBank'},
            scripts = {
                OnAdd = OnAdd,
            },
        },
        {
            type = 'ListWidget', label = L['Load from bank rule'], itemObject = tdCore('GUI')('ListWidgetLinkItem'),
            verticalArgs = {-1, 0, 0, 0},
            selectMode = 'MULTI', extraButtons = {GUI.ListButton.Add, GUI.ListButton.Delete, GUI.ListButton.SelectAll, GUI.ListButton.SelectNone},
            profile = {self:GetName(), 'LoadFromBank'},
            scripts = {
                OnAdd = OnAdd,
            },
        },
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

tdPack.PackMenu = {
    { text = L['Pack asc'], onClick = function() tdPack:Pack('asc') end },
    { text = L['Pack desc'], onClick = function() tdPack:Pack('desc') end },
    { text = L['Save to bank'], onClick = function() tdPack:Pack('save') end },
    { text = L['Load from bank'], onClick = function() tdPack:Pack('load') end },
    { text = L['Open tdPack config frame'], onClick = function() tdPack:ToggleOption() end },
}