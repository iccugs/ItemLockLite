# Changelog

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
