---
title: Munchkin Dungeon — Concept
date: 2026-04-10
tags:
  - concept
  - munchkin-dungeon
---

# Munchkin Dungeon (working title)

Roguelike dungeon crawler with absurd humor, ridiculous loot, and escalating risk. Kick down doors, fight stupid monsters, hoard broken gear, and try not to die horribly.

## Elevator Pitch

You're a terrible adventurer delving into a dungeon that wants you dead. Each floor is a door — behind it could be a monster, a curse, or the absurdly powerful item you've been hunting. Build your character from the loot you find, but every fight is a gamble: push too hard and you'll lose everything. Roguelike progression meets Munchkin's chaotic energy.

## What Makes It Fun

- **Absurd encounters** — the monsters, items, and curses are genuinely funny. A "3,872 Orcs", a "Boots of Butt-Kicking", a curse that makes you lose your pants. The humor is in the specifics.
- **Push-your-luck tension** — complete the dungeon for the big payout, or bail early with partial loot. Every room deeper is a gamble. Greed kills.
- **Auto-battle builds** — you don't control fights directly. Strategy is in the party composition, equipment, and positioning before battle. Watching your build work (or fail) is the payoff.
- **Permadeath stakes** — dead characters are gone forever, along with their gear and levels. Losing a veteran hurts. The risk of loss makes every dungeon decision meaningful.
- **Short, punchy runs** — pick a mission, assemble your party, delve, come back (or don't). Each expedition is 5-15 minutes.

## Core Gameplay Loop

Manage a party of 4 adventurers through dungeon expeditions. Auto-battles resolve combat based on character stats, equipment, race/abilities, and initiative. Between dungeons, recruit new members, buy supplies, and heal survivors.

**Per expedition**: Choose mission → assemble party → kick doors → auto-battle → loot/curse → continue or bail → return with treasure (or not at all)

## Inspirations

- **Munchkin** (Steve Jackson Games, 2001) — the humor, the absurd items, the "kick down doors" structure. Adapted: the dungeon backstabs you instead of other players.
- **Darkest Dungeon** — expedition structure (missions of different lengths), permadeath, party management between runs, the big payout for completing vs bailing early.
- **Super Auto Pets** — auto-battle where strategy is in the build, not execution. Drafting/recruiting party members, items that create synergies, watching fights play out.
- **Slay the Spire** — roguelike structure, strategic choices with escalating difficulty, short runs.

## What's Different from Munchkin

| Aspect | Munchkin | Munchkin Dungeon |
|--------|---------|-----------------|
| Format | Competitive multiplayer card game | Solo roguelike |
| Social layer | Players backstab each other | The dungeon backstabs you |
| Combat | Compare numbers, roll to run | Auto-battle with initiative, positioning, and abilities |
| Progression | Single session | Meta-progression across expeditions |
| Depth | Thin strategy, thick social | Strategic builds + risk management |
| Win condition | First to Level 10 | Survive the dungeon (or die trying) |

## Key Design Decisions

- **Party size**: 4 characters per expedition
- **Auto-battle**: Turn-based, characters act based on initiative. Attack patterns determined by race/abilities/equipped items.
- **Character stats**: RPG stats (damage, health, defense, initiative, carry capacity) + equipment
- **XP**: Base XP per fight + bonus for participation (damage dealt, damage taken/dodged, healing)
- **Permadeath**: Dead characters are gone, items lost with them
- **Mission variety**: Different dungeons with different lengths. Shorter = safer but less reward. Longer = bigger payout but higher risk.
- **Room types**: Monsters, curses, treasure, rest areas. Most rooms hidden until opened.
- **Economy**: Loot during dungeons (equipment, useful stuff). Shop between dungeons (recruits, consumables).
- **Bail mechanic**: Can retreat from a dungeon early, keep partial loot. Complete for full reward.

## Constraints

- **Platform**: Web (WASM export from Godot 4)
- **Time**: ~2 days pre-scaffold + ~8 hours at the jam (April 11, 2026)
- **Solo**: Single player
- **Jam context**: Needs to be playable and understandable within minutes
