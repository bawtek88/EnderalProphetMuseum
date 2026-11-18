# The Prophet's Museum

An in-development museum mod for **Enderal: Forgotten Stories (Special Edition)**. The project is inspired by the display and collection loop of Legacy of the Dragonborn, but is deliberately smaller in scope and built specifically for Enderal.

## Current features

- Dedicated museum interior
- Individual item display activators
- Displayed-object interaction and physics blocking
- Armor-set displays using mannequins
- Replica crafting and permanent recipe unlock tracking
- Museum display counter

## Requirements

- Enderal: Forgotten Stories (Special Edition)
- The Skyrim Special Edition runtime used by Enderal SE
- SKSE for that Enderal installation

The plugin has the following masters:

- `Skyrim.esm`
- `Update.esm`
- `Enderal - Forgotten Stories.esm`

## Installation

Install the repository contents as a normal Mod Organizer 2 mod and enable `ProphetMuseum.esp`. The folder structure is already Data-relative.

This is an early development build. It is not yet intended for a normal playthrough, and test records may still be present.

## Development layout

- `ProphetMuseum.esp` — plugin records and placed references
- `Scripts/` — compiled Papyrus scripts used by the game
- `Source/Scripts/` — editable Papyrus source
- `SEQ/` — start-game-enabled quest registration data
- `meshes/` and `textures/` — only custom assets currently referenced by the plugin

When changing a Papyrus script, commit both the `.psc` source and its newly compiled `.pex` file.

## Third-party assets

Some display furniture meshes originate from DarkFox/Dark's modding resources and are included because their permissions allow reuse. Only assets currently referenced by this plugin are stored here. See [THIRD_PARTY.md](THIRD_PARTY.md) for details.

Bethesda and Enderal game assets are not included. The custom meshes reference textures supplied by the required game installation, except for the explicitly included custom glass texture.
