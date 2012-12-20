
local tdPack = tdCore(...)

local ipairs, ripairs, tinsert, tremove, wipe = ipairs, ripairs, tinsert, tremove, wipe
local ActionStatus_DisplayMessage = ActionStatus_DisplayMessage

local Bag = tdPack('Bag')
local Slot = tdPack('Slot')
local Pack = tdPack:NewModule('Pack', CreateFrame('Frame'), 'Event', 'Update')
local L = tdPack:GetLocale()

Pack.updateElapsed = 0.1
Pack.nextUpdate = 0
Pack.isBankOpened = nil
Pack.status = 'free'
Pack.slots = {}
Pack.bags = {}

function Pack:IsLocked()
    for _, bag in ipairs(self.bags) do
        if bag:IsLocked() then
            return true
        end
    end
end

function Pack:FindSlot(item, tarSlot)
    for _, bag in ipairs(self.bags) do
        local slot = bag:FindSlot(item, tarSlot)
        if slot then
            return slot
        end
    end
end

function Pack:Start()
    if self.status ~= 'free' then
        self:ShowMessage(L['Packing now'], 1, 0, 0)
        return
    end
    
    if InCombatLockdown() then
        self:ShowMessage(L['Player in combat'], 1, 0, 0)
        return
    end
    
    if GetCursorInfo() then
        self:ShowMessage(L['Please drop the item holding on your mouse. Don\'t click/hold item, money, skills while packing.'], 1, 0, 0)
    end
    
    self:SetStatus('ready')
    self:StartUpdate()
end

function Pack:Stop()
    self:StopUpdate()
    
    wipe(self.bags)
    wipe(self.slots)
    self:SetStatus('free')
end

function Pack:ShowMessage(text, r, g, b)
--    ActionStatus_DisplayMessage(format('|cff%02x%02x%02x%s|r', (r or 1) * 0xff, (g or 1) * 0xff, (b or 1) * 0xff, text), true)
    UIErrorsFrame:AddMessage(text, r or 1, g or 1, b or 1, 1)
end

------ stack

local bags = {
    bag = {0, 1, 2, 3, 4},
    bank = {0, 1, 2, 3, 4, -1, 5, 6, 7, 8, 9, 10, 11},
}

function Pack:StackReady()
    for _, bag in ipairs(self.isBankOpened and bags.bank or bags.bag) do
        for slot = 1, tdPack:GetBagNumSlots(bag) do
            if not tdPack:IsBagSlotEmpty(bag, slot) and not tdPack:IsBagSlotFull(bag, slot) then
                tinsert(self.slots, Slot:New(nil, bag, slot))
            end
        end
    end
end

function Pack:Stack()
    local stackingSlots = {}
    local complete = true
    
    for i, slot in ripairs(self.slots) do
        if slot:IsLocked() then
            complete = false
        else
            if not slot:IsEmpty() and not slot:IsFull() then
                local itemID = slot:GetItemID()
                if stackingSlots[itemID] then
                    slot:MoveTo(stackingSlots[itemID])
                    
                    stackingSlots[itemID] = nil
                    complete = false
                else
                    stackingSlots[itemID] = slot
                end
            else
                tremove(self.slots, i)
            end
        end
    end
    return complete
end

function Pack:StackFinish()
    wipe(self.slots)
end

local startTime
function Pack:PackReady()
    wipe(self.bags)
    
    startTime = GetTime()
    
    local bag, bank
    
    bag = Bag:New('bag')
    tinsert(self.bags, bag)
    
    if self.isBankOpened then
        bank = Bag:New('bank')
        tinsert(self.bags, bank)
        
        
        if tdPack:IsLoadToBag() and tdPack:IsSaveToBank() then
            local loadTo = bank:GetSwapItems()
            local saveTo = bag:GetSwapItems()
            
            bag:ChooseItems(loadTo)
            bank:ChooseItems(saveTo)
            
            bag:RestoreItems()
            bank:RestoreItems()
        elseif tdPack:IsLoadToBag() then
            local loadTo = bank:GetSwapItems()
            bag:ChooseItems(loadTo)
            bank:RestoreItems()
        elseif tdPack:IsSaveToBank() then
            local saveTo = bag:GetSwapItems()
            bank:ChooseItems(saveTo)
            bag:RestoreItems()
        end
        
        bank:Sort()
    end
    bag:Sort()
end

function Pack:Pack()
    local complete = true
    for _, bag in ipairs(self.bags) do
        if not bag:Pack() then
            complete = false
        end
    end
    return complete
end

function Pack:PackFinish()
    wipe(self.bags)
    
    print(GetTime() - startTime)
end

------ status

function Pack:SetStatus(status)
    self.status = status
    
--    print(status)
end

function Pack:StatusReady()
    if self:IsLocked() then
        return
    end
    
    self:StackReady()
    self:SetStatus('stacking')
end

function Pack:StatusStacking()
    if not self:Stack() then
        return
    end
    
    self:SetStatus('stacked')
    self:StackFinish()
end

function Pack:StatusStacked()
    if self:IsLocked() then
        return
    end
    
    self:PackReady()
    self:SetStatus('packing')
end

function Pack:StatusPacking()
    if not self:Pack() then
        return
    end
    
    self:SetStatus('packed')
    self:PackFinish()
end

function Pack:StatusPacked()
    self:SetStatus('finish')
end

function Pack:StatusFinish()
    self:Stop()
    self:ShowMessage(L['Pack finish.'], 0, 1, 0)
end

function Pack:StatusCancel()
    self:Stop()
end

Pack.statusProc = {
    ready    = Pack.StatusReady,
    stacking = Pack.StatusStacking,
    stacked  = Pack.StatusStacked,
    packing  = Pack.StatusPacking,
    packed   = Pack.StatusPacked,
    finish   = Pack.StatusFinish,
    cancel   = Pack.StatusCancel,
}

function Pack:OnUpdate(elapsed)
    self.nextUpdate = self.nextUpdate - elapsed
    if self.nextUpdate < 0 then
        self.nextUpdate = self.updateElapsed
        
        local proc = self.statusProc[self.status]
        if proc then
            proc(self)
        end
    end
end

------ event

function Pack:BANKFRAME_OPENED()
    self.isBankOpened = true
end

function Pack:BANKFRAME_CLOSED()
    self.isBankOpened = nil
    if self.status ~= 'free' then
        self:SetStatus('cancel')
    end
end

function Pack:PLAYER_ENTER_COMBAT()
    if self.status ~= 'free' then
        self:SetStatus('cancel')
        self:ShowMessage(L['Player enter combat, pack cancel.'], 1, 0, 0)
    end
end

function Pack:OnInit()
    self:RegisterEvent('BANKFRAME_OPENED')
    self:RegisterEvent('BANKFRAME_CLOSED')
    self:RegisterEvent('PLAYER_ENTER_COMBAT')
end
