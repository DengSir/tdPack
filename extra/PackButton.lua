
local tdPack = tdCore(...)
local L = tdPack:GetLocale()

local PackButton = tdPack:NewModule('PackButton', CreateFrame('Button'))
tdCore('GUI'):Embed(PackButton, 'UIObject')

function PackButton:New(parent)
    local obj = self:Bind(CreateFrame('Button', nil, parent))
    obj:RegisterForClicks('anyUp')

    obj:SetScript('OnClick', self.OnClick)
    obj:SetNote{'tdPack', L['<Left Click> '] .. L['Pack bags'], L['<Right Click> '] .. L['Show pack menu']}

    return obj
end

function PackButton:OnClick(button)
    if button == 'LeftButton' then
        tdPack:Pack()
    elseif button == 'RightButton' then
        tdCore('GUI'):ToggleMenu(self, 'ComboMenu', tdPack.PackMenu)
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
