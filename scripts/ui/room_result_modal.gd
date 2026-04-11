class_name RoomResultModal
extends CanvasLayer

## Displays loot/results as a right-side panel with papyrus background and item icons.

signal dismissed()

const ICON_SIZE := Vector2(52, 52)
const GOLD_COLOR := Color(1.0, 0.85, 0.2)
const RARITY_COLORS := {
	"common": Color(0.8, 0.8, 0.8),
	"uncommon": Color(0.3, 0.9, 0.3),
	"rare": Color(0.3, 0.5, 1.0),
	"legendary": Color(0.9, 0.5, 0.1),
	"cursed": Color(0.7, 0.1, 0.7),
}

# Item keyword -> icon texture path
const ITEM_ICON_MAP := {
	"sword": "res://assets/ui/icon_weapon.png",
	"mace": "res://assets/ui/icon_weapon.png",
	"staff": "res://assets/ui/icon_weapon.png",
	"sling": "res://assets/ui/icon_weapon.png",
	"dmg": "res://assets/ui/icon_weapon.png",
	"buckler": "res://assets/ui/icon_armor.png",
	"cloak": "res://assets/ui/icon_armor.png",
	"armor": "res://assets/ui/icon_armor.png",
	"cap": "res://assets/ui/icon_hat.png",
	"helmet": "res://assets/ui/icon_hat.png",
	"bucket": "res://assets/ui/icon_hat.png",
	"boots": "res://assets/ui/icon_boots.png",
	"potion": "res://assets/ui/icon_potion.png",
	"healing": "res://assets/ui/icon_potion.png",
	"cheese": "res://assets/ui/icon_food.png",
	"charm": "res://assets/ui/icon_cursed.png",
	"ring": "res://assets/ui/icon_cursed.png",
	"cursed": "res://assets/ui/icon_cursed.png",
}

# Dark ink-like text color for papyrus
const TEXT_DARK := Color(0.25, 0.15, 0.05)
const TEXT_GOLD := Color(0.5, 0.35, 0.05)

var _tex_papyrus: Texture2D = preload("res://assets/ui/papyrus_bg.png")
var _tex_gold: Texture2D = preload("res://assets/ui/icon_gold.png")

var _panel: TextureRect
var _vbox: VBoxContainer
var _title_label: Label
var _items_container: VBoxContainer


func _init() -> void:
	layer = 10

	# Papyrus scroll background
	_panel = TextureRect.new()
	_panel.texture = _tex_papyrus
	_panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_panel.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_panel.anchor_left = 0.70
	_panel.anchor_right = 0.95
	_panel.anchor_top = 0.15
	_panel.anchor_bottom = 0.60
	_panel.offset_left = 0
	_panel.offset_right = 0
	_panel.offset_top = 0
	_panel.offset_bottom = 0
	add_child(_panel)

	# Larger margins to stay within the papyrus scroll area
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 44)
	margin.add_theme_constant_override("margin_right", 44)
	margin.add_theme_constant_override("margin_top", 52)
	margin.add_theme_constant_override("margin_bottom", 52)
	_panel.add_child(margin)

	_vbox = VBoxContainer.new()
	_vbox.add_theme_constant_override("separation", 12)
	margin.add_child(_vbox)

	# Title
	_title_label = Label.new()
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 26)
	_vbox.add_child(_title_label)

	var sep := HSeparator.new()
	_vbox.add_child(sep)

	# Items list
	_items_container = VBoxContainer.new()
	_items_container.add_theme_constant_override("separation", 8)
	_items_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_vbox.add_child(_items_container)

	# Continue button
	var continue_btn := Button.new()
	continue_btn.text = "Continue"
	continue_btn.custom_minimum_size = Vector2(0, 36)
	continue_btn.pressed.connect(_dismiss)
	_vbox.add_child(continue_btn)


func show_treasure(gold: int, items: Array[String]) -> void:
	_title_label.text = "Treasure Found!"
	_title_label.add_theme_color_override("font_color", Color(0.5, 0.3, 0.05))

	if gold > 0:
		_add_gold_row(gold)

	for item: String in items:
		_add_item_row(item, "uncommon")

	if gold == 0 and items.is_empty():
		_add_text_row("Empty chest...", Color(0.4, 0.35, 0.25))


func show_curse(curse_name: String, curse_description: String) -> void:
	_title_label.text = "Cursed!"
	_title_label.add_theme_color_override("font_color", Color(0.5, 0.1, 0.5))

	_add_icon_row("res://assets/ui/icon_cursed.png", curse_name, Color(0.5, 0.1, 0.5))
	_add_text_row(curse_description, Color(0.4, 0.3, 0.25))


func show_rest(heal_amount: int) -> void:
	_title_label.text = "Rest Area"
	_title_label.add_theme_color_override("font_color", Color(0.15, 0.45, 0.2))

	_add_icon_row("res://assets/ui/icon_potion.png", "Campfire Rest", Color(0.15, 0.45, 0.2))
	_add_text_row("+ %d HP restored to each hero" % heal_amount, Color(0.15, 0.45, 0.2))


func show_battle_loot(result: String, gold: int, items: Array[String]) -> void:
	if result == "victory":
		_title_label.text = "Victory!"
		_title_label.add_theme_color_override("font_color", Color(0.15, 0.45, 0.1))

		if gold > 0:
			_add_gold_row(gold)

		for item: String in items:
			_add_item_row(item, _random_rarity())

		if gold == 0 and items.is_empty():
			_add_text_row("No loot dropped", Color(0.4, 0.35, 0.25))

	else:
		_title_label.text = "Defeat..."
		_title_label.add_theme_color_override("font_color", Color(0.6, 0.15, 0.1))
		_add_text_row("The party has been defeated...", Color(0.6, 0.15, 0.1))


# -- Row builders --

func _add_gold_row(amount: int) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_items_container.add_child(row)

	var icon := TextureRect.new()
	icon.texture = _tex_gold
	icon.custom_minimum_size = ICON_SIZE
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(icon)

	var label := Label.new()
	label.text = "+ %d Gold" % amount
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", TEXT_GOLD)
	row.add_child(label)


func _add_item_row(item_name: String, rarity: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_items_container.add_child(row)

	var border_color: Color = RARITY_COLORS.get(rarity, Color(0.5, 0.5, 0.5))

	# Item icon from keyword matching
	var icon_path := _guess_icon_path(item_name)
	var icon := TextureRect.new()
	icon.custom_minimum_size = ICON_SIZE
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	if ResourceLoader.exists(icon_path):
		icon.texture = load(icon_path)

	icon.modulate = border_color.lightened(0.3)
	row.add_child(icon)

	var label := Label.new()
	label.text = item_name
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", TEXT_DARK)
	row.add_child(label)


func _add_icon_row(icon_path: String, text: String, color: Color) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_items_container.add_child(row)

	var icon := TextureRect.new()
	icon.custom_minimum_size = ICON_SIZE
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	if ResourceLoader.exists(icon_path):
		icon.texture = load(icon_path)

	row.add_child(icon)

	var label := Label.new()
	label.text = text
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", TEXT_DARK)
	row.add_child(label)


func _add_text_row(text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_items_container.add_child(label)


func _guess_icon_path(item_name: String) -> String:
	var lower := item_name.to_lower()

	for keyword: String in ITEM_ICON_MAP:
		if lower.find(keyword) >= 0:
			return ITEM_ICON_MAP[keyword]

	return "res://assets/ui/icon_weapon.png"


func _random_rarity() -> String:
	var roll := randf()

	if roll < 0.5:
		return "common"
	elif roll < 0.8:
		return "uncommon"
	elif roll < 0.95:
		return "rare"

	return "legendary"


func _dismiss() -> void:
	dismissed.emit()
	queue_free()
