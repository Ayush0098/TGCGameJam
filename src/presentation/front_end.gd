extends Control
## Title screen and Sunday Edition page select. Presentation only: the game
## owns progress and page loading; this view emits requests.

signal start_requested()
signal page_requested(index: int)
signal closed()

const INK := Color("243043")
const PAPER := Color("f3ead8")
const CARD := Color("fffaf0")
const RED := Color("a4383e")
const GOLD := Color("d9a521")
const MUTED := Color("8c8a80")

var _title_panel: Control
var _edition_panel: Control
var _cards: VBoxContainer
var _start: Button
var _edition_note: Label
var _close: Button


func _ready() -> void:
	size = Vector2(1280, 720)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var paper := ColorRect.new()
	paper.color = PAPER
	paper.size = size
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(paper)
	_build_title()
	_build_edition()


func _label(text: String, font_size: int, colour: Color = INK) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", colour)
	return label


func _button(text: String, font_size: int, primary: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.add_theme_font_size_override("font_size", font_size)
	button.custom_minimum_size = Vector2(240, 56)
	for state in ["normal", "hover", "pressed", "focus"]:
		var box := StyleBoxFlat.new()
		box.bg_color = (RED if primary else CARD).lightened(0.08 if state == "hover" else 0.0)
		box.border_color = INK
		box.set_border_width_all(3)
		box.set_corner_radius_all(4)
		button.add_theme_stylebox_override(state, box)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(state, Color.WHITE if primary else INK)
	return button


func _build_title() -> void:
	_title_panel = Control.new()
	_title_panel.size = size
	add_child(_title_panel)
	var frame := Panel.new()
	var box := StyleBoxFlat.new()
	box.bg_color = Color("1d2740")
	box.border_color = INK
	box.set_border_width_all(6)
	frame.add_theme_stylebox_override("panel", box)
	frame.position = Vector2(140, 70)
	frame.size = Vector2(1000, 330)
	_title_panel.add_child(frame)
	var bulb := _Bulb.new()
	bulb.position = Vector2(640, 150)
	_title_panel.add_child(bulb)
	var title := _label("LIGHTBULB MOMENT", 64, Color("ffe08a"))
	title.add_theme_constant_override("outline_size", 10)
	title.add_theme_color_override("font_outline_color", INK)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(140, 230)
	title.size = Vector2(1000, 80)
	_title_panel.add_child(title)
	var tagline := _label("Shine a light into the comic. Swap what they're thinking. Twist the punchline.", 22, Color("dfe5f2"))
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.position = Vector2(140, 320)
	tagline.size = Vector2(1000, 40)
	_title_panel.add_child(tagline)
	var buttons := VBoxContainer.new()
	buttons.position = Vector2(520, 430)
	buttons.add_theme_constant_override("separation", 14)
	_title_panel.add_child(buttons)
	_start = _button("START", 26, true)
	_start.name = "Start"
	_start.pressed.connect(func(): start_requested.emit())
	buttons.add_child(_start)
	var pages := _button("PAGES", 22, false)
	pages.name = "Pages"
	pages.pressed.connect(show_edition)
	buttons.add_child(pages)
	var how := _label("Drag lanterns to light characters  •  Drag a lit thought onto another lit character to swap  •  Space = ACTION!", 16, MUTED)
	how.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	how.position = Vector2(40, 660)
	how.size = Vector2(1200, 30)
	_title_panel.add_child(how)


func _build_edition() -> void:
	_edition_panel = Control.new()
	_edition_panel.size = size
	_edition_panel.hide()
	add_child(_edition_panel)
	var masthead := _label("THE DAILY BULB", 52)
	masthead.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	masthead.position = Vector2(0, 26)
	masthead.size = Vector2(1280, 64)
	_edition_panel.add_child(masthead)
	var sub := _label("SUNDAY EDITION  —  every page a little different", 18, MUTED)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, 92)
	sub.size = Vector2(1280, 26)
	_edition_panel.add_child(sub)
	var rule := ColorRect.new()
	rule.color = INK
	rule.position = Vector2(80, 126)
	rule.size = Vector2(1120, 4)
	_edition_panel.add_child(rule)
	_cards = VBoxContainer.new()
	_cards.position = Vector2(180, 150)
	_cards.size = Vector2(920, 440)
	_cards.add_theme_constant_override("separation", 14)
	_edition_panel.add_child(_cards)
	_edition_note = _label("", 18, MUTED)
	_edition_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_edition_note.position = Vector2(0, 600)
	_edition_note.size = Vector2(1280, 28)
	_edition_panel.add_child(_edition_note)
	_close = _button("BACK", 20, false)
	_close.custom_minimum_size = Vector2(160, 48)
	_close.position = Vector2(560, 640)
	_close.pressed.connect(func():
		hide()
		closed.emit()
	)
	_edition_panel.add_child(_close)


## pages: Array of {title, solved, unlocked, current, stars, max_stars, endings, max_endings}
func set_pages(pages: Array, note: String = "") -> void:
	for child in _cards.get_children():
		_cards.remove_child(child)
		child.queue_free()
	for index in pages.size():
		_cards.add_child(_card(index, pages[index]))
	_edition_note.text = note


func _card(index: int, info: Dictionary) -> Control:
	var button := Button.new()
	button.name = "Page%d" % (index + 1)
	button.custom_minimum_size = Vector2(920, 120)
	button.disabled = not info.get("unlocked", false)
	var solved: bool = info.get("solved", false)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box := StyleBoxFlat.new()
		box.bg_color = CARD if state != "disabled" else Color("e6dfcf")
		if state == "hover":
			box.bg_color = Color("fff3d6")
		box.border_color = INK if solved or state == "hover" else Color(INK, 0.45)
		box.set_border_width_all(4 if info.get("current", false) else 2)
		if not solved and state != "hover":
			# Unsolved strips are pencil placeholders until inked by a win.
			box.border_color = Color(MUTED, 0.9)
		button.add_theme_stylebox_override(state, box)
	button.pressed.connect(func(): page_requested.emit(index))
	var number := _label("PAGE %d" % (index + 1), 16, MUTED)
	number.position = Vector2(24, 16)
	number.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(number)
	var title := _label(str(info.get("title", "")), 30, INK if info.get("unlocked", false) else MUTED)
	title.position = Vector2(24, 40)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(title)
	var detail := ""
	if not info.get("unlocked", false):
		detail = "Solve the previous page to unlock"
	elif solved:
		detail = "Solved: " + str(info.get("caption", ""))
	else:
		detail = "Not solved yet"
	if info.has("max_endings") and int(info.max_endings) > 0:
		detail += "     Endings %d / %d" % [int(info.get("endings", 0)), int(info.max_endings)]
	var line := _label(detail, 16, RED if solved else MUTED)
	line.position = Vector2(24, 84)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(line)
	if info.has("max_stars"):
		var stars := _Stars.new()
		stars.count = int(info.get("stars", 0))
		stars.total = int(info.max_stars)
		stars.position = Vector2(880 - 44 * stars.total, 40)
		stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(stars)
	if solved:
		var stamp := _label("INKED", 22, RED)
		stamp.rotation = -0.18
		stamp.position = Vector2(760, 76)
		stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(stamp)
	return button


func show_title(can_continue: bool) -> void:
	_title_panel.show()
	_edition_panel.hide()
	_start.text = "CONTINUE" if can_continue else "START"
	show()
	_start.grab_focus()


func show_edition() -> void:
	_title_panel.hide()
	_edition_panel.show()
	show()


class _Bulb extends Control:
	func _draw() -> void:
		draw_circle(Vector2.ZERO, 70, Color(1, 0.88, 0.45, 0.18))
		draw_circle(Vector2.ZERO, 46, Color(1, 0.88, 0.45, 0.35))
		draw_circle(Vector2.ZERO, 30, Color("ffe17a"))
		draw_arc(Vector2.ZERO, 30, 0, TAU, 40, Color("243043"), 4, true)
		draw_rect(Rect2(-14, 26, 28, 18), Color("243043"))
		for i in 8:
			var angle := TAU * i / 8.0
			var direction := Vector2.from_angle(angle)
			draw_line(direction * 54, direction * 70, Color("ffe08a"), 4, true)


class _Stars extends Control:
	var count := 0
	var total := 3

	func _draw() -> void:
		for i in total:
			var centre := Vector2(22 + i * 44, 22)
			var points := PackedVector2Array()
			for k in 10:
				var radius := 18.0 if k % 2 == 0 else 8.0
				points.append(centre + Vector2.from_angle(-PI / 2 + k * PI / 5) * radius)
			draw_colored_polygon(points, Color("f2c94c") if i < count else Color("e6dfcf"))
			points.append(points[0])
			draw_polyline(points, Color("243043"), 2.0, true)
