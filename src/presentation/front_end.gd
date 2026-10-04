extends Control
## Title screen and Sunday Edition page select. Presentation only: the game
## owns progress and page loading; this view emits requests.

signal start_requested()
signal page_requested(index: int)
signal closed()
signal settings_requested()

const TIER_COLOURS := [Color("3a8d4f"), Color("d9a521"), Color("c0392b")]
const TIER_NAMES := ["EASY", "MEDIUM", "HARD"]
var _star_total: Label
var _credits_panel: Control

const INK := Color("243043")
const PAPER := Color("f3ead8")
const CARD := Color("fffaf0")
const RED := Color("a4383e")
const GOLD := Color("d9a521")
const MUTED := Color("8c8a80")
const COMIC_FONT = preload("res://assets/fonts/Bangers-Regular.ttf")

var _title_panel: Control
var _edition_panel: Control
var _cards: GridContainer
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
	button.add_theme_font_override("font", COMIC_FONT)
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
	frame.position = Vector2(140, 64)
	frame.size = Vector2(1000, 290)
	_title_panel.add_child(frame)
	var bulb := _Bulb.new()
	bulb.position = Vector2(640, 136)
	_title_panel.add_child(bulb)
	var title := _label("LIGHTBULB MOMENT", 88, Color("ffe08a"))
	title.add_theme_font_override("font", COMIC_FONT)
	title.add_theme_constant_override("outline_size", 10)
	title.add_theme_color_override("font_outline_color", INK)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(140, 206)
	title.size = Vector2(1000, 80)
	_title_panel.add_child(title)
	var tagline := _label("Shine a light into the comic. Swap what they're thinking. Twist the punchline.", 22, Color("dfe5f2"))
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.position = Vector2(140, 296)
	tagline.size = Vector2(1000, 40)
	_title_panel.add_child(tagline)
	var buttons := VBoxContainer.new()
	buttons.position = Vector2(520, 376)
	buttons.add_theme_constant_override("separation", 8)
	_title_panel.add_child(buttons)
	_start = _button("PLAY", 26, true)
	_start.name = "Start"
	_start.pressed.connect(func(): start_requested.emit())
	buttons.add_child(_start)
	var pages := _button("LEVELS", 22, false)
	pages.name = "Pages"
	pages.pressed.connect(show_edition)
	buttons.add_child(pages)
	var settings := _button("SETTINGS", 22, false)
	settings.name = "Settings"
	settings.pressed.connect(func(): settings_requested.emit())
	buttons.add_child(settings)
	var credits := _button("CREDITS", 22, false)
	credits.name = "Credits"
	credits.pressed.connect(func(): _credits_panel.show())
	buttons.add_child(credits)
	if not OS.has_feature("web"):
		# A browser tab cannot quit itself, so EXIT only exists on desktop.
		var leave := _button("EXIT", 20, false)
		leave.name = "Exit"
		leave.custom_minimum_size = Vector2(240, 44)
		leave.pressed.connect(func(): get_tree().quit())
		buttons.add_child(leave)
	for button in buttons.get_children():
		button.custom_minimum_size.y = 48
	_star_total = _label("", 22)
	_star_total.position = Vector2(980, 20)
	_star_total.size = Vector2(280, 30)
	_star_total.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_title_panel.add_child(_star_total)
	var masthead := _label("THE DAILY BULB  ·  VOL. 1  ·  TGC GAME JAM, INFINIUM 2026", 16, MUTED)
	masthead.position = Vector2(20, 24)
	_title_panel.add_child(masthead)
	_build_credits()
	var how := _label("Drag lanterns to light characters  •  Drag a lit thought onto another lit character to swap  •  Space = ACTION!", 16, MUTED)
	how.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	how.position = Vector2(40, 660)
	how.size = Vector2(1200, 30)
	how.hide()
	_title_panel.add_child(how)


func _build_edition() -> void:
	_edition_panel = Control.new()
	_edition_panel.size = size
	_edition_panel.hide()
	add_child(_edition_panel)
	var masthead := _label("THE DAILY BULB", 64)
	masthead.add_theme_font_override("font", COMIC_FONT)
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
	_cards = GridContainer.new()
	_cards.columns = 5
	_cards.position = Vector2(85, 150)
	_cards.size = Vector2(1110, 440)
	_cards.add_theme_constant_override("h_separation", 18)
	_cards.add_theme_constant_override("v_separation", 18)
	var legend := HBoxContainer.new()
	legend.position = Vector2(85, 96)
	legend.add_theme_constant_override("separation", 22)
	_edition_panel.add_child(legend)
	for tier in 3:
		var chip := _label("■ " + TIER_NAMES[tier], 16, TIER_COLOURS[tier])
		legend.add_child(chip)
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
	# Level card: tier colour + distinct border style (colour-blind safe).
	var tier := int(info.get("tier", 0))
	var unlocked: bool = info.get("unlocked", false)
	var solved: bool = info.get("solved", false)
	var button := Button.new()
	button.name = "Page%d" % (index + 1)
	button.custom_minimum_size = Vector2(206, 200)
	button.disabled = not unlocked
	button.tooltip_text = "" if unlocked else "Solve the previous page to unlock"
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box := StyleBoxFlat.new()
		box.bg_color = CARD if unlocked else Color("e6dfcf")
		if state == "hover":
			box.bg_color = Color("fff3d6")
		box.border_color = TIER_COLOURS[tier] if unlocked else Color(TIER_COLOURS[tier], 0.45)
		box.set_border_width_all([3, 6, 9][tier])
		box.set_corner_radius_all([10, 3, 0][tier])
		box.shadow_color = Color(INK, 0.8 if unlocked else 0.25)
		box.shadow_offset = Vector2(4, 4)
		button.add_theme_stylebox_override(state, box)
	button.pressed.connect(func(): page_requested.emit(index))
	var number := _label(str(index + 1), 40, TIER_COLOURS[tier])
	number.add_theme_font_override("font", COMIC_FONT)
	number.position = Vector2(16, 6)
	number.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(number)
	var tier_name := _label(TIER_NAMES[tier], 13, TIER_COLOURS[tier])
	tier_name.position = Vector2(120, 16)
	tier_name.size = Vector2(70, 18)
	tier_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	tier_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(tier_name)
	var title := _label(str(info.get("title", "")).to_upper() if unlocked else "? ? ?", 22, INK if unlocked else MUTED)
	title.add_theme_font_override("font", COMIC_FONT)
	title.position = Vector2(16, 62)
	title.size = Vector2(176, 60)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(title)
	if not unlocked:
		var lock := TextureRect.new()
		lock.texture = load("res://assets/ui/lock.svg")
		lock.position = Vector2(79, 124)
		lock.size = Vector2(48, 48)
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(lock)
		return button
	if info.has("max_stars"):
		var row := HBoxContainer.new()
		row.position = Vector2(16, 130)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for i in int(info.max_stars):
			var bulb := TextureRect.new()
			bulb.texture = load("res://assets/ui/%s.svg" % ("star_on" if i < int(info.get("stars", 0)) else "star_off"))
			bulb.custom_minimum_size = Vector2(28, 28)
			bulb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			bulb.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_child(bulb)
		button.add_child(row)
	var detail := ("Endings %d / %d" % [int(info.get("endings", 0)), int(info.get("max_endings", 0))]) if solved or int(info.get("endings", 0)) > 0 else "NEW!"
	var line := _label(detail, 14, RED if not solved else MUTED)
	line.position = Vector2(16, 166)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(line)
	if solved:
		var stamp := _label("INKED", 20, RED)
		stamp.add_theme_font_override("font", COMIC_FONT)
		stamp.rotation = -0.2
		stamp.position = Vector2(130, 150)
		stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(stamp)
	return button


func show_title(can_continue: bool) -> void:
	_title_panel.show()
	_edition_panel.hide()
	_start.text = "CONTINUE" if can_continue else "PLAY"
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



func set_star_total(stars: int, total: int) -> void:
	if is_instance_valid(_star_total):
		_star_total.text = "Bulbs lit: %d / %d" % [stars, total]


func _build_credits() -> void:
	_credits_panel = Control.new()
	_credits_panel.size = size
	_credits_panel.hide()
	add_child(_credits_panel)
	var dim := ColorRect.new()
	dim.color = Color(INK, 0.55)
	dim.size = size
	_credits_panel.add_child(dim)
	var box := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = CARD
	style.border_color = INK
	style.set_border_width_all(3)
	style.shadow_color = INK
	style.shadow_offset = Vector2(6, 6)
	box.add_theme_stylebox_override("panel", style)
	box.position = Vector2(300, 70)
	box.size = Vector2(680, 580)
	_credits_panel.add_child(box)
	var heading := _label("THE DAILY BULB  ·  STAFF", 40)
	heading.add_theme_font_override("font", COMIC_FONT)
	heading.position = Vector2(30, 18)
	box.add_child(heading)
	var body := _label("\n".join([
		"Made in 100 hours for the TGC Game Jam, Infinium 2026.",
		"Themes: COMIC  ·  TWIST  ·  LIGHT",
		"",
		"Game by Ayush Raj and team.",
		"",
		"Printed with Godot Engine 4 (MIT licence).",
		"Type: Bangers and Comic Neue (SIL Open Font Licence).",
		"Characters, props, icons and sound effects: original work.",
		"Room paintings: AI image generation (see THIRD_PARTY.md).",
		"Narration: synthetic voices (see THIRD_PARTY.md).",
		"",
		"Thanks for reading the Sunday funnies.",
	]), 18)
	body.position = Vector2(30, 88)
	body.size = Vector2(620, 420)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body)
	var back := _button("BACK", 20, false)
	back.custom_minimum_size = Vector2(160, 48)
	back.position = Vector2(490, 510)
	back.pressed.connect(func(): _credits_panel.hide())
	box.add_child(back)
