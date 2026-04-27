---
title: Design Process
date: 2026-04-10
tags:
  - process
  - munchkin-dungeon
---

# Design Process

How we're approaching the game design for the jam. Same methodology as Gemfire Kingdoms — core loop first, then subsystems.

## Design Principles

1. **Core loop first** — If the core loop isn't fun, nothing else matters. Define what the player does before defining how systems work.
2. **Humor is a mechanic, not decoration** — The funny names and absurd items aren't just flavor — they're part of why the game is memorable. The humor should emerge from gameplay, not cutscenes.
3. **Every system earns its place** — Each subsystem must create at least one interesting decision. If it doesn't, cut it.
4. **Simple before clever** — A working simple game beats an ambitious broken one. We have ~8 hours at the jam.
5. **The dungeon is the opponent** — No social layer to lean on, so the game itself must create tension, surprise, and those "oh no" moments.

## Design Steps

### Phase 1: Foundation

**Step 1: Core Loop** → [[subsystems/core-loop]]
Define the player experience at three time scales:
- **Floor-to-floor**: What do you do each floor? (Kick, fight/flee, loot, decide)
- **Combat-to-combat**: What do you do in fights? (Items, abilities, risk/reward)
- **Run-to-run**: What's the arc of a full game? (Weak start, build power, climax, death or victory)

Also define: the core tension (what tradeoff does the player face every floor?), the win condition, and what makes a "good move" feel good.

**Step 2: Encounter System** → `subsystems/encounters.md`
What's behind each door. Monster types, curses, loot drops, events. The variety engine.

**Step 3: Character & Progression** → [[subsystems/character]]
How the player gets stronger. Levels, items, class/race abilities. Build variety.

### Phase 2: Depth & Spice

**Step 4: Combat System** → `subsystems/combat.md`
How fights actually work. Not deep tactical — fast and punchy with meaningful item/ability choices.

**Step 5: Dungeon Structure** → `subsystems/dungeon.md`
The overall shape of a run. Floor count, difficulty curve, bosses, checkpoints. What changes as you go deeper.

### Phase 3: Scope

**Step 6: Scope & Priorities** → [[scope]]
Shape Up framing: bets, appetite, rabbit holes. What to scaffold before the jam, what to build at the event, what to cut if time runs short.

## Per-Subsystem Template

When designing each subsystem, answer:
1. **Purpose** — What role does this play in the core loop?
2. **Player Actions** — What can the player do?
3. **Rules & Constraints** — What limits exist?
4. **Interactions** — How does this connect to other systems?
5. **Fun Check** — Does this create an interesting decision? Would the player miss it if it were gone?

## Current Status

- [x] Concept defined
- [x] Design process established
- [x] Core loop definition
- [x] Encounter system design
- [x] Character & progression design
- [x] Combat system design
- [x] Dungeon structure design (procedural generation implemented)
- [ ] Scope & priorities
