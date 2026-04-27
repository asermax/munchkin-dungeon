---
title: Combat System
date: 2026-04-10
tags:
  - subsystem
  - munchkin-dungeon
  - combat
  - auto-battler
---

# Combat System

## Purpose

Define how fights resolve. The player doesn't control combat directly — strategy is in the build (party composition, equipment, abilities). Combat is the payoff where you watch your decisions play out. It needs to be fast, readable, and create moments of tension ("the Cleric just healed, she won't heal again for 2 rounds").

## Positioning

### 2-Row System

Characters stand in a front row and a back row, 2 characters each:

```
[Front] [Front]    ← melee range
[Back]  [Back]     ← ranged/safe
        VS
[Front] [Front]    ← enemy front row
[Back]  [Back]     ← enemy back row
```

- **Melee attacks** primarily target the front row. If the front row is empty, melee hits the back row. Even with a living front line, melee has a **30% chance to reach through** and target a back-row unit — but reach-through attacks suffer a **+25% dodge penalty** (capped at 65% total dodge) and **25% damage reduction**.
- **Ranged attacks** (magic weapons, bows) can target anyone in either row.
- **Abilities** may have their own targeting rules (e.g., Fireball hits all enemies regardless of row).

### Default Row Assignment

Characters default to the row that matches their class:

| Class | Default Row | Why |
|-------|------------|-----|
| Warrior | Front | Melee, wants to be in the fight |
| Rogue | Front | Melee, needs to be close for Backstab |
| Mage | Back | Squishy, ranged attacks |
| Cleric | Back | Support, needs to stay alive to heal |

The player can override row assignment when assembling the party before a dungeon. Putting a Mage in the front row is a valid (risky) choice.

### When Front Row Falls

If both front-row characters die, back-row characters are exposed:
- Enemies can now target them directly
- Their attacks still use their default targeting (ranged hits anyone, melee hits whatever's in front)
- No explicit "forced to front" state — just no one protecting them anymore

## Turn Structure

### Round-Based

Each round, every living combatant acts once. Order is determined by initiative (highest first) with a **random jitter of +/-4** applied each round for tie-breaking variety.

```
Initiative = AGI × 3 + boots_bonus + random(-4, +4) per round
```

A round completes when all combatants have acted once. Then a new round starts. Repeat until one side is eliminated.

### No Player Input During Combat

Combat is fully automated. The player watches. There is no "pause and give orders" — the strategy happened before the dungeon (party comp, equipment, row placement).

### What Happens Each Turn

1. **Determine action** — the ability AI selects an action based on priority rules (see Ability AI)
2. **Select target** — based on targeting rules (see Targeting)
3. **Resolve attack** — damage formula, dodge check, crit check (see Damage)
4. **Apply effects** — damage dealt, status effects, cooldowns tick
5. **Check for death** — character at 0 HP is removed from combat
6. **Retarget if needed** — if the target died mid-round, the attacker picks a living replacement from the same target pool
7. **Check for fight end** — all enemies dead (win) or all party members dead (lose)

## Damage

### Base Damage

| Damage Type | Formula | Source |
|-------------|---------|--------|
| Melee | `STR × 2 + weapon_bonus` | 1H/2H/blunt weapons, Warrior/Rogue abilities |
| Magic | `INT × 2 + weapon_bonus` | Staves/wands, Mage abilities, Cleric Smite |

### Defense Calculation

```
damage_reduction = min(80%, defense × 2%)
damage_dealt = max(1, floor(attack_power × (1 - damage_reduction / 100)))
```

Defense reduces incoming damage by a percentage, up to 80%. This means a tanky Dwarf in heavy gear can block most damage but always takes at least 1. A squishy Mage in light armor barely notices their defense.

| Defense | Reduction | 20 dmg in | 50 dmg in |
|---------|-----------|-----------|-----------|
| 5 | 10% | 18 | 45 |
| 10 | 20% | 16 | 40 |
| 20 | 40% | 12 | 30 |
| 30 | 60% | 8 | 20 |
| 40+ | 80% | 4 | 10 |

### Critical Hits

```
crit_chance = min(30%, LUCK × 3%)
```

On a crit:
- Damage is multiplied after defense reduction
- `crit_multiplier = min(3, 2 + LUCK × 0.1)` — starts at 2× base, scales to 3× at LUCK 10+
- Defense is not affected — the hit just hurts more
- Visual/audio feedback makes crits feel impactful

### Dodge

```
dodge_chance = min(40%, AGI × 2%)
```

On a dodge:
- No damage taken
- The attacker "wastes" their turn
- Dodge is checked before crit — if you dodge, it doesn't matter if it would have been a crit

### Resolution Order

```
1. Dodge check → if dodged, stop (no damage, no crit)
2. Raw damage (stat × ability power)
3. Crit check → if crit, multiply damage
4. Apply defense reduction
5. Apply minimum damage (1)
```

## Ability AI

### Priority System

Each class has a fixed priority tree. The AI evaluates conditions top-to-bottom and uses the first ability whose condition is met. If no ability triggers, the character performs a basic attack.

### Warrior Priority

```
1. Taunt        — if any back-row ally is below 50% HP and enemy is targeting them
2. Shield Wall  — if own HP below 40% (not on cooldown)
3. Power Strike — if single high-HP enemy and not on cooldown
4. Revenge      — if attacked this round (counter-attack trigger)
5. Charge       — if no enemy in melee range and not on cooldown
6. Cleave       — if 2+ enemies in front row and not on cooldown
7. Basic attack — weighted random from front-row enemies
```

### Mage Priority

```
1. Arcane Shield — if own HP below 30% and not on cooldown
2. Frost        — if fastest enemy is about to act next round (slow them)
3. Chain Lightning — if 2+ enemies alive and not on cooldown
4. Fireball     — if 2+ enemies grouped in same row and not on cooldown
5. Mana Drain   — if enemy damage output is high and not on cooldown
6. Arcane Bolt  — ranged damage, not on cooldown
7. Basic attack — target enemy with highest HP
```

### Rogue Priority

```
1. Evasion      — if own HP below 25% and not on cooldown
2. Smoke Bomb   — if targeted by high-damage enemy and not on cooldown
3. Execute      — if any enemy below 20% HP
4. Backstab     — if behind an enemy (enemy targeted someone else this round)
5. Poison Blade — if not on cooldown
6. Twin Strike  — multi-hit attack, not on cooldown
7. Basic attack — weighted random from enemies
```

### Cleric Priority

```
1. Resurrect    — if ally is dead and hasn't been used this dungeon
2. Heal         — if any ally below 40% HP
3. Purify       — if any ally is cursed
4. Holy Shield  — if ally below 60% HP and enemy has high crit chance
5. Bless        — if no healing needed and not on cooldown (buff highest-LUCK ally)
6. Smite        — if no healing needed
7. Basic attack — target enemy with lowest HP
```

### Cooldowns

Most abilities have a cooldown of 2-3 rounds after use. This prevents spam and creates rhythm — the Cleric heals, then can't heal for 2 rounds, so those rounds feel tense.

- **Short cooldown** (1 round): Defensive reactions (Smoke Bomb, Evasion)
- **Medium cooldown** (2 rounds): Standard abilities (Heal, Fireball, Cleave)
- **Long cooldown** (3 rounds): Powerful abilities (Resurrect, Shield Wall)
- **Passive** (no cooldown): Loot (Rogue — triggers post-fight), Revenge (Warrior — triggers on being hit)

## Targeting

### Default Targeting

Targeting uses **weighted random selection** where damaged enemies are weighted higher (not deterministic lowest-HP). This creates less predictable, more varied combat.

| Role | Target Pool |
|------|-------------|
| Front row | Front-row enemies, weighted by damage taken |
| Back row | All enemies, weighted by damage taken |
| Healing | Ally with lowest HP % |

### Monster Targeting

Monsters follow simpler AI:
- Melee monsters: weighted random from front-row characters (damaged weighted higher)
- Ranged monsters: weighted random from all characters (damaged weighted higher)
- Bosses: may have unique targeting (e.g., target highest-damage character, or random)

### Monster Abilities

Not all monsters are mindless attackers. Ability complexity scales with difficulty:

| Monster Type | Abilities | Examples |
|-------------|-----------|----------|
| Basic (most common) | Basic attack only | Goblin, Skeleton, Slime |
| Advanced | 1 ability | Poison Spit (DoT), Howl (buff ally damage), Shield (temp +defense) |
| Elite / Boss | 2+ abilities | Summon (add a minion), AoE attack, Enrage (buff self when low HP) |

Basic monsters are the bread and butter — just hit things. Advanced monsters appear in Medium+ dungeons and add one wrinkle to the fight. Elite and boss monsters have full ability kits that demand specific party comps to handle.

## Fleeing

### How It Works

The player can flee **between rounds** (not mid-round). Fleeing is not free — the dungeon punishes cowardice.

### Flee Consequence: Curse

When you flee, a **random curse** is applied to a **random party member**:

- Follows the same curse severity rules as curse rooms (permanent for item loss, temporary for stat debuffs)
- The curse counts toward the 2-curse-per-character cap
- A character at their curse cap can't receive the flee curse → flee fails, you're forced to fight the next round

### Flee Cost Summary

| Cost | Details |
|------|---------|
| No completion bonus | You don't get the dungeon completion reward |
| No room loot | You don't get loot from the room you fled |
| Curse on random character | Permanent or temporary, per standard curse rules |
| Keep existing loot | Everything looted from previous rooms stays |

### Failed Flee

If the flee curse can't be applied (all characters at curse cap), the flee fails:
- The party stays in combat
- One random party member takes a free hit from a random enemy
- You can try to flee again next round (if a curse slot opened up)

### When to Flee

Fleeing is a calculated risk. The decision matrix:
- **Fight and maybe lose someone permanently** vs **flee and definitely get cursed**
- A temporary curse is almost always better than losing a character
- A permanent curse (item loss) might be worse than fighting — depends on what you're wearing
- The randomness of which character gets cursed adds tension — it might hit your already-cursed character (wasted) or your fully-geared veteran (devastating)

## Death

### In Combat

- Character reaches 0 HP → immediately removed from the fight
- Their turn is skipped for the rest of the combat
- They remain "dead" for the rest of the dungeon

### After Combat

- **Dead in dungeon = permanent death**
- All equipped items are lost forever
- All inventory items are lost forever
- A roster slot opens up for recruiting
- The remaining party members continue with fewer people (harder, but possible)

### Total Party Wipe

If all 4 characters die:
- **Expedition failed**
- All loot from this dungeon is lost
- All 4 characters and their gear are gone
- You return to base with only whatever was in reserve

This is the worst outcome. It's meant to hurt — it's the push-your-luck penalty for going too deep.

## Interactions with Other Systems

- **Character system**: Stats and equipment feed directly into combat calculations. Race traits (Thick Skull, Foresight, Sturdy) modify combat behavior.
- **Encounter system**: Monster groups of 1-3, scaled by dungeon difficulty. Bad Stuff triggers post-victory.
- **Dungeon structure**: Rest areas heal between fights. Difficulty tier determines monster power. Fleeing adds curses.
- **Progression**: XP awarded per fight based on participation (damage dealt, damage taken, healing done).

## Fun Check

- **Can the player predict what will happen?** Yes — ability priority trees are deterministic. The player can learn "my Cleric will heal before she Smites."
- **Does the build matter?** Yes — party composition, equipment, and row placement directly affect combat outcomes.
- **Is watching fun?** Yes — crits, dodges, abilities firing, the tension of "will the Cleric heal in time?" The auto-battler is a spectator sport.
- **Does fleeing feel like a real choice?** Yes — the curse consequence makes it a genuine tradeoff, not a free out.
- **Is total party wipe devastating?** Yes — losing everything is the ultimate push-your-luck punishment. It should be rare but memorable.

## Open Questions

- **Monster abilities**: Do monsters have abilities too, or just basic attacks? Some monster abilities (a goblin that poisons, a skeleton that resurrects) would add variety.
- **Status effect duration**: How many rounds do debuffs (Poison, Frost slow) last? Flat duration or chance to clear each round?
- **Row swapping mid-dungeon**: Can the player swap rows between fights? Probably yes — it's a pre-fight decision, not mid-combat.
- **Ability balance**: The priority trees are first drafts. Needs playtesting to see if Cleric is too strong, Mage too squishy, etc.
- **Speed of combat**: How fast should rounds resolve? Instant? With animation? With a short delay between turns for readability?
