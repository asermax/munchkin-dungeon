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

Define what's behind each door and how the dungeon unfolds room by room. The encounter system creates variety, tension, and the Munchkin-style absurdity that makes each run memorable.

## Room Types

Four room types, each with a distinct role in the dungeon's rhythm:

### Monster Rooms (~50-60%)

The main event. Auto-battle against themed monster groups.

- **Monster groups**: 1-3 monsters per room, always a pre-determined themed group — not random assortments. A goblin room is three goblins with different names, sizes, and stats ("Grok the Huge, Snig the Tiny, Blorp the Annoying"). A skeleton room is a skeleton knight, skeleton archer, and skeleton dog. The group composition tells a tiny story.
- **Funny names**: Every monster gets a name. The humor is in the specifics — "3,872 Orcs" (it's just one very confused orc), "Angry Cheese Wheel", "Potted Plant of Doom", "Steve" (a terrifying dragon).
- **Bad Stuff**: ~30% of monsters have post-victory effects that trigger even if you win. Severity is weighted: most are minor (temporary debuffs, flavor), but ~3-4% hit hard (lose an equipped item, permanent stat reduction). The rare severe ones make every fight feel slightly dangerous — even when you're winning, there's a small chance it still hurts.

### Curse Rooms

The dungeon being a jerk. No fight — just consequences. You open the door and something awful happens.

**Curse severity depends on the type of curse:**

| Type | Duration | Examples |
|------|----------|----------|
| Item loss | Permanent | "Your hat crumbles to dust", "Your wizard's spellbook catches fire" |
| Stat debuff | Temporary | "Everyone's shoes are soaked" (-1 initiative), "-2 damage until next rest" |
| Status effect | Temporary | "The dwarf is allergic to gold" (can't carry gold this run) |
| Bizarre condition | Temporary | "You can only speak in rhyme" (no mechanical effect, just flavor) |

The rule: if it removes something you earned, it's permanent. If it reduces your capabilities, it fades on rest or dungeon end.

**Curse stacking**: Characters can accumulate up to 2 curses at a time. Temporary curses falling off at rest naturally manages the stack. The cap prevents bad RNG from making a run mathematically unwinnable — the worst case is rough but survivable.

### Treasure Rooms (~10-15%)

Free loot, no danger. The gamble payoff. Rare enough that finding one with a half-dead party feels like a lucky break.

- Equipment, consumables, gold — the good stuff
- No catch (that's what curse rooms are for)
- Loot quality tied to dungeon difficulty tier — harder dungeons have better tables. The hard dungeon is the only place to find the really absurd legendary gear
- The rarity is what makes them exciting

### Rest Areas

Visible before entering (campfire icon on the door). Safe rooms where you can:
- Heal all surviving heroes for a flat 20-40 HP each
- Rearrange equipment between characters
- Clear temporary curses

**Cost**: Resting costs dungeon progress — you're spending a room slot on safety instead of rewards. Healing is damage control, not a reset button. You'll always be worse off than when you entered the dungeon.

## Dungeon Layout

**Darkest Dungeon-style paths.** A mostly linear route that occasionally splits into two parallel tracks, rejoin, and may split again. Not a maze — a road with detours.

### Structure

- Start with a linear sequence
- Hit a split: two parallel paths of multiple rooms each
- Paths rejoin into a single track
- May split again (up to 3 splits per dungeon)
- Ends at the final room (boss or big reward)

Splits scale with dungeon length:
- **Normal** (5-7 rooms): 1 split, each path has 1-2 rooms
- **Large** (9-12 rooms): 2-3 splits, paths have 1-3 rooms each

### Meaningful Splits

Each split is a **deliberate choice**, not a coin flip. The player can see hints about what's down each path:

- One path has a visible rest area, the other has a treasure icon
- One path looks longer (more rooms = more risk but more potential loot)
- One path has a visible monster room, the other is fully hidden

The choice is always: "do I play it safe or do I push my luck?" — the core tension of the game, expressed at the map level.

### Room Visibility

- **Hidden**: Monster rooms and curse rooms by default — you don't know what's behind the door until you open it
- **Visible**: Rest areas and boss rooms — always shown before entering
- **Hinted**: Treasure rooms have a 50% chance of being hinted (otherwise hidden)
- **Path previews**: At a split, the player sees the visible/hinted rooms on each path. Hidden rooms show as blank doors. Enough info to create a meaningful choice, not enough to remove the gamble

## Dungeon Difficulty & Length

### Difficulty Tiers

Three tiers that set the monster power level relative to the party:

| Tier | Monster Level | Vibe |
|------|--------------|------|
| Easy | Party level - 1 to party level | Warm-up. Stomping feels good. |
| Medium | Party level | Fair fight. Resources matter. |
| Hard | Party level or party level + 1 | Brutal. Every fight is a risk. |

Monster level is **stable within a dungeon** — once you enter, every monster room uses the same level range. No scaling with depth. The difficulty is the dungeon itself.

**Exception**: The final room's boss can exceed the dungeon's normal monster level.

### Length Types

| Length | Approx. Rooms | Use |
|--------|--------------|-----|
| Normal | 5-7 rooms | Standard run, moderate risk/reward |
| Large | 9-12 rooms | Big payout, high attrition, more branches |

Combined, a dungeon is defined by tier + length: "Easy Normal", "Hard Large", etc. The player chooses before entering.

### Why Stable Monster Levels

- A leveled party stomping easy rooms **feels good** — it's the power fantasy payoff
- Difficulty is a deliberate choice (which dungeon to enter), not a surprise escalation
- The tension comes from attrition (health, resources, curses) across rooms, not from monsters suddenly getting harder deeper in
- The final boss exception creates a climactic moment without undermining the stable-difficulty design

## Encounter Distribution

Within a single dungeon run, rooms are distributed to create rhythm:

- **Opening** (first 1-2 rooms): Usually monster rooms to establish the dungeon's difficulty tier. Rarely a curse or treasure as a curveball.
- **Middle** (bulk): Mix of all types. Monster rooms dominate, with 1-2 curse rooms, maybe a treasure, and a rest area near a branch point.
- **End** (final room): Boss monster, big treasure, or a nasty curse — the climactic beat.

The distribution isn't purely random — it's structured to create a narrative arc within each run.

## Open Questions

- **Bad Stuff details**: What's the exact split between common/uncommon/rare severity? What counts as "minor" vs "severe"?
- **Treasure room loot tables**: How many items per room? Consumables vs equipment ratio?
- **Split room count**: Fixed per split or variable? Should the player see how many rooms are on each path?
- **Encounter generation**: Are monster groups hand-crafted (finite pool) or template-generated (combinatorial)?
