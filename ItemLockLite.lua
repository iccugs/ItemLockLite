-- ItemLockLite v0.5
-- Goal: "Lock Equipped Gear Mode" that prevents gear swaps by reverting equipment changes.
-- Approach: Snapshot equipped items when lock enabled; if any slot changes, auto-re-equip snapshot item.
-- This avoids taint from overriding Blizzard container APIs and avoids relying on bag button templates.

local addonName = "ItemLockLite"

-- SavedVariables
ItemLockLiteDB = ItemLockLiteDB or {}
ItemLockLiteDB.settings = ItemLockLiteDB.settings or { lockGear = false }

-- Runtime snapshot (not saved; rebuilt on login/when you toggle)
local equippedSnapshot = {}
local isReverting = false
local lastRevertTime = 0
local REVERT_COOLDOWN = 0.5  -- Half second cooldown between reverts

local function err(msg)
  UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
end

local function info(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00ItemLockLite|r: " .. msg)
end

-- Inventory slots we want to protect (equipment slots only)
local protectedSlots = {
  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17
}
-- 1 Head, 2 Neck, 3 Shoulder, 4 Shirt, 5 Chest, 6 Waist, 7 Legs, 8 Feet,
-- 9 Wrist, 10 Hands, 11 Finger1, 12 Finger2, 13 Trinket1, 14 Trinket2,
-- 15 Back, 16 MainHand, 17 OffHand

local function SnapshotEquipped()
  wipe(equippedSnapshot)
  for _, slot in ipairs(protectedSlots) do
    equippedSnapshot[slot] = GetInventoryItemLink("player", slot) -- can be nil
  end
end

local function ReEquipSlot(slot, retryCount)
  retryCount = retryCount or 0
  local wantedLink = equippedSnapshot[slot]
  if not wantedLink then
    -- If snapshot had nothing equipped here, we allow empty.
    return
  end

  -- If we're in combat, don't try to force equip (can cause protected action issues)
  if InCombatLockdown and InCombatLockdown() then
    return
  end
  
  -- First check if the item is currently in the slot being checked
  local currentLink = GetInventoryItemLink("player", slot)
  if currentLink == wantedLink then
    return
  end
  
  -- Check if there's something on the cursor
  local cursorType, cursorItemID, cursorItemLink = GetCursorInfo()
  if cursorType == "item" then
    ClearCursor()
  end
  
  -- Try to find the exact item in bags
  local foundBag, foundSlot = nil, nil
  for bag = 0, 4 do
    for bagSlot = 1, C_Container.GetContainerNumSlots(bag) do
      local itemLink = C_Container.GetContainerItemLink(bag, bagSlot)
      if itemLink == wantedLink then
        foundBag = bag
        foundSlot = bagSlot
        break
      end
    end
    if foundBag then break end
  end
  
  if not foundBag then
    -- Item might be in another equipment slot - check all slots
    for equipSlot = 1, 17 do
      if equipSlot ~= slot then
        local equipLink = GetInventoryItemLink("player", equipSlot)
        if equipLink == wantedLink then
          isReverting = true
          -- Swap items between equipment slots
          PickupInventoryItem(equipSlot)
          PickupInventoryItem(slot)
          C_Timer.After(0.3, function() 
            isReverting = false
          end)
          return
        end
      end
    end
    
    -- Item not found - retry if we haven't exceeded max retries
    if retryCount < 3 then
      C_Timer.After(0.2, function()
        ReEquipSlot(slot, retryCount + 1)
      end)
      return
    else
      return
    end
  end
  
  isReverting = true
  
  -- Use pickup/equip method which is more reliable
  C_Container.PickupContainerItem(foundBag, foundSlot)
  PickupInventoryItem(slot)
  
  -- The item that was in the slot is now on cursor - put it back in bags
  C_Timer.After(0.1, function()
    local cursorType = GetCursorInfo()
    if cursorType == "item" then
      -- Try to put it back in the original bag slot if empty, otherwise first available
      if C_Container.GetContainerItemInfo(foundBag, foundSlot) == nil then
        C_Container.PickupContainerItem(foundBag, foundSlot)
      else
        -- Find first empty bag slot
        for bag = 0, 4 do
          for bagSlot = 1, C_Container.GetContainerNumSlots(bag) do
            if C_Container.GetContainerItemInfo(bag, bagSlot) == nil then
              C_Container.PickupContainerItem(bag, bagSlot)
              break
            end
          end
        end
      end
    end
  end)
  
  -- Small delay before clearing isReverting to ensure event doesn't re-trigger
  C_Timer.After(0.3, function() 
    isReverting = false
  end)
end

local function OnEquipmentChanged(slot, hasItem)
  if not ItemLockLiteDB.settings.lockGear then return end
  if isReverting then return end
  
  -- Check cooldown to prevent rapid re-triggering
  local currentTime = GetTime()
  if currentTime - lastRevertTime < REVERT_COOLDOWN then
    return
  end

  -- Compare current vs snapshot; if different, revert.
  local currentLink = GetInventoryItemLink("player", slot)
  local wantedLink = equippedSnapshot[slot]

  -- If snapshot had nil, allow nil. If snapshot had item and current differs, revert.
  if wantedLink and currentLink ~= wantedLink then
    err("Gear locked: reverting swap.")
    lastRevertTime = currentTime
    -- Delay to allow item to settle into bags
    C_Timer.After(0.2, function() ReEquipSlot(slot) end)
  end
end

-- Best-effort: block drag from character slots (this *does* help)
local function HookPaperDollSlots()
  if not PaperDollItemsFrame then return end

  for _, slotName in ipairs({
    "HeadSlot","NeckSlot","ShoulderSlot","BackSlot","ChestSlot","ShirtSlot","TabardSlot",
    "WristSlot","HandsSlot","WaistSlot","LegsSlot","FeetSlot",
    "Finger0Slot","Finger1Slot","Trinket0Slot","Trinket1Slot",
    "MainHandSlot","SecondaryHandSlot"
  }) do
    local btn = _G["Character" .. slotName]
    if btn and not btn.__itemLockLiteHooked then
      btn:HookScript("OnDragStart", function()
        if ItemLockLiteDB.settings.lockGear then
          err("Gear locked: drag blocked.")
          ClearCursor()
        end
      end)
      btn.__itemLockLiteHooked = true
    end
  end
end

-- Slash command
SLASH_ITEMLOCKLITE1 = "/ilock"
SlashCmdList["ITEMLOCKLITE"] = function(msg)
  msg = (msg or ""):lower():gsub("^%s+",""):gsub("%s+$","")

  local function setLock(state)
    ItemLockLiteDB.settings.lockGear = state
    if state then
      SnapshotEquipped()
      info("Lock Equipped Gear Mode: ON (snapshot saved)")
    else
      info("Lock Equipped Gear Mode: OFF")
    end
  end

  if msg == "gear" or msg == "toggle" or msg == "" then
    setLock(not ItemLockLiteDB.settings.lockGear)
  elseif msg == "on" then
    setLock(true)
  elseif msg == "off" then
    setLock(false)
  elseif msg == "snap" then
    SnapshotEquipped()
    info("Snapshot refreshed.")
  else
    info("Commands: /ilock gear (toggle), /ilock on, /ilock off, /ilock snap")
  end
end

-- Init
local frame = CreateFrame("Frame")
local isInitialized = false

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

frame:SetScript("OnEvent", function(self, event, arg1, arg2)
  if event == "ADDON_LOADED" and arg1 == addonName then
    ItemLockLiteDB = ItemLockLiteDB or {}
    ItemLockLiteDB.settings = ItemLockLiteDB.settings or { lockGear = false }
    info("Loaded. Use /ilock gear to toggle gear lock.")
  elseif event == "PLAYER_LOGIN" then
    HookPaperDollSlots()
  elseif event == "PLAYER_ENTERING_WORLD" then
    if not isInitialized then
      isInitialized = true
      -- Delay slightly to ensure equipment data is fully loaded
      C_Timer.After(0.5, function()
        -- If lock was left ON previously, refresh snapshot on login
        if ItemLockLiteDB.settings.lockGear then
          SnapshotEquipped()
          info("Gear lock is ON. Snapshot refreshed.")
        end
      end)
    end
  elseif event == "PLAYER_EQUIPMENT_CHANGED" then
    -- Only process equipment changes after initialization
    if isInitialized then
      local slot = arg1
      local hasItem = arg2
      OnEquipmentChanged(slot, hasItem)
    end
  end
end)
