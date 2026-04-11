---
name: godot-mcp-pro
description: Reference for all 169 Godot MCP Pro tools. Use when creating scenes, adding nodes, writing scripts, simulating input, inspecting running games, or any editor interaction through MCP.
---

# Godot MCP Pro — Skills for AI Assistants

## What is Godot MCP Pro?

You have access to 169 MCP tools that connect directly to the Godot 4 editor. You can create scenes, write scripts, simulate player input, inspect running games, and more — all without the user leaving this conversation. Every change goes through Godot's UndoRedo system, so the user can always Ctrl+Z.

## Essential Workflows

### 1. Explore a Project

Always start by understanding the project before making changes:

```
get_project_info          → project name, Godot version, renderer, viewport size
get_filesystem_tree       → directory structure (use filter: "*.tscn" or "*.gd")
get_scene_tree            → node hierarchy of the currently open scene
read_script               → read any GDScript file
get_project_settings      → check project configuration
```

### 2. Build a 2D Scene

```
create_scene   → create .tscn file with root node type
add_node       → add child nodes with properties
create_script  → write GDScript for game logic
attach_script  → attach script to a node
update_property → set position, scale, modulate, etc.
save_scene     → save to disk
```

### 3. Write & Edit Scripts

```
create_script  → create new .gd file (provide full content)
edit_script    → modify existing scripts
  - Use `replacements: [{search: "old code", replace: "new code"}]` for targeted edits
  - Use `content` for full file replacement
  - Use `insert_at_line` + `text` for inserting code
validate_script → check for syntax errors without running
read_script    → read current content before editing
```

### 4. Playtest & Debug

```
play_scene             → launch the game (mode: "current", "main", or file path)
get_game_screenshot    → see what the game looks like right now
capture_frames         → capture multiple frames to observe motion/animation
get_game_scene_tree    → inspect the live scene tree at runtime
get_game_node_properties → read runtime values (position, health, state, etc.)
set_game_node_property → modify values in the running game
simulate_key           → press keys (WASD, SPACE, etc.) with duration
simulate_mouse_click   → click at viewport coordinates
simulate_action        → trigger InputMap actions (move_left, jump, etc.)
get_editor_errors      → check for runtime errors
stop_scene             → stop the game
```

### 5. Animations

```
create_animation       → new animation with length and loop mode
add_animation_track    → add property/transform/method tracks
set_animation_keyframe → insert keyframes at specific times
get_animation_info     → inspect existing animations
```

### 6. UI / HUD

```
add_node          → Control, Label, Button, TextureRect, etc.
set_anchor_preset → position Controls (full_rect, center, bottom_wide, etc.)
set_theme_color   → change font_color, etc.
set_theme_font_size → adjust text size
set_theme_stylebox  → backgrounds, borders, rounded corners
connect_signal    → wire up button pressed, value_changed, etc.
```

### 7. Project Configuration

```
set_project_setting  → change viewport size, physics settings, etc.
set_input_action     → define input mappings (move_left → KEY_A, etc.)
add_autoload         → register autoload singletons
set_physics_layers   → name collision layers (player, enemy, world, etc.)
```

## Important Rules & Pitfalls

### Prefer Inspector Properties Over Code
When changing visual properties (colors, sizes, theme overrides, transforms, etc.), use `update_property` to set them directly on the node.

### Property Values
Properties are auto-parsed from strings. Use these formats:
- Vector2: `"Vector2(100, 200)"`
- Vector3: `"Vector3(1, 2, 3)"`
- Color: `"Color(1, 0, 0, 1)"` or `"#ff0000"`
- Bool: `"true"` / `"false"`
- Numbers: `"42"`, `"3.14"`
- Enums: Use integer values

### Never Edit project.godot Directly
Use `set_project_setting` to change project settings.

### Script Changes Need Reload
After creating or significantly modifying scripts, use `reload_project` to ensure Godot picks up the changes.

### simulate_key Tips
- Use **short durations** (0.3-0.5 seconds) for precise movement
- For gameplay testing, prefer `simulate_action` over `simulate_key` when InputMap actions are defined

## Analysis & Debugging Tools

```
get_editor_errors          → check for script errors and runtime exceptions
get_output_log             → read print() output and warnings
analyze_scene_complexity   → find performance bottlenecks
analyze_signal_flow        → visualize signal connections
get_performance_monitors   → FPS, memory, draw calls, physics stats
```
