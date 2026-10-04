extends Control
## Star award after a page: the page's bulbs light up one by one with a pop,
## a spin and a spray of sparks. Stars earned earlier are already lit; the
## ones earned this run arrive one at a time. Click to skip.

signal star_landed(index: int, fresh: bool)
signal finished

const INK := Color("243043")
const GOLD := Color("ffd27a")
const BULB_ON := '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24"><circle cx="12" cy="11" r="10" fill="#ffd27a" opacity=".45"/><path d="M12 4 A7 7 0 0 1 16.2 16.3 L16.2 18.5 L7.8 18.5 L7.8 16.3 A7 7 0 0 1 12 4 Z" fill="#ffe17a" stroke="#243043" stroke-width="1.8" stroke-linejoin="round"/><path d="M8.5 20.5 H15.5 M9.5 22.5 H14.5" stroke="#243043" stroke-width="1.6" stroke-linecap="round"/></svg>'
const BULB_OFF := '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24"><path d="M12 4 A7 7 0 0 1 16.2 16.3 L16.2 18.5 L7.8 18.5 L7.8 16.3 A7 7 0 0 1 12 4 Z" fill="#d9d2c3" stroke="#6d6a62" stroke-width="1.6" stroke-linejoin="round"/><path d="M8.5 20.5 H15.5 M9.5 22.5 H14.5" stroke="#6d6a62" stroke-width="1.4" stroke-linecap="round"/></svg>'
const SIZE := 132.0
const GAP := 40.0

var _on: Texture2D
var _off: Texture2D
var _total := 3
var _before := 0
var _after := 0
var _title := ""
var _time := 0.0
var _landed: Array[bool] = []
var _sparks: Array[Dictionary] = []
var _reduced := false
var _done := false
var _font: Font


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(false)
	hide()
	_on = _svg(BULB_ON)
	_off = _svg(BULB_OFF)


func _svg(text: String) -> Texture2D:
	var image := Image.new()
	image.load_svg_from_string(text, SIZE / 24.0)
	return ImageTexture.create_from_image(image)


## before: stars already owned; after: stars owned now; total: stars on the page.
func play(before: int, after: int, total: int, title: String, font: Font, reduced_motion: bool) -> void:
	_before = clampi(before, 0, total)
	_after = clampi(after, _before, total)
	_total = total
	_title = title
	_font = font
	_reduced = reduced_motion
	_time = 0.0
	_done = false
	_sparks.clear()
	_landed.clear()
	for i in total:
		_landed.append(i < _before)
	show()
	set_process(true)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_finish()


func _arrival(index: int) -> float:
	# Fresh stars land 0.55 s apart, after a short beat for the ribbon to open.
	return 0.45 + 0.55 * float(index - _before)


func _process(delta: float) -> void:
	_time += delta
	for i in range(_before, _after):
		if not _landed[i] and _time >= _arrival(i) + 0.22:
			_landed[i] = true
			star_landed.emit(i, true)
			_burst(_centre(i))
	for spark in _sparks:
		spark.age += delta
		spark.at += spark.vel * delta
		spark.vel.y += 420.0 * delta
	_sparks = _sparks.filter(func(spark): return spark.age < spark.life)
	var hold := _arrival(_after) + 1.4 if _after > _before else 1.6
	if _time > hold:
		_finish()
	queue_redraw()


func _finish() -> void:
	if _done:
		return
	_done = true
	set_process(false)
	if _reduced:
		hide()
		finished.emit()
		return
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_callback(func():
		hide()
		modulate.a = 1.0
		finished.emit())


func _centre(index: int) -> Vector2:
	var width := _total * SIZE + (_total - 1) * GAP
	return Vector2(size.x * 0.5 - width * 0.5 + SIZE * 0.5 + index * (SIZE + GAP), size.y * 0.5 + 10.0)


func _burst(at: Vector2) -> void:
	if _reduced:
		return
	for k in 26:
		var angle := TAU * float(k) / 26.0 + randf() * 0.2
		var speed := 220.0 + randf() * 260.0
		_sparks.append({"at": at, "vel": Vector2.from_angle(angle) * speed + Vector2(0, -120), "age": 0.0, "life": 0.6 + randf() * 0.5, "colour": [GOLD, Color("fff3c4"), Color("f28c28")][k % 3]})


func _draw() -> void:
	var opening := clampf(_time / 0.3, 0.0, 1.0) if not _reduced else 1.0
	# Dim the stage and lay a ribbon across it.
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.03, 0.08, 0.55 * opening))
	var ribbon := Rect2(0, size.y * 0.5 - 140.0 * opening, size.x, 280.0 * opening)
	draw_rect(ribbon, Color(INK, 0.92))
	draw_line(ribbon.position, ribbon.position + Vector2(size.x, 0), GOLD, 4)
	draw_line(ribbon.end - Vector2(size.x, 0), ribbon.end, GOLD, 4)
	if opening < 1.0:
		return
	if _font != null:
		var text_size := _font.get_string_size(_title, HORIZONTAL_ALIGNMENT_CENTER, -1, 44)
		draw_string_outline(_font, Vector2(size.x * 0.5 - text_size.x * 0.5, size.y * 0.5 - 92), _title, HORIZONTAL_ALIGNMENT_LEFT, -1, 44, 8, INK)
		draw_string(_font, Vector2(size.x * 0.5 - text_size.x * 0.5, size.y * 0.5 - 92), _title, HORIZONTAL_ALIGNMENT_LEFT, -1, 44, GOLD)
	for i in _total:
		var centre := _centre(i)
		var scale := 1.0
		var spin := 0.0
		var lit := i < _before
		if i >= _before and i < _after:
			var t := _time - _arrival(i)
			if t < 0.0:
				lit = false
			elif _reduced:
				lit = true
			else:
				lit = true
				# Drop in from above, overshoot, settle; a half spin on the way.
				var k := clampf(t / 0.22, 0.0, 1.0)
				centre.y -= (1.0 - k) * (1.0 - k) * 220.0
				scale = lerpf(0.3, 1.0, k) if t < 0.22 else 1.0 + 0.35 * exp(-(t - 0.22) * 9.0) * cos((t - 0.22) * 22.0)
				spin = (1.0 - k) * PI
		var tex := _on if lit else _off
		if lit:
			var glow := 0.5 + 0.2 * sin(_time * 5.0 + i)
			draw_circle(centre, SIZE * 0.62 * scale, Color(GOLD, 0.18 * glow))
		draw_set_transform(centre, spin, Vector2.ONE * scale)
		draw_texture_rect(tex, Rect2(-Vector2.ONE * SIZE * 0.5, Vector2.ONE * SIZE), false)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if i >= _before and i < _after and _landed[i] and _font != null:
			draw_string(_font, centre + Vector2(-26, SIZE * 0.62), "NEW!", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("ff8a5c"))
	for spark in _sparks:
		var fade: float = 1.0 - float(spark.age) / float(spark.life)
		draw_circle(spark.at, 3.0 + 3.0 * fade, Color(spark.colour, fade))
	if _font != null:
		var hint := "%d of %d bulbs lit" % [_after, _total]
		var hint_size := _font.get_string_size(hint, HORIZONTAL_ALIGNMENT_CENTER, -1, 20)
		draw_string(_font, Vector2(size.x * 0.5 - hint_size.x * 0.5, size.y * 0.5 + 118), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("f2e8cf"))
