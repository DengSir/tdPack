
if not IsAddOnLoaded('Bagnon') then return end

local SIZE = 20
local NORMAL_TEXTURE_SIZE = 64 * (SIZE/36)

local tdPack = tdCore(...)
local L = tdPack:GetLocale()

local PackToggle = tdPack:NewModule('PackToggle', CreateFrame('Button'))

function PackToggle:New(parent)
    local b = self:Bind(CreateFrame('Button', nil, parent))
    b:SetWidth(SIZE)
    b:SetHeight(SIZE)
    b:RegisterForClicks('anyUp')

    local nt = b:CreateTexture()
    nt:SetTexture([[Interface\Buttons\UI-Quickslot2]])
    nt:SetWidth(NORMAL_TEXTURE_SIZE)
    nt:SetHeight(NORMAL_TEXTURE_SIZE)
    nt:SetPoint('CENTER', 0, -1)
    b:SetNormalTexture(nt)

    local pt = b:CreateTexture()
    pt:SetTexture([[Interface\Buttons\UI-Quickslot-Depress]])
    pt:SetAllPoints(b)
    b:SetPushedTexture(pt)

    local ht = b:CreateTexture()
    ht:SetTexture([[Interface\Buttons\ButtonHilight-Square]])
    ht:SetAllPoints(b)
    b:SetHighlightTexture(ht)

    local icon = b:CreateTexture()
    icon:SetAllPoints(b)
    icon:SetTexture([[Interface\Icons\INV_Misc_Gift_03]])

    b:SetScript('OnClick', self.OnClick)
    b:SetScript('OnEnter', self.OnEnter)
    b:SetScript('OnLeave', self.OnLeave)

    return b
end

function PackToggle:OnEnter()
    if self:GetRight() > (GetScreenWidth() / 2) then
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
    else
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    end
    GameTooltip:SetText('tdPack')
    GameTooltip:AddLine(L['<Left Click> '] .. L['Pack bags'], 1, 1, 1)
    GameTooltip:AddLine(L['<Right Click> '] .. L['Show pack menu'], 1, 1, 1)
    GameTooltip:Show()
end

function PackToggle:OnLeave()
    GameTooltip:Hide()
end

function PackToggle:OnClick(button)
    if button == 'LeftButton' then
        tdPack:Pack()
    elseif button == 'RightButton' then
        tdCore('GUI'):ToggleMenu('ComboMenu', self, tdPack.PackMenu)
    end
end

local Frame = Bagnon.Frame

function Frame:GetPackToggle()
    return self.packToggle
end

function Frame:CreatePackToggle()
    local toggle = PackToggle:New(self)
    self.packToggle = toggle
    return toggle
end

function Frame:PlaceMenuButtons()
    local menuButtons = self.menuButtons or {}
    self.menuButtons = menuButtons

    --hide the old buttons
    for i, button in pairs(menuButtons) do
        button:Hide()
        menuButtons[i] = nil
    end

    if self:HasPlayerSelector() then
        local selector = self:GetPlayerSelector() or self:CreatePlayerSelector()
        tinsert(menuButtons, selector)
    end

    if self:HasBagFrame() and self:HasBagToggle() then
        local toggle = self:GetBagToggle() or self:CreateBagToggle()
        tinsert(menuButtons, toggle)
    end
    
    -- guild bank support
    if self:HasLogs() then
        for i, toggle in ipairs(self:GetLogToggles()) do
            tinsert(menuButtons, toggle)
        end
    end
    
    local frameID = self:GetFrameID()
    if frameID == 'bank' or frameID == 'inventory' then
        tinsert(menuButtons, self:GetPackToggle() or self:CreatePackToggle())
    end
    
    if self:HasSearchToggle() then
        local toggle = self:GetSearchToggle() or self:CreateSearchToggle()
        tinsert(menuButtons, toggle)
    end

    for i, button in ipairs(menuButtons) do
        button:ClearAllPoints()
        if i == 1 then
            button:SetPoint('TOPLEFT', self, 'TOPLEFT', 8, -8)
        else
            button:SetPoint('TOPLEFT', menuButtons[i-1], 'TOPRIGHT', 4, 0)
        end
        button:Show()
    end

    local numButtons = #menuButtons
    if numButtons > 0 then
        return (menuButtons[1]:GetWidth() + 4 * numButtons - 4), menuButtons[1]:GetHeight()
    end
    return 0, 0
end
