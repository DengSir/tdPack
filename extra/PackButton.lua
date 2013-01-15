
local tdPack = tdCore(...)
local L = tdPack:GetLocale()

local PackButton = tdPack:NewModule('PackButton', CreateFrame('Button'))

function PackButton:New(parent)
    local obj = self:Bind(CreateFrame('Button', nil, parent))
    obj:RegisterForClicks('anyUp')

    obj:SetScript('OnClick', self.OnClick)
    obj:SetScript('OnEnter', self.OnEnter)
    obj:SetScript('OnLeave', self.OnLeave)

    return obj
end

function PackButton:OnEnter()
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

function PackButton:OnLeave()
    GameTooltip:Hide()
end

function PackButton:OnClick(button)
    if button == 'LeftButton' then
        tdPack:Pack()
    elseif button == 'RightButton' then
        tdCore('GUI'):ToggleMenu('ComboMenu', self, tdPack.PackMenu)
    end
end

function PackButton:GetPackButton(parent)
    if not parent.tdPackButton then
        parent.tdPackButton = self:New(parent)
        parent.tdPackButton:Init()
    end
    return parent.tdPackButton
end

function PackButton:Init()
end
