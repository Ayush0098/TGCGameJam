extends Control
## Presentation owns visuals only; lighting and recorded worlds own puzzle truth.

signal spotlight_moved(index: int, centre: int)
signal lantern_moved(index: int, position: Vector2, enabled: bool)
signal thought_swapped(first: String, second: String)
signal preview_requested(first: String, second: String)
signal preview_cleared()

const INK := Color("243043")
const PAPER := Color("f0eee5")
const MEMORY := Color("a2adbd")
const DARK := Color("18243a")
const COLOURS := {"HUNGRY": Color("db8738"), "SLEEPY": Color("5684ba"), "ANGRY": Color("cb5757"), "SCARED": Color("9475b9")}
const FACES := {"HUNGRY": "hungry", "SLEEPY": "sleepy", "ANGRY": "angry", "SCARED": "frightened"}
const LIGHTING = preload("res://core/lighting.gd")
const ACTOR = preload("res://scenes/character_actor.tscn")
const ROOM_SHADER = preload("res://presentation/room_light.gdshader")
const LOGICAL_SIZE := Vector2(1280, 460)
const SAMPLE_Y := 318.0
const FLOOR_Y := 404.0
var _page: Dictionary = {}
var _world: Dictionary = {}
var _plan: Dictionary = {}
var _knowledge: Dictionary = {}
var _decisions: Array = []
var _preview: Dictionary = {}
var _preview_decisions: Array = []
var _visual_positions: Dictionary = {}
var _planning := false
var _bubble_rects: Dictionary = {}
var _actor_rects: Dictionary = {}
var _bulb_rects: Array[Rect2] = []
var _drag_bubble := ""
var _drag_bulb := -1
var _drag_in_tray := false
var _target := ""
var _mouse := Vector2.ZERO
var _selected_lantern := 0
var _shade_key := ""
var _shade: ImageTexture
var _mask_image: Image
var _mask_from: Image
var _shade_from: ImageTexture
var _blend := 1.0
var _reduced_motion := false
var _playback_speed := 1.0
var _mask_update_us := 0
var _art := false
var _root: Node2D
var _room: ColorRect
var _props: PropLayer
var _rigs: Dictionary = {}
var _prop_sprites: Dictionary = {}
var _actions: Dictionary = {}
var _textures: Dictionary = {}
var _effects: Array[Dictionary] = []
var _manifest: Dictionary = {}

class PropLayer extends Node2D:
	var stage: Control
	func _draw() -> void:
		stage._draw_props(self)

func _ready() -> void:
	clip_contents = true
	z_index = 100
	focus_mode = Control.FOCUS_ALL
	_manifest = JSON.parse_string(FileAccess.get_file_as_string("res://assets/stage_manifest.json"))
	_root = Node2D.new()
	add_child(_root)
	_room = ColorRect.new()
	_room.size = LOGICAL_SIZE
	_room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_room.z_index = -60
	var material := ShaderMaterial.new()
	material.shader = ROOM_SHADER
	material.set_shader_parameter("painting", load(_manifest.background.texture))
	_room.material = material
	_root.add_child(_room)
	_props = PropLayer.new()
	_props.stage = self
	_props.z_index = -45
	_root.add_child(_props)
	for key in _manifest.props:
		_textures[key] = load(_manifest.props[key])
	for key in _manifest.thoughts:
		_textures[key.to_upper()] = load(_manifest.thoughts[key])
	resized.connect(_layout)
	get_window().focus_exited.connect(_cancel_drag)
	_layout()

func _fit() -> float:
	return maxf(0.0001, minf(size.x / LOGICAL_SIZE.x, size.y / LOGICAL_SIZE.y))

func _offset() -> Vector2:
	return (size - LOGICAL_SIZE * _fit()) * 0.5

func to_stage(local_point: Vector2) -> Vector2:
	return (local_point - _offset()) / _fit()

func stage_to_local(point: Vector2) -> Vector2:
	return _offset() + point * _fit()

func world_to_stage(point: Vector2) -> Vector2:
	return Vector2(_x(point.x), SAMPLE_Y + point.y * _spacing())

func stage_to_world(point: Vector2) -> Vector2:
	return Vector2((point.x - 90.0) / _spacing(), (point.y - SAMPLE_Y) / _spacing())

func _layout() -> void:
	if is_instance_valid(_root):
		_root.position = _offset()
		_root.scale = Vector2.ONE * _fit()
	queue_redraw()

func _cancel_drag() -> void:
	_drag_bubble = ""
	_drag_bulb = -1
	_drag_in_tray = false
	_target = ""
	preview_cleared.emit()
	clear_preview()

func configure(page: Dictionary) -> void:
	cancel_presentation()
	_page = page.duplicate(true)
	_shade_key = ""
	_mask_image = null
	_mask_from = null
	_shade = null
	_shade_from = null
	_selected_lantern = 0
	_art = page.get("id", "") == "page_02"
	for rig in _rigs.values():
		_root.remove_child(rig)
		rig.queue_free()
	_rigs.clear()
	_actions.clear()
	for sprite in _prop_sprites.values():
		_props.remove_child(sprite)
		sprite.queue_free()
	_prop_sprites.clear()
	if _art:
		for record in page.characters:
			var rig = ACTOR.instantiate()
			rig.z_index = -40
			_root.add_child(rig)
			rig.configure(record.art)
			_rigs[record.id] = rig
		for record in page.objects:
			var sprite := Sprite2D.new()
			sprite.centered = false
			var light_material := ShaderMaterial.new()
			light_material.shader = preload("res://presentation/actor_light.gdshader")
			sprite.material = light_material
			_props.add_child(sprite)
			_prop_sprites[record.id] = sprite
	_room.visible = _art
	_props.visible = _art
	clear_preview()

func pose(world: Dictionary, plan: Dictionary, knowledge: Dictionary, planning: bool, decisions: Array = [], visual_positions: Dictionary = {}) -> void:
	_world = world.duplicate(true)
	_plan = plan.duplicate(true)
	_knowledge = knowledge.duplicate(true)
	_planning = planning
	_decisions = decisions.duplicate(true)
	_visual_positions = visual_positions.duplicate()
	if not planning:
		_drag_bubble = ""
		_drag_bulb = -1
		_target = ""
		_preview.clear()
	_update_visuals()

func set_preview(world: Dictionary, decisions: Array = []) -> void:
	_preview = world.duplicate(true)
	_preview_decisions = decisions.duplicate(true)
	_update_visuals()

func clear_preview() -> void:
	_preview.clear()
	_preview_decisions.clear()
	_update_visuals()

func _shown() -> Dictionary:
	return _preview if not _preview.is_empty() else _world

func _x(slot: float) -> float:
	return 90.0 + slot * _spacing()

func _spacing() -> float:
	return 1100.0 / maxf(1.0, float(_page.get("width", 11)) - 1.0)

func _light_position(light: Dictionary) -> Vector2:
	return world_to_stage(Vector2(light.x, light.y))

func _world_position(at: Vector2) -> Vector2:
	return stage_to_world(at)

func _lit(slot: float, world: Dictionary) -> bool:
	return LIGHTING.is_lit(_page, _plan, world, slot)

func revealed_thought_ids() -> Array[String]:
	var result: Array[String] = []
	var world := _shown()
	for actor in world.get("characters", []):
		if actor.get("status", "READY") == "READY" and _lit(float(actor.slot), world):
			result.append(str(actor.id))
	return result

func _update_visuals() -> void:
	if not is_instance_valid(_root) or _page.is_empty() or _world.is_empty():
		queue_redraw()
		return
	var world := _shown()
	_update_mask(world)
	var stack: Dictionary = {}
	for record in world.characters:
		if not _rigs.has(record.id):
			continue
		var rig = _rigs[record.id]
		var index := int(stack.get(record.slot, 0))
		stack[record.slot] = index + 1
		rig.visible = record.status != "EXITED"
		rig.position = _actor_position(record, index)
		var amount: float = _manifest.characters[record.art].scale
		var facing := -1.0 if record.get("facing", "R") == "L" else 1.0
		if _visual_positions.has(record.id):
			var movement: float = float(_visual_positions[record.id]) - float(record.slot)
			if absf(movement) > 0.001:
					facing = signf(movement)
		rig.scale = Vector2(amount * facing, amount)
		var lit := _lit(record.slot, world)
		rig.set_lit(lit)
		if _planning:
			var expression: String = FACES.get(record.thought, "neutral") if lit else "neutral"
			if _actions.get(record.id, "") != "plan_" + expression:
				rig.stop()
				rig.set_plan_expression(expression)
				if not _reduced_motion:
					rig.animation_player.play("idle")
				_actions[record.id] = "plan_" + expression
		elif record.status != "READY":
			if _actions.get(record.id, "") not in ["eat", "sit", "bonk", "rest"]:
				rig.show_terminal(record.status)
				_actions[record.id] = "rest"
		elif _actions.get(record.id, "") in ["walk", "run"] and not _visual_positions.has(record.id):
			_play(record.id, "idle")
		elif _actions.get(record.id, "").is_empty():
			_play(record.id, "idle")
	for object in world.get("objects", []):
		if not _prop_sprites.has(object.id):
			continue
		var key := str(object.art)
		if key == "cake" and not object.get("present", true):
			key = "cake_empty"
		var sprite: Sprite2D = _prop_sprites[object.id]
		sprite.texture = _textures[key]
		sprite.position = Vector2(_x(object.slot) - sprite.texture.get_width() * 0.5, FLOOR_Y - sprite.texture.get_height())
		sprite.material.set_shader_parameter("lit", 1.0 if _lit(object.slot, world) else 0.0)
	_props.queue_redraw()
	queue_redraw()

func _actor_position(record: Dictionary, stack: int = 0) -> Vector2:
	return Vector2(_x(float(_visual_positions.get(record.id, record.slot))) + stack * 22, FLOOR_Y - stack * 12)

func _update_mask(world: Dictionary) -> void:
	var lights: Array = []
	for lamp in world.get("lamps", []):
		lights.append([lamp.get("id", ""), lamp.get("zone", []), lamp.get("on", false)])
	var key := str([_page.get("width"), _page.get("fixed_lights", []), _page.get("obstacles", []), _page.get("lanterns", {}), _plan.get("lanterns", []), _plan.get("centres", []), lights])
	if key == _shade_key:
		return
	var start := Time.get_ticks_usec()
	var spacing := _spacing()
	var world_y := PackedFloat64Array()
	for y in range(46):
		world_y.append(((y + 0.5) * 10.0 - SAMPLE_Y) / spacing)
	var sources: Array[Vector2] = []
	for lantern in _plan.get("lanterns", []):
		if lantern.get("enabled", false):
			sources.append(Vector2(lantern.x, lantern.y))
	var outer_radius := LIGHTING.radius(_page) * LIGHTING.HALO_SCALE
	var outer_radius_squared := outer_radius * outer_radius
	var radial: bool = _page.has("lanterns") and not _plan.get("lanterns", []).is_empty()
	var blank := Image.create(128, 46, false, Image.FORMAT_RGBA8)
	blank.fill(Color(0, 0, 0, 1))
	var pixels := blank.get_data()
	for x in range(128):
		var world_x := ((x + 0.5) * 10.0 - 90.0) / spacing
		# Authored zones cover a complete column. Skip only points which no
		# lantern can reach; every potentially illuminated point still uses
		# the shared intensity calculation, including obstacle occlusion.
		var column_lit := LIGHTING._zone_lit(_page, world, world_x, 0.45)
		if column_lit:
			for y in range(46):
				pixels.encode_u32((y * 128 + x) * 4, 0xffffffff)
			continue
		var column_sources: Array[Vector2] = []
		for source in sources:
			var dx_squared := (world_x - source.x) * (world_x - source.x)
			if dx_squared < outer_radius_squared:
				column_sources.append(Vector2(source.y, dx_squared))
		if radial and column_sources.is_empty():
			continue
		var legacy_value := LIGHTING.intensity(_page, _plan, world, Vector2(world_x, 0.0)) if not radial else 0.0
		var first_row := 0 if not radial else 46
		var last_row := 45 if not radial else -1
		for source in column_sources:
			var extent := sqrt(maxf(0.0, outer_radius_squared - source.y))
			# Include a neighbouring row on both sides to keep conservative
			# bounds despite float conversion; the authority returns zero there.
			first_row = mini(first_row, maxi(0, int(floor(((source.x - extent) * spacing + SAMPLE_Y - 5.0) / 10.0)) - 1))
			last_row = maxi(last_row, mini(45, int(ceil(((source.x + extent) * spacing + SAMPLE_Y - 5.0) / 10.0)) + 1))
		for y in range(first_row, last_row + 1):
			var value := legacy_value
			if radial:
				value = LIGHTING.lantern_intensity(_page, _plan, Vector2(world_x, world_y[y]), outer_radius)
			var grey := clampi(int(value * 255.0), 0, 255)
			pixels.encode_u32((y * 128 + x) * 4, 0xff000000 | (grey * 0x010101))
	var raster := Image.create_from_data(128, 46, false, Image.FORMAT_RGBA8, pixels)
	# A cancelled/interrupted transition resumes from its currently displayed mask.
	var from_image: Image = _mask_image
	if _mask_image != null and _blend < 1.0:
		from_image = _mask_from.duplicate()
		for y in range(46):
			for x in range(128):
				from_image.set_pixel(x, y, _mask_from.get_pixel(x, y).lerp(_mask_image.get_pixel(x, y), _blend))
	_mask_from = raster if from_image == null else from_image
	_mask_image = raster
	_shade_from = ImageTexture.create_from_image(_mask_from)
	_shade = ImageTexture.create_from_image(raster)
	_blend = 1.0 if _planning or _reduced_motion or from_image == null else 0.0
	_shade_key = key
	_room.material.set_shader_parameter("previous_mask", _shade_from)
	_room.material.set_shader_parameter("light_mask", _shade)
	_room.material.set_shader_parameter("blend", _blend)
	_mask_update_us = Time.get_ticks_usec() - start

func set_reduced_motion(enabled: bool) -> void:
	_reduced_motion = enabled
	if enabled:
		cancel_presentation()
		for rig in _rigs.values():
			rig.stop()
	_update_visuals()

func set_playback_speed(speed: float) -> void:
	_playback_speed = speed
	for rig in _rigs.values():
		rig.animation_player.speed_scale = speed * 2.0

func cancel_presentation() -> void:
	_drag_bubble = ""
	_drag_bulb = -1
	_target = ""
	_effects.clear()
	_blend = 1.0
	if is_instance_valid(_room):
		_room.material.set_shader_parameter("blend", 1.0)
	for rig in _rigs.values():
		rig.stop()
	_actions.clear()
	_visual_positions.clear()
	queue_redraw()

func _play(id: String, action: String) -> void:
	if _rigs.has(id):
		_rigs[id].play_action(action, _playback_speed * 2.0, _reduced_motion)
		_actions[id] = action

func present_events(events: Array, speed: float = 1.0, reduced_motion: bool = false) -> void:
	_playback_speed = speed
	_reduced_motion = reduced_motion
	var actions := {"MOVE": "walk", "FLEE": "run", "STARTLE": "startle", "EAT": "eat", "SIT": "sit", "BONK": "bonk", "EXIT": "exit"}
	var words := {"DING": "DING!", "STARTLE": "EEK!", "EAT": "CHOMP!", "SIT": "Zzz", "BONK": "BONK!", "CLASH": "CLONK!", "EXIT": "ZOOM!", "LAMP_ON": "CLICK!", "WHIFF": "WHIFF!"}
	for event in events:
		var id := str(event.get("actor", ""))
		if actions.has(event.type):
			var action: String = actions[event.type]
			if event.type == "MOVE":
				for record in _world.get("characters", []):
					if record.id == id and record.thought == "SCARED":
						action = "run"
			_play(id, action)
		if event.type == "BONK":
			_play(str(event.get("target", "")), "ko")
		if words.has(event.type):
			var slot := float(event.get("to", 4))
			for record in _world.get("characters", []):
				if record.id == id:
					slot = record.slot
			if event.type == "LAMP_ON":
				for lamp in _world.get("lamps", []):
					if lamp.id == event.get("object", ""):
						for object in _world.get("objects", []):
							if object.id == lamp.switch_id:
								slot = object.slot
			_effects.append({"text": words[event.type], "at": Vector2(clampf(_x(slot), 75, 1205), 255), "age": 0.0, "colour": COLOURS.get("HUNGRY" if event.type == "EAT" else "ANGRY", Color("edce76"))})
	queue_redraw()

func _process(delta: float) -> void:
	if _blend < 1.0:
		_blend = minf(1.0, _blend + delta * _playback_speed / 0.3)
		_room.material.set_shader_parameter("blend", _blend)
	for effect in _effects:
		effect.age += delta * _playback_speed
	_effects = _effects.filter(func(effect): return effect.age < 0.65)
	for id in _actions.keys():
		if _actions[id] in ["eat", "sit", "bonk", "startle"] and not _rigs[id].animation_player.is_playing():
			_actions[id] = ""
			_update_visuals()
	if not _effects.is_empty():
		queue_redraw()

func _label(canvas: CanvasItem, at: Vector2, value: String, colour: Color = INK, font_size: int = 18) -> void:
	canvas.draw_string(ThemeDB.fallback_font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, colour)

func _draw_props(canvas: CanvasItem) -> void:
	var world := _shown()
	for actor in world.get("characters", []):
		if actor.status != "EXITED":
			var at := _actor_position(actor)
			canvas.draw_set_transform(at + Vector2(0, -2), 0, Vector2(1, 0.18))
			canvas.draw_circle(Vector2.ZERO, 28, Color(0.06, 0.06, 0.1, 0.25))
			canvas.draw_set_transform(Vector2.ZERO)
	for zone in _page.get("fixed_lights", []):
		var at := Vector2(_x((float(zone[0]) + float(zone[1])) * 0.5), 50)
		canvas.draw_line(Vector2(at.x, 0), at, Color("524b51"), 3, true)
		canvas.draw_texture(_textures.fixture, at - Vector2(34, 0))

func _positions(world: Dictionary) -> Dictionary:
	var positions: Dictionary = {}
	var stack: Dictionary = {}
	for actor in world.get("characters", []):
		var index := int(stack.get(actor.slot, 0))
		stack[actor.slot] = index + 1
		positions[actor.id] = _actor_position(actor, index)
	return positions

func _bubble_layout(world: Dictionary, positions: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var ordered: Array = world.get("characters", []).duplicate()
	ordered.sort_custom(func(a, b): return str(a.id) < str(b.id))
	for actor in ordered:
		if actor.status != "READY" or not _lit(actor.slot, world):
			continue
		var at: Vector2 = positions[actor.id]
		var height := 168.0 if actor.get("art", "") != "dog" else 100.0
		var origin := Vector2(clampf(at.x - 48, 10, 1174), maxf(70, at.y - height - 83 - (36 if int(actor.slot) % 2 == 0 else 0)))
		var candidates: Array[Vector2] = [origin]
		for row in [80.0, 150.0, 220.0]:
			for shift in [0.0, -108.0, 108.0, -216.0, 216.0, -324.0, 324.0]:
				candidates.append(Vector2(clampf(origin.x + shift, 10, 1174), row))
		for candidate in candidates:
			var rect := Rect2(candidate, Vector2(96, 64))
			var blocked := false
			for existing in result.values():
				if existing.grow(4).intersects(rect):
					blocked = true
			for other in ordered:
				if other.status == "EXITED":
					continue
				var head: Vector2 = positions[other.id] - Vector2(0, 150 if other.get("art", "") != "dog" else 85)
				if Rect2(head - Vector2(34, 24), Vector2(68, 48)).intersects(rect):
					blocked = true
			if not blocked:
				result[actor.id] = rect
				break
	return result

func _draw() -> void:
	if size.x <= 0 or size.y <= 0 or _page.is_empty():
		return
	draw_set_transform(_offset(), 0, Vector2.ONE * _fit())
	var world := _shown()
	var positions := _positions(world)
	_bubble_rects.clear()
	_actor_rects.clear()
	_bulb_rects.clear()
	if not _art:
		draw_rect(Rect2(Vector2.ZERO, LOGICAL_SIZE), PAPER)
		_label(self, Vector2(20, 32), "WORK IN PROGRESS / " + str(_page.title), INK, 16)
		for actor in world.get("characters", []):
			if actor.status == "EXITED":
				continue
			var at: Vector2 = positions[actor.id]
			var tint := Color("a9afb8") if _lit(actor.slot, world) else Color("53617b")
			draw_circle(at - Vector2(0, 135), 19, tint)
			draw_rect(Rect2(at - Vector2(22, 110), Vector2(44, 110)), tint)
			_label(self, at - Vector2(30, 5), str(actor.art).capitalize(), PAPER if not _lit(actor.slot, world) else INK, 16)
		for object in world.get("objects", []):
			var at := Vector2(_x(object.slot), FLOOR_Y - 32)
			draw_rect(Rect2(at - Vector2(27, 20), Vector2(54, 40)), Color("b0a496") if object.present else Color("847e79"), object.present)
			_label(self, at + Vector2(-30, 24), str(object.art).replace("_", " "), INK, 14)
	for obstacle in _page.get("obstacles", []):
		var start := world_to_stage(Vector2(obstacle.from[0], obstacle.from[1]))
		var end := world_to_stage(Vector2(obstacle.to[0], obstacle.to[1]))
		draw_line(start, end, Color("b3ada0"), 9, true)
		draw_line(start, end, INK, 2, true)
	for lamp in world.get("lamps", []):
		var centre := Vector2(_x((float(lamp.zone[0]) + float(lamp.zone[1])) * 0.5), 65)
		if lamp.on:
			draw_colored_polygon(PackedVector2Array([centre, Vector2(_x(lamp.zone[0]) - _spacing() * 0.45, FLOOR_Y), Vector2(_x(lamp.zone[1]) + _spacing() * 0.45, FLOOR_Y)]), Color(1, 0.86, 0.55, 0.055))
		draw_circle(centre, 10, Color("efce66") if lamp.on else Color("687489"))
		for object in world.get("objects", []):
			if object.id == lamp.switch_id:
				draw_polyline(PackedVector2Array([Vector2(_x(object.slot), FLOOR_Y), Vector2(_x(object.slot), FLOOR_Y + 5), Vector2(centre.x, FLOOR_Y + 5), centre]), Color("7f8e9e"), 2, true)
	_draw_lanterns()
	var decisions: Array = _preview_decisions if not _preview.is_empty() else _decisions
	if _planning:
		for decision in decisions:
			if not positions.has(decision.actor):
				continue
			for actor in world.get("characters", []):
				if actor.id == decision.actor and _lit(actor.slot, world):
					var step := int(decision.get("step", 0))
					if step != 0:
						draw_circle(Vector2(_x(actor.slot + step), FLOOR_Y + 4), 5, Color("c68b3f"))
					_label(self, positions[actor.id] + Vector2(-25, 25), str(decision.type).to_lower() + (" >" if step > 0 else (" <" if step < 0 else "")), MEMORY, 15)
	var bubbles := _bubble_layout(world, positions)
	for actor in world.get("characters", []):
		if actor.status == "EXITED":
			continue
		var at: Vector2 = positions[actor.id]
		if not _planning and actor.active:
			draw_circle(at - Vector2(0, 180 if actor.art != "dog" else 113), 5, Color("efd17a"))
		if not bubbles.has(actor.id):
			continue
		var rect: Rect2 = bubbles[actor.id]
		var colour: Color = COLOURS.get(actor.thought, MEMORY)
		draw_line(rect.position + Vector2(48, 64), at - Vector2(0, 164 if actor.art != "dog" else 94), colour, 2, true)
		draw_style_box(_bubble_style(colour), rect)
		if _textures.has(actor.thought):
			draw_texture_rect(_textures[actor.thought], Rect2(rect.position + Vector2(32, 4), Vector2(32, 32)), false)
		var label_width := ThemeDB.fallback_font.get_string_size(actor.thought, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
		_label(self, rect.position + Vector2((96 - label_width) / 2, 54), actor.thought, colour, 16)
		if _planning:
			_bubble_rects[actor.id] = rect
			_actor_rects[actor.id] = Rect2(at - Vector2(42, 168 if actor.art != "dog" else 100), Vector2(84, 168 if actor.art != "dog" else 100))
		if actor.id == _target:
			draw_rect(rect.grow(5), Color("42a88c"), false, 3)
	for effect in _effects:
		var offset := Vector2(0, 0 if _reduced_motion else -effect.age * 18)
		var at: Vector2 = effect.at + offset
		var alpha := minf(1, (0.65 - effect.age) * 5)
		_label(self, at + Vector2(-39, 2), effect.text, Color(INK, alpha), 31)
		_label(self, at + Vector2(-41, 0), effect.text, Color(effect.colour, alpha), 31)
	if _drag_bubble != "":
		draw_circle(_mouse, 18, Color(1, 0.85, 0.3, 0.7))
	draw_rect(Rect2(3, 3, 1274, 454), INK, false, 6)

func _bubble_style(colour: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PAPER
	style.border_color = colour
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	return style

func _draw_lanterns() -> void:
	var bounds: Array = _page.get("lanterns", {}).get("bounds", [0, -1.2, _page.get("width", 11) - 1, 0.6])
	if _planning:
		var first := world_to_stage(Vector2(bounds[0], bounds[1]))
		var last := world_to_stage(Vector2(bounds[2], bounds[3]))
		draw_rect(Rect2(first, last - first), Color(0.80, 0.57, 0.23, 0.20), false, 1.0)
	for index in _plan.get("lanterns", []).size():
		var light: Dictionary = _plan.lanterns[index]
		if not light.enabled:
			_bulb_rects.append(Rect2())
			continue
		var at := _light_position(light)
		var opacity := 1.0 if _planning else 0.3
		for segment in range(48):
			draw_arc(at, LIGHTING.radius(_page) * _spacing(), TAU * segment / 48.0, TAU * (segment + 0.55) / 48.0, 3, Color(0.97, 0.78, 0.33, opacity * 0.7), 1.5, true)
		draw_line(Vector2(at.x, 6), at - Vector2(0, 22), Color(0.35, 0.32, 0.32, opacity), 2, true)
		draw_texture(_textures.lantern, at - Vector2(20, 26), Color(1, 1, 1, opacity))
		_label(self, at + Vector2(-5, 4), str(index + 1), INK, 15)
		if _planning and index == _selected_lantern:
			draw_arc(at, 27, 0, TAU, 32, Color("d8b575"), 2, true)
		_bulb_rects.append(Rect2(at - Vector2(25, 27), Vector2(50, 54)))

func _move_selected(position: Vector2, enabled: bool = true) -> void:
	var bounds: Array = _page.lanterns.bounds
	var clamped := Vector2(clampf(position.x, bounds[0], bounds[2]), clampf(position.y, bounds[1], bounds[3]))
	# Quantization limits jitter and gives exact, reproducible saved placements.
	clamped = clamped.snapped(Vector2(0.01, 0.01))
	clamped.x = clampf(clamped.x, bounds[0], bounds[2])
	clamped.y = clampf(clamped.y, bounds[1], bounds[3])
	lantern_moved.emit(_selected_lantern, clamped, enabled)


func _gui_input(event: InputEvent) -> void:
	if not _planning or _page.is_empty():
		return
	if event is InputEventMouse:
		_mouse = to_stage(event.position)
	if event is InputEventKey and event.pressed:
		if _drag_bulb >= 0 or not _drag_bubble.is_empty():
			# A pointer gesture owns its selected piece until release/cancellation.
			accept_event()
			return
		if event.keycode in [KEY_1, KEY_2]:
			_selected_lantern = 0 if event.keycode == KEY_1 else 1
		elif event.keycode in [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN, KEY_P]:
			var light: Dictionary = _plan.lanterns[_selected_lantern]
			var at := Vector2(light.x, light.y)
			var step := 0.1 if event.shift_pressed else 0.25
			match event.keycode:
				KEY_LEFT: at.x -= step
				KEY_RIGHT: at.x += step
				KEY_UP: at.y -= step
				KEY_DOWN: at.y += step
			_move_selected(at, not light.enabled if event.keycode == KEY_P else true)
		else:
			return
		accept_event()
		queue_redraw()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			grab_focus()
			for id in _bubble_rects:
				if _bubble_rects[id].has_point(_mouse):
					_drag_bubble = id
					accept_event()
					return
			for index in range(_bulb_rects.size()):
				if _bulb_rects[index].has_point(_mouse):
					_drag_bulb = index
					_selected_lantern = index
					accept_event()
					return
		else:
			if _drag_bubble != "" and _target != "":
				thought_swapped.emit(_drag_bubble, _target)
			_drag_bubble = ""
			_drag_bulb = -1
			_target = ""
			preview_cleared.emit()
			clear_preview()
			queue_redraw()
	elif event is InputEventMouseMotion:
		if _drag_bulb >= 0:
			_move_selected(_world_position(_mouse))
		elif _drag_bubble != "":
			var next_target := ""
			for id in _bubble_rects:
				if id != _drag_bubble and (_bubble_rects[id].has_point(_mouse) or _actor_rects[id].has_point(_mouse)):
					next_target = id
			if next_target != _target:
				_target = next_target
				if _target == "":
					preview_cleared.emit()
					clear_preview()
				else:
					preview_requested.emit(_drag_bubble, _target)
		queue_redraw()
