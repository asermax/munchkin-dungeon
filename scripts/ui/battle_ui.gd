class_name BattleUI
extends CanvasLayer

## Master UI controller for the battle screen.
## All child nodes are defined in main.tscn. This script wires up signals
## and routes updates to the pre-built UI hierarchy.

@onready var _round_label: Label = %RoundLabel
@onready var _speed_label: Label = %SpeedLabel
@onready var _log_toggle: Button = %LogToggle
@onready var _log_margin: MarginContainer = %LogMargin
@onready var _log_panel: PanelContainer = %LogPanel
@onready var _log_scroll: ScrollContainer = %LogScroll
@onready var _log_text: RichTextLabel = %LogText
@onready var _result_overlay: ColorRect = %ResultOverlay
@onready var _result_label: Label = %ResultLabel

@onready var _hero_slots: Array = [%HeroSlot0, %HeroSlot1, %HeroSlot2, %HeroSlot3]
@onready var _monster_slots: Array = [%MonsterSlot0, %MonsterSlot1, %MonsterSlot2, %MonsterSlot3]

var _unit_slot_map: Dictionary = {}


func _ready() -> void:
	_connect_signals()
	_connect_speed_buttons()


func _connect_signals() -> void:
	EventBus.battle_setup.connect(_on_battle_setup)
	EventBus.battle_started.connect(_on_battle_started)
	EventBus.battle_ended.connect(_on_battle_ended)
	EventBus.round_started.connect(_on_round_started)
	EventBus.action_resolved.connect(_on_action_resolved)
	EventBus.unit_damaged.connect(_on_unit_damaged)
	EventBus.unit_healed.connect(_on_unit_healed)
	EventBus.unit_died.connect(_on_unit_died)
	EventBus.boss_phase_changed.connect(_on_boss_phase_changed)
	EventBus.speed_changed.connect(_on_speed_changed)

	_log_toggle.toggled.connect(_on_log_toggled)


func _connect_speed_buttons() -> void:
	var speed_box: HBoxContainer = _speed_label.get_parent()

	for child: Node in speed_box.get_children():
		if child is Button:
			var speed: float = {"||": 0.0, ">": 1.0, ">>": 2.0, ">>>": 4.0}.get(child.text, -1.0)

			if speed >= 0.0:
				child.pressed.connect(_on_speed_pressed.bind(speed))


func _on_battle_setup(heroes: Array, monsters: Array) -> void:
	_unit_slot_map.clear()
	_log_text.clear()

	# Heroes: back row on the left, front row on the right (closest to enemies)
	for info: Dictionary in heroes:
		var slot_idx: int = _hero_slot_index(info["row"], info["slot"])

		if slot_idx >= 0 and slot_idx < _hero_slots.size():
			_hero_slots[slot_idx].setup(info)
			_unit_slot_map[info["unit_id"]] = _hero_slots[slot_idx]

	# Monsters: front row on the left (closest to heroes), back row on the right
	for info: Dictionary in monsters:
		var slot_idx: int = _monster_slot_index(info["row"], info["slot"])

		if slot_idx >= 0 and slot_idx < _monster_slots.size():
			_monster_slots[slot_idx].setup(info)
			_unit_slot_map[info["unit_id"]] = _monster_slots[slot_idx]


func _on_battle_started() -> void:
	_log("[color=yellow]--- Battle Begins! ---[/color]")


func _on_battle_ended(result: Dictionary) -> void:
	if result.result == "victory":
		_log("\n[color=green][b]VICTORY![/b][/color]")
	else:
		_log("\n[color=red][b]DEFEAT...[/b][/color]")

	_show_result_overlay.call_deferred(result)


func _show_result_overlay(result: Dictionary) -> void:
	await get_tree().create_timer(0.5).timeout

	_result_overlay.visible = true

	if result.result == "victory":
		_result_label.text = "VICTORY!"
		_result_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
	else:
		_result_label.text = "DEFEAT..."
		_result_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))


func _on_round_started(round_number: int) -> void:
	_round_label.text = "Round %d" % round_number
	_log("\n[color=white]--- Round %d ---[/color]" % round_number)


func _on_action_resolved(action_info: Dictionary) -> void:
	var line := _format_action(action_info)

	if line != "":
		_log(line)

	_refresh_slot(action_info.get("actor", {}))
	_refresh_slot(action_info.get("target", {}))

	# Show dodge popup on the target
	if action_info.get("type", "") == "damage" and action_info.get("dodged", false):
		var target_id: String = action_info.get("target", {}).get("unit_id", "")
		var slot: UnitSlotUI = _unit_slot_map.get(target_id)

		if slot != null:
			slot.show_dodge()


func _on_unit_damaged(unit_info: Dictionary, amount: int, is_crit: bool) -> void:
	var unit_id: String = unit_info.get("unit_id", "")
	var slot: UnitSlotUI = _unit_slot_map.get(unit_id)

	if slot != null:
		slot.update_hp(unit_info.get("current_hp", 0), unit_info.get("max_hp", 1))
		slot.flash_damage()
		slot.show_damage_number(amount, is_crit)


func _on_unit_healed(unit_info: Dictionary, amount: int) -> void:
	var unit_id: String = unit_info.get("unit_id", "")
	var slot: UnitSlotUI = _unit_slot_map.get(unit_id)

	if slot != null:
		slot.update_hp(unit_info.get("current_hp", 0), unit_info.get("max_hp", 1))
		slot.flash_heal()
		slot.show_heal_number(amount)


func _on_unit_died(unit_info: Dictionary) -> void:
	var unit_id: String = unit_info.get("unit_id", "")
	var slot: UnitSlotUI = _unit_slot_map.get(unit_id)

	if slot != null:
		slot.mark_dead()


func _on_boss_phase_changed(unit_info: Dictionary, phase: int) -> void:
	_log("[color=orange][b]%s enters Phase %d![/b][/color]" % [
		unit_info.get("display_name", "Boss"), phase,
	])


func _on_speed_changed(new_speed: float) -> void:
	if new_speed == 0.0:
		_speed_label.text = "||"
	else:
		_speed_label.text = "%sx" % str(new_speed)


func _on_speed_pressed(speed: float) -> void:
	if GameState.battle_manager != null:
		GameState.battle_manager.set_speed(speed)


func _on_log_toggled(pressed: bool) -> void:
	_log_margin.visible = pressed
	_log_toggle.text = "v Log" if pressed else "> Log"


func _format_action(info: Dictionary) -> String:
	var action_type: String = info.get("type", "")

	var actor: Dictionary = info.get("actor", {})
	var target: Dictionary = info.get("target", {})
	var actor_name: String = actor.get("display_name", "???")
	var target_name: String = target.get("display_name", "???")
	var ability_name: String = info.get("ability_name", "Attack")

	match action_type:
		"damage":
			if info.get("dodged", false):
				return "%s uses [b]%s[/b] on %s — [color=gray]Dodged![/color]" % [
					actor_name, ability_name, target_name,
				]

			var dmg_text := "[color=red]%d damage[/color]" % info.get("amount", 0)

			if info.get("crit", false):
				dmg_text += " [color=yellow](CRIT!)[/color]"

			if info.get("killed", false):
				dmg_text += " [color=red][b]KILLED![/b][/color]"

			var secondary: String = info.get("secondary", "")

			if secondary != "":
				dmg_text += " [%s]" % secondary

			return "%s uses [b]%s[/b] on %s → %s" % [
				actor_name, ability_name, target_name, dmg_text,
			]

		"heal":
			return "%s uses [b]%s[/b] on %s → [color=green]+%d HP[/color]" % [
				actor_name, ability_name, target_name, info.get("amount", 0),
			]

		"buff":
			return "%s uses [b]%s[/b] on %s → [color=cyan]%s (%d rounds)[/color]" % [
				actor_name, ability_name, target_name,
				info.get("effect", "buff"), info.get("duration", 0),
			]

		"debuff":
			return "%s uses [b]%s[/b] on %s → [color=purple]%s (%d rounds)[/color]" % [
				actor_name, ability_name, target_name,
				info.get("effect", "debuff"), info.get("duration", 0),
			]

		"taunt":
			return "%s uses [b]%s[/b] — [color=cyan]Taunting![/color]" % [
				actor_name, ability_name,
			]

		"resurrect":
			return "%s uses [b]%s[/b] on %s → [color=yellow]Revived with %d HP![/color]" % [
				actor_name, ability_name, target_name, info.get("amount", 0),
			]

		"cleanse":
			return "%s uses [b]%s[/b] on %s → [color=white]Cleansed %d effects![/color]" % [
				actor_name, ability_name, target_name, info.get("removed", 0),
			]

		"dot":
			return "  %s takes [color=red]%d %s damage[/color]" % [
				target_name, info.get("amount", 0), info.get("effect", ""),
			]

		"stunned":
			return "%s is [color=gray]stunned![/color]" % actor_name

	return ""


func _refresh_slot(info: Dictionary) -> void:
	if info.is_empty():
		return

	var slot: UnitSlotUI = _unit_slot_map.get(info.get("unit_id", ""))

	if slot != null:
		slot.update_info(info)


func _log(text: String) -> void:
	_log_text.append_text(text + "\n")

	await get_tree().process_frame
	_log_scroll.scroll_vertical = _log_scroll.get_v_scroll_bar().max_value


func _hero_slot_index(row: String, slot: int) -> int:
	## Heroes: [back_1, back_0, front_1, front_0] — back on far left, front_0 rightmost (near enemies)
	if row == "front":
		return 3 - slot
	return 1 - slot


func _monster_slot_index(row: String, slot: int) -> int:
	## Monsters: [front_0, front_1, back_0, back_1] — front row on the left
	if row == "front":
		return slot
	return 2 + slot
