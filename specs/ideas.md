# Munchkin Dungeon — Design Ideas & Backlog

Feature and UX ideas to incorporate. Not yet part of any subsystem design — captured here for later integration.

---

## Fog of War Map

The dungeon map is **not fully visible from the start**. Players can only see a limited number of rooms ahead.

- **Default visibility**: see the next 1-2 rooms ahead (current room + next)
- **Room type icons**: visible rooms show their type icon (monster, treasure, rest, curse, boss, unknown)
- **Hidden depth**: rooms beyond visibility show as "?" — could be anything
- This reinforces the push-your-luck tension: you know a rest is *somewhere* ahead, but not exactly where

### Visibility Extenders

Items that increase how far ahead you can see:

| Item Type | Effect | Example |
|-----------|--------|---------|
| Hat (common) | +1 visibility | "Grandpa's Reading Glasses (On a Stick)" |
| Consumable | Reveal next 3 rooms for current dungeon | "Dungeon Map Scroll" (shop item, ~20g) |
| Equipment enchant | +1 permanent visibility | Rare hat effect |

### Dungeon Map (Shop Item)

Buyable consumable that reveals the full dungeon layout:
- Shows all room types for the current dungeon
- One-time use, consumed on purchase
- Cost: ~35-40g (meaningful expense — ~half an easy dungeon's earnings)
- Could be a "Rusty Map" sold by a shady vendor with 10% chance of being wrong about one room

---

## Monster Sizes

Monsters can have different visual sizes, affecting both presentation and gameplay:

- **Small**: swarm creatures (bats, fingers, roaches). Visually tiny. Can stack multiple in one grid cell.
- **Medium**: standard size (most strikers, supports, standard bruisers). One per cell.
- **Large**: big bruisers, bosses. Take up 2 cells (front row width). Can't be flanked by multiple small enemies on the same row.

Size is already implicit in the swarm mechanics (×3, ×4 groups), but making it explicit in the visual/grid system adds clarity and could open up positioning interactions.

---

## UI Layout

### Bottom-Left: Character Stats & Equipment

- Show current party: portraits, HP bars, stats, equipped items
- Click/tap a character to see full details
- Equipment slots visible: weapon, armor, hat, boots
- Active buffs/debuffs shown as icons

### Bottom-Right: Dungeon Map

- Horizontal room chain (left-to-right progression)
- Each room as an icon with type indicator
- Current room highlighted
- Visibility range shown (rooms beyond range are dimmed/hidden)
- Fog of war: "?" for unseen rooms

```
┌─────────────────────────────────┐
│         COMBAT AREA             │
│    [Front] [Front]              │
│    [Back]  [Back]    VS         │
│    [Front] [Front]              │
│    [Back]  [Back]               │
├────────────────┬────────────────┤
│ PARTY & EQUIP  │    DUNGEON MAP  │
│ [Warrior] 90HP │ [M]→[?]→[?]→.. │
│ ⚔+10 🛡+8      │  ↑ you are here │
│ [Mage]   74HP  │                 │
│ 🔮+12          │                 │
│ [Rogue]  82HP  │                 │
│ 🗡+8  👟+3     │                 │
│ [Cleric] 100HP │                 │
│ ⛏+6  🛡+10    │                 │
└────────────────┴────────────────┘
```

---

## Equipment Display on Characters

Visual representation of equipped gear on character sprites:

- **Weapon**: shown in hand / at side
- **Armor**: changes torso appearance (light/medium/heavy visual)
- **Hat**: shown on head (this is the fun slot — buckets, wizard hats, chicken costumes)
- **Boots**: subtle foot appearance change

This is mostly a polish/visual feature but important for the "loot goblin" satisfaction — you *see* your character getting cooler as you gear up.

### Implementation Note

For a game jam, this could be simplified:
- Equipment shown as icon overlays on character portraits (not full sprite changes)
- Hat slot gets a dedicated visual since it's the humor slot
- Full sprite customization is post-jam scope
