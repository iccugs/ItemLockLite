# ItemLockLite

ItemLockLite is a lightweight World of Warcraft Retail addon that prevents accidental gear swaps by enforcing a locked equipment state. It is designed for fast-paced farming and Remix gameplay where rapid looting, scrapping, and movement can lead to unintended gear changes.

## What It Does

When gear lock is enabled, ItemLockLite snapshots your currently equipped items.  
If any of those items are accidentally swapped or unequipped, the addon automatically re-equips the original item.

This approach avoids UI taint and does not interfere with bag usage, consumables, or scrapping.

## Features

- Lock your currently equipped gear with a simple toggle
- Automatically re-equips locked gear if a swap occurs
- Prevents accidental gear loss during rapid looting or scrapping
- Allows consumables, quest items, and bag interactions
- Persistent lock state across sessions
- No external libraries or dependencies
- Minimal, low-overhead design

## Installation

1. Download or clone this repository
2. Copy the `ItemLockLite` folder to your WoW AddOns directory:
   - Windows: `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\`
   - Mac: `/Applications/World of Warcraft/_retail_/Interface/AddOns/`
3. Restart WoW or reload the UI with `/reload`

## Usage

- Enable gear lock:
  ```
  /ilock on
  ```
- Disable gear lock:
  ```
  /ilock off
  ```
- Toggle gear lock:
  ```
  /ilock
  ```
- Refresh the gear snapshot manually (optional):
  ```
  /ilock snap
  ```
- Open settings panel:
  ```
  /ilock config
  ```

You can also manage the gear lock via the in-game settings panel:
- Press `ESC` > `Options` > `AddOns` > `ItemLockLite`

### Recommended Workflow

1. Equip your desired gear
2. Enable gear lock (`/ilock on` or via settings panel)
3. Loot, scrap, and farm freely without fear of accidental gear swaps

If you intentionally want to change gear, disable the lock, make changes, then re-enable it.

## Technical Details

- **SavedVariables**: Uses `ItemLockLiteDB.settings.lockGear`
- **Approach**: Detects equipment changes and reverts them when locked
- **Events**: Uses `PLAYER_EQUIPMENT_CHANGED`
- **API**: Uses modern `C_Item.EquipItemByName` (patch 10.2.6+) with fallback to deprecated API for compatibility
- **Safety**: Avoids overriding protected container or equip APIs
- **UI Feedback**: Uses `UIErrorsFrame` and chat messages

## Latest Update (v0.7)
- **Added**: In-game settings panel accessible via ESC > Options > AddOns > ItemLockLite
- **Added**: `/ilock config` command to open settings directly
- **Improved**: Simplified slash commands for cleaner interface
- **Improved**: Code quality with better handling of unused function returns

## Previous Updates (v0.6)
- **Verified**: Compatible with WoW Pre-Release Version 12.0.0

## v0.5

- **Fixed**: Critical bug where gear lock would intermittently fail to re-equip items
- **Improved**: Complete rewrite of re-equip mechanism for 100% reliability
- **Enhanced**: Automatic retry system handles timing issues when swapping items rapidly
- **Added**: Intelligent cooldown system prevents swap loops and event conflicts

## Previous Updates (v0.4)

- **Fixed**: Updated to use `C_Item.EquipItemByName` API for patch 10.2.6+ compatibility
- **Fixed**: Corrected timer usage to `C_Timer.After` for proper functionality
- **Improved**: Automatic API fallback ensures compatibility with older WoW versions
- **Enhanced**: Increased revert delay to 50ms for better client state stability

## Limitations

- Gear swaps made while in combat may not be reverted due to Blizzard restrictions
- If a locked item is destroyed or moved, it cannot be re-equipped
- This addon does not directly block selling or scrapping; it prevents gear loss by preserving the equipped state
- Swapping between two identical items (same item ID) may not be prevented in all cases

## License

MIT License — see LICENSE file for details
