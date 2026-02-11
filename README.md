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

## Latest Update (v0.8)
- **Notes**: No major refactoring was implemented (none of the code that you care about was changed).
- **Updates**: TOC `Interface` line was changed from 120000 to 120001. Version was bumped from 0.7 to 0.8 to adhere to CurseForge standards so users can update the add-on within the CurseForge app and eliminate "app is out-of-date" type errors.
- **Testing**: Item lock functionality was tested in the new WoW Retail version 12.0.1 and works as intended.

## Known Limitations

- Gear swaps made while in combat may not be reverted due to Blizzard restrictions
- If a locked item is destroyed or moved, it cannot be re-equipped
- This addon does not directly block selling or scrapping; it prevents gear loss by preserving the equipped state
- Swapping between two identical items (same item ID) may not be prevented in all cases

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and technical changes.

## License

MIT License — see LICENSE file for details
