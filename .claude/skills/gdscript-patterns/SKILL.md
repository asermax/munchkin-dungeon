---
name: gdscript-patterns
description: Architecture patterns for the GDScript codebase. Use when implementing battle systems, state machines, event buses, resources, actions, or turn queues.
---

# GDScript Architecture Patterns

## State Machine (Node-Based)

Each state is a child Node. State machine manages transitions via signals.

```gdscript
# battle_state_machine.gd
class_name BattleStateMachine
extends Node

signal state_changed(new_state: BattleState, old_state: BattleState)
var current_state: BattleState: set = set_current_state

func _ready():
    for child in get_children():
        if child is BattleState:
            child.state_machine = self
            child.state_finished.connect(_on_state_finished)
    if get_child_count() > 0:
        current_state = get_child(0) as BattleState

func set_current_state(value: BattleState):
    if current_state == value: return
    var old := current_state
    if current_state: current_state.exit()
    current_state = value
    if current_state: current_state.enter()
    state_changed.emit(current_state, old)

func _on_state_finished(next: StringName):
    var target = _find_state(next)
    if target: current_state = target

func _process(delta): if current_state: current_state.update(delta)
func _unhandled_input(event): if current_state: current_state.handle_input(event)
```

```gdscript
# battle_state.gd
class_name BattleState
extends Node

signal state_finished(next_state_name: StringName)
var state_machine: BattleStateMachine

func enter() -> void: pass
func exit() -> void: pass
func update(_delta: float) -> void: pass
func handle_input(_event: InputEvent) -> void: pass
```

## Event Bus (Autoload)

Global signal bus registered as autoload. All cross-system communication goes through here.

Current signals (see `autoload/event_bus.gd`):
- Grid: `tile_clicked`, `tile_hovered`
- Units: `unit_selected`, `unit_deselected`, `unit_moved`, `unit_damaged`, `unit_died`
- Battle: `battle_started`, `battle_ended`, `turn_started`, `turn_ended`
- Range: `movement_range_requested`, `attack_range_requested`, `range_display_cleared`

Usage: `EventBus.unit_selected.emit(unit)` and `EventBus.unit_selected.connect(_on_unit_selected)`

## Resource System (Data-Driven)

Resources are data containers saved as `.tres` files, editable in inspector. New content = new `.tres` files, no code changes.

Pattern: `class_name X extends Resource` with `@export` fields.

## Turn Queue (CT System)

Speed-based initiative. Each tick, all units gain CT = speed. First to reach threshold acts.

```gdscript
const ACT_THRESHOLD: int = 100

func advance():
    var active = _sorted_queue[0]
    active.current_ct -= ACT_THRESHOLD
    for unit in all_units:
        if unit.is_alive:
            unit.current_ct += unit.stats.speed
    _rebuild_queue()
```

## Command Pattern (Actions)

Every action extends `BattleAction` (RefCounted). Has `execute()`, `undo()`, `serialize()`.
The `serialize()` method is key — it enables the LLM to produce the same format as the human player.

Action manager tracks undo stack per turn: `push_action()`, `undo_last()`, `commit_turn()`.

## GDScript Conventions (from CLAUDE.md)

- Type hints everywhere: `var hp: int = 100`
- `class_name` on every reusable script
- No enums — use string or int constants
- `&"StringName"` for signal/state references
- `RefCounted` for pure logic (no scene tree needed)
- `Node` only when _process, input, or scene tree required
- Airy code style: blank lines between logical blocks
