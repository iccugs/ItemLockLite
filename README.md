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

### Recommended Workflow

1. Equip your desired gear
2. Enable gear lock (`/ilock on`)
3. Loot, scrap, and farm freely without fear of accidental gear swaps

If you intentionally want to change gear, disable the lock, make changes, then re-enable it.

## Technical Details

- **SavedVariables**: Uses `ItemLockLiteDB.settings.lockGear`
- **Approach**: Detects equipment changes and reverts them when locked
- **Events**: Uses `PLAYER_EQUIPMENT_CHANGED`
- **Safety**: Avoids overriding protected container or equip APIs
- **UI Feedback**: Uses `UIErrorsFrame` and chat messages

## Limitations

- Gear swaps made while in combat may not be reverted due to Blizzard restrictions
- If a locked item is destroyed or moved, it cannot be re-equipped
- This addon does not directly block selling or scrapping; it prevents gear loss by preserving the equipped state

## License

MIT License — see LICENSE file for details
