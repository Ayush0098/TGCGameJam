extends Control
## Title screen and Sunday Edition page select. Presentation only: the game
## owns progress and page loading; this view emits requests.

signal start_requested()
signal page_requested(index: int)
signal closed()
signal settings_requested()
signal levels_requested()
## Where the Sunday Edition was opened from, so BACK returns there.
var _edition_from_title := false

const TIER_COLOURS := [Color("3a8d4f"), Color("d9a521"), Color("c0392b")]
const TIER_NAMES := ["EASY", "MEDIUM", "HARD"]
var _star_total: Label
var _credits_panel: Control
var _credits_back: Button
var _credits_button: Button
var _pages_button: Button

const INK := Color("1e1b2e")
const PAPER := Color("f4e9d2")
const CARD := Color("fffaf0")
const RED := Color("a4383e")
const GOLD := Color("d9a521")
const MUTED := Color("8c8a80")
const FOCUS := Color("e8731a")
const COMIC_FONT = preload("res://assets/fonts/Bangers-Regular.ttf")

var _title_panel: Control
var _paper: ColorRect
var _scene: ColorRect
var _logo: Label
var _swing_bulb: Control
var _motes: Control
var _light := Vector2(0.5, 0.42)
var _light_target := Vector2(0.5, 0.42)
var _idle_time := 0.0
var _clock := 0.0
var _flicker := 0.0
const TITLE_SHADER = preload("res://presentation/title_light.gdshader")
var _edition_panel: Control
var _cards: GridContainer
var _page_count := 10
var _start: Button
var _edition_note: Label
var _close: Button


func _ready() -> void:
	size = Vector2(1280, 720)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_paper = ColorRect.new()
	_paper.color = PAPER
	_paper.size = size
	_paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_paper)
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
		if state == "focus":
			# Keyboard focus must be obvious: a thick orange frame and a glow.
			box.bg_color = (RED if primary else Color("fff3d6")).lightened(0.1)
			box.border_color = FOCUS
			box.set_border_width_all(6)
			box.shadow_color = Color(1.0, 0.72, 0.2, 0.8)
			box.shadow_size = 12
		button.add_theme_stylebox_override(state, box)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(state, Color.WHITE if primary else INK)
	return button


func _build_title() -> void:
	_title_panel = Control.new()
	_title_panel.size = size
	add_child(_title_panel)
	_scene = ColorRect.new()
	_scene.size = size
	_scene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var scene_material := ShaderMaterial.new()
	scene_material.shader = TITLE_SHADER
	scene_material.set_shader_parameter("painting", load("res://assets/art/rooms/room_kadamba.png"))
	_scene.material = scene_material
	_title_panel.add_child(_scene)
	_motes = _Motes.new()
	_motes.size = size
	_motes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_panel.add_child(_motes)
	_swing_bulb = _Bulb.new()
	_swing_bulb.position = Vector2(640, 0)
	_title_panel.add_child(_swing_bulb)
	_logo = _label("LIGHTBULB MOMENT", 96, Color("ffe08a"))
	_logo.add_theme_font_override("font", COMIC_FONT)
	_logo.add_theme_constant_override("outline_size", 14)
	_logo.add_theme_color_override("font_outline_color", INK)
	_logo.add_theme_constant_override("shadow_offset_x", 6)
	_logo.add_theme_constant_override("shadow_offset_y", 8)
	_logo.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	_logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_logo.position = Vector2(140, 196)
	_logo.size = Vector2(1000, 100)
	_logo.pivot_offset = _logo.size * 0.5
	_title_panel.add_child(_logo)
	var tagline := _label("The Official Campus Comic (Approved). Shine a light, swap a thought, twist the punchline.", 22, Color("f4e9d2"))
	tagline.add_theme_constant_override("outline_size", 6)
	tagline.add_theme_color_override("font_outline_color", Color(INK, 0.9))
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.position = Vector2(140, 300)
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
	pages.pressed.connect(func():
		_edition_from_title = true
		levels_requested.emit())
	buttons.add_child(pages)
	_pages_button = pages
	var settings := _button("SETTINGS", 22, false)
	settings.name = "Settings"
	settings.pressed.connect(func(): settings_requested.emit())
	buttons.add_child(settings)
	var credits := _button("CREDITS", 22, false)
	credits.name = "Credits"
	credits.pressed.connect(func(): _credits_panel.show())
	_credits_button = credits
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
	_star_total = _label("", 22, Color("ffe08a"))
	_star_total.position = Vector2(980, 20)
	_star_total.size = Vector2(280, 30)
	_star_total.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_title_panel.add_child(_star_total)
	var masthead := _label("IIIT HYDERABAD  ·  INFINIUM 2026  ·  TGC GAME JAM", 16, Color("d8cbb0"))
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
	var masthead := _label("THE CAMPUS COMIC", 64)
	masthead.add_theme_font_override("font", COMIC_FONT)
	masthead.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	masthead.position = Vector2(0, 26)
	masthead.size = Vector2(1280, 64)
	_edition_panel.add_child(masthead)
	var sub := _label("ORIENTATION WEEK  —  every page a little different", 18, MUTED)
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
		if _edition_from_title:
			_edition_from_title = false
			_title_panel.show()
			_edition_panel.hide()
			_pages_button.grab_focus()
		else:
			hide()
			closed.emit()
	)
	_edition_panel.add_child(_close)


## pages: Array of {title, solved, unlocked, current, stars, max_stars, endings, max_endings}
func set_pages(pages: Array, note: String = "") -> void:
	for child in _cards.get_children():
		_cards.remove_child(child)
		child.queue_free()
	_page_count = pages.size()
	_cards.add_theme_constant_override("v_separation", 12 if _page_count > 10 else 18)
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
	var compact := _page_count > 10
	button.custom_minimum_size = Vector2(206, 140 if compact else 200)
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
		if state == "focus":
			box.bg_color = Color("fff3d6")
			box.border_color = FOCUS
			box.set_border_width_all(10)
			box.shadow_color = Color(1.0, 0.72, 0.2, 0.85)
			box.shadow_size = 14
			box.shadow_offset = Vector2.ZERO
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
	var title := _label(str(info.get("title", "")).to_upper() if unlocked else "? ? ?", 20 if compact else 22, INK if unlocked else MUTED)
	title.add_theme_font_override("font", COMIC_FONT)
	title.position = Vector2(16, 48 if compact else 62)
	title.size = Vector2(176, 44 if compact else 60)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(title)
	if not unlocked:
		var lock := TextureRect.new()
		lock.texture = load("res://assets/ui/lock.svg")
		lock.position = Vector2(79, 88 if compact else 124)
		lock.size = Vector2(48, 48)
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(lock)
		return button
	if info.has("max_stars"):
		var row := HBoxContainer.new()
		row.position = Vector2(16, 90 if compact else 130)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for i in int(info.max_stars):
			var bulb := TextureRect.new()
			bulb.texture = load("res://assets/ui/%s.svg" % ("star_on" if i < int(info.get("stars", 0)) else "star_off"))
			bulb.custom_minimum_size = Vector2(24, 24) if compact else Vector2(28, 28)
			bulb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			bulb.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_child(bulb)
		button.add_child(row)
	var detail := ("Endings %d / %d" % [int(info.get("endings", 0)), int(info.get("max_endings", 0))]) if solved or int(info.get("endings", 0)) > 0 else "NEW!"
	var line := _label(detail, 14, RED if not solved else MUTED)
	line.position = Vector2(16, 116 if compact else 166)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(line)
	if solved:
		var stamp := _label("INKED", 20, RED)
		stamp.add_theme_font_override("font", COMIC_FONT)
		stamp.rotation = -0.2
		stamp.position = Vector2(130, 96 if compact else 150)
		stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(stamp)
	return button


func show_title(can_continue: bool) -> void:
	_edition_from_title = false
	_title_panel.show()
	_edition_panel.hide()
	_paper.hide()
	_flicker = 0.0
	_start.text = "CONTINUE" if can_continue else "PLAY"
	show()
	_start.grab_focus()


func show_edition() -> void:
	_title_panel.hide()
	_edition_panel.show()
	_paper.show()
	show()
	# Keyboard: start on the newest unlocked page; arrows move through the grid.
	var focus: Control = _close
	for card in _cards.get_children():
		if card is Button and not card.disabled:
			focus = card
	focus.grab_focus.call_deferred()


class _Bulb extends Control:
	## Bulby hangs from the top of the screen on a cord and swings.
	var angle := 0.0
	var brightness := 1.0
	const CORD := 120.0

	func _draw() -> void:
		var tip := Vector2(0, CORD).rotated(angle)
		draw_line(Vector2.ZERO, tip, Color("2b2530"), 4, true)
		var at := tip + Vector2(0, 30).rotated(angle)
		var b := brightness
		draw_circle(at, 120, Color(1, 0.88, 0.45, 0.10 * b))
		draw_circle(at, 70, Color(1, 0.88, 0.45, 0.20 * b))
		draw_circle(at, 46, Color(1, 0.88, 0.45, 0.35 * b))
		draw_circle(at, 30, Color("ffe17a").lerp(Color("7a7462"), 1.0 - b))
		draw_arc(at, 30, 0, TAU, 40, INK, 4, true)
		draw_set_transform(at, angle, Vector2.ONE)
		draw_rect(Rect2(-14, -42, 28, 16), INK)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		# Smile: Bulby is happy to see you.
		draw_arc(at + Vector2(0, 4), 12, 0.3, PI - 0.3, 12, INK, 3, true)
		draw_circle(at + Vector2(-9, -6), 3, INK)
		draw_circle(at + Vector2(9, -6), 3, INK)
		if b > 0.6:
			for i in 8:
				var direction := Vector2.from_angle(TAU * i / 8.0 + angle)
				draw_line(at + direction * 54, at + direction * (66 + 6 * b), Color(Color("ffe08a"), b), 4, true)


class _Motes extends Control:
	## Dust drifting through the torch light.
	var light := Vector2(640, 300)
	var time := 0.0

	func _draw() -> void:
		for i in 46:
			var seed := float(i) * 12.9898
			var x := fposmod(sin(seed) * 43758.5453, 1.0) * size.x
			var speed := 10.0 + fposmod(seed * 7.1, 1.0) * 18.0
			var y := size.y - fposmod(time * speed + fposmod(seed * 3.7, 1.0) * size.y, size.y + 40.0)
			var at := Vector2(x + sin(time * 0.6 + seed) * 14.0, y)
			var near := clampf(1.0 - at.distance_to(light) / 260.0, 0.0, 1.0)
			draw_circle(at, 1.5 + near * 1.8, Color(1, 0.93, 0.7, 0.08 + near * 0.55))


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
			draw_polyline(points, INK, 2.0, true)



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
	# Team name and maker get the main focus; everyone else follows smaller.
	var kicker := _label("THE OFFICIAL CAMPUS COMIC  ·  STAFF", 16, MUTED)
	kicker.position = Vector2(0, 22)
	kicker.size = Vector2(680, 20)
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(kicker)
	var team := _label("PROJECT NAP", 64, RED)
	team.add_theme_font_override("font", COMIC_FONT)
	team.position = Vector2(0, 44)
	team.size = Vector2(680, 76)
	team.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(team)
	var maker := _label("Made by AYUSH RAJ", 34)
	maker.add_theme_font_override("font", COMIC_FONT)
	maker.position = Vector2(0, 120)
	maker.size = Vector2(680, 44)
	maker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(maker)
	# One centred line per entry: every label spans the full card width.
	var lines := [
		[170, "Contact:  ayush.raj@research.iiit.ac.in   ·   9102582903", 16, INK],
		[214, "Team member:  Kancharla Nagapranav Reddy", 16, INK],
		[240, "Testing and ideation:  Ayush Pattanayak, Pranshu Porwal, Adiraj Jain", 16, INK],
		[300, "Made in 100 hours for the TGC Game Jam, Infinium 2026", 14, MUTED],
		[324, "Themes: COMIC  ·  TWIST  ·  LIGHT", 14, MUTED],
		[348, "Printed with Godot Engine 4 (MIT licence)  ·  Type: Bangers and Comic Neue (SIL OFL)", 14, MUTED],
		[372, "Props, icons, sound effects and music: original work", 14, MUTED],
		[396, "Character and room art: AI image generation  ·  Voices: synthetic (see THIRD_PARTY.md)", 14, MUTED],
		[440, "Thanks for reading the Official Campus Comic. In memory of Oreo, Queen of IIITH.", 16, RED],
	]
	for entry in lines:
		var line := _label(str(entry[1]), int(entry[2]), entry[3])
		line.position = Vector2(0, float(entry[0]))
		line.size = Vector2(680, 24)
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		line.autowrap_mode = TextServer.AUTOWRAP_OFF
		box.add_child(line)
	for y in [204, 284]:
		var rule := ColorRect.new()
		rule.color = Color(INK, 0.8 if y == 204 else 0.25)
		rule.position = Vector2(140, y)
		rule.size = Vector2(400, 2)
		box.add_child(rule)
	var back := _button("BACK", 20, false)
	back.custom_minimum_size = Vector2(160, 48)
	back.size = Vector2(160, 48)
	back.position = Vector2(260, 500)
	back.pressed.connect(go_back)
	box.add_child(back)
	_credits_back = back
	_credits_panel.visibility_changed.connect(func():
		if _credits_panel.visible:
			_credits_back.grab_focus.call_deferred())



## The finale adds its own lines to the credits card (data/campaign/page_15.gd).
func set_credits_extra(lines: Array) -> void:
	var box: Panel = _credits_back.get_parent()
	var old := box.get_node_or_null("Extra")
	if old:
		old.queue_free()
	if lines.is_empty():
		return
	var extra := Control.new()
	extra.name = "Extra"
	box.add_child(extra)
	for i in lines.size():
		var line := _label(str(lines[i]), 13)
		line.position = Vector2(0, 466 + 19 * i)
		line.size = Vector2(680, 18)
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		extra.add_child(line)
	# Make room: the card grows downward for the finale lines.
	box.position.y = 20
	box.size.y = 680
	_credits_back.position.y = 616


func show_credits() -> void:
	_credits_panel.show()


## Whichever part of the front end the keyboard is working in right now.
func menu_scope() -> Control:
	if _credits_panel.visible:
		return _credits_panel
	return _edition_panel if _edition_panel.visible else _title_panel


func _process(delta: float) -> void:
	if not visible or not _title_panel.visible:
		return
	_clock += delta
	_idle_time += delta
	var mouse := get_local_mouse_position()
	if Rect2(Vector2.ZERO, size).has_point(mouse) and _idle_time < 2.5:
		_light_target = mouse / size
	else:
		# Nobody moving the mouse: the torch wanders by itself.
		_light_target = Vector2(0.5 + 0.28 * sin(_clock * 0.45), 0.45 + 0.16 * sin(_clock * 0.71))
	_light = _light.lerp(_light_target, clampf(delta * 6.0, 0.0, 1.0))
	# Bulby flickers on when the title appears, then stays lit.
	_flicker += delta
	var on := 1.0
	if _flicker < 0.9:
		on = 1.0 if fmod(_flicker * 9.0, 2.0) > 0.7 or _flicker > 0.7 else 0.15
	var material: ShaderMaterial = _scene.material
	material.set_shader_parameter("light_pos", _light)
	material.set_shader_parameter("glow", on * (0.94 + 0.06 * sin(_clock * 7.0)))
	_swing_bulb.angle = 0.16 * sin(_clock * 1.3) + (_light.x - 0.5) * 0.25
	_swing_bulb.brightness = on
	_swing_bulb.queue_redraw()
	_logo.rotation = 0.025 * sin(_clock * 1.7)
	_logo.scale = Vector2.ONE * (1.0 + 0.02 * sin(_clock * 2.3))
	_motes.light = _light * size
	_motes.time = _clock
	_motes.queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_idle_time = 0.0



## Esc on the title screens: close Credits, or leave the Sunday Edition.
func go_back() -> void:
	if _credits_panel.visible:
		_credits_panel.hide()
		_credits_button.grab_focus()
	elif _edition_panel.visible:
		_close.pressed.emit()


func focus_settings() -> void:
	var settings := _title_panel.find_child("Settings", true, false)
	if settings is Control and settings.is_visible_in_tree():
		settings.grab_focus()
