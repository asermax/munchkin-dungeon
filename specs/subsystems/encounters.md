---
title: Encounter System
date: 2026-04-10
tags:
  - subsystem
  - munchkin-dungeon
  - encounters
---

# Encounter System

## Purpose

The encounter system is the variety engine of the game. It determines what's behind every door, how danger and reward are distributed, and what makes each room exciting to open. It feeds directly into the push-your-luck core tension — the player needs to feel like the next room *might* be amazing or *might* kill them, and they can't know until they open it.

## Room Types

### Monster Rooms (~50-60% of rooms)

The main event. Auto-battle against absurd monsters.

**Monster Anatomy:**
- Name (absurd: "3,872 Orcs", "Gelatinous Cube of Disappointment", "Kevin")
- Combat stats (health, damage, defense, initiative)
- Special ability (1 per monster, creates variety in fights)
- Bad Stuff (optional — effect that triggers even if you win, like Munchkin)
- Loot table (what they drop when killed)
- Tier (determines when they appear, scaled to dungeon difficulty)

**Monster Special Abilities (examples):**
- "Swarm" — summons 2 smaller copies of itself
- "Thick Skin" — takes half damage until armor is broken
- "Coward" — runs away after 2 turns, no loot if it escapes
- "Vengeful" — deals double damage on its last HP
- "Sticky" — sticks to one character, they can't be swapped out
- "Hat Thief" — steals a random equipped item if it lands a hit

**Bad Stuff (examples):**
- "Lose your lunch" — one random character loses their consumable
- "You smell terrible" — party initiative -1 for next 2 rooms
- " existential crisis" — one character refuses to attack next fight (skips turns)

**Monster Tiers:**
- **Tier 1** (early rooms): low stats, no special abilities. "Goblin With a Stick", "Sad Skeleton"
- **Tier 2** (mid rooms): moderate stats, 1 ability. "Orc With a Plan", "Enraged Chicken"
- **Tier 3** (late rooms): high stats, 1 ability + Bad Stuff. "Dragon Who Pays Taxes", "The IRS"
- **Boss** (final room): unique per dungeon, multiple abilities, guaranteed high-tier loot

### Curse Rooms (~15-20% of rooms)

No fight. Open the door, something bad happens. The dungeon being a jerk.

**Curse Properties:**
- **Severity**: mostly temporary (lasts until next rest or end of dungeon). Rare permanent curses exist but are very uncommon (~5% of curses).
- **Target**: can hit one random character, the whole party, or a specific slot (e.g., "whoever is in front")
- **Duration**: instant (happens and done), temporary (lasts N rooms or until rest), or permanent (rare)

**Curse Examples:**
- "Wet Socks" — whole party, -1 initiative for 3 rooms. Absurd but tactically meaningful.
- "Your wizard forgot how to read" — one character, can't use magic items for 2 rooms.
- "The floor is lava" — front character takes 3 damage. Simple, funny, costs resources.
- "Identity crisis" — two characters swap equipment. Chaotic and creates interesting re-equip decisions.
- "Lost the map" — next room is always a monster (can't get treasure or rest). Changes risk calculation.
- "Ancient grudge" — permanent. One character takes +1 damage from all sources forever. Rare and terrifying.

**Design note**: curses should be *inconvenient* not *devastating*. The humor comes from the specificity. A curse that kills a character isn't funny. A curse that makes your tank fight in his underwear (-2 defense) is funny AND tactically relevant.

### Treasure Rooms (~10-15% of rooms)

Free loot, no danger. The payoff for pushing your luck.

**Treasure Types:**
- Equipment (weapons, armor, accessories)
- Consumables (potions, scrolls, bombs)
- Gold (currency for between-dungeon shopping)
- Rare items (powerful equipment with tradeoffs)

**Treasure Scaling**: treasure quality scales with dungeon depth and difficulty tier. A treasure room in room 2 of a short dungeon gives basic loot. A treasure room in room 8 of a long dungeon gives premium loot.

### Rest Areas (~10-15% of rooms)

Safe room. The catch-your-breath moment.

**What rest does:**
- Heal all surviving heroes for a flat 20-40 HP each
- Remove temporary curses
- Allow equipment rearrangement (swapping between characters)
- Option to use consumables without time pressure

**Visibility**: rest areas are visible before entering (you can see the icon on the door). This is intentional — they're the game's way of saying "you can stop pushing your luck here." The player knows safety is one room away, which makes the decision to skip a rest and keep going more agonizing.

## Room Distribution

### Base Probabilities (per room)

| Room Type | Short Dungeon | Medium Dungeon | Long Dungeon |
|-----------|:------------:|:--------------:|:------------:|
| Monster   | 55%          | 55%            | 60%          |
| Curse     | 15%          | 18%            | 20%          |
| Treasure  | 15%          | 15%            | 10%          |
| Rest      | 15%          | 12%            | 10%          |

Longer dungeons are harder — more monsters, more curses, fewer safe rooms. The ratio shifts as depth increases within a dungeon too: early rooms are gentler, late rooms are brutal.

### Guaranteed Placements

- **Room 1**: always a monster (the "entrance guard"). Sets the tone, never a curveball.
- **Final room**: always a boss monster (unique per dungeon). The ultimate risk/reward moment.
- **Midpoint room** (dungeons 6+ rooms): guaranteed rest area. A breather before the harder second half.
- **No consecutive curses**: never two curse rooms in a row. The game is mean but not unfair.

### Room Visibility

- **Hidden** (monster and curse rooms by default): you don't know what's inside until you open the door
- **Visible** (rest areas and boss rooms): always shown before entering
- **Hinted** (treasure rooms): 50% chance of being hinted, otherwise hidden

## Dungeon Path Structure

Procedural generation via DungeonGenerator (not LLM-generated):
- First room: always a single monster encounter
- Last room: always a boss encounter
- Middle: mix of single rooms and branching segments
- **Branches**: 1-2 per dungeon, 1-2 rooms per branch path — player picks one path at each fork
- Room types assigned by weighted random: monster 60%, curse 18%, treasure 10%, rest 12%
- Validation: at least 1 monster + 1 boss, midpoint rest for 6+ rooms, guaranteed treasure for 5+ rooms, no consecutive curses on any traversal path
- Encounters assigned from EncounterPool by room position: early = easy, mid = medium, late = hard

## Monster Scaling

Monsters scale based on **dungeon depth + dungeon tier**, NOT the player's level. This is important:

- A leveled-up party should *feel* powerful — they stomp early rooms. This is rewarding.
- Later rooms remain challenging regardless of how strong the party is. Difficulty comes from the dungeon, not level matching.
- This encourages the player to take on harder dungeons as they get stronger — the reward scales with the challenge.

**Scaling formula (directional, not final):**
- Base stats = monster tier (1/2/3)
- Depth modifier = +X% stats per room beyond the first
- Dungeon tier modifier = multiplier based on dungeon difficulty tier

## Interactions With Other Systems

- **Combat system**: monster stats and abilities feed directly into auto-battle. Special abilities create different fight dynamics.
- **Character system**: curses that target stats (initiative, defense) interact with character builds. A curse on your fastest character hurts more.
- **Loot/equipment**: treasure rooms and monster drops feed the equipment system. Better gear = stronger party = can push deeper.
- **Dungeon structure**: room distribution and scaling change per dungeon type/length.

## Fun Check

| Question | Answer |
|----------|--------|
| Does this create an interesting decision? | Yes — every door is a gamble. Do you push forward with a weakened party or bail? |
| Would the player miss it if it were gone? | Yes — variety in room types prevents monotony. Every room feels different. |
| Does it connect to the core tension? | Directly — curse rooms increase risk, treasure rooms increase reward, rest rooms offer safety at the cost of progress. |
| Is it funny? | The monster names, curse descriptions, and bad stuff effects carry the humor. |
