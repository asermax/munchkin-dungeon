# Dungeon Structures & Generation Reference

Complete dungeon generation system tying together encounter design (`encounters.md`), enemy database (`enemies.md`), equipment drops (`equipment.md`), and balance targets (`base-numbers.md`). Designed for direct implementation.

---

## Part A: Room Distribution Tables

### Room Count by Configuration

| Difficulty | Length | Min Rooms | Max Rooms | Typical |
|------------|--------|:---------:|:---------:|:-------:|
| Easy | Normal | 4 | 5 | 4 |
| Easy | Long | 6 | 8 | 7 |
| Medium | Normal | 5 | 6 | 5 |
| Medium | Long | 7 | 9 | 8 |
| Hard | Normal | 5 | 7 | 6 |
| Hard | Long | 8 | 10 | 9 |

### Room Type Probabilities by Position

Room type probabilities shift as depth increases. Early rooms are safer; late rooms are brutal. Values are percentages; roll d100 per room.

#### Easy / Normal (4-5 rooms)

| Position | Monster | Curse | Treasure | Rest |
|----------|:-------:|:-----:|:--------:|:----:|
| Room 1 | 100% (guaranteed) | — | — | — |
| Room 2 | 50% | 10% | 25% | 15% |
| Room 3 | 50% | 15% | 20% | 15% |
| Room 4 | 50% | 10% | 20% | 20% |
| Room 5 (Boss) | 100% (boss) | — | — | — |

#### Easy / Long (6-8 rooms)

| Position | Monster | Curse | Treasure | Rest |
|----------|:-------:|:-----:|:--------:|:----:|
| Room 1 | 100% (guaranteed) | — | — | — |
| Room 2 | 50% | 10% | 25% | 15% |
| Room 3 | 55% | 12% | 20% | 13% |
| Room 4 | 55% | 15% | 15% | 15% |
| Room 5 (midpoint) | 50% | 12% | 20% | 18% |
| Room 6+ | 60% | 15% | 12% | 13% |
| Final | 100% (boss) | — | — | — |

#### Medium / Normal (5-6 rooms)

| Position | Monster | Curse | Treasure | Rest |
|----------|:-------:|:-----:|:--------:|:----:|
| Room 1 | 100% (guaranteed) | — | — | — |
| Room 2 | 55% | 12% | 20% | 13% |
| Room 3 | 55% | 18% | 15% | 12% |
| Room 4 | 58% | 18% | 12% | 12% |
| Room 5 (6-room) | 60% | 15% | 12% | 13% |
| Final | 100% (boss) | — | — | — |

#### Medium / Long (7-9 rooms)

| Position | Monster | Curse | Treasure | Rest |
|----------|:-------:|:-----:|:--------:|:----:|
| Room 1 | 100% (guaranteed) | — | — | — |
| Room 2 | 55% | 12% | 20% | 13% |
| Room 3 | 55% | 15% | 18% | 12% |
| Room 4 | 58% | 18% | 12% | 12% |
| Room 5 (midpoint) | 55% | 15% | 15% | 15% |
| Room 6 | 60% | 18% | 10% | 12% |
| Room 7+ | 62% | 20% | 8% | 10% |
| Final | 100% (boss) | — | — | — |

#### Hard / Normal (5-7 rooms)

| Position | Monster | Curse | Treasure | Rest |
|----------|:-------:|:-----:|:--------:|:----:|
| Room 1 | 100% (guaranteed) | — | — | — |
| Room 2 | 58% | 15% | 15% | 12% |
| Room 3 | 60% | 20% | 10% | 10% |
| Room 4 | 62% | 20% | 8% | 10% |
| Room 5 | 60% | 18% | 10% | 12% |
| Room 6 (7-room) | 65% | 20% | 8% | 7% |
| Final | 100% (boss) | — | — | — |

#### Hard / Long (8-10 rooms)

| Position | Monster | Curse | Treasure | Rest |
|----------|:-------:|:-----:|:--------:|:----:|
| Room 1 | 100% (guaranteed) | — | — | — |
| Room 2 | 58% | 15% | 15% | 12% |
| Room 3 | 60% | 18% | 12% | 10% |
| Room 4 | 62% | 20% | 10% | 8% |
| Room 5 (midpoint) | 55% | 15% | 15% | 15% |
| Room 6 | 62% | 20% | 8% | 10% |
| Room 7+ | 65% | 22% | 6% | 7% |
| Final | 100% (boss) | — | — | — |

### Guaranteed Placement Rules

| Rule | Condition | Placement |
|------|-----------|-----------|
| First room | Always | Monster (entrance guard) |
| Final room | Always | Boss monster |
| Midpoint rest | 6+ room dungeons | Rest area at `floor(total_rooms / 2)` |
| No consecutive curses | Always | If room N is curse, room N+1 cannot be curse (re-roll to non-curse) |
| Minimum 1 treasure | 5+ room dungeons | If no treasure rolled by room 3, room 4 is guaranteed treasure |
| Minimum 1 rest | 6+ room dungeons | If no rest rolled by midpoint, midpoint becomes rest |

### Room Visibility

| Room Type | Visibility | Notes |
|-----------|-----------|-------|
| Rest area | Always visible | Intentional — the game signals safety |
| Boss room | Always visible | Player knows the final fight is ahead |
| Monster room | Hidden | Could be anything |
| Curse room | Hidden | Could be anything |
| Treasure room | 50% hinted / 50% hidden | "Faint glow" hint when visible |

---

## Part B: Monster Group Compositions

Group templates define what enemies appear in each monster room. Select template based on biome, difficulty, and room depth (early = rooms 1-3, mid = rooms 4-5, late = rooms 6+).

Difficulty modifiers applied to all monster stats:
- **Easy**: ×0.85 HP, ×0.80 Dmg, ×0.75 Def
- **Medium**: ×1.0 (base)
- **Hard**: ×1.20 HP, ×1.25 Dmg, ×1.25 Def

### Cave Biome Groups

#### Early Room Templates (Tier 1 only)

| Template Name | Monsters | Front Row | Back Row | Total Enemies |
|---------------|----------|-----------|----------|:-------------:|
| Entrance Guard | Rock That's Actually a Fist | Bruiser | — | 1 |
| Guard Patrol | Sedimentary Pete, Blind Cave Fish With a Grudge | Bruiser, Striker | — | 2 |
| Roach Infestation | Cave Roaches ×4 | Swarm ×4 | — | 4 |
| Bat Cave | Bats. Just. So Many Bats. ×3 | Swarm ×3 | — | 3 |
| Crystal Clear | Helpful Crystal (It's Not Helpful), Cave Potato | Support | Bruiser | 2 |
| Dark Echo | Echo With a Bad Attitude, Grumpy Boulder | Support | Bruiser | 2 |
| Ambush | Stalactite (the Pointy Kind), Pebble Gremlins ×4 | Striker | Swarm ×4 | 5 |
| The Odd Couple | Mushroom That Looks at You Funny, Centipede Who Skipped Leg Day | Support | Striker | 2 |

#### Mid Room Templates (Tier 1 + Tier 2 mix)

| Template Name | Monsters | Front Row | Back Row | Total Enemies |
|---------------|----------|-----------|----------|:-------------:|
| Spider's Parlor | Giant Cave Spider Named Margaret, Bats. Just. So Many Bats. ×3 | Striker, Swarm ×3 | — | 4 |
| Troll Bridge | Cave Troll Who Forgot His Club, Echo With a Bad Attitude | Bruiser | Support | 2 |
| Haunted Stream | Underground Stream (It's Haunted), Angriest Worm in the County, Grub Colony ×3 | Striker, Swarm ×3 | Support | 5 |
| Crystal Cavern | Crystal Vampire Bat, Obsidian Tortoise | Striker | Bruiser | 2 |
| Living Rock | Greg the Living Boulder, Geode Golem, Emotional Support Model | Bruiser | Support | 2 |
| Diamond Den | Diamond Rats ×3, Cave Potato | Swarm ×3 | Bruiser | 4 |
| Echo Chamber | Echo Wraithlets ×3, Stalactite (the Pointy Kind) | Swarm ×3 | Striker | 4 |

#### Late Room Templates (Tier 2 + Tier 3 mix)

| Template Name | Monsters | Front Row | Back Row | Total Enemies |
|---------------|----------|-----------|----------|:-------------:|
| Deep Horror | The Mountain That Walks, Fossilized Oracle | Bruiser | Support | 2 |
| Crystal Lair | Crystal Drake, Shadow Crawlers ×3 | Striker | Swarm ×3 | 4 |
| Stone Awakening | Ancient Stone Guardian, Earthquake Elemental | Bruiser | Support | 2 |
| Abyss Gate | Abyssal Horror From Below, Emerald Scarab Swarm ×3 | Striker, Swarm ×3 | — | 4 |
| Darkmantle Roost | Darkmantle Pack ×2, Giant Cave Spider Named Margaret | Swarm ×2, Striker | — | 3 |

### Crypt Biome Groups

#### Early Room Templates (Tier 1 only)

| Template Name | Monsters | Front Row | Back Row | Total Enemies |
|---------------|----------|-----------|----------|:-------------:|
| Graveyard Shift | Sad Skeleton (He's Having a Bad Day) | Bruiser | — | 1 |
| Shuffling Patrol | Zombie Who Forgot How to Zombie, Skull That Rolls Toward You | Bruiser, Striker | — | 2 |
| Finger Trap | Just Fingers ×4 | Swarm ×4 | — | 4 |
| Ghostly Gathering | Shy Ghosts ×3, Ghost With Commitment Issues | Swarm ×3 | Striker | 4 |
| Bone Yard | Bone Juggler, Flickering Candle (It Judges You) | Bruiser | Support | 2 |
| Haunted Door | Cursed Doorknob, Wraith Intern (First Day) | Support | Striker | 2 |
| The Crawlies | Crawlies ×4, Moaning Margaret | Swarm ×4 | Support | 5 |
| Restless Armor | Cursed Armor (the Ghost Inside Is Bored), Cursed Doorknob | Bruiser | Support | 2 |

#### Mid Room Templates (Tier 1 + Tier 2 mix)

| Template Name | Monsters | Front Row | Back Row | Total Enemies |
|---------------|----------|-----------|----------|:-------------:|
| Bone Library | Skeleton Who Read a Book Once, Wraith With a Spreadsheet | Bruiser | Striker | 2 |
| Accounting Dept | Zombie Accountant, Haunted Coat Rack, Crawling Hands ×3 | Bruiser, Swarm ×3 | Support | 5 |
| Vampire's Den | Vampire's Lesser-Known Cousin, Poltergeist Who Throws Things | Striker | Striker | 2 |
| Bone Pile | Bone Golem (Questionable Parts), Phylactery of a Very Minor Lich | Bruiser | Support | 2 |
| Moth Swarm | Spectral Moths ×3, Sad Skeleton (He's Having a Bad Day) | Swarm ×3 | Bruiser | 4 |
| Tomb Raid | Tomb Rats ×3, Ghost With Commitment Issues | Swarm ×3 | Striker | 4 |
| Seance | Wraith With a Spreadsheet, Moaning Margaret, Shy Ghosts ×3 | Striker, Support | Swarm ×3 | 5 |

#### Late Room Templates (Tier 2 + Tier 3 mix)

| Template Name | Monsters | Front Row | Back Row | Total Enemies |
|---------------|----------|-----------|----------|:-------------:|
| Tax Audit | The IRS (They Found You), Necromancer Behind on Rent | Bruiser | Support | 2 |
| Dread Maw | Existential Dread Made Flesh, Ghost Army ×3 | Bruiser, Swarm ×3 | — | 4 |
| Bone Storm | Bone Dragon's Smaller Sibling, Cursed Skull Swarm ×3 | Striker | Swarm ×3 | 4 |
| Unpaid Debts | Wraith of Unpaid Debts, Ancient Mummy With a Grudge | Striker | Support | 2 |
| Death's Errands | Death's Interns ×2, Haunted Coat Rack | Swarm ×2 | Support | 3 |

### Forest Biome Groups

#### Early Room Templates (Tier 1 only)

| Template Name | Monsters | Front Row | Back Row | Total Enemies |
|---------------|----------|-----------|----------|:-------------:|
| Root Guard | Tree Stump That's Actually a Fist | Bruiser | — | 1 |
| Hedge Maze | Hedgehog of Unusual Size, Angry Squirrel With a Tiny Sword | Bruiser, Striker | — | 2 |
| Bunny Stampede | Rabid Bunnies ×4 | Swarm ×4 | — | 4 |
| Caterpillar Crew | Caterpillar Gang ×4, Moss That Bites | Swarm ×4 | Support | 5 |
| Owl Watch | Very Condescending Owl, Singing Flower (the Song Is Threats) | Bruiser | Support | 2 |
| Frog Pond | Poison Dart Frog (the Frog Is the Dart), Enchanted Acorn of Disappointment | Striker | Support | 2 |
| Sprite Swarm | Mischievous Sprites ×3, Deer Who's Seen Things | Swarm ×3 | Striker | 4 |
| Log Trap | Angry Log, Singing Flower (the Song Is Threats) | Bruiser | Support | 2 |

#### Mid Room Templates (Tier 1 + Tier 2 mix)

| Template Name | Monsters | Front Row | Back Row | Total Enemies |
|---------------|----------|-----------|----------|:-------------:|
| Wolf Pack | Wolf Who Thinks He's the Protagonist, Bee Swarm, Now Unionized ×3 | Striker, Swarm ×3 | — | 4 |
| Bear Debt | Bear Who Owes You Money, Fairy Loan Shark | Bruiser | Support | 2 |
| Mushroom Grove | Mushroom Witch, Poison Dart Frogs ×3 | Striker | Swarm ×3 | 4 |
| Treant Phase | Treant Teenager (Going Through a Phase), Druid's Failed Experiment | Bruiser | Support | 2 |
| Thorny Thicket | Thorny Situation (Ambulatory Bush), Fox Who's Too Clever | Bruiser | Striker | 2 |
| Pixie Riot | Pixie Mob ×3, Angry Squirrel With a Tiny Sword | Swarm ×3 | Striker | 4 |
| Experiment Gone Wrong | Druid's Failed Experiment, Rabid Bunnies ×4 | Support | Swarm ×4 | 5 |

#### Late Room Templates (Tier 2 + Tier 3 mix)

| Template Name | Monsters | Front Row | Back Row | Total Enemies |
|---------------|----------|-----------|----------|:-------------:|
| Elder's Wrath | Elder Treant's Angry Younger Brother, Ancient Forest Spirit With a Hangover | Bruiser | Support | 2 |
| Boar Charge | Dire Boar of Indeterminate Rage, Killer Bee Swarm ×3 | Bruiser, Swarm ×3 | — | 4 |
| Wolf Street | The Wolf of Wall Street (an Actual Wolf), Fey Noble With a Lawsuit | Striker | Support | 2 |
| Spore Cloud | Myconid Sovereign, Mandrake Chorus ×3 | Striker | Swarm ×3 | 4 |
| Thorn Prison | Thorn Wall (It Walks) ×2, Mushroom Witch | Swarm ×2 | Striker | 3 |

### Tower Biome Groups

#### Early Room Templates (Tier 1 only)

| Template Name | Monsters | Front Row | Back Row | Total Enemies |
|---------------|----------|-----------|----------|:-------------:|
| Broom Closet | Animated Broom (It Swept Too Hard) | Bruiser | — | 1 |
| Clockwork Patrol | Wind-Up Soldier, Clockwork Mouse (It Ticks Ominously) | Bruiser, Striker | — | 2 |
| Roach Factory | Clockwork Roaches ×4 | Swarm ×4 | — | 4 |
| Quill Rain | Animated Quills ×3, Sentient Scroll (Unhelpful) | Swarm ×3 | Support | 4 |
| Potted Guard | Potted Plant Golem, Wizard's Homework (It Fights Back) | Bruiser | Support | 2 |
| Magic Mayhem | Magic 8-Ball (It Only Says "YOU WILL DIE"), Enchanted Stapler | Striker | Support | 2 |
| Organized Components | Spell Components That Organized ×4, Floating Book (It Slaps) | Swarm ×4 | Striker | 5 |
| Cupid's Arrow | Stone Cupid (Arrows Are Real), Sentient Scroll (Unhelpful) | Bruiser | Support | 2 |

#### Mid Room Templates (Tier 1 + Tier 2 mix)

| Template Name | Monsters | Front Row | Back Row | Total Enemies |
|---------------|----------|-----------|----------|:-------------:|
| Bookshelf Barrage | Bookshelf Golem, Floating Book (It Slaps) | Bruiser | Striker | 2 |
| Fire & Ice | Fire Elemental Who's Always Cold, Ice Elemental With a Warm Personality | Striker | Striker | 2 |
| Armor March | Enchanted Armor (Empty, Still Punches), Bouncing Orbs of Doom ×3 | Bruiser, Swarm ×3 | — | 4 |
| Lightning Strike | Lightning in a Bottle (It Escaped), Rogue Spell (It Got Lost) | Striker | Support | 2 |
| Clockwork Menagerie | Clockwork Beetles ×3, Animated Statue With Imposter Syndrome | Swarm ×3 | Bruiser | 4 |
| Potion Frenzy | Sentient Potions ×3, Mirror That Talks Back | Swarm ×3 | Support | 4 |
| Imposter Syndrome | Animated Statue With Imposter Syndrome, Enchanted Stapler | Bruiser | Support | 2 |

#### Late Room Templates (Tier 2 + Tier 3 mix)

| Template Name | Monsters | Front Row | Back Row | Total Enemies |
|---------------|----------|-----------|----------|:-------------:|
| Rogue Spell | The Spell That Learned to Think, Wizard's Final Exam | Bruiser | Support | 2 |
| Overload | Arcane Construct Gone Rogue, Animated Armor Battalion ×2 | Bruiser, Swarm ×2 | — | 3 |
| Elemental Chaos | Elemental Chaos (It's All of Them), Magic Missile Storm ×3 | Striker, Swarm ×3 | — | 4 |
| Living Room | Living Dungeon (Yes, the Room Itself), The Golem That Unionized | Striker | Support | 2 |
| Papercut Hell | Swarm of Cursed Scrolls ×3, Rogue Spell (It Got Lost) | Swarm ×3 | Support | 4 |

---

## Part C: Loot Tables

### Monster Kill Loot

Per monster killed. Roll independently for each monster.

#### Equipment Drop Chance

| Monster Tier | Drop Chance | Rarity Weights (C/UC/R/L) | Gold Range |
|-------------|:-----------:|:-------------------------:|:----------:|
| Tier 1 | 20% | 70/25/5/0 | 5-10g |
| Tier 2 | 35% | 55/30/13/2 | 10-18g |
| Tier 3 | 50% | 35/30/28/7 | 15-25g |
| Boss | 100% (1-2 items) | 10/25/40/25 | 30-50g |

#### Consumable Drop Chance

| Source | Drop Chance | Type Weights |
|--------|:-----------:|:------------:|
| Tier 1 | 5% | Small Heal 60%, Antidote 40% |
| Tier 2 | 8% | Small Heal 40%, Large Heal 30%, Antidote 20%, Buff Scroll 10% |
| Tier 3 | 12% | Large Heal 40%, Buff Scroll 30%, Curse Negator 20%, Smoke Bomb 10% |
| Boss | 25% | Large Heal 30%, Curse Negator 30%, Buff Scroll 25%, Resurrect Scroll 15% |

### Treasure Room Loot

Guaranteed: 1 equipment + gold. Possible bonus consumable.

#### Equipment Rarity by Dungeon Depth

| Depth | Common | Uncommon | Rare | Legendary |
|-------|:------:|:--------:|:----:|:---------:|
| Early (rooms 1-3) | 55% | 30% | 13% | 2% |
| Mid (rooms 4-5) | 40% | 32% | 22% | 6% |
| Late (rooms 6+) | 25% | 30% | 35% | 10% |

#### Gold Range by Depth and Difficulty

| Depth | Easy | Medium | Hard |
|-------|:----:|:------:|:----:|
| Early | 8-15g | 12-20g | 15-25g |
| Mid | 12-22g | 18-30g | 22-38g |
| Late | 18-30g | 25-40g | 30-50g |

#### Treasure Room Consumable Drop

| Difficulty | Drop Chance | Type |
|-----------|:-----------:|------|
| Easy | 20% | Small Heal only |
| Medium | 25% | Small Heal 50%, Large Heal 30%, Buff Scroll 20% |
| Hard | 30% | Large Heal 40%, Buff Scroll 25%, Curse Negator 25%, Smoke Bomb 10% |

### Boss Loot

Guaranteed drops from boss kills.

| Item | Easy Boss | Medium Boss | Hard Boss |
|------|-----------|-------------|-----------|
| Guaranteed legendary | 1 item | 1 item | 1 item |
| Additional loot | 1× Tier 3 table roll | 2× Tier 3 table rolls | 2× Tier 3 table rolls |
| Gold | 20-35g | 30-50g | 40-65g |
| Consumable | 25% chance | 35% chance | 50% chance |

#### Boss Legendary Drop Tables

Each boss has a curated legendary pool (2-3 items) weighted for their biome theme, plus a small chance at any legendary.

| Boss | Guaranteed Legendary Pool | Any-Legendary Chance |
|------|--------------------------|---------------------|
| Mount Grrr, the Angry Hill | Godslayer Jr., The Wall, Thunderbane, The Fridge, Godplate | 20% |
| Gerald the Unnerving, Esq. | The Archmage's Spine, Deus Ex Wanda, Crown of Infinite Wisdom, The Answer, Sacred Sarcasm | 20% |
| Elder Oakheart, Who Has Had ENOUGH | The Spatula of Destiny, Hermes' Hand-Me-Downs, The Walking Mountain, The Absolute Unit, Grandpa's Tank | 20% |
| Sentient Spellbook That Learned Too Much | Singularity, Reality's Stepladder, The Exam, Quantum Weave, The Emperor's New Armor | 20% |
| Blorb, Eater of Lunch | Any legendary from any boss pool + Shoes of the First Step, Grandpa's Slippers | 30% |

### Cursed Item Injection

Cursed items enter the loot pool through specific triggers:

| Trigger | Chance | Notes |
|---------|:------:|-------|
| Tier 3 monster drop | 3% (replaces normal rarity roll) | Disguised as rare until equipped |
| Late treasure room (rooms 6+) | 4% (replaces normal rarity roll) | Looks like rare/legendary |
| Boss drop | 2% (replaces normal rarity roll) | Even bosses troll you |
| Total cursed rate | ~1% of all equipment drops | Matches `base-numbers.md` target |

When a cursed item drops, it appears as the rarity one tier above its actual stats (e.g., a cursed item with uncommon stats appears as rare). The curse is revealed after the first fight with it equipped, or immediately with a Curse Negator consumable.

---

## Part D: Difficulty Scaling Curves

### Per-Room Depth Scaling

Applied cumulatively per room beyond the first. Each room's multiplier is the base × room depth modifier.

| Room Position | HP Multiplier | Dmg Multiplier | Def Multiplier | Notes |
|:-------------:|:------------:|:--------------:|:--------------:|-------|
| Room 1 | ×1.00 | ×1.00 | ×1.00 | Always base stats |
| Room 2 | ×1.05 | ×1.00 | ×1.00 | Slightly tougher |
| Room 3 | ×1.10 | ×1.05 | ×1.00 | Difficulty ramps |
| Room 4 | ×1.15 | ×1.10 | ×1.05 | Getting harder |
| Room 5 | ×1.20 | ×1.12 | ×1.05 | Late dungeon |
| Room 6 | ×1.25 | ×1.15 | ×1.10 | Deep runs |
| Room 7 | ×1.30 | ×1.15 | ×1.10 | Very deep |
| Room 8+ | ×1.35 | ×1.18 | ×1.12 | Brutal |
| Boss Room | ×1.40 | ×1.20 | ×1.15 | Climactic |

### Dungeon Difficulty Modifiers

Applied as a flat multiplier on top of depth scaling. Stacks multiplicatively with room depth.

| Difficulty | HP | Dmg | Def | Gold Drop | XP | Notes |
|-----------|:--:|:---:|:---:|:---------:|:--:|-------|
| Easy | ×0.85 | ×0.80 | ×0.75 | ×0.80 | ×0.75 | Below party level |
| Medium | ×1.00 | ×1.00 | ×1.00 | ×1.00 | ×1.00 | At party level |
| Hard | ×1.20 | ×1.25 | ×1.25 | ×1.30 | ×1.25 | Above party level |

**Combined example — Hard dungeon, Room 5:**
- HP: base × 1.20 (room depth) × 1.20 (hard) = ×1.44
- Dmg: base × 1.12 (room depth) × 1.25 (hard) = ×1.40
- Def: base × 1.05 (room depth) × 1.25 (hard) = ×1.31

### Loot Quality Scaling by Depth

Equipment rarity weights shift with room depth. Later rooms give better items.

| Room Depth | Common | Uncommon | Rare | Legendary | Gold Multiplier |
|:----------:|:------:|:--------:|:----:|:---------:|:--------------:|
| Room 1-2 | 65% | 25% | 9% | 1% | ×1.0 |
| Room 3-4 | 50% | 30% | 17% | 3% | ×1.1 |
| Room 5-6 | 35% | 30% | 28% | 7% | ×1.2 |
| Room 7+ | 20% | 28% | 38% | 14% | ×1.3 |
| Boss Room | 10% | 25% | 40% | 25% | ×1.5 |

### Tier Assignment by Room Depth

Which enemy tiers can appear at each room position, combined with dungeon difficulty.

| Room | Easy Dungeon | Medium Dungeon | Hard Dungeon |
|:----:|:------------|:---------------|:------------|
| 1 | Tier 1 (1-2 enemies) | Tier 1 (1-2 enemies) | Tier 1-2 (2 enemies) |
| 2-3 | Tier 1 (1-3 enemies) | Tier 1-2 (1-3 enemies) | Tier 2 (2-3 enemies) |
| 4-5 | Tier 1-2 (2-3 enemies) | Tier 2 (2-3 enemies) | Tier 2-3 (2-3 enemies) |
| 6+ | Tier 2 (2-3 enemies) | Tier 2-3 (2-3 enemies) | Tier 3 (2-4 enemies) |
| Boss | Easy boss | Biome boss | Biome boss + minions |

---

## Part E: Quest Definitions

12 quests (3 per biome) with humorous Munchkin-style flavor. Each defines a dungeon configuration and reward.

### Cave Quests

#### 1. "Rock Bottom (Literally)"

| Field | Value |
|-------|-------|
| Biome | Cave |
| Length | Normal (4-5 rooms) |
| Difficulty | Easy |
| Quest Reward | 30g + Chipped Shortsword (Common 1H, +2 dmg) |
| Flavor Text | "Local geologist needs someone to check why the basement keeps growing teeth. Bring a sword." |
| Quest Giver | Professor Sediment |

#### 2. "Margaret's Revenge"

| Field | Value |
|-------|-------|
| Biome | Cave |
| Length | Long (7-8 rooms) |
| Difficulty | Medium |
| Quest Reward | 65g + Windrunner Boots (Rare boots, +5 init, +1 AGI) |
| Flavor Text | "The giant spider named Margaret has filed a formal complaint about adventurers. Serve her an eviction notice." |
| Quest Giver | Cavern Landlord Association |

#### 3. "The Mountain Must Not Fall (On Us)"

| Field | Value |
|-------|-------|
| Biome | Cave |
| Length | Long (8-9 rooms) |
| Difficulty | Hard |
| Quest Reward | 100g + Godslayer Jr. (Legendary 2H, +12 dmg, +3 STR, execute below 15%) |
| Flavor Text | "Mount Grrr has been grumbling louder than usual. Geologists say it's about to blow. Geologists are cowards. Go punch a mountain." |
| Quest Giver | The Department of Geological Aggression |

### Crypt Quests

#### 4. "Gerald Wants a Word"

| Field | Value |
|-------|-------|
| Biome | Crypt |
| Length | Normal (5-6 rooms) |
| Difficulty | Medium |
| Quest Reward | 60g + Moonbeam Scepter (Uncommon magic, +3 dmg, +5% vs undead) |
| Flavor Text | "A lich named Gerald has been sending threatening letters about 'proper dungeon etiquette.' His legal team is undead." |
| Quest Giver | The Bar Association (Literally a Bar of Ghosts) |

#### 5. "Unpaid Debts Collection"

| Field | Value |
|-------|-------|
| Biome | Crypt |
| Length | Normal (5 rooms) |
| Difficulty | Easy |
| Quest Reward | 35g + Sanctified Hammer (Uncommon blunt, +4 dmg, +1 VIT) |
| Flavor Text | "Several ghosts have outstanding library fines dating back three centuries. Collect or don't come back." |
| Quest Giver | The Eternal Librarian |

#### 6. "Death's Interns Are Not Paid Enough For This"

| Field | Value |
|-------|-------|
| Biome | Crypt |
| Length | Long (9-10 rooms) |
| Difficulty | Hard |
| Quest Reward | 110g + The Archmage's Spine (Legendary magic, +10 dmg, +4 INT) |
| Flavor Text | "Death's HR department has lost control of the intern program. There are more skeletons than budget allocations. Someone needs to fix this." |
| Quest Giver | Death's HR Department |

### Forest Quests

#### 7. "The Bear Definitely Remembers You"

| Field | Value |
|-------|-------|
| Biome | Forest |
| Length | Normal (4-5 rooms) |
| Difficulty | Easy |
| Quest Reward | 28g + Ranger's Hatchet (Uncommon 1H, +3 dmg, +1 AGI) |
| Flavor Text | "A bear claims you owe it 50 gold. The bear is right. Settle the debt by clearing its forest of pests." |
| Quest Giver | The Bear (He Learned to Write) |

#### 8. "The Treant's Terrible Twos"

| Field | Value |
|-------|-------|
| Biome | Forest |
| Length | Long (7-8 rooms) |
| Difficulty | Medium |
| Quest Reward | 70g + Boots of Butt-Kicking (Rare boots, +4 init, +1 AGI) |
| Flavor Text | "A treant teenager is going through a phase. It involves throwing acorns at unprecedented velocity. Deal with it before the insurance claim." |
| Quest Giver | Forest Homeowners Association |

#### 9. "Elder Oakheart Has Had ENOUGH (And a Hangover)"

| Field | Value |
|-------|-------|
| Biome | Forest |
| Length | Long (9-10 rooms) |
| Difficulty | Hard |
| Quest Reward | 105g + The Spatula of Destiny (Legendary 1H, +9 dmg, +2 all stats) |
| Flavor Text | "Elder Oakheart has filed 347 noise complaints. Nobody read them. He's taking matters into his own branches." |
| Quest Giver | The Squirrels (Concerned Citizens) |

### Tower Quests

#### 10. "The Spellbook Won't Stop Reading"

| Field | Value |
|-------|-------|
| Biome | Tower |
| Length | Normal (5-6 rooms) |
| Difficulty | Medium |
| Quest Reward | 55g + Sage's Walking Stick (Uncommon magic, +3 dmg, +1 INT) |
| Flavor Text | "A spellbook gained sentience and won't stop correcting everyone's grammar. It has opinions about YOUR dungeon map." |
| Quest Giver | The Tower's Former Janitor |

#### 11. "Broom Closet Miscalculation"

| Field | Value |
|-------|-------|
| Biome | Tower |
| Length | Normal (4-5 rooms) |
| Difficulty | Easy |
| Quest Reward | 32g + Steel Rapier (Uncommon 1H, +4 dmg, +1 initiative) |
| Flavor Text | "Someone enchanted every broom in the tower to sweep autonomously. They now form a militia. Fix this." |
| Quest Giver | The Tower's Current Janitor |

#### 12. "The Golem That Unionized"

| Field | Value |
|-------|-------|
| Biome | Tower |
| Length | Long (8-10 rooms) |
| Difficulty | Hard |
| Quest Reward | 115g + Singularity (Legendary magic, +11 dmg, pulls enemies back) |
| Flavor Text | "The tower constructs have formed a union and are demanding better working conditions (fewer adventurers). Negotiations have broken down." |
| Quest Giver | The Wizard's Landlord |

---

## Part F: Dungeon Generation Rules

Pseudocode algorithm for generating a complete dungeon from a quest selection.

```
GENERATE_DUNGEON(quest):
    1. CONFIGURE
       - Read quest.biome, quest.length, quest.difficulty
       - Determine room_count: roll within range for length+difficulty (see Part A)
       - Set difficulty_multiplier from difficulty table (see Part D)

    2. BUILD_ROOM_SEQUENCE(room_count)
       - rooms = empty array
       - rooms[0] = MONSTER (guaranteed entrance guard)
       - rooms[room_count - 1] = BOSS (guaranteed final boss)
       - If room_count >= 6:
           midpoint = floor(room_count / 2)
           rooms[midpoint] = REST (guaranteed midpoint rest)
       - For each unassigned room i (1 to room_count - 2):
           If rooms[i] is not already assigned:
               Roll room type from distribution table (Part A) for this difficulty + position
               Apply constraints:
                   - If rooms[i-1] == CURSE, re-roll curse to TREASURE or REST
                   - If no TREASURE by room 3 and i >= 3, force TREASURE
                   - If no REST by midpoint and i == midpoint, force REST
               rooms[i] = rolled_type

    3. POPULATE_MONSTER_ROOMS(rooms, biome, difficulty)
       For each room tagged MONSTER:
           - Determine room depth category (early/mid/late)
           - Determine eligible tiers from depth + difficulty table (Part D)
           - Select group template from biome-appropriate templates (Part B)
           - Apply depth scaling multipliers to all monster stats (Part D)
           - Apply difficulty multiplier to all monster stats (Part D)
           - Store scaled monsters in room

    4. POPULATE_BOSS_ROOM(rooms, biome, difficulty)
       - Select boss by biome from boss table (enemies.md)
       - If difficulty == Hard and roll <= 15%:
           Use Blorb, Eater of Lunch instead of biome boss
       - Apply difficulty + depth scaling to boss stats
       - Add 0-2 Tier 2 minions (0 for Easy, 1 for Medium, 2 for Hard)

    5. GENERATE_LOOT_TABLES(rooms, difficulty)
       For each MONSTER room:
           - Create loot table per monster using kill loot table (Part C)
           - Apply depth-based rarity shifts (Part D)
       For each TREASURE room:
           - Create treasure loot using treasure room table (Part C)
           - Apply depth-based rarity + gold scaling (Part D)
       For BOSS room:
           - Create boss loot using boss table (Part C)
           - Roll from boss's curated legendary pool

    6. GENERATE_CURSE_EFFECTS(rooms)
       For each room tagged CURSE:
           - Roll severity from curse distribution (base-numbers.md)
           - Roll target (one char 60%, front 15%, back 10%, party 15%)
           - Roll duration (instant 10%, 2-3 rooms 40%, until rest 35%, permanent 15%)
           - Generate curse name and effect from themed pool

    7. VALIDATE(rooms)
       Assert all rules:
           - rooms[0] is MONSTER
           - rooms[last] is BOSS
           - No two consecutive CURSE rooms
           - room_count >= 6 → at least 1 REST
           - room_count >= 5 → at least 1 TREASURE
           - At least 1 REST or TREASURE in rooms 1..last-1
           - Boss is biome-appropriate (or Blorb override)
           - All monster stats within 2× expected range for difficulty
       If validation fails, re-generate from step 2 (max 3 attempts, then force valid)

    8. VISIBILITY(rooms)
       For each room:
           - REST rooms: always VISIBLE
           - BOSS room: always VISIBLE
           - TREASURE rooms: 50% HINTED ("faint glow"), 50% HIDDEN
           - All others: HIDDEN

    9. RETURN dungeon
```

### Generation Example: "Rock Bottom (Literally)"

```
Quest: Rock Bottom (Literally)
Biome: Cave | Length: Normal | Difficulty: Easy
Room count: 4 (rolled 4-5, got 4)

Step 2 — Room sequence:
  Room 1: MONSTER (guaranteed)
  Room 2: Roll d100 → 42 → MONSTER
  Room 3: Roll d100 → 73 → TREASURE (50+10+15 = 75 threshold, 73 < 75 → treasure)
  Room 4: BOSS (guaranteed)

Step 3 — Monster rooms:
  Room 1 (early, easy): Entrance Guard template → Rock That's Actually a Fist
    Stats: HP 48, Dmg 10, Def 4, Init 8 (base, room 1 = ×1.00, easy = ×0.85/×0.80/×0.75)
    Scaled: HP 41, Dmg 8, Def 3, Init 8
  Room 2 (early, easy): Guard Patrol template → Sedimentary Pete + Blind Cave Fish
    Pete: HP 40, Dmg 8, Def 3, Init 9
    Fish: HP 27, Dmg 10, Def 2, Init 13

Step 4 — Boss:
  Room 4: Mount Grrr, the Angry Hill (Easy: ×0.85/×0.80/×0.75, boss room ×1.40/×1.20/×1.15)
    Base: HP 160, Dmg 24, Def 10, Init 18
    Scaled: HP 190, Dmg 23, Def 9, Init 18
    Minions: 0 (Easy boss, no minions)

Step 5 — Loot:
  Room 1: 20% drop → Common if drops. Gold: 5-10g.
  Room 2: 20% × 2 monsters → ~36% chance of at least one drop. Gold: 10-20g total.
  Room 3 (treasure): 1 equipment (55% common, 30% uncommon, 13% rare, 2% legendary). Gold: 8-15g.
  Room 4 (boss): 1 legendary from Mount Grrr's pool. Gold: 20-35g.

Step 6 — No curse rooms in this dungeon.

Step 7 — Validate:
  ✓ Room 1 is MONSTER
  ✓ Room 4 is BOSS
  ✓ Room count 4 < 6, no midpoint rest required
  ✓ Treasure present at room 3 ✓
  ✓ No consecutive curses (none present)

Final dungeon layout:
  [MONSTER: Rock That's Actually a Fist] → [MONSTER: Pete + Fish] → [TREASURE: ✨] → [BOSS: Mount Grrr]
  Expected total HP cost: ~15-20% (easy dungeon target)
  Expected gold: ~40-80g + quest reward 30g + quest item
```

---

## Quick Reference Summary

| What | Where | Count |
|------|-------|:-----:|
| Room configurations | Part A | 6 difficulty × length combos |
| Distribution tables | Part A | 6 complete probability tables |
| Monster group templates | Part B | 80 total (20 per biome × 4 biomes) |
| Loot table sources | Part C | 4 (kill, treasure, boss, cursed) |
| Scaling curves | Part D | 4 (room depth, difficulty, loot quality, tier assignment) |
| Quest definitions | Part E | 12 (3 per biome) |
| Generation algorithm | Part F | 9-step pseudocode + worked example |

### Cross-Reference

| This Document References | Source File |
|-------------------------|-------------|
| Monster stats, names, abilities | `enemies.md` |
| Equipment names, stats, rarities | `equipment.md` |
| Balance targets, XP, gold, curse mechanics | `base-numbers.md` |
| Room types, encounter philosophy | `encounters.md` |
| Combat positioning, targeting | `combat.md` |
| Character stats, derived formulas | `character.md` |
| Dungeon selection, quest system, shop | `dungeon-structure.md` (memories/facts) |
| Core loop, push-your-luck | `core-loop.md` |
| Tone, humor, theme | `concept.md` |
