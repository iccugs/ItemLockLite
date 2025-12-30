-- ItemLockLite: Lightweight item lock addon
-- Prevents accidental selling or using of locked items

local addonName = "ItemLockLite"

-- Initialize SavedVariables
ItemLockLiteDB = ItemLockLiteDB or {}
ItemLockLiteDB.locked = ItemLockLiteDB.locked or {}

-- Store original function
local OriginalUseContainerItem = C_Container.UseContainerItem

-- Override C_Container.UseContainerItem to block locked items
C_Container.UseContainerItem = function(bagID, slot, ...)
    local info = C_Container.GetContainerItemInfo(bagID, slot)
    if info and info.itemID then
        if ItemLockLiteDB.locked[info.itemID] then
            UIErrorsFrame:AddMessage("Item is locked!", 1.0, 0.1, 0.1, 1.0)
            return
        end
    end
    return OriginalUseContainerItem(bagID, slot, ...)
end

-- Function to toggle item lock
local function ToggleItemLock(itemID, itemLink)
    if not itemID then return end
    
    if ItemLockLiteDB.locked[itemID] then
        ItemLockLiteDB.locked[itemID] = nil
        UIErrorsFrame:AddMessage("Item unlocked: " .. itemLink, 0.1, 1.0, 0.1, 1.0)
    else
        ItemLockLiteDB.locked[itemID] = true
        UIErrorsFrame:AddMessage("Item locked: " .. itemLink, 1.0, 0.8, 0.1, 1.0)
    end
end

-- Hook bag item clicks
local function HookBagItems()
    -- Hook ContainerFrame item buttons
    hooksecurefunc("ContainerFrame_Update", function(frame)
        local bagID = frame:GetID()
        local name = frame:GetName()
        
        for i = 1, frame.size do
            local itemButton = _G[name.."Item"..i]
            if itemButton and not itemButton.lockHooked then
                itemButton:HookScript("OnClick", function(self, button)
                    if button == "RightButton" and IsAltKeyDown() then
                        local info = C_Container.GetContainerItemInfo(bagID, self:GetID())
                        if info and info.itemID then
                            ToggleItemLock(info.itemID, info.hyperlink)
                        end
                    end
                end)
                itemButton.lockHooked = true
            end
        end
    end)
end

-- Initialize addon
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize database structure
        ItemLockLiteDB = ItemLockLiteDB or {}
        ItemLockLiteDB.locked = ItemLockLiteDB.locked or {}
        print("|cFFFFFF00ItemLockLite|r loaded. Alt+RightClick items to lock/unlock.")
    elseif event == "PLAYER_LOGIN" then
        -- Hook bag items after UI is loaded
        HookBagItems()
    end
end)
