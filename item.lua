﻿
local type, tonumber = type, tonumber

local BattlePetSubTypes = {GetAuctionItemSubClasses(11)}
local GetPetInfoBySpeciesID = C_PetJournal.GetPetInfoBySpeciesID

local tdPack = tdCore(...)
local L = tdPack:GetLocale()

local Rule = tdPack('Rule')
local Item = tdPack:NewModule('Item', {}, 'Base')

function Item:New(parent, bag, slot)
    local itemID = tdPack:GetBagSlotID(bag, slot)
    if not itemID then
        return
    end
    
    local obj = self:Bind{}
    
    local itemName, itemType, itemSubType, itemEquipLoc, itemQuality, itemLevel, itemTexture = self:GetItemInfo(itemID)
    
    obj:SetParent(parent)
    obj.itemID = itemID
    obj.itemName = itemName
    obj.itemType = itemType
    obj.itemSubType = itemSubType
    obj.itemEquipLoc = itemEquipLoc
    obj.itemQuality = itemQuality
    obj.itemLevel = itemLevel
    obj.itemTexture = itemTexture
    
    return obj
end

function Item:GetItemInfo(itemID)
    local itemName, itemType, itemSubType, itemEquipLoc, itemQuality, itemLevel, itemTexture
    if type(itemID) == 'number' then
        itemName, _, itemQuality, itemLevel, _, itemType, itemSubType, _, itemEquipLoc, itemTexture = GetItemInfo(itemID)
    else
        local SpeciesID
        SpeciesID, itemLevel, itemQuality = itemID:match('battlepet:(%d+):(%d+):(%d+)')
        itemName, itemTexture, itemSubType = GetPetInfoBySpeciesID(tonumber(SpeciesID))
        itemType = L.BattlePet
        itemSubType = BattlePetSubTypes[itemSubType]
    end
    
    return itemName, itemType, itemSubType, itemEquipLoc, itemQuality, itemLevel, itemTexture
end

function Item:GetFamily()
    local itemID = self:GetItemID()
    
    return type(itemID) == 'string' and 0 or GetItemFamily(itemID)
end

function Item:NeedSaveToBank()
    if tdPack:IsLoadToBag() then
        return Rule:NeedSaveToBank(self) and not Rule:NeedLoadToBag(self)
    else
        return Rule:NeedSaveToBank(self)
    end
end

function Item:NeedLoadToBag()
    if tdPack:IsSaveToBank() then
        return Rule:NeedLoadToBag(self) and not Rule:NeedSaveToBank(self)
    else
        return Rule:NeedLoadToBag(self)
    end
end

function Item:GetItemID()
    return self.itemID or 0
end

function Item:GetItemName()
    return self.itemName or ''
end

function Item:GetItemType()
    return self.itemType or ''
end

function Item:GetItemSubType()
    return self.itemSubType or ''
end

function Item:GetItemLevel()
    return self.itemLevel or ''
end

function Item:GetItemQuality()
    return self.itemQuality or 1
end

function Item:GetItemTexture()
    return self.itemTexture or ''
end

function Item:GetItemEquipLoc()
    return self.itemEquipLoc or ''
end
