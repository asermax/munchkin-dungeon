# Munchkin Dungeon — Godot Project

Isometric tactical game on a grid with height/elevation. Built with Godot 4.6.

## Tech Stack

- **Engine**: Godot 4.6.2 (GDScript)
- **Renderer**: GL Compatibility (required for WebAssembly export)
- **LLM**: z.ai GLM API for AI-powered game logic
- **Export**: WebAssembly (runs in browser)
- **MCP**: GDAI MCP plugin for Claude Code integration

## Architecture

The game engine is agnostic about who issues commands. Both human input and AI output produce the same Action objects:
- Human: UI clicks → Action
- LLM: game state → prompt → response → parse → Action
- Fallback AI: game state → heuristic → Action

### Core Systems
- **GridManager**: isometric coordinate conversion, height map, unit positions
- **EventBus** (autoload): decoupled signal-based communication
- **GameState** (autoload): current battle references

## Project Structure

```
res://
├── scenes/           # .tscn files (generated via headless scripts)
│   ├── main.tscn
│   ├── battle/
│   └── ui/
├── scripts/          # .gd files (Claude Code writes these directly)
│   ├── battle/
│   │   └── states/
│   ├── grid/
│   ├── units/
│   ├── actions/
│   └── ai/
├── data/             # .tres resource files
│   ├── units/
│   ├── skills/
│   └── terrain/
├── resources/        # Resource class definitions (.gd)
├── assets/           # Art, tiles, sprites
├── autoload/         # Singleton scripts
├── addons/           # GDAI MCP
└── tools/            # Headless setup scripts
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
- **RefCounted** over Node for pure logic classes (TurnQueue, Pathfinder, ActionManager, BattleAction types)

## .tscn File Editing Rules

**CRITICAL**: Never edit .tscn files directly. They use Godot's internal format with UIDs, resource IDs, and load_steps that are easy to corrupt.

**Safe approaches**:
1. Use GDAI MCP tools (create_scene, add_node, etc.) when the editor is running
2. Use headless setup scripts: `godot --headless --script res://tools/setup_scenes.gd`
3. Use the Godot editor GUI

**Claude Code can freely write/edit**: `.gd` scripts, `project.godot`, `.cfg` files, `.tres` resources (simple ones), Python files

## Isometric Grid Reference

- Tile size: 64x32 (2:1 diamond ratio)
- Grid size: 8x8 (configurable via @export)
- Height stored in `Dictionary` mapping `Vector2i → int` (0-4 levels)
- Height Y-offset: `pos.y -= height * tile_half_height`

Coordinate conversion (manual, not TileMapLayer):
```gdscript
func grid_to_world(cell: Vector2i) -> Vector2:
    var x = (cell.x - cell.y) * tile_half_width
    var y = (cell.x + cell.y) * tile_half_height
    return Vector2(x, y)

func world_to_grid(world_pos: Vector2) -> Vector2i:
    var col = (world_pos.x / tile_half_width + world_pos.y / tile_half_height) / 2.0
    var row = (world_pos.y / tile_half_height - world_pos.x / tile_half_width) / 2.0
    return Vector2i(floori(col), floori(row))
```

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

# Run headless scene setup
godot --headless --path /home/agus/workspace/asermax/munchkin-dungeon --script res://tools/setup_scenes.gd

# Web export (after templates installed)
godot --headless --path /home/agus/workspace/asermax/munchkin-dungeon --export-debug "Web" build/index.html

# Serve web build
cd build && python3 -m http.server 8000
```
