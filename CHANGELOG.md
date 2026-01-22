# Changelog

## [0.6] - 2026-01-22
- **Verified**: Compatible with WoW Pre-Release Version 12.0.0

### Fixed
- **Critical Bug**: Fixed gear lock not working reliably - items would sometimes not be re-equipped
  - Completely rewrote the re-equip mechanism to use pickup/place method instead of EquipItemByName
  - Added retry logic (up to 3 attempts) to handle timing issues when items haven't settled into bags yet
  - Properly handles cursor state and places displaced items back into bags
  - Added cooldown system to prevent rapid re-triggering and swap loops

## [0.5] - 2026-01-15

### Fixed
- **Critical Bug**: Fixed gear lock not working reliably - items would sometimes not be re-equipped
  - Completely rewrote the re-equip mechanism to use pickup/place method instead of EquipItemByName
  - Added retry logic (up to 3 attempts) to handle timing issues when items haven't settled into bags yet
  - Properly handles cursor state and places displaced items back into bags
  - Added cooldown system to prevent rapid re-triggering and swap loops

### Improved
- **Reliability**: Gear swaps are now blocked and reverted consistently, even with rapid successive swaps
- **Item Detection**: Searches both bags and equipment slots to find the correct item to re-equip
- **Edge Cases**: Handles scenarios where items are temporarily on cursor or in other equipment slots

### Technical Changes
- Switched from `C_Item.EquipItemByName()` to `C_Container.PickupContainerItem()` + `PickupInventoryItem()` method
- Added automatic retry mechanism with 0.2s delays between attempts (max 3 retries)
- Implemented 0.5s cooldown between revert operations to prevent event loops
- Extended `isReverting` flag duration to 0.3s to ensure event handling stability
- Added proper cursor state management to handle displaced items

## [0.4] - 2026-01-09

### Fixed
- **API Deprecation**: Updated from deprecated `EquipItemByName` to `C_Item.EquipItemByName` (patch 10.2.6+)
  - Blizzard deprecated the old API in patch 10.2.6 and moved it to C_Item namespace
  - Addon now uses the modern API to ensure future compatibility
- **Timer Function**: Corrected to use `C_Timer.After` instead of incorrect timer implementation

### Improved
- **API Compatibility**: Automatic fallback to deprecated API for older WoW versions (pre-10.2.6)
- **Revert Timing**: Increased revert delay from 0ms to 50ms for better client state stability
- **Code Quality**: Cleaner implementation with proper API usage

### Technical Changes
- Replaced `EquipItemByName()` with `C_Item.EquipItemByName()` where available
- Added conditional check for `C_Item` namespace existence for backward compatibility
- Updated timer calls to use correct `C_Timer.After()` syntax
- Maintained simple item link comparison for reliable gear locking

## [0.3] - Previous Version

### Features
- Basic gear locking functionality
- Character paper doll drag blocking
- Slash commands for toggling lock state
- Persistent settings across sessions

### Known Issues (Fixed in 0.4)
- Infinite loop when swapping identical items
- Using deprecated API that may be removed in future patches
