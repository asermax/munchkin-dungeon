# Base Numbers — Game Balance Reference

All formulas validated against reference games (Darkest Dungeon, Super Auto Pets, Slay the Spire, Munchkin) and cross-checked for internal consistency. Numbers are starting points — playtesting will refine them.

---

## Balance Targets

The core ratios that drive every other number.

| Target | Value | Reasoning |
|--------|-------|-----------|
| Hits to survive (frontline, same-tier) | 4-6 | DD uses 3-5; RPG standard is 4-6 hits |
| Hits to survive (backline, same-tier) | 3-4 | Squishier but not one-shot |
| Hits to kill a same-tier monster | 2-3 | Party focus-fire kills in 1-2 rounds |
| Avg fight duration (standard room) | 3-5 rounds | Fast enough to not drag, long enough for abilities |
| Avg fight duration (boss) | 5-8 rounds | Needs strategy, cooldown cycling |
| HP cost per room (easy dungeon) | 10-20% of party HP | Room 1 should feel safe |
| HP cost per room (hard dungeon) | 30-45% of party HP | Room 5 should feel dangerous |
| Rest area recovery | Flat 20-40 HP to all surviving heroes | Partial recovery, not a reset |
| Easy dungeon total cost | 15-30% net HP loss | Completable without bailing |
| Hard dungeon total cost | 60-100% net HP loss | Risky, may need to bail or lose characters |
| Crit expected value boost | ~20-25% avg damage | At LUCK 5: 15% chance × 2.5× = +22.5% expected |
| Dodge effective value | ~10-15% damage avoided | At AGI 5: 10% dodge; meaningful but not dominant |
| Cleric heal vs incoming DPS | ~40-50% of front-row DPS | Extends fight life by ~2×; not infinite sustain |

---

## Character Stats

### Primary Stat Progression

Per level-up: guaranteed +1 to class stat + +1 to 2 random stats (race-weighted). ~30% chance of +1 to a 3rd stat. Average gain: +3.3 stats/level. Over 9 levels: ~30 total stat points.

**Class stat bonuses per level:**

| Class | Guaranteed +1 to | Ability Slot |
|-------|------------------|-------------|
| Warrior | STR | Heavy weapons, heavy armor |
| Mage | INT | Magic weapons, light armor |
| Rogue | AGI | Dual wield, light armor |
| Cleric | VIT | Blunt weapons, medium armor |

### Stat Ranges by Level (Typical Values)

Values shown for a Human (balanced 5/5/5/5/5). Race-specific variants below.

| Level | STR | AGI | VIT | INT | LUCK | Notes |
|-------|-----|-----|-----|-----|------|-------|
| 1 | 5 | 5 | 5 | 5 | 5 | Base (±2 racial variance) |
| 3 | 7 | 6 | 6 | 5 | 5 | Warrior bias; others get +1-2 |
| 5 | 9 | 6 | 7 | 6 | 6 | Class stat clearly leading |
| 7 | 11 | 7 | 8 | 6 | 7 | Gap widening |
| 10 | 14 | 8 | 9 | 7 | 8 | Max power; class stat dominates |

### Race-Specific Progression (Warrior Class)

| Level | Orc STR/AGI/VIT/INT/LUCK | Dwarf STR/AGI/VIT/INT/LUCK |
|-------|--------------------------|----------------------------|
| 1 | 8/3/7/2/5 | 6/2/9/3/5 |
| 3 | 10/4/9/2/5 | 8/3/11/3/5 |
| 5 | 12/4/11/3/5 | 10/3/13/4/6 |
| 7 | 14/5/13/3/6 | 12/4/15/4/6 |
| 10 | 17/6/15/4/7 | 15/5/17/5/7 |

### Race-Specific Progression (Mage Class)

| Level | Elf STR/AGI/VIT/INT/LUCK | Human STR/AGI/VIT/INT/LUCK |
|-------|--------------------------|----------------------------|
| 1 | 4/8/3/7/5 | 5/5/5/5/5 |
| 3 | 4/9/4/9/6 | 5/6/5/7/5 |
| 5 | 5/10/5/11/6 | 6/7/5/9/6 |
| 7 | 5/12/5/13/7 | 6/7/6/11/7 |
| 10 | 6/14/6/16/8 | 7/9/7/14/8 |

### Derived Stats Formulas (Confirmed)

| Stat | Formula | Cap |
|------|---------|-----|
| Max HP | `50 + (VIT × 8) + armor_HP_bonus` | None |
| Melee Damage | `STR × 2 + weapon_bonus` | None |
| Magic Damage | `INT × 2 + weapon_bonus` | None |
| Defense | `VIT + armor_bonus + hat_bonus + racial_bonus` | 40 (80% reduction cap) |
| Damage Reduction | `min(80%, defense × 2%)` | 80% |
| Initiative | `AGI × 3 + boots_bonus` | None |
| Dodge Chance | `AGI × 2%` | 40% |
| Crit Chance | `LUCK × 3%` | 30% |
| Crit Multiplier | `min(3.0, 2.0 + LUCK × 0.1)` | 3.0× |
| Carry Capacity | `3 + floor(STR / 5)` | None |

### HP Ranges at Key Levels (No Equipment)

| Level | Min HP (VIT 3, Elf) | Avg HP (VIT 5, Human) | Max HP (VIT 9, Dwarf) | Max w/Sturdy |
|-------|---------------------|----------------------|----------------------|--------------|
| 1 | 74 | 90 | 122 | 122 (Sturdy is defense, not HP) |
| 3 | 82 | 106 | 138 | 138 |
| 5 | 90 | 122 | 154 | 154 |
| 7 | 98 | 130 | 170 | 170 |
| 10 | 98 | 138 | 186 | 186 |

Notes: Base 50 prevents one-shots at any level. VIT range 3-15 across levels keeps HP ratio between tanky and squishy at ~1.7-1.9×. Consistent with DD where tanks have ~50% more HP than DPS.

### Damage Ranges at Key Levels (No Equipment)

| Level | Min Melee (STR 3) | Avg Melee (STR 5) | Max Melee (STR 8) | Min Magic (INT 3) | Max Magic (INT 7) |
|-------|-------------------|-------------------|-------------------|-------------------|-------------------|
| 1 | 6 | 10 | 16 | 6 | 14 |
| 3 | 8 | 12 | 18 | 8 | 16 |
| 5 | 10 | 16 | 24 | 12 | 22 |
| 7 | 12 | 20 | 28 | 14 | 26 |
| 10 | 14 | 26 | 34 | 18 | 32 |

### Defense Ranges at Key Levels (No Equipment)

| Level | Min Def (VIT 3) | Avg Def (VIT 5) | Max Def (VIT 9) | Max w/Sturdy |
|-------|-----------------|-----------------|-----------------|--------------|
| 1 | 3 (6%) | 5 (10%) | 9 (18%) | 12 (24%) |
| 3 | 4 (8%) | 7 (14%) | 11 (22%) | 14 (28%) |
| 5 | 5 (10%) | 9 (18%) | 13 (26%) | 16 (32%) |
| 7 | 6 (12%) | 11 (22%) | 15 (30%) | 18 (36%) |
| 10 | 7 (14%) | 15 (30%) | 17 (34%) | 20 (40%) |

### Initiative Ranges at Key Levels (No Equipment)

| Level | Min (AGI 2) | Avg (AGI 5) | Max (AGI 8) | Elf Max (AGI 8 + Foresight) |
|-------|-------------|-------------|-------------|------------------------------|
| 1 | 6 | 15 | 24 | 24 (Foresight affects dodge, not init) |
| 3 | 9 | 18 | 27 | 27 |
| 5 | 12 | 18 | 30 | 30 |
| 7 | 15 | 21 | 36 | 36 |
| 10 | 18 | 24 | 42 | 42 |

Notes: Typical turn order at level 1 — Elf Mage (24) > Human Warrior (15) > Monster avg (12) > Dwarf Cleric (6). Elves almost always go first. Dwarves almost always go last. This is intentional and creates distinct playfeel.

### Dodge and Crit at Key Levels

| Level | Min Dodge (AGI 2) | Avg Dodge (AGI 5) | Max Dodge (AGI 8) | Elf Dodge (AGI 8+10%) | Min Crit (LUCK 3) | Max Crit (LUCK 7) |
|-------|-------------------|-------------------|-------------------|-----------------------|-------------------|-------------------|
| 1 | 4% | 10% | 16% | 26% | 9% | 21% |
| 5 | 8% | 12% | 20% | 30% | 15% | 21% |
| 10 | 12% | 16% | 28% | 38% | 21% | 27% |

Crit multiplier at key LUCK values:

| LUCK | Crit Chance | Crit Multiplier | Expected Damage Boost |
|------|-------------|-----------------|-----------------------|
| 3 | 9% | 2.3× | +11.7% |
| 5 | 15% | 2.5× | +22.5% |
| 7 | 21% | 2.7× | +35.7% |
| 10 | 30% | 3.0× | +60.0% |

---

## Equipment Stats

Equipment is the primary progression driver — more impactful than raw stat gains (consistent with Munchkin's design where gear > level).

### Weapon Bonus by Rarity

| Rarity | Bonus Range | Drop Rate | Example |
|--------|------------|-----------|---------|
| Common | +1 to +3 | ~50% | Rusty Sword (+1), Iron Sword (+2), Sharp Sword (+3) |
| Uncommon | +3 to +5 | ~30% | Fine Blade (+3), Vorpal Knife (+4), Flamebrand (+5) |
| Rare | +5 to +8 | ~15% | Gryphon's Beak (+6), Skullcrusher (+7), The Screaming Sword (+8) |
| Legendary | +8 to +12 | ~4% | Excalibur's Discount Cousin (+10), Godslayer Jr. (+12) |
| Cursed | +5 to +10 (with downside) | ~1% | Lucky Blade (+8, -3 LUCK), Berserker Axe (+12, can't flee) |

### Armor Bonus by Rarity

| Rarity | Defense Bonus | HP Bonus | Drop Rate |
|--------|--------------|----------|-----------|
| Common | +1 to +2 | 0 | ~50% |
| Uncommon | +2 to +4 | 0-5 | ~30% |
| Rare | +4 to +6 | 0-10 | ~15% |
| Legendary | +6 to +8 | 5-15 | ~4% |
| Cursed | +4 to +8 (with downside) | 0 | ~1% |

### Hat Bonus by Rarity

| Rarity | Defense Bonus | Special Effects | Drop Rate |
|--------|--------------|-----------------|-----------|
| Common | +1 | None | ~50% |
| Uncommon | +1 to +2 | None | ~30% |
| Rare | +2 to +3 | Minor (+1 stat, minor resist) | ~15% |
| Legendary | +3 to +5 | Strong (+2 stat, major effect) | ~4% |
| Cursed | +2 to +4 (with downside) | Mixed | ~1% |

### Boots Bonus by Rarity

| Rarity | Initiative Bonus | Special Effects | Drop Rate |
|--------|-----------------|-----------------|-----------|
| Common | +1 to +2 | None | ~50% |
| Uncommon | +2 to +3 | None | ~30% |
| Rare | +3 to +5 | Minor (+1 AGI) | ~15% |
| Legendary | +5 to +8 | Strong (+2 AGI, dodge bonus) | ~4% |
| Cursed | +3 to +6 (with downside) | Mixed | ~1% |

### Equipment Impact on Total Power

| Stage | Weapon | Armor | Hat | Boots | Total Added |
|-------|--------|-------|-----|-------|-------------|
| Level 1, Common | +2 | +2 def | +1 def | +2 init | +2 dmg, +3 def, +2 init |
| Level 3, Common/Uncommon | +4 | +3 def | +1 def | +2 init | +4 dmg, +4 def, +2 init |
| Level 5, Uncommon/Rare | +6 | +5 def, +3 HP | +2 def | +3 init | +6 dmg, +7 def, +3 init |
| Level 10, Rare/Legendary | +10 | +7 def, +10 HP | +4 def | +6 init | +10 dmg, +11 def, +6 init |

### Complete Character at Key Levels (With Equipment)

**Human Warrior (front row) — All stages:**

| Level | HP | Damage | Defense | Reduction | Initiative | Dodge | Crit |
|-------|-----|--------|---------|-----------|------------|-------|------|
| 1 | 90 | 12 | 8 | 16% | 17 | 10% | 15% |
| 3 | 106 | 18 | 11 | 22% | 20 | 12% | 15% |
| 5 | 129 | 24 | 16 | 32% | 21 | 12% | 18% |
| 7 | 138 | 30 | 19 | 38% | 24 | 14% | 21% |
| 10 | 148 | 38 | 26 | 52% | 30 | 16% | 24% |

**Elf Mage (back row) — All stages:**

| Level | HP | Damage | Defense | Reduction | Initiative | Dodge | Crit |
|-------|-----|--------|---------|-----------|------------|-------|------|
| 1 | 74 | 16 | 5 | 10% | 26 | 26% | 15% |
| 3 | 82 | 22 | 7 | 14% | 30 | 28% | 18% |
| 5 | 90 | 28 | 9 | 18% | 35 | 30% | 18% |
| 7 | 98 | 34 | 10 | 20% | 41 | 34% | 21% |
| 10 | 108 | 42 | 13 | 26% | 50 | 38% | 24% |

**Dwarf Cleric (back row) — All stages:**

| Level | HP | Damage | Defense | Reduction | Initiative | Dodge | Crit |
|-------|-----|--------|---------|-----------|------------|-------|------|
| 1 | 122 | 12 | 15 | 30% | 8 | 4% | 15% |
| 3 | 130 | 16 | 17 | 34% | 11 | 6% | 15% |
| 5 | 164 | 18 | 21 | 42% | 12 | 6% | 18% |
| 7 | 170 | 22 | 23 | 46% | 15 | 8% | 21% |
| 10 | 186 | 28 | 27 | 54% | 21 | 10% | 24% |

**Orc Warrior (front row) — All stages:**

| Level | HP | Damage | Defense | Reduction | Initiative | Dodge | Crit |
|-------|-----|--------|---------|-----------|------------|-------|------|
| 1 | 106 | 18 | 10 | 20% | 11 | 6% | 15% |
| 3 | 122 | 24 | 13 | 26% | 14 | 8% | 15% |
| 5 | 138 | 30 | 16 | 32% | 14 | 8% | 15% |
| 7 | 154 | 36 | 18 | 36% | 17 | 10% | 18% |
| 10 | 170 | 44 | 22 | 44% | 22 | 12% | 21% |

---

## Monster Stats

### Tier 1 — Chumps (Easy rooms, early dungeons)

*"Goblin With a Stick", "Sad Skeleton", "Disoriented Slime"*

| Stat | Range | Avg |
|------|-------|-----|
| HP | 30-50 | 40 |
| Damage | 8-12 | 10 |
| Defense | 2-4 | 3 |
| Initiative | 8-14 | 11 |
| Abilities | None | — |
| Bad Stuff | None | — |

**Damage math vs Level 1 Human Warrior (Def 8, 16% reduction):**
- Avg hit: 10 × 0.84 = 8.4 damage → 11 hits to kill warrior. Consistent with 4-6 target (3 monsters attacking).
- Warrior kills Tier 1 in: 12 damage / (40 HP / 12 dmg × 0.94) = 3-4 hits. But party focuses, so ~1-2 rounds.

### Tier 2 — Troublemakers (Medium rooms, mid dungeons)

*"Orc With a Plan", "Enraged Chicken", "Skeleton Who Read a Book Once"*

| Stat | Range | Avg |
|------|-------|-----|
| HP | 50-75 | 65 |
| Damage | 12-18 | 15 |
| Defense | 4-7 | 6 |
| Initiative | 12-18 | 15 |
| Abilities | 1 ability | — |
| Bad Stuff | None | — |

**Damage math vs Level 3 party:**
- Avg hit on front row (Def 11, 22% reduction): 15 × 0.78 = 11.7 damage → ~9 hits to kill warrior
- Party focus damage: 4 × 17 × 0.88 = ~60/round → kills Tier 2 in ~1 round (3 monsters in ~3 rounds)

### Tier 3 — Menaces (Hard rooms, late dungeons)

*"Dragon Who Pays Taxes", "The IRS", "Existential Dread Made Flesh"*

| Stat | Range | Avg |
|------|-------|-----|
| HP | 70-110 | 90 |
| Damage | 18-26 | 22 |
| Defense | 6-10 | 8 |
| Initiative | 16-24 | 20 |
| Abilities | 1 ability + Bad Stuff | — |
| Bad Stuff | 30% have it | — |

**Damage math vs Level 5 party:**
- Avg hit on front row (Def 16, 32% reduction): 22 × 0.68 = 15 damage → ~9 hits to kill warrior
- Party focus: 4 × 26 × 0.84 = ~87/round → kills Tier 3 in ~1 round per monster

### Boss Monsters (Final room)

*"Gerald the Unnerving", "Blorb, Eater of Lunch", "Karen, Manager of Darkness"*

| Stat | Easy Boss | Medium Boss | Hard Boss |
|------|-----------|-------------|-----------|
| HP | 80-120 | 130-180 | 180-260 |
| Damage | 14-20 | 20-30 | 28-40 |
| Defense | 5-8 | 8-12 | 10-15 |
| Initiative | 14-18 | 18-25 | 22-30 |
| Abilities | 1 | 2 | 2-3 |
| Bad Stuff | Mild | Moderate | Severe |

### Monster Group Composition by Room

| Room Depth | Group Size | Tier Mix | Notes |
|------------|-----------|----------|-------|
| Room 1 | 1-2 | 100% Tier 1 | Entrance guard; sets tone |
| Rooms 2-3 | 1-3 | 80% Tier 1, 20% Tier 2 | Mix starts |
| Rooms 4-5 | 2-3 | 50% Tier 1, 50% Tier 2 | Difficulty ramps |
| Rooms 6+ | 2-3 | 30% Tier 2, 70% Tier 3 | Late dungeon is hard |
| Final Room | 1 boss | Boss + 0-2 Tier 2 minions | Climactic |

---

## Combat Math Verification

### Scenario 1: Level 1 Party vs Room 1 (Easy Dungeon)

**Party:** Human Warrior L1, Human Rogue L1, Elf Mage L1, Dwarf Cleric L1 (Common gear)
- Total HP: 90 + 90 + 74 + 122 = 376
- Party DPR (after Tier 1 monster defense 6%): ~50/round
- Cleric heal: 18 HP (2-round cooldown)

**Monsters:** 2 × Tier 1 (HP 40, Dmg 10, Def 3)
- Monster DPR on front row (Def 8, 16% reduction): 2 × 8.4 = 16.8/round

**Round-by-round:**
- Round 1: Party deals 50 → Monster A dies (40 HP), overflow 10 to Monster B. 2 monsters attack: 16.8 damage.
- Round 2: Party deals 50 → Monster B (30 HP) dies. 1 monster attacks: 8.4 damage. Cleric heals 18.
- **Total party damage taken: 25.2 - 18 healed = 7.2 HP (1.9% of party HP)**

**Verdict:** Very easy. Intentionally so — room 1 should feel safe. ✅

### Scenario 2: Level 1 Party vs Room 5 (Easy Dungeon, 3 Tier 1 monsters)

**Same party, now with some damage from previous rooms (~25% HP lost = ~282 HP remaining)**

**Monsters:** 3 × Tier 1 (HP 45, Dmg 12, Def 4)
- Monster DPR: 3 × 12 × 0.84 = 30.2/round
- Party DPR: ~48/round (after defense)

**Round-by-round:**
- Round 1: Party 48 → Monster A (45 HP) dies, overflow 3 to B. 3 monsters attack: 30.2 damage.
- Round 2: Party 48 → Monster B (42 HP) dies, overflow 6 to C (39 HP). 2 monsters attack: 20.1 damage.
- Round 3: Party 48 → Monster C (39 HP) dies. 1 monster attacks: 10 damage. Cleric heals 18.
- **Total damage taken: 60.3 - 18 = 42.3 HP (11.2% of party HP)**

**Verdict:** Moderate. After 4 fights without rest: ~42% HP lost total. Push-your-luck tension builds. ✅

### Scenario 3: Level 3 Party vs Hard Dungeon Room (3 Tier 2 monsters)

**Party:** Orc Warrior L3, Human Rogue L3, Elf Mage L3, Human Cleric L3 (Common/Uncommon gear)
- Total HP: ~122 + 106 + 82 + 106 = 416
- Party DPR: ~68/round
- Cleric heal: 24 HP

**Monsters:** 3 × Tier 2 (HP 65, Dmg 16, Def 6)
- Monster DPR on front row (Def 11, 22% reduction): 3 × 16 × 0.78 = 37.4/round

**Round-by-round:**
- Round 1: Party 68 → Monster A (65 HP) dies, overflow 3 to B. 3 monsters attack: 37.4 damage.
- Round 2: Party 68 → Monster B (62 HP) dies, overflow 6 to C (59 HP). 2 monsters attack: 24.9 damage. Cleric heals 24.
- Round 3: Party 68 → Monster C (59 HP) dies. 1 monster attacks: 12.5 damage.
- **Total damage taken: 74.8 - 24 = 50.8 HP (12.2% of party HP)**

**Verdict:** Moderate for a level 3 party. Hard dungeon is challenging but manageable per-room. Over a full dungeon (5 rooms), total damage: ~60-80% HP, which creates real bail-or-push decisions. ✅

### Scenario 4: Level 1 Party (2 chars only) vs First Easy Dungeon

**Party:** Human Warrior L1, Human Cleric L1 (Common gear)
- Total HP: 180
- DPR: ~24/round

**Room 1:** 1 × Tier 1 (HP 35, Dmg 8)
- 2 rounds. Monster deals 8 × 2 × 0.84 = 13.4 damage. Cleric heals 18. Net: 0 HP lost. ✅

**Room 2:** 1 × Tier 1 (HP 40, Dmg 10)
- 2 rounds. Monster deals 10 × 2 × 0.84 = 16.8 damage. Net: ~0 (healed). ✅

**Room 3:** Treasure room. Free loot.

**Room 4:** Rest area. Heal 50% of any accumulated damage.

**Room 5 (Boss):** Easy Boss (HP 80, Dmg 14, Def 5)
- 4 rounds. Boss deals 14 × 4 × 0.84 = 47 damage. Cleric heals 2× = 36. Net: 11 HP (6% of party HP). ✅

**Verdict:** First dungeon with 2 characters is very manageable. Good intro experience. ✅

---

## XP System

### Level Thresholds (Confirmed)

| Level | Total XP | XP from Previous | Fights to Level* |
|-------|----------|------------------|------------------|
| 1 | 0 | — | — |
| 2 | 30 | 30 | 1-2 |
| 3 | 80 | 50 | 2-3 |
| 4 | 150 | 70 | 3-4 |
| 5 | 250 | 100 | 4-5 |
| 6 | 400 | 150 | 5-6 |
| 7 | 600 | 200 | 6-8 |
| 8 | 850 | 250 | 8-10 |
| 9 | 1,150 | 300 | 10-12 |
| 10 | 1,500 | 350 | 12-15 |

\*Estimated fights at appropriate dungeon level. Assumes participation bonuses.

**Curve shape:** Accelerating (1.5× per level roughly). Consistent with RPG standard. Level 10 = 50× the XP of level 2. Reaching max level should feel like an achievement.

### XP Per Monster (By Monster Tier)

| Source | XP Value | Notes |
|--------|----------|-------|
| Tier 1 monster | 8 XP | Easy rooms |
| Tier 2 monster | 15 XP | Medium rooms |
| Tier 3 monster | 25 XP | Hard rooms |
| Boss (Easy) | 30 XP | Final room |
| Boss (Medium) | 50 XP | Final room |
| Boss (Hard) | 80 XP | Final room |

### XP Participation Bonuses (Per Character)

| Activity | XP Rate | Example |
|----------|---------|---------|
| Damage dealt | +1 per 10 damage | Dealt 30 → +3 XP |
| Damage taken/dodged | +1 per 15 damage | Took 30 → +2 XP |
| Healing done | +1 per 10 HP healed | Healed 20 → +2 XP |

### Typical XP Per Room (Per Character)

| Dungeon Tier | Monsters | Base XP | Participation | Total/Char |
|-------------|----------|---------|---------------|------------|
| Easy (Tier 1 ×2) | 2 | 16 | 4-6 | 8-11 |
| Medium (Tier 2 ×2) | 2 | 30 | 6-8 | 15-19 |
| Hard (Tier 3 ×3) | 3 | 75 | 8-12 | 25-37 |

### Dungeon Completion Bonus

| Difficulty | Bonus XP |
|------------|----------|
| Easy | 25 XP per character |
| Medium | 50 XP per character |
| Hard | 75 XP per character |

### XP Progression Speed (Validation)

**Level 1 character doing Easy dungeons:**
- Per room: ~10 XP. Per dungeon (5 rooms, 3 monster rooms): ~30 XP + 25 completion = 55 XP.
- Level 2 reached: after 1 dungeon. ✅ (fast, feels good)
- Level 3 reached: after 2 dungeons. ✅
- Level 5 reached: after 5-6 dungeons. ✅ (reasonable pace)

**Level 5 character doing Hard dungeons:**
- Per room: ~30 XP. Per dungeon (6 rooms, 4 monster rooms): ~120 XP + 75 completion = 195 XP.
- Level 5 → 6 needs 150: reached in 1 dungeon. ✅
- Level 9 → 10 needs 350: reached in 2 hard dungeons. ✅ (max level is achievable)

### Mid-Dungeon Leveling

Yes, characters can level up mid-dungeon. XP applies immediately. The level-up grants stats but abilities only apply from the next fight (prevents mid-combat complexity).

---

## Gold Economy

### Starting Gold

| Item | Amount |
|------|--------|
| Starting gold | 30 |

Enough for 1 consumable before the first dungeon, or save it all.

### Gold Income

| Source | Easy | Medium | Hard |
|--------|------|--------|------|
| Per Tier 1 monster kill | 5-8 | 8-10 | 10-12 |
| Per Tier 2 monster kill | — | 10-15 | 12-18 |
| Per Tier 3 monster kill | — | — | 15-25 |
| Per treasure room | 10-20 | 15-30 | 20-40 |
| Quest completion reward | 25-40 | 50-75 | 80-120 |

### Gold Per Dungeon (Estimated Total)

| Dungeon | Monster Gold | Treasure | Quest | Total |
|---------|-------------|----------|-------|-------|
| Easy (5 rooms) | ~35 | ~15 | ~30 | ~80 |
| Medium (6 rooms) | ~65 | ~25 | ~60 | ~150 |
| Hard (7 rooms) | ~120 | ~35 | ~100 | ~255 |

### Gold Costs

| Item | Cost | Notes |
|------|------|-------|
| Healing Potion (Small) | 15 | Restores 25 HP flat |
| Healing Potion (Large) | 25 | Restores 45 HP flat |
| Curse Negator | 30 | Removes 1 curse from 1 character |
| Resurrect Scroll | 50 | Revive dead character at 10% HP (rare shop item) |

Shop has 3 slots per run, randomized between potions and curse negators. Resurrect scrolls appear ~10% of the time.

### Recruit Costs

| Recruit Level | Gold Cost | Notes |
|---------------|-----------|-------|
| Level 1 | 40 | Basic, cheapest |
| Level 2 | 55 | |
| Level 3 | 70 | |
| Level 4 | 85 | Sometimes requires donating an item |
| Level 5 | 100 | Usually requires donating an item |
| Level 6+ | 100 + (level × 15) | Expensive veterans; rare |

**Formula:** `40 + (recruit_level - 1) × 15`

### Economy Balance Check

After 1 easy dungeon (80 gold):
- Buy 1 large potion (25) + save 55. Can't afford recruit yet.
- OR save all 80. Still can't afford level 2+ recruit.

After 2 easy dungeons (160 gold total, minus 1 potion = 135):
- Buy recruit (40-70) + 1-2 potions. ✅ Meaningful choice.

After 1 medium dungeon (150 gold):
- Buy recruit (55-85) + 1-2 potions. ✅ Meaningful choice.

After 1 hard dungeon (255 gold):
- Buy high-level recruit + stock up. ✅ Reward for risk.

**The economy makes every purchase a real decision.** Players choose between safety (potions) and growth (recruits). This is consistent with Slay the Spire's "can afford ~1 thing per shop" principle.

---

## Healing & Recovery

### Cleric Heal Formula

```
Heal = 15 + (Cleric_Level × 3)
```

| Cleric Level | Heal Amount | % of Frontline HP (avg) | Cooldown |
|-------------|-------------|------------------------|----------|
| 1 | 18 | 20% | 2 rounds |
| 3 | 24 | 22% | 2 rounds |
| 5 | 30 | 23% | 2 rounds |
| 7 | 36 | 26% | 2 rounds |
| 10 | 45 | 33% | 2 rounds |

Notes: Heal restores flat HP to the ally with lowest HP%. Scales with level so it stays relevant. At all levels, heal is ~20-33% of a frontliner's max HP, which means it meaningfully extends survival without creating infinite sustain.

### Healing Potion Stats

| Potion | HP Restored | Cost | % of Avg L1 HP | % of Avg L5 HP |
|--------|------------|------|-----------------|-----------------|
| Small | 25 | 15 | 28% | 20% |
| Large | 45 | 25 | 50% | 35% |

Potions are used between rooms (not during combat). Each character can carry potions in their inventory (carry capacity permitting).

### Rest Area Recovery

```
HP Restored = flat 20-40 HP (per surviving hero)
```

Heals all surviving heroes for a flat amount. Maintains tension without being punishing — low-HP characters get meaningful recovery, high-HP characters get less relative benefit.

Rest also clears all temporary curses and allows equipment rearrangement.

### Between-Dungeon Recovery

Full heal for all surviving characters. No cost. This is the "reset" between expeditions — attrition does NOT carry between dungeons.

---

## Curse Mechanics

### Severity Distribution

| Severity | Probability | Effect Examples | Duration |
|----------|-------------|-----------------|----------|
| Mild | 50% | -1 to one stat, -2 initiative, "wet socks" | 2-3 rooms |
| Annoying | 25% | -2 to one stat, equipment swap, "forgot how to read" | Until rest |
| Moderate | 15% | -3 to one stat, can't use one ability, "identity crisis" | Until rest |
| Severe | 7% | Destroy one equipped item, -2 to two stats | Permanent |
| Devastating | 3% | Destroy best equipped item, permadeath risk | Permanent |

**Permanent curse rate: ~10%** (severe + devastating combined). This is rare enough to not feel unfair but common enough to be scary. Consistent with design doc's "~5% of curses" for the truly severe.

### Stat Penalty Ranges

| Severity | Stat Penalty | Notes |
|----------|-------------|-------|
| Mild | -1 to one stat | Barely noticeable |
| Annoying | -1 to -2 to one stat | Tactically relevant |
| Moderate | -2 to -3 to one stat, or -1 to two stats | Hurts |
| Severe | -3 to -4 to one stat | Major impact |
| Devastating | Item loss or -2 to all stats | Character-defining |

### Duration by Type

| Duration | Probability | Clears When |
|----------|-------------|-------------|
| Instant | 10% | Immediately (effect happens, no lingering) |
| 2-3 rooms | 40% | After 2-3 rooms pass |
| Until rest | 35% | Next rest area or dungeon end |
| Permanent | 15% | Never (until item/scroll used) |

### Curse Targets

| Target | Probability | Example |
|--------|-------------|---------|
| One random character | 60% | "Your wizard forgot how to read" |
| Front character | 15% | "The floor is lava" |
| Back character | 10% | "Someone's watching you" |
| Whole party | 15% | "Wet socks for everyone" |

### Curse Cap

Max **2 curses per character**. At cap:
- Cannot receive flee curse → flee fails
- Cannot receive curse room curse → effect is instead 10% max HP damage

### Flee Curse

Fleeing a fight curses a random party member. Roll on the standard curse table but shifted toward milder effects:

| Severity | Flee Curse Probability |
|----------|----------------------|
| Mild | 60% |
| Annoying | 25% |
| Moderate | 10% |
| Severe | 5% |
| Devastating | 0% |

No devastating curses from fleeing — the punishment should hurt, not end runs.

---

## Difficulty Scaling

### Dungeon Difficulty Multipliers

| Difficulty | Monster HP | Monster Damage | Monster Defense | Notes |
|------------|-----------|---------------|-----------------|-------|
| Easy | ×0.85 | ×0.80 | ×0.75 | Below party level |
| Medium | ×1.00 | ×1.00 | ×1.00 | At party level |
| Hard | ×1.20 | ×1.25 | ×1.25 | At or above party level |

These multipliers apply to the base monster stats for each tier.

### Room Depth Scaling

Within a dungeon, monster stats increase slightly per room beyond the first:

| Room Position | HP Bonus | Damage Bonus | Notes |
|---------------|----------|--------------|-------|
| Room 1 | +0% | +0% | Always base stats |
| Room 2-3 | +5% | +0% | Slightly tougher |
| Room 4-5 | +10% | +5% | Getting harder |
| Room 6-7 | +15% | +10% | Late dungeon |
| Room 8+ | +20% | +15% | Deep runs are brutal |
| Boss Room | +30% HP | +15% damage | Climactic |

### Easy vs Hard: The Full Picture

For a **level 3 party** doing a **Normal-length dungeon** (6 rooms):

| Dungeon | Room 1 Monsters | Room 5 Monsters | Boss |
|---------|-----------------|-----------------|------|
| Easy | 1× Tier 1 (HP 34, Dmg 8) | 2× Tier 1 (HP 42, Dmg 10) | Tier 1 boss (HP 100, Dmg 16) |
| Medium | 2× Tier 1 (HP 40, Dmg 10) | 2× Tier 2 (HP 65, Dmg 15) | Tier 2 boss (HP 155, Dmg 25) |
| Hard | 2× Tier 2 (HP 78, Dmg 20) | 3× Tier 2 (HP 75, Dmg 19) | Tier 3 boss (HP 235, Dmg 36) |

### Long vs Normal Dungeons

| Aspect | Normal (5-7 rooms) | Large (9-12 rooms) |
|--------|-------------------|-------------------|
| Monster count | ~4-5 rooms | ~7-9 rooms |
| Rest areas | 1 guaranteed | 2 guaranteed |
| Depth scaling | Up to +15% | Up to +20% |
| Monster tier ceiling | Tier 2 (Tier 3 boss) | Tier 3 |
| Boss power | Standard | +20% stats |
| Curse rooms | 1-2 | 2-3 |
| Loot quality | Normal | +1 rarity tier on room 6+ |

---

## Loot Tables

### Monster Drop Rates

| Monster Tier | Gold Drop | Equipment Drop | Drop Rate |
|-------------|-----------|----------------|-----------|
| Tier 1 | 5-10 | Common | 20% per monster |
| Tier 2 | 10-18 | Common/Uncommon | 35% per monster |
| Tier 3 | 15-25 | Uncommon/Rare | 50% per monster |
| Boss | 20-40 | Rare/Legendary | 100% (1-2 items) |

### Treasure Room Quality by Dungeon

| Dungeon Tier | Common | Uncommon | Rare | Legendary |
|-------------|--------|----------|------|-----------|
| Easy | 60% | 30% | 9% | 1% |
| Medium | 40% | 35% | 20% | 5% |
| Hard | 25% | 30% | 35% | 10% |

### Cursed Item Rate

~1% of all equipment drops are cursed. Cursed items have 1-3× the normal bonus but a hidden downside:
- Stat penalty (-2 to -4 on a different stat)
- Conditional debuff (can't flee, takes extra crit damage, etc.)
- Identified after first fight wearing it, or with a Curse Negator consumable

---

## Consumable Design

### Healing Potions

| Potion | HP Restored | Cost | Notes |
|--------|------------|------|-------|
| Small | 25 HP | 15 gold | ~25-30% of max HP at level 1 |
| Large | 45 HP | 25 gold | ~50% of max HP at level 1, scales less at higher levels |

Used between rooms. One action. Does not consume a room turn.

### Curse Negator

Removes one curse (temporary or permanent) from one character. Cost: 30 gold.

### Other Consumables (Nice-to-Have)

| Item | Effect | Cost | Rarity |
|------|--------|------|--------|
| Antidote | Cures poison/DoT effects | 10 gold | Common |
| Buff Scroll | +2 to one stat for next fight | 20 gold | Uncommon |
| Smoke Bomb | Guaranteed flee next fight (no curse) | 35 gold | Rare |
| Resurrect Scroll | Revive dead char at 10% HP | 50 gold | Very rare |

---

## Encounter Pacing Targets

### Typical Easy Dungeon (5 rooms, Level 1 Party)

| Room | Type | Threat | Expected HP Cost |
|------|------|--------|-----------------|
| 1 | Monster (2× Tier 1) | Low | 5-10% |
| 2 | Monster (1× Tier 1) | Very low | 3-5% |
| 3 | Treasure | None | 0% |
| 4 | Rest | Recovery | -10-15% |
| 5 | Boss (Easy) | Moderate | 10-15% |
| **Total** | | | **8-15% net** |

Outcome: Party completes with 85-92% HP. Feels easy. Intended for first runs.

### Typical Hard Dungeon (6 rooms, Level 5 Party)

| Room | Type | Threat | Expected HP Cost |
|------|------|--------|-----------------|
| 1 | Monster (3× Tier 2) | High | 15-25% |
| 2 | Monster (2× Tier 2) | Moderate | 10-15% |
| 3 | Curse (Annoying) | -2 STR to one char | 0% (but weaker) |
| 4 | Rest | Recovery | -15-20% |
| 5 | Monster (3× Tier 3) | Very high | 25-35% |
| 6 | Boss (Hard) | Extreme | 25-35% |
| **Total** | | | **60-90% net** |

Outcome: Party barely survives. Likely needs bail at room 5-6 or loses 1 character. Push-your-luck works.

### When to Bail (Design Target)

| Situation | HP Remaining | Recommendation |
|-----------|-------------|----------------|
| After room 2 | >80% | Keep going, you're fine |
| After room 3 | 60-80% | Cautious. Consider bailing if next room is unknown. |
| After room 4 (post-rest) | 50-70% | Borderline. One more fight, then decide. |
| After room 5 | <40% | Bail. The curse is better than losing a character. |
| Front row dead | Any | Probably bail unless boss room is next. |

---

## Bad Stuff Design (Post-Victory Monster Effects)

~30% of monsters have Bad Stuff. Distribution:

| Severity | Probability | Effect | Example |
|----------|-------------|--------|---------|
| Flavor (0%) | 10% | No mechanical effect, just flavor text | "You smell bad. Monsters avoid you for 1 room (good?)" |
| Mild (60%) | 15% | Minor temporary debuff | "-1 initiative for 2 rooms", "One char loses consumable" |
| Moderate (25%) | 5% | Meaningful temporary debuff | "-2 STR until rest", "Front char takes 10 damage" |
| Severe (5%) | 3% | Item loss or major debuff | "Random equipped item breaks", "-3 LUCK permanently" |

---

## Research Sources

### Numbers Used From Reference Games

| Source | What We Used | How It Informed Design |
|--------|-------------|----------------------|
| **Darkest Dungeon** | HP per level (22-82), damage ranges (4-18), dodge (0-60%), protection (0-40%), death's door at 0 HP | Informed base HP (50), defense cap (80%), dodge cap (40%), and the "front row takes hits" model |
| **Super Auto Pets** | Tier scaling (T1 avg 3.8 total stats → T6 avg 12.9 = 3.4×), economy (3 gold per pet, tight income) | Informed monster tier scaling (×3 from T1 to T3), gold economy (tight, meaningful choices) |
| **Slay the Spire** | Enemy HP by act (12-250), player HP (65-80), card damage (6-30), 3-7 turn fights, gold per fight (~20-30) | Informed fight length (3-5 rounds standard), XP curve shape, gold income per room |
| **Munchkin** | Monster levels 1-20, equipment bonuses +1 to +5 per slot, combat strength scaling, 33% flee chance | Informed equipment bonus ranges, the "absurd item" spirit, and the equipment > level progression model |
| **General RPG Balance** | 4-6 hits to survive, 3-5 round standard fights, polynomial power curves (L^1.5), 5-15% base crit, 2.0× base crit multiplier | Informed all derived stat formulas, balance targets, and damage/HP ratios |

### Key Design Principles Applied

1. **Equipment > level**: From Munchkin. Gear is the primary power source. A well-equipped level 3 should beat a poorly-equipped level 5.
2. **Action economy matters**: 4 party members vs 1-3 monsters creates natural difficulty scaling. More monsters = harder, regardless of stats.
3. **Percentage defense with cap**: From LoL's armor formula. Each point of defense has consistent value. Cap prevents invincibility.
4. **Partial recovery**: Rest heals a flat 20-40 HP, not a percentage. Prevents full resets while keeping the math simple.
5. **Accelerating XP**: From RPG standards (D&D, Pokemon). Each level takes more XP than the last.
6. **Tight economy**: From Slay the Spire. Player can afford ~1 meaningful purchase per dungeon run.
7. **Crits multiply post-defense**: Multiplication is commutative, so order doesn't change the math. Defense stays relevant on crits.
8. **Dodge before crit**: Consistent with RPG standard. A dodged attack can't crit. Makes dodge valuable.

### Numbers We Adjusted From Research

| What | Research Suggested | What We Used | Why |
|------|-------------------|--------------|-----|
| Base HP | DD: 22-35 HP at level 1 | 50 + VIT×8 (74-122) | Higher base prevents one-shots in a permadeath game |
| Crit multiplier | Industry avg: 1.5-2.0× | 2.0-3.0× (LUCK-based) | Higher to make crits feel exciting in an auto-battler |
| Dodge cap | Recommendation: 25-35% | 40% | Elves are dodge-focused; cap needs to be reachable for them |
| Defense cap | WoW: 75%, LoL: no cap | 80% | Higher cap makes tanks feel tanky, but never invincible |
| Monster tier scaling | SAP: 3.4× from T1 to T6 | ~3× from T1 to T3 (across 3 tiers, not 6) | Fewer tiers = bigger jumps per tier |
