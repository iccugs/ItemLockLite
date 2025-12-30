# ItemLockLite

Lightweight item lock addon for World of Warcraft Retail to prevent accidental selling or using of locked items.

## Features

- Lock bag items with Alt+RightClick to prevent accidental actions
- Blocks locked items from being used via C_Container.UseContainerItem
- Visual feedback messages when locking/unlocking items
- Persistent lock state saved across sessions
- No external libraries or dependencies
- Minimal, lightweight design

## Installation

1. Download or clone this repository
2. Copy the `ItemLockLite` folder to your WoW AddOns directory:
   - Windows: `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\`
   - Mac: `/Applications/World of Warcraft/_retail_/Interface/AddOns/`
3. Restart WoW or reload UI with `/reload`

## Usage

- **Lock/Unlock Item**: Hold `Alt` and `Right-Click` on any item in your bags
- Locked items cannot be used or consumed
- Lock status is saved and persists across sessions
- Feedback messages appear when locking/unlocking items

## Technical Details

- **SavedVariables**: Uses `ItemLockLiteDB` with a `locked` table keyed by itemID
- **Hooks**: Alt+RightClick on default Blizzard bag items
- **Override**: C_Container.UseContainerItem blocks actions on locked items
- **Feedback**: UIErrorsFrame displays lock/unlock messages

## License

MIT License - See LICENSE file for details
