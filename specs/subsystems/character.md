---
title: Character & Progression
date: 2026-04-10
tags:
  - subsystem
  - munchkin-dungeon
  - characters
  - progression
---

# Character & Progression

## Purpose

Define who the adventurers are, how they grow, and what makes each one unique. The character system creates attachment (you care when they die), variety (different builds feel different), and the "loot goblin" satisfaction of finding the perfect gear for a specific character.

## Stats

### Primary Stats

Five base stats that define each character:

| Stat | Role | Affected By |
|------|------|-------------|
| **STR** | Physical power | Melee damage, carry capacity |
| **AGI** | Speed & finesse | Initiative, dodge chance, ranged accuracy |
| **VIT** | Toughness | Max HP, defense, curse resistance |
| **INT** | Mental power | Magic damage, ability effectiveness |
| **LUCK** | Fortune | Crit chance, loot quality, rare event avoidance |

### Derived Stats

Computed from primary stats + equipment + class bonuses:

| Derived | Formula | Notes |
|---------|---------|-------|
| **Max HP** | `50 + (VIT × 8) + armor_bonus` | Base 50 so level 1 characters aren't one-shot |
| **Melee Damage** | `STR × 2 + weapon_bonus` | Raw damage before defense reduction |
| **Magic Damage** | `INT × 2 + weapon_bonus` | For staves/wands and magic abilities |
| **Defense** | `VIT + armor_bonus + hat_bonus` | Flat damage reduction per hit |
| **Initiative** | `AGI × 3 + boots_bonus` | Determines turn order in auto-battles |
| **Dodge Chance** | `AGI × 2%` (cap 40%) | Chance to avoid an attack entirely |
| **Crit Chance** | `LUCK × 3%` (cap 30%) | Chance to deal 2× damage |
| **Crit Damage** | `min(3×, 2× + LUCK × 0.1)` | Crit multiplier after defense — scales from 2× to 3× with LUCK |
| **Carry Capacity** | `3 + floor(STR / 5)` | Items a character can hold in their pack |

### Stat Ranges (Level 1)

| Stat | Min | Max | Notes |
|------|-----|-----|-------|
| STR | 3 | 10 | Warrior/Orc biased high |
| AGI | 3 | 10 | Rogue/Elf biased high |
| VIT | 3 | 10 | Cleric/Dwarf biased high |
| INT | 3 | 10 | Mage/Elf biased high |
| LUCK | 3 | 10 | No race bias — the wild card |

### Level-Up Stat Gains

Each level gives +1 to +3 in 2-3 random stats, weighted by race tendencies. Class gives a guaranteed +1 to its associated stat each level.

Example: An Orc Warrior levels up → guaranteed +1 STR (class), then +1 to +3 distributed across STR/VIT (race bias) and one wild stat. Very likely to gain STR and VIT, unlikely to gain INT.

## Races

Each race has a stat template (base values with ±2 random variance), a variance range (how much stats swing on level-up), and a special trait.

### Human
- **Base stats**: 5/5/5/5/5 (all equal, ±2 variance)
- **Level-up variance**: Moderate (stats swing 1-3 per level)
- **Special**: **Adaptive** — can be any class. No restrictions.
- **Vibe**: Flexible filler. Good for covering gaps.

### Orc
- **Base stats**: STR 8, AGI 3, VIT 7, INT 2, LUCK 5 (±2 variance)
- **Level-up variance**: Low (stats swing 1-2, biased toward STR/VIT)
- **Special**: **Thick Skull** — takes 50% less damage from crits
- **Class restriction**: Cannot be Mage
- **Vibe**: Frontline bruiser. Predictable but powerful.

### Elf
- **Base stats**: STR 4, AGI 8, VIT 3, INT 7, LUCK 5 (±2 variance)
- **Level-up variance**: High (stats swing 2-3, can go anywhere)
- **Special**: **Foresight** — +10% dodge chance (stacks with AGI dodge, before cap)
- **Class restriction**: Cannot be Warrior
- **Vibe**: Glass cannon. Exciting but fragile.

### Dwarf
- **Base stats**: STR 6, AGI 2, VIT 9, INT 3, LUCK 5 (±2 variance)
- **Level-up variance**: Very low (stats swing 1-2, heavily biased toward VIT)
- **Special**: **Sturdy** — +3 flat defense (always active)
- **Class restriction**: Cannot be Rogue
- **Vibe**: Immovable. Not flashy, doesn't die.

### Race/Class Compatibility

|  | Warrior | Mage | Rogue | Cleric |
|---|:---:|:---:|:---:|:---:|
| **Human** | ✓ | ✓ | ✓ | ✓ |
| **Orc** | ✓ | ✗ | ✓ | ✓ |
| **Elf** | ✗ | ✓ | ✓ | ✓ |
| **Dwarf** | ✓ | ✗ | ✗ | ✓ |

Blocked combos create party-building constraints — you can't have an Orc Mage or a Dwarf Rogue. Humans are the universal option.

## Classes

Each class defines what equipment a character can use, what abilities they learn, and a stat bonus per level.

### Warrior
- **Equipment**: Any weapon, heavy armor. No magic weapons (staves, wands).
- **Level bonus**: +1 STR
- **Ability pool** (~7 abilities): Defensive stance (temp +defense), Cleave (hit adjacent target), Shield Wall (party +defense for 1 turn), Revenge (counter-attack when hit), Charge (bonus damage if moved this turn), Taunt (force enemies to target this character), Power Strike (high-damage single target)
- **Auto-battle behavior**: Prioritizes front-line enemies. Uses defensive abilities when low HP, offensive when healthy. Taunt available to protect squishier allies.

### Mage
- **Equipment**: Magic weapons only (staves, wands), light armor only.
- **Level bonus**: +1 INT
- **Ability pool** (~6 abilities): Fireball (AoE damage), Frost (slow enemy initiative), Arcane Shield (temp +defense), Chain Lightning (bounce damage), Mana Drain (reduce enemy damage), Arcane Bolt (ranged damage)
- **Auto-battle behavior**: Stays in back. Prioritizes grouped enemies for AoE. Uses defensive spells when threatened. Uses Arcane Bolt for single-target ranged damage.

### Rogue
- **Equipment**: Dual wield (two 1H weapons), light armor only. No 2H weapons.
- **Level bonus**: +1 AGI
- **Ability pool** (~6 abilities): Backstab (bonus damage from behind), Smoke Bomb (dodge next attack), Poison Blade (DoT on hit), Twin Strike (multi-hit attack), Evasion (dodge all attacks for 1 turn), Execute (instant kill below 20% HP)
- **Auto-battle behavior**: Targets weakest enemies first. Uses Execute on low-HP targets. Smoke Bomb when threatened. Backstab when positioned behind an enemy. Twin Strike for multi-hit burst.

### Cleric
- **Equipment**: Blunt weapons (maces, hammers), medium armor.
- **Level bonus**: +1 VIT
- **Ability pool** (~6 abilities): Heal (restore HP to ally), Purify (remove curse from ally), Bless (+LUCK to ally for fight), Holy Shield (ally immune to crits for 1 turn), Smite (magic damage to one enemy), Resurrect (revive fallen ally with 10% HP, once per dungeon)
- **Auto-battle behavior**: Prioritizes healing lowest-HP allies. Purifies cursed allies. Attacks only when no healing is needed. Uses Resurrect on the most valuable fallen ally.

### Ability Acquisition

Each class has a pool of ~6 abilities. On each level-up (levels 2, 4, 6, 8, 10), the character learns one ability from their pool. Abilities are offered in a fixed order per class (not random), but the **auto-battle AI decides when to use them** based on the situation. Two Warriors with the same level will have the same abilities — the variety comes from race differences, equipment, and the emergent behavior of the auto-battler reacting to different combat situations.

Five ability slots over 10 levels means a max-level character knows 5 of their class's ~6 abilities. One ability is always left out, creating a small build choice — but since the AI controls usage, the "choice" is more about which tools the AI has available, not which button the player presses.

## Equipment

### Slots

Four equipment slots per character:

| Slot | Primary Effect | Examples |
|------|---------------|----------|
| **Weapon** | Damage (melee or magic) | Rusty Sword, +3 Flaming Staff of Questionable Intent, Spatula of Doom |
| **Armor** | Defense, HP | Leather Vest, Chainmail, Cardboard Box (it's surprisingly effective) |
| **Hat** | Defense, special effects | Helm, Wizard Hat, Bucket (provides +1 defense and mild embarrassment) |
| **Boots** | Initiative, dodge | Sandals, Iron Boots, Sneakers of Sneaking |

### Rarity Tiers

| Rarity | Stat Bonus | Drop Rate | Name Style |
|--------|-----------|-----------|------------|
| Common | Low | ~50% | Simple names ("Iron Sword") |
| Uncommon | Medium | ~30% | Adjective ("Sharp Iron Sword") |
| Rare | High | ~15% | Named ("Grimjaw's Iron Sword") |
| Legendary | Very High | ~4% | Absurd ("The Iron Sword That Screams When You Swing It") |
| Cursed | Variable | ~1% | Seems good but has a downside ("Lucky Sword" — +5 damage, -3 LUCK) |

Cursed items are the Munchkin twist — they look appealing but carry a hidden cost. The player can identify them after equipping (first fight reveals the curse) or with a consumable.

### Equipment Restrictions by Class

|  | Warrior | Mage | Rogue | Cleric |
|---|:---:|:---:|:---:|:---:|
| **2H weapons** | ✓ | ✗ | ✗ | ✗ |
| **1H weapons** | ✓ | ✗ | ✓ | ✗ |
| **Magic weapons** | ✗ | ✓ | ✗ | ✗ |
| **Blunt weapons** | ✗ | ✗ | ✗ | ✓ |
| **Heavy armor** | ✓ | ✗ | ✗ | ✗ |
| **Medium armor** | ✓ | ✗ | ✗ | ✓ |
| **Light armor** | ✓ | ✓ | ✓ | ✗ |
| **Hats** | All | All | All | All |
| **Boots** | All | All | All | All |

Hats and boots are universal — the humor slot. Everyone can wear a bucket on their head.

## Leveling & XP

### XP Sources

- **Base XP per fight**: 10 × monster level
- **Participation bonuses**:
  - Damage dealt: +1 XP per 10 damage
  - Damage taken/dodged: +1 XP per 15 damage (tanking matters)
  - Healing done: +1 XP per 10 HP healed
- **Dungeon completion bonus**: 50 × dungeon difficulty tier (Easy=1, Medium=2, Hard=3)

### Level Thresholds (10 levels)

| Level | Total XP Needed | XP From Previous |
|-------|-----------------|-------------------|
| 1 | 0 | — |
| 2 | 30 | 30 |
| 3 | 80 | 50 |
| 4 | 150 | 70 |
| 5 | 250 | 100 |
| 6 | 400 | 150 |
| 7 | 600 | 200 |
| 8 | 850 | 250 |
| 9 | 1,150 | 300 |
| 10 | 1,500 | 350 |

Accelerating costs mean mid-game is the sweet spot — levels come fast enough to feel rewarding but slow down enough that a level 10 character feels like an accomplishment. A character reaching level 10 should feel like a veteran who's been through hell.

### What Each Level Gives

- Level 1-9: +1 to +3 stats (race-weighted), +1 class stat (guaranteed)
- Levels 2, 4, 6, 8, 10: Learn a new ability from class pool
- Level 10: Max level. "Veteran" status. Maybe a small cosmetic title.

## Roster Management

### Party & Reserve

- **Active party**: 4 characters per dungeon expedition
- **Reserve**: 2-4 additional characters stored at the tavern (total roster: 6-8)
- **Starting roster**: 2 fixed characters (one frontline, one support — e.g., Human Warrior + Human Cleric)
- **Swapping**: Can swap active and reserve characters between dungeons (not during)

### Recruiting

New characters can be recruited at the tavern between dungeons. Costs are significant — recruiting is an investment, not a casual action.

- **Gold cost**: Scales with the recruit's level (higher level = more expensive)
- **Item cost**: May require donating an item (especially for higher-level recruits)
- **One recruit per run**: Can only hire one new character between dungeons. Choose wisely.
- **Available recruits**: Random selection that refreshes each time you return from a dungeon. Recruit levels are offered around the **lowest** level in your current party — recruiting catches you up rather than starting from scratch. The pool is limited — you see 2-3 options and pick one or none.
- **Race/class restrictions**: The available recruits respect race/class compatibility (no Orc Mages in the tavern)

### Permadeath

When a character dies in a dungeon:
- They are gone forever
- All equipped items are lost with them
- Their inventory items are lost with them
- A roster slot opens up for recruiting

This is the sting. Losing a level 8 Elf Mage with legendary gear hurts on multiple levels — you lose the character, the time invested, AND the loot.

## Interactions with Other Systems

- **Encounter system**: Monster level relative to party level (average of active party). Curses can permanently destroy equipment.
- **Combat system**: Auto-battle AI uses abilities based on class pool. Stats determine effectiveness. Initiative order from AGI + boots.
- **Dungeon structure**: Difficulty tier determines loot quality (and therefore equipment power). Rest areas heal based on VIT.

## Fun Check

- **Does losing a character hurt?** Yes — permadeath + lost gear + lost investment. This is intentional.
- **Does finding the right gear feel good?** Yes — the rarity system + class restrictions mean that perfect item is a real event.
- **Do different builds feel different?** Yes — race/class combos create distinct auto-battle behaviors. An Orc Warrior and an Elf Rogue will fight in completely different ways.
- **Is there a reason to care about reserves?** Yes — permadeath means reserves are insurance. A shallow roster is a single bad run away from disaster.

## Open Questions

- **Starting characters**: Should they be fixed (Human Warrior + Human Cleric) or randomized? Fixed is simpler and ensures a viable starting comp.
- **Exact equipment numbers**: How much does a Common vs Legendary weapon differ? Needs playtesting — the formulas above are a starting point.
- **Cursed item identification**: How does the player discover the curse? First fight after equipping? A consumable? A tavern service?
- **Ability auto-battle priority**: How does the AI decide which ability to use when multiple are available? Needs to be defined in the combat system step.
- **Level cap in dungeons**: Can a character level up mid-dungeon? If so, does the XP carry over? Probably yes for feel-good moments.
- **Reserve roster exact size**: 6 or 8 total? Needs to balance "enough to recover" with "small enough that death matters."
