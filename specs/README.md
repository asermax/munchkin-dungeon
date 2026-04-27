---
date: 2026-04-10
tags: [games, roguelike, munchkin, project]
status: active
---

# Munchkin Dungeon

Roguelike dungeon crawler with absurd humor, ridiculous loot, and escalating risk. Auto-battler combat, party management, and push-your-luck tension.

**Repo**: https://github.com/asermax/munchkin-dungeon

## Design

- [[concept]] — Elevator pitch, inspirations, key design decisions
- [[design-process]] — 6-step methodology (Foundation → Depth & Spice → Scope)
- [[ideas]] — Brainstorm notes and open questions

## Subsystems

- [[subsystems/core-loop]] — Core game loop (Step 1)
- [[subsystems/encounter-system]] — Room types, monster groups, dungeon layout (Step 2)
- [[subsystems/character]] — Stats, races, classes, equipment, leveling (Step 3)
- [[subsystems/combat]] — 2-row positioning, damage formulas, ability AI (Step 4)

## Data

- [[data/base-numbers]] — Stat ranges and balance numbers
- [[data/equipment]] — 248 items across all slots and rarities
- [[data/enemies]] — Enemy database with stats and abilities
- [[data/dungeon-structures]] — Room templates, quests, loot tables

## Tech Stack

- **Engine**: Godot 4 (2D, WASM export)
- **Language**: GDScript
- **Dev tooling**: Claude Code + godot-mcp

## Status

All core systems designed. All 4 foundational data files complete. Ready for implementation.

## Related

- [[02_Areas/Game-Design|Game Design Area]] — Other game ideas and reference designs
