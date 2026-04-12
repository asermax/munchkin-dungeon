# Munchkin Dungeon — Godot Project

Munchkin × Darkest Dungeon mashup. Auto-battle with formation-based combat. Built with Godot 4.6. PostHog event edition — all monsters are hog/pig mutations.

## Tech Stack

- **Engine**: Godot 4.6.2 (GDScript)
- **Renderer**: GL Compatibility (required for WebAssembly export)
- **LLM**: z.ai GLM API for AI-powered game logic (future)
- **Export**: WebAssembly (runs in browser)
- **MCP**: GDAI MCP plugin for Claude Code integration

## Architecture

Auto-battle system with formation-based combat (2 front + 2 back per side). The player builds a party and watches battles unfold — no real-time control during fights.

### Core Systems
- **BattleManager** (Node): state machine host for the battle loop, owns unit data and helper methods
- **BattleState** (Node): base class for battle states (Idle, Running, Ended) in `scripts/battle/states/`
- **BattleAction** (RefCounted): command pattern wrapping actor + ability + targets, with `execute()` and `serialize()` for LLM integration
- **TurnQueue** (RefCounted): round-based initiative sorting, each unit acts once per round
- **AbilityAI** (RefCounted): deterministic priority-based AI picks abilities per class, returns BattleAction
- **AbilityResolver** (RefCounted): executes abilities, resolves damage/heal/buff
- **StatCalculator** (RefCounted): centralized formulas from the design doc
- **BattleUnit** (RefCounted): runtime wrapper holding live HP, cooldowns, effects
- **HeroStateManager** (RefCounted): manages hero data and persisted HP/alive state across battles
- **RoomHandler** (Node): handles room outcome modals (treasure, curse, rest, battle loot)
- **EventBus** (autoload): decoupled signal-based communication

### Data Model
- **Resources** (templates): AbilityData, RaceData, ClassData, EquipmentData, UnitData, MonsterData, EncounterData
- **Runtime** (live state): BattleUnit wraps a resource with mutable battle state
- Hero stats = class base + level growth + race mods + equipment bonuses → derived formulas
- Monster stats are flat (no composition)

### Combat Flow
1. BattleManager.setup_battle() creates BattleUnits, assigns formation → state: Idle
2. BattleManager.start_battle() → transitions to Running state
3. Running state drives timer-paced turns: sort by initiative, each unit acts once per round
4. AbilityAI picks ability → returns BattleAction (command pattern with serialize() for LLM)
5. BattleAction.execute() resolves through AbilityResolver → damage/heal/buff pipeline
6. Damage pipeline: dodge check → raw damage → crit check → defense reduction → min 1
7. Battle ends when one side eliminated → transitions to Ended state
8. BattleManager.configure() accepts injected dependencies (TurnQueue, AbilityAI, AbilityResolver) for testing/LLM swap

## Project Structure

```
res://
├── scenes/           # .tscn files (generated via headless scripts)
│   └── main.tscn
├── scripts/          # .gd files
│   ├── battle/       # BattleManager, BattleUnit, BattleAction, TurnQueue, AbilityAI, AbilityResolver, StatCalculator
│   │   └── states/   # BattleState, BattleStateIdle, BattleStateRunning, BattleStateEnded
│   ├── ui/           # BattleUI, UnitSlotUI
│   ├── ai/           # LLMClient (z.ai)
│   ├── hero_state_manager.gd
│   └── room_handler.gd
├── resources/        # Resource class definitions (.gd)
│   ├── ability_data.gd
│   ├── race_data.gd
│   ├── class_data.gd
│   ├── equipment_data.gd
│   ├── unit_data.gd
│   ├── monster_data.gd
│   └── encounter_data.gd
├── data/             # .tres resource instances
│   ├── abilities/    # Per-class ability definitions
│   ├── races/        # Human, Orc, Elf, Dwarf
│   ├── classes/      # Warrior, Mage, Rogue, Cleric
│   ├── equipment/    # Weapons, armor, hats, boots
│   ├── monsters/     # Cave biome: tier1, tier2, boss
│   ├── encounters/   # Preset encounter groups
│   └── heroes/       # Test hero configurations
├── assets/           # Art, sprites, sprite_prompts.md
├── autoload/         # EventBus
├── addons/           # GDAI MCP
└── tools/            # setup_scenes.gd, setup_data.gd
```

## GDScript Conventions

- **Naming**: snake_case for variables/functions, PascalCase for classes
- **Type hints**: always use them (`var hp: int = 100`, `func get_path(from: Vector2i) -> Array[Vector2i]`)
- **class_name**: declare on every script that other scripts reference
- **Null checks**: use explicit `== null` syntax
- **No enums**: use string or int constants instead
- **Code style**: airy, with blank lines between logical blocks. Add comments only when the block isn't self-explanatory from context and variable names.
- **Signals**: use `&"StringName"` syntax for signal/state references
- **@export**: for inspector-editable properties
- **@onready**: for node references resolved at _ready time
- **RefCounted** over Node for pure logic classes (TurnQueue, AbilityAI, AbilityResolver, StatCalculator, BattleUnit, BattleAction, HeroStateManager)
- **Circular deps**: when two class_name scripts reference each other, type the back-reference as `Node` or `RefCounted` to break the cycle (see BattleState.battle)

## .tscn File Editing Rules

**CRITICAL**: Never edit .tscn files directly. They use Godot's internal format with UIDs, resource IDs, and load_steps that are easy to corrupt.

**Safe approaches**:
1. Use GDAI MCP tools (create_scene, add_node, etc.) when the editor is running
2. Use headless setup scripts: `godot --headless --script res://tools/setup_scenes.gd`
3. Use the Godot editor GUI

**Claude Code can freely write/edit**: `.gd` scripts, `project.godot`, `.cfg` files, `.tres` resources (simple ones), Python files

## Stat Formulas (from design doc)

- Max HP = `50 + (VIT × 8) + armor_hp_bonus`
- Melee Damage = `STR × 2 + weapon_bonus`
- Magic Damage = `INT × 2 + weapon_bonus`
- Defense = `VIT + armor_defense_bonus` (reduces by `min(80%, defense × 2%)`)
- Initiative = `AGI × 3 + boots_bonus`
- Dodge Chance = `min(40%, AGI × 2%)`
- Crit Chance = `min(30%, LUCK × 3%)`
- Crit Multiplier = `min(3×, 2× + LUCK × 0.1)`

## z.ai GLM API

- **Endpoint**: `https://api.z.ai/api/paas/v4/chat/completions`
- **Auth**: `Authorization: Bearer API_KEY`
- **Format**: OpenAI-compatible (same request/response schema)
- **Free models**: GLM-4.7-Flash, GLM-4.5-Flash

If CORS blocks browser calls, a FastAPI proxy in `proxy/` forwards requests.

## Running the Project

```bash
# Editor
godot --path /home/agus/workspace/asermax/munchkin-dungeon

# Headless validation
godot --headless --path /home/agus/workspace/asermax/munchkin-dungeon --quit

# Generate data files (.tres)
godot --headless --path /home/agus/workspace/asermax/munchkin-dungeon --script res://tools/setup_data.gd

# Generate scene files (.tscn)
godot --headless --path /home/agus/workspace/asermax/munchkin-dungeon --script res://tools/setup_scenes.gd

# Web export (after templates installed)
godot --headless --path /home/agus/workspace/asermax/munchkin-dungeon --export-release "Web" build/index.html

# Serve web build
cd build && python3 -m http.server 8000
```
