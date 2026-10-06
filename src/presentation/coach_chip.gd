extends Control
## A small "press this key" pop-up with drawn key caps. It slides in when a hint
## is relevant and slides away once the player does the thing. Presentation only:
## the game decides which hint is current.

const INK := Color("1e1b2e")
const PAPER := Color("fff4d6")
const GOLD := Color("d9a521")
const COMIC_FONT = preload("res://assets/fonts/Bangers-Regular.ttf")

const ARROWS := ["←", "→", "↑", "↓"]

var hint_id := ""
var reduce_motion := false
var _panel: PanelContainer
var _row: HBoxContainer
var _shown := false
var _clock := 0.0
var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 190
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := StyleBoxFlat.new()
	box.bg_color = PAPER
	box.border_color = INK
	box.set_border_width_all(3)
	box.set_corner_radius_all(14)
	box.corner_radius_bottom_left = 3
	box.shadow_color = Color(0, 0, 0, 0.45)
	box.shadow_size = 8
	box.shadow_offset = Vector2(3, 4)
	box.content_margin_left = 14
	box.content_margin_right = 16
	box.content_margin_top = 6
	box.content_margin_bottom = 6
	_panel.add_theme_stylebox_override("panel", box)
	add_child(_panel)
	_row = HBoxContainer.new()
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row.add_theme_constant_override("separation", 6)
	_panel.add_child(_row)
	modulate.a = 0.0
	hide()


## parts: [{"keys": ["W","A","S","D"], "or": ["←","↑","↓","→"], "label": "move the light"}, ...]
func show_hint(id: String, parts: Array) -> void:
	if id == hint_id and _shown:
		return
	hint_id = id
	for child in _row.get_children():
		_row.remove_child(child)
		child.queue_free()
	for index in parts.size():
		var part: Dictionary = parts[index]
		if index > 0:
			_row.add_child(_text("·", 22, Color(INK, 0.5)))
		_caps(part.get("keys", []))
		if part.has("or"):
			_row.add_child(_text("or", 16, Color(INK, 0.6)))
			_caps(part["or"])
		_row.add_child(_text(str(part.get("label", "")), 20, INK))
	_panel.reset_size()
	size = _panel.size
	_shown = true
	show()
	_fade(1.0)


func hide_hint() -> void:
	if not _shown:
		return
	_shown = false
	hint_id = ""
	_fade(0.0)


func _fade(target: float) -> void:
	if is_instance_valid(_tween):
		_tween.kill()
	if reduce_motion:
		modulate.a = target
		visible = target > 0.0
		return
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", target, 0.22)
	if target > 0.0:
		_panel.position.x = -24.0
		_tween.tween_property(_panel, "position:x", 0.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		_tween.chain().tween_callback(func(): visible = _shown)


func _process(delta: float) -> void:
	if not _shown or reduce_motion:
		return
	_clock += delta
	# A slow breathing bob keeps the pop-up noticeable without being loud.
	_panel.position.y = sin(_clock * 3.0) * 2.0


func _caps(keys: Array) -> void:
	for key in keys:
		_row.add_child(_cap(str(key)))


func _cap(label: String) -> Control:
	var cap := PanelContainer.new()
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := StyleBoxFlat.new()
	box.bg_color = Color("ffffff")
	box.border_color = INK
	box.set_border_width_all(2)
	box.border_width_bottom = 5
	box.set_corner_radius_all(6)
	box.content_margin_left = 8
	box.content_margin_right = 8
	box.content_margin_top = 1
	box.content_margin_bottom = 1
	cap.add_theme_stylebox_override("panel", box)
	cap.custom_minimum_size = Vector2(36, 36)
	if label in ARROWS:
		# The web font has no arrow glyphs, so arrows are drawn.
		var arrow := _Arrow.new()
		arrow.direction = ARROWS.find(label)
		arrow.custom_minimum_size = Vector2(20, 28)
		cap.add_child(arrow)
		return cap
	var text := _text(label, 22, INK)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cap.add_child(text)
	return cap


func _text(text: String, font_size: int, colour: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", COMIC_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", colour)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


class _Arrow extends Control:
	var direction := 0  # 0 left, 1 right, 2 up, 3 down

	func _draw() -> void:
		var c := size * 0.5
		var tip := [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)][direction] as Vector2
		var side := Vector2(-tip.y, tip.x)
		var points := PackedVector2Array([c + tip * 8.0, c - tip * 6.0 + side * 8.0, c - tip * 6.0 - side * 8.0])
		draw_colored_polygon(points, Color("1e1b2e"))
