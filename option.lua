
local tdPack = tdCore(...)
local L = tdPack:GetLocale()

local GUI = tdCore('GUI')

local ItemMenu
ItemMenu = GUI:CreateGUI({
    type = 'Widget', label = L['Add rule'],
    width = 400, height = 200,
    scripts = {
        OnShow = function(self)
            self.itemID = nil
            self.itemType = nil
            self.itemSubType = nil
            self:GetControl('ItemInfo'):SetLabelText([[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t ]] .. L['|cff00ff00Drag item to here|r'])
            self:GetControl('TypeCheckBox'):SetLabelText(L['Type'])
            self:GetControl('SubtypeCheckBox'):SetLabelText(L['Sub type'])
            self:GetControl('ByIDWidget'):SetValueText('')
            self:GetControl('InputLineEdit'):SetText('')
            self:GetControl('TypeCheckBox'):SetChecked(true)
            self:GetControl('SubtypeCheckBox'):SetChecked(true)
        end
    },
    {
        type = 'TabWidget', height = 80, verticalArgs = {100, -20, 0, 0}, name = 'AddTypeWidget',
        {
            type = 'Widget', label = L['By id'], name = 'ByIDWidget',
        },
        {
            type = 'Widget', label = L['By type'],
            {
                type = 'CheckBox', label = L['Type'], verticalArgs = {0, 0, 0}, name = 'TypeCheckBox',
            },
            {
                type = 'CheckBox', label = L['Sub type'], verticalArgs = {0, 0, 150}, name = 'SubtypeCheckBox',
            },
        },
        {
            type = 'Widget', label = L['By input'],
            {
                type = 'LineEdit', label = L['Please input rule:'], name = 'InputLineEdit',
            }
        },
    },
    {
        type = 'Button', name = 'ItemInfo', verticalArgs = {50, -12, 0, 0},
        height = 36,
        scripts = {
            OnClick = function()
                local type, _, link = GetCursorInfo()
                if type == 'item' then
                    ClearCursor()
                    ItemMenu:OnSetItem(tdPack:GetItemID(link))
                end
            end,
        }
    },
    {
        type = 'Button', label = ADD, verticalArgs = {0, -8, 0},
        scripts = {
            OnClick = function()
                local addtype = ItemMenu:GetControl('AddTypeWidget'):GetSelected()
                local rule
                if addtype == L['By id'] then
                    rule = ItemMenu.itemID
                elseif addtype == L['By type'] then
                    rule = (ItemMenu:GetControl('TypeCheckBox'):GetChecked() and '#' .. ItemMenu.itemType or '') .. 
                           (ItemMenu:GetControl('SubtypeCheckBox'):GetChecked() and '##' .. ItemMenu.itemSubType or '')
                elseif addtype == L['By input'] then
                    rule = ItemMenu:GetControl('InputLineEdit'):GetText()
                else
                    return
                end
                
                if type(rule) == 'string' and rule:trim() == '' then
                    return
                end
                ItemMenu.caller:GetItemList():InsertItem(rule)
                ItemMenu.caller:SetProfileValue(ItemMenu.caller:GetItemList(), true)
                ItemMenu.caller:Refresh()
                ItemMenu:Hide()
            end
        }
    },
    {
        type = 'Button', label = CANCEL, verticalArgs = {40, -8, 100},
        scripts = {
            OnClick = function()
                ItemMenu:Hide()
            end
        }
    },
})

function ItemMenu:OnSetItem(itemID)
    local itemName, itemType, itemSubType, itemEquipLoc, itemQuality, _, itemTexture = tdPack:GetItemInfo(itemID)
    
    local r, g, b = GetItemQualityColor(itemQuality)
    
    self.itemID = itemID
    self.itemType = itemType
    self.itemSubType = itemSubType
    
    self:GetControl('ItemInfo'):SetFormattedText('|T%s:24|t |cff%02x%02x%02x%s|r', itemTexture, r * 0xff, g * 0xff, b * 0xff, itemName)
    self:GetControl('TypeCheckBox'):SetFormattedText('%s - %s', L['Type'], itemType)
    self:GetControl('SubtypeCheckBox'):SetFormattedText('%s - %s', L['Sub type'], itemSubType)
    self:GetControl('ByIDWidget'):SetValueText('ID: ' .. itemID)
end

do
    ItemMenu:SetFrameStrata('DIALOG')
    ItemMenu:SetBackdropColor(0, 0, 0, 0.9)
    ItemMenu:GetLabelFontString():ClearAllPoints()
    ItemMenu:GetLabelFontString():SetPoint('TOPLEFT', 10, -10)
    ItemMenu:ClearAllPoints()
    ItemMenu:SetPoint('CENTER')
    ItemMenu:Hide()
    
    local ItemInfo = ItemMenu:GetControl('ItemInfo')
    ItemInfo:SetBackdrop{
        bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
        edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
        edgeSize = 14, tileSize = 20, tile = true,
        insets = {left = 2, right = 2, top = 2, bottom = 2},
    }
    ItemInfo:SetBackdropColor(0, 0, 0, 0.4)
    ItemInfo:SetBackdropBorderColor(1, 1, 1, 1)

    ItemInfo:SetNormalFontObject('GameFontHighlightSmall')
    ItemInfo:SetHighlightTexture([[Interface\TokenFrame\UI-TokenFrame-CategoryButton]])
    ItemInfo:GetHighlightTexture():SetTexCoord(0, 1, 0.609375, 0.796875)
    ItemInfo:GetHighlightTexture():SetAlpha(0.5)
    ItemInfo:GetHighlightTexture():SetPoint('TOPLEFT', 3, -3)
    ItemInfo:GetHighlightTexture():SetPoint('BOTTOMRIGHT', -3, 3)
    ItemInfo:SetNormalTexture(nil)
    ItemInfo:SetPushedTexture(nil)

    ItemInfo:GetLabelFontString():SetPoint('LEFT', 10, 0)
    ItemInfo:SetFontString(ItemInfo:GetLabelFontString())
    
    local ByIDWidget = ItemMenu:GetControl('ByIDWidget')
    ByIDWidget:GetValueFontString():SetPoint('TOPLEFT', 20, -20)
end

local function OnAdd(self)
    ItemMenu.caller = self
    ItemMenu:Show()
end

local function ImportFromJPack()
    if not IsAddOnLoaded('JPack') then
        GUI:ShowMenu('DialogMenu', nil, nil, L['%s not loaded.']:format('JPack'))
        return
    end
    
    GUI:ShowMenu('DialogMenu', nil, nil,
        {
            label = L['Import %s rules will |cffff0000clear the current rules|r and |cffff0000reload addons|r, continue?']:format('JPack'),
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

function tdPack:LoadOption()
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
                type = 'ComboBox', label = L['Import rules from other addon'] .. [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t]],
                itemList = {
                    {text = L['Import rules from |cffffffff%s|r']:format('JPack'), onClick = ImportFromJPack},
                }
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
--            verticalArgs = {-1, 0, 0, 0},
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