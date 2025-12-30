-- ItemLockLite v0.3
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

local function ReEquipSlot(slot)
  local wantedLink = equippedSnapshot[slot]
  if not wantedLink then
    -- If snapshot had nothing equipped here, we allow empty.
    return
  end

  -- If we’re in combat, don’t try to force equip (can cause protected action issues)
  if InCombatLockdown and InCombatLockdown() then
    return
  end

  -- Attempt to re-equip the snapshot item into the slot.
  -- EquipItemByName(itemLink, slot) is the simplest; if it fails, user may have moved/destroyed item.
  isReverting = true
  EquipItemByName(wantedLink, slot)
  isReverting = false
end

local function OnEquipmentChanged(slot, hasItem)
  if not ItemLockLiteDB.settings.lockGear then return end
  if isReverting then return end

  -- Compare current vs snapshot; if different, revert.
  local currentLink = GetInventoryItemLink("player", slot)
  local wantedLink = equippedSnapshot[slot]

  -- If snapshot had nil, allow nil. If snapshot had item and current differs, revert.
  if wantedLink and currentLink ~= wantedLink then
    err("Gear locked: reverting swap.")
    -- Slight delay helps if the equip event fires before client state settles.
    C_Timer.After(0, function() ReEquipSlot(slot) end)
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
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

frame:SetScript("OnEvent", function(self, event, arg1, arg2)
  if event == "ADDON_LOADED" and arg1 == addonName then
    ItemLockLiteDB = ItemLockLiteDB or {}
    ItemLockLiteDB.settings = ItemLockLiteDB.settings or { lockGear = false }
    info("Loaded. Use /ilock gear to toggle gear lock.")
  elseif event == "PLAYER_LOGIN" then
    HookPaperDollSlots()
    -- If lock was left ON previously, refresh snapshot on login
    if ItemLockLiteDB.settings.lockGear then
      SnapshotEquipped()
      info("Gear lock is ON. Snapshot refreshed on login.")
    end
  elseif event == "PLAYER_EQUIPMENT_CHANGED" then
    local slot = arg1
    local hasItem = arg2
    OnEquipmentChanged(slot, hasItem)
  end
end)
