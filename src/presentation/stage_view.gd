extends Control
## Presentation owns visuals only; lighting and recorded worlds own puzzle truth.

signal spotlight_moved(index: int, centre: int)
signal lantern_moved(index: int, position: Vector2, enabled: bool)
signal thought_swapped(first: String, second: String)
signal preview_requested(first: String, second: String)
signal preview_cleared()
signal actor_revealed(id: String, thought: String)
signal actor_poked(id: String, kind: String)
signal flick_cleared()

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
const TEXT_FONT = preload("res://assets/fonts/ComicNeue-Bold.ttf")
const WORD_FONT = preload("res://assets/fonts/Bangers-Regular.ttf")
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
# Living light: additive glow pools, flicker, dust motes and lamp cones. They are
# decoration inside the mask's lit area and never change who is lit.
var _glow: GlowLayer
var _glow_texture: Texture2D
var _rigs: Dictionary = {}
var _prop_sprites: Dictionary = {}
var _actions: Dictionary = {}
var _textures: Dictionary = {}
var _effects: Array[Dictionary] = []
# Bulby: the lantern bulb is the player's face. Mood is presentation only.
var _bulb_mood := "idle"
var _mood_after := "idle"
var _mood_left := 0.0
var _bulb_clock := 0.0
var _look := Vector2.ZERO
var _lit_last: Dictionary = {}
## Walking direction per actor this beat (set by playback), for stable facing.
var motion_headings: Dictionary = {}
var _last_moved: Dictionary = {}
var _stack_shown: Dictionary = {}
var _stack_time: Dictionary = {}
# FLICK: aiming during ACTION, and the ghost of a kept flick during PLAN.
var _flick_ready := false
var _aim_slot := -1
var _flick_ghost_rect := Rect2()
# Comic juice: screen shake (trauma 0..1, decays) applied to the panel root only.
var _trauma := 0.0
var _shake_time := 0.0
const EFFECT_LIFE := 0.85
const WORD_COLOURS := {"DING": Color("ffd27a"), "EAT": Color("f28c28"), "BONK": Color("d7263d"), "CLASH": Color("d7263d"), "STARTLE": Color("8e5cc9"), "EXIT": Color("8e5cc9"), "SIT": Color("4a90d9"), "LAMP_ON": Color("f2e8cf"), "WHIFF": Color("f2e8cf")}
const WORD_TRAUMA := {"BONK": 0.5, "CLASH": 0.55, "EXIT": 0.4, "EAT": 0.22, "STARTLE": 0.12}
var _manifest: Dictionary = {}

class GlowLayer extends Node2D:
	var stage: Control
	func _draw() -> void:
		stage._draw_glow(self)

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
	_glow = GlowLayer.new()
	_glow.stage = self
	_glow.z_index = -50
	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow.material = additive
	_root.add_child(_glow)
	_glow_texture = _radial_texture()
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
	_lit_last.clear()
	_spark_start.clear()
	# Illustrated whenever every cast member and prop has production art.
	_art = page.get("characters", []).all(func(record): return _manifest.characters.has(str(record.art))) 		and page.get("objects", []).all(func(record): return _textures.has(str(record.art)))
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
	# Each page names its room; a room without a painting yet uses the living room.
	var painting: String = _manifest.background.texture
	var room_path: String = _manifest.get("rooms", {}).get(str(page.get("room", "")), "")
	if not room_path.is_empty() and ResourceLoader.exists(room_path):
		painting = room_path
	_room.material.set_shader_parameter("painting", load(painting))
	_room.visible = _art
	_glow.visible = _art
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
		# Shared-slot staggering eases in and out instead of popping 22 px.
		var target_stack := float(index)
		var shown_stack: float = _stack_shown.get(record.id, target_stack)
		var since: float = _bulb_clock - float(_stack_time.get(record.id, _bulb_clock))
		_stack_time[record.id] = _bulb_clock
		shown_stack = target_stack if _reduced_motion or _planning else lerpf(shown_stack, target_stack, clampf(since * 6.0, 0.0, 1.0))
		if absf(shown_stack - target_stack) < 0.01:
			shown_stack = target_stack
		_stack_shown[record.id] = shown_stack
		rig.position = _actor_position(record, 0) + Vector2(shown_stack * 22.0, -shown_stack * 12.0)
		var amount: float = _manifest.characters[record.art].scale
		var facing := -1.0 if record.get("facing", "R") == "L" else 1.0
		if motion_headings.has(record.id) and motion_headings[record.id] != 0.0:
			facing = motion_headings[record.id]
		elif _visual_positions.has(record.id):
			var movement: float = float(_visual_positions[record.id]) - float(record.slot)
			if absf(movement) > 0.001:
					facing = signf(movement)
		rig.scale = Vector2(amount * facing, amount)
		var lit := _lit(record.slot, world)
		rig.set_lit(lit)
		if _planning and _preview.is_empty():
			# A newly revealed actor does a take; leaving the light is silent.
			if lit and _lit_last.has(record.id) and not _lit_last[record.id] and record.status == "READY":
				rig.pop()
				actor_revealed.emit(str(record.id), str(record.thought))
			_lit_last[record.id] = lit
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
			# Keep the walk cycle through the short gap between consecutive steps.
			if _bulb_clock - float(_last_moved.get(record.id, -10.0)) > 0.12:
				_play(record.id, "idle")
		if _visual_positions.has(record.id):
			_last_moved[record.id] = _bulb_clock
		elif _actions.get(record.id, "").is_empty():
			_play(record.id, "idle")
	for object in world.get("objects", []):
		if not _prop_sprites.has(object.id):
			continue
		var key := str(object.art)
		if not object.get("present", true) and _textures.has(key + "_empty"):
			key += "_empty"
		for lamp in world.get("lamps", []):
			if lamp.get("switch_id", "") == object.id and lamp.get("on", false) and _textures.has(key + "_down"):
				key += "_down"
		var sprite: Sprite2D = _prop_sprites[object.id]
		sprite.texture = _textures[key]
		sprite.position = Vector2(_x(object.slot) - sprite.texture.get_width() * 0.5, FLOOR_Y - sprite.texture.get_height())
		sprite.material.set_shader_parameter("lit", 1.0 if _lit(object.slot, world) else 0.0)
	_props.queue_redraw()
	if is_instance_valid(_glow):
		_glow.queue_redraw()
	queue_redraw()

func _figure_height(art: String) -> float:
	# Drawn height in stage pixels: human rigs are ~340 px tall at scale 1.
	if art == "dog":
		return 100.0
	return 340.0 * float(_manifest.get("characters", {}).get(art, {}).get("scale", 0.49))

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
	_sayings.clear()
	_bulb_mood = "idle"
	_mood_left = 0.0
	_trauma = 0.0
	if is_instance_valid(_root):
		_root.position = _offset()
	_blend = 1.0
	if is_instance_valid(_room):
		_room.material.set_shader_parameter("blend", 1.0)
	for rig in _rigs.values():
		rig.stop()
	_actions.clear()
	_visual_positions.clear()
	queue_redraw()

func _play(id: String, action: String) -> void:
	# A walk that continues into the next step keeps its cycle (no restart hitch).
	if action in ["walk", "run"] and _actions.get(id, "") == action and _rigs.has(id) and _rigs[id].animation_player.is_playing():
		return
	if _rigs.has(id):
		_rigs[id].play_action(action, _playback_speed * 2.0, _reduced_motion)
		_actions[id] = action

func present_events(events: Array, speed: float = 1.0, reduced_motion: bool = false) -> void:
	_playback_speed = speed
	_reduced_motion = reduced_motion
	var actions := {"MOVE": "walk", "FLEE": "run", "STARTLE": "startle", "EAT": "eat", "SIT": "sit", "BONK": "bonk", "EXIT": "exit"}
	var words := {"FLICK": "FLICK!", "DING": "DING!", "STARTLE": "EEK!", "EAT": "CHOMP!", "SIT": "Zzz", "BONK": "BONK!", "CLASH": "CLONK!", "EXIT": "ZOOM!", "LAMP_ON": "CLICK!", "WHIFF": "WHIFF!"}
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
			var anchor_x := -1.0
			for record in _world.get("characters", []):
				if record.id == id:
					slot = record.slot
					anchor_x = _actor_position(record).x
			if event.type == "LAMP_ON":
				for lamp in _world.get("lamps", []):
					if lamp.id == event.get("object", ""):
						for object in _world.get("objects", []):
							if object.id == lamp.switch_id:
								slot = object.slot
			var height := 255.0
			if event.type == "DING":
				# The idea bulb pops above the head; the word sits a little higher.
				for record in _world.get("characters", []):
					if record.id == id:
						height = FLOOR_Y - _figure_height(str(record.get("art", ""))) - 37.0
			var wobble := float((str(event.type).hash() + int(slot) * 7) % 7 - 3) * 0.05
			_effects.append({"text": words[event.type], "kind": str(event.type), "at": Vector2(clampf(anchor_x if anchor_x >= 0.0 and event.type != "LAMP_ON" else _x(slot), 75, 1205), height), "age": 0.0, "rot": wobble, "colour": WORD_COLOURS.get(event.type, Color("ffd27a"))})
			if not reduced_motion:
				_trauma = minf(1.0, _trauma + float(WORD_TRAUMA.get(event.type, 0.0)))
			_look = Vector2(clampf(_x(slot), 75, 1205), height)
			if event.type in ["BONK", "CLASH", "EXIT"]:
				set_mood("flinch", 0.45)
	queue_redraw()

func _process(delta: float) -> void:
	if _blend < 1.0:
		_blend = minf(1.0, _blend + delta * _playback_speed / 0.3)
		_room.material.set_shader_parameter("blend", _blend)
	_bulb_clock += delta
	if _mood_left > 0.0:
		_mood_left -= delta
		if _mood_left <= 0.0:
			_bulb_mood = _mood_after
	if not _reduced_motion and not _plan.get("lanterns", []).is_empty():
		queue_redraw()
		if is_instance_valid(_props):
			_props.queue_redraw()
		if is_instance_valid(_glow):
			_glow.queue_redraw()
	for effect in _effects:
		effect.age += delta * _playback_speed
	_effects = _effects.filter(func(effect): return effect.age < EFFECT_LIFE)
	for saying in _sayings:
		saying.age += delta * _playback_speed
	_sayings = _sayings.filter(func(saying): return saying.age < float(saying.get("life", 1.0)))
	if _caption_left > 0.0:
		_caption_left -= delta
		if _caption_left <= 0.0:
			_caption_text = ""
			queue_redraw()
	if not _sayings.is_empty():
		queue_redraw()
	if _trauma > 0.0 and is_instance_valid(_root):
		_shake_time += delta
		_trauma = maxf(0.0, _trauma - delta * 1.6)
		var amount := 9.0 * _trauma * _trauma
		_root.position = _offset() + Vector2(sin(_shake_time * 71.0), cos(_shake_time * 53.0)) * amount
		if _trauma == 0.0:
			_root.position = _offset()
		queue_redraw()
	for id in _actions.keys():
		if _actions[id] in ["eat", "sit", "bonk", "startle"] and not _rigs[id].animation_player.is_playing():
			_actions[id] = ""
			_update_visuals()
	if not _effects.is_empty():
		queue_redraw()

func _label(canvas: CanvasItem, at: Vector2, value: String, colour: Color = INK, font_size: int = 18) -> void:
	canvas.draw_string(TEXT_FONT, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, colour)

func _draw_props(canvas: CanvasItem) -> void:
	var world := _shown()
	for actor in world.get("characters", []):
		if actor.status != "EXITED":
			var at := _actor_position(actor)
			canvas.draw_set_transform(at + Vector2(0, -2), 0, Vector2(1, 0.18))
			canvas.draw_circle(Vector2.ZERO, 28, Color(0.06, 0.06, 0.1, 0.25))
			canvas.draw_set_transform(Vector2.ZERO)
	# Bulby hangs behind the cast so a lantern never hides a face.
	for index in _plan.get("lanterns", []).size():
		if _plan.lanterns[index].get("enabled", false):
			_draw_bulby(canvas, index, _light_position(_plan.lanterns[index]))
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
		var height := _figure_height(str(actor.get("art", "")))
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
				var head: Vector2 = positions[other.id] - Vector2(0, _figure_height(str(other.get("art", ""))) - 17.0)
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
		_label(self, Vector2(20, 32), str(_page.title), INK, 16)
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
		_draw_screen(start, end)
	_draw_flick(world)
	for lamp in world.get("lamps", []):
		if lamp.get("id", "") == "flick":
			continue
		var centre := Vector2(_x((float(lamp.zone[0]) + float(lamp.zone[1])) * 0.5), 65)
		if _art and _textures.has("lamp_on"):
			draw_line(Vector2(centre.x, 0), centre - Vector2(0, 30), Color("524b51"), 3, true)
			draw_texture(_textures["lamp_on" if lamp.on else "lamp_off"], centre - Vector2(40, 30))
		else:
			draw_circle(centre, 10, Color("efce66") if lamp.on else Color("687489"))
		for object in world.get("objects", []):
			if object.id == lamp.switch_id:
				var wire := PackedVector2Array([Vector2(_x(object.slot), FLOOR_Y), Vector2(_x(object.slot), FLOOR_Y + 5), Vector2(centre.x, FLOOR_Y + 5), centre])
				if lamp.on:
					draw_polyline(wire, Color(1, 0.82, 0.4, 0.35), 7, true)
					draw_polyline(wire, Color("ffd27a"), 3, true)
					_draw_spark(wire, str(lamp.id))
				else:
					_spark_start.erase(str(lamp.id))
					draw_polyline(wire, Color("5b6274"), 2, true)
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
					_label(self, positions[actor.id] + Vector2(-25, 46), str(decision.type).to_lower() + (" >" if step > 0 else (" <" if step < 0 else "")), MEMORY, 14)
	_draw_name_plates(world, positions)
	var bubbles := _bubble_layout(world, positions)
	for actor in world.get("characters", []):
		if actor.status == "EXITED":
			continue
		var at: Vector2 = positions[actor.id]
		if not _planning and actor.active:
			draw_circle(at - Vector2(0, _figure_height(actor.art) + 13.0), 5, Color("efd17a"))
		if not bubbles.has(actor.id):
			continue
		var rect: Rect2 = bubbles[actor.id]
		var colour: Color = COLOURS.get(actor.thought, MEMORY)
		_draw_thought_cloud(rect, at - Vector2(0, _figure_height(actor.art) - 5.0), colour)
		if _textures.has(actor.thought):
			draw_texture_rect(_textures[actor.thought], Rect2(rect.position + Vector2(32, 4), Vector2(32, 32)), false)
		var label_width := TEXT_FONT.get_string_size(actor.thought, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
		_label(self, rect.position + Vector2((96 - label_width) / 2, 54), actor.thought, colour, 16)
		if _planning:
			_bubble_rects[actor.id] = rect
			_actor_rects[actor.id] = Rect2(at - Vector2(42, _figure_height(actor.art)), Vector2(84, _figure_height(actor.art)))
		if actor.id == _target:
			draw_rect(rect.grow(5), Color("42a88c"), false, 3)
	for effect in _effects:
		_draw_word(effect)
	for saying in _sayings:
		_draw_saying(saying)
	_draw_caption_box()
	if _drag_bubble != "":
		draw_circle(_mouse, 18, Color(1, 0.85, 0.3, 0.7))
	draw_set_transform(_offset(), 0, Vector2.ONE * _fit())
	draw_rect(Rect2(3, 3, 1274, 454), INK, false, 6)

func _draw_word(effect: Dictionary) -> void:
	# Onomatopoeia: an inked starburst with an outlined word; pops in, drifts, fades.
	var age: float = effect.age
	var scale := 1.0
	if not _reduced_motion:
		if age < 0.1:
			scale = lerpf(0.2, 1.25, age / 0.1)
		elif age < 0.18:
			scale = lerpf(1.25, 1.0, (age - 0.1) / 0.08)
	var alpha := clampf((EFFECT_LIFE - age) * 5.0, 0.0, 1.0)
	var at: Vector2 = effect.at + Vector2(0, 0 if _reduced_motion else -age * 14.0)
	var font: Font = WORD_FONT
	var kind := str(effect.get("kind", ""))
	var size := 26 if kind in ["DING", "SIT"] else 34
	var width := font.get_string_size(effect.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_set_transform(_offset() + at * _fit(), float(effect.get("rot", 0.0)), Vector2.ONE * scale * _fit())
	if kind == "DING":
		# Idea bulb pop with a flash ring.
		var ring := 14.0 + age * 60.0
		draw_arc(Vector2(0, 26), ring, 0, TAU, 32, Color(1, 0.95, 0.75, alpha * 0.6), 3, true)
		draw_circle(Vector2(0, 26), 11, Color(1, 0.84, 0.48, alpha))
		draw_arc(Vector2(0, 26), 11, 0, TAU, 20, Color(INK, alpha), 2, true)
		draw_rect(Rect2(-5, 36, 10, 6), Color(INK, alpha))
	elif kind != "SIT":
		var points := PackedVector2Array()
		var spikes := 14
		var rx := width * 0.5 + 26.0
		var ry := size * 0.95
		for k in spikes * 2:
			var angle := TAU * k / (spikes * 2)
			var radius := 1.0 if k % 2 == 0 else 0.72
			radius *= 1.0 + 0.08 * sin(k * 2.3)
			points.append(Vector2(cos(angle) * rx, sin(angle) * ry - size * 0.32) * radius)
		var fill: Color = Color("fff4d6") if kind not in ["LAMP_ON", "WHIFF"] else Color("ffd27a")
		draw_colored_polygon(points, Color(fill, alpha))
		points.append(points[0])
		draw_polyline(points, Color(INK, alpha), 2.5, true)
	var origin := Vector2(-width * 0.5, size * 0.35 - size * 0.32)
	if kind == "DING":
		origin.y = 0
	draw_string_outline(font, origin, effect.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 7, Color(INK, alpha))
	draw_string(font, origin, effect.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(effect.colour, alpha))
	draw_set_transform(_offset(), 0, Vector2.ONE * _fit())

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
			# Parked bulbs hang on hooks inside the panel; one hook per usable
			# lantern (lanterns.count), so the limit is visible.
			if index < _lantern_count() and _planning:
				var hook := _hook_position(index)
				_draw_parked_bulb(hook, index)
				_bulb_rects.append(Rect2(hook - Vector2(24, 26), Vector2(48, 58)))
			else:
				_bulb_rects.append(Rect2())
			continue
		var at := _light_position(light)
		var opacity := 1.0 if _planning else 0.3
		for segment in range(48):
			draw_arc(at, LIGHTING.radius(_page) * _spacing(), TAU * segment / 48.0, TAU * (segment + 0.55) / 48.0, 3, Color(0.97, 0.78, 0.33, opacity * 0.7), 1.5, true)
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
	if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_RIGHT]:
		for index in range(_bulb_rects.size()):
			if _bulb_rects[index].has_area() and _bulb_rects[index].has_point(_mouse) and _plan.lanterns[index].enabled:
				_selected_lantern = index
				var light: Dictionary = _plan.lanterns[index]
				if event.button_index == MOUSE_BUTTON_RIGHT:
					lantern_moved.emit(index, Vector2(light.x, light.y), false)
				else:
					# Wheel raises/lowers the bulb: lower lights a wider circle of the floor.
					_move_selected(Vector2(light.x, light.y + (-0.1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.1)))
				accept_event()
				return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			grab_focus()
			for id in _bubble_rects:
				if _bubble_rects[id].has_point(_mouse):
					_drag_bubble = id
					accept_event()
					return
			if _flick_ghost_rect.has_area() and _flick_ghost_rect.has_point(_mouse):
				flick_cleared.emit()
				accept_event()
				return
			for index in range(_bulb_rects.size()):
				if _bulb_rects[index].has_point(_mouse):
					_drag_bulb = index
					_selected_lantern = index
					accept_event()
					return
			var poked := _actor_at(_mouse)
			if not poked.is_empty():
				poke(poked)
				accept_event()
				return
		else:
			if _drag_bulb >= 0 and _hook_area().has_point(_mouse):
				# Dropping a bulb back on the hooks parks it.
				var parked: Dictionary = _plan.lanterns[_drag_bulb]
				lantern_moved.emit(_drag_bulb, Vector2(parked.x, parked.y), false)
			if _drag_bubble != "" and _target != "":
				thought_swapped.emit(_drag_bubble, _target)
			_drag_bubble = ""
			_drag_bulb = -1
			_target = ""
			preview_cleared.emit()
			clear_preview()
			queue_redraw()
	elif event is InputEventMouseMotion:
		_look = _mouse
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


func set_mood(mood: String, seconds: float = 0.0) -> void:
	# Timed moods (flinch, scheme) fall back to the last persistent mood.
	if seconds <= 0.0:
		_mood_after = mood
	elif _mood_left <= 0.0:
		_mood_after = _bulb_mood
	_bulb_mood = mood
	_mood_left = seconds
	queue_redraw()
	if is_instance_valid(_props):
		_props.queue_redraw()

func react_swap(first: String, second: String) -> void:
	for id in [first, second]:
		if _rigs.has(id):
			_rigs[id].pop()
	set_mood("scheme", 1.2)

func _actor_at(point: Vector2) -> String:
	var world := _shown()
	var positions := _positions(world)
	for actor in world.get("characters", []):
		if actor.status == "EXITED" or not positions.has(actor.id):
			continue
		var height := _figure_height(str(actor.get("art", "")))
		if Rect2(positions[actor.id] - Vector2(40, height), Vector2(80, height)).has_point(point):
			return str(actor.id)
	return ""

## Poking is a pure toy. A dark actor gives the same generic grumble whatever it
## is thinking, so pokes never leak a hidden thought.
func poke(id: String) -> String:
	var world := _shown()
	var kind := "HMPH"
	for actor in world.get("characters", []):
		if actor.id == id and actor.status == "READY" and _lit(actor.slot, world):
			kind = "POKE_" + str(actor.thought)
	if _rigs.has(id):
		_rigs[id].pop()
	actor_poked.emit(id, kind)
	return kind

func _draw_bulby(canvas: CanvasItem, index: int, at: Vector2) -> void:
	# The lantern bulb is Bulby, the player. Faces never change the light radius.
	var mood := _bulb_mood
	if _drag_bulb == index:
		mood = "grab"
	var small := index == 1
	var r := 13.0 if small else 16.0
	var tint := Color("ffc7d9") if small else Color("ffe17a")
	var bob := 0.0 if _reduced_motion or _drag_bulb == index else sin(_bulb_clock * 2.2 + index) * 2.0
	var squash := Vector2(0.9, 1.14) if mood == "grab" else Vector2.ONE
	var centre := at + Vector2(0, bob)
	canvas.draw_line(Vector2(at.x, 6), centre - Vector2(0, r + 10), Color("524b51"), 2, true)
	var glow := 0.18 if mood == "fail" else (0.55 if mood == "win" else 0.32)
	if mood == "win" and not _reduced_motion:
		for ray in 10:
			var direction := Vector2.from_angle(TAU * ray / 10.0 + _bulb_clock)
			canvas.draw_line(centre + direction * (r + 8), centre + direction * (r + 20), Color(1, 0.86, 0.45, 0.8), 3, true)
	canvas.draw_circle(centre, r * 1.9, Color(tint, glow * 0.5))
	canvas.draw_set_transform(centre, 0, squash)
	canvas.draw_rect(Rect2(-r * 0.45, r * 0.7, r * 0.9, r * 0.55), Color("8e97aa"))
	canvas.draw_rect(Rect2(-r * 0.45, r * 0.7, r * 0.9, r * 0.55), INK, false, 2)
	canvas.draw_line(Vector2(-r * 0.45, r * 0.95), Vector2(r * 0.45, r * 0.95), INK, 1.5)
	canvas.draw_circle(Vector2.ZERO, r, tint if mood != "fail" else tint.darkened(0.35))
	canvas.draw_arc(Vector2.ZERO, r, 0, TAU, 28, INK, 2.5, true)
	var look := Vector2.ZERO
	if _look != Vector2.ZERO:
		look = (_look - centre).limit_length(1.0) * 2.0
	var ex := r * 0.36
	var ey := -r * 0.12
	match mood:
		"grab", "watch":
			for side in [-1, 1]:
				canvas.draw_circle(Vector2(side * ex, ey), 4.2, Color.WHITE)
				canvas.draw_arc(Vector2(side * ex, ey), 4.2, 0, TAU, 12, INK, 1.2, true)
				canvas.draw_circle(Vector2(side * ex, ey) + look, 2.0, INK)
			canvas.draw_circle(Vector2(0, r * 0.42), 3.0 if mood == "grab" else 2.2, INK)
		"scheme":
			for side in [-1, 1]:
				canvas.draw_line(Vector2(side * ex - 3.5, ey - side * 1.5), Vector2(side * ex + 3.5, ey + side * 1.5), INK, 2.2, true)
			canvas.draw_arc(Vector2(0, r * 0.18), r * 0.42, 0.15, PI - 0.15, 10, INK, 2.2, true)
		"win":
			for side in [-1, 1]:
				canvas.draw_arc(Vector2(side * ex, ey + 1.5), 3.2, PI, TAU, 8, INK, 2.2, true)
			canvas.draw_circle(Vector2(0, r * 0.3), r * 0.3, Color("8d4b59"))
		"fail":
			for side in [-1, 1]:
				canvas.draw_line(Vector2(side * ex - 3, ey + 1), Vector2(side * ex + 3, ey + 1), INK, 2.2, true)
			canvas.draw_arc(Vector2(0, r * 0.62), r * 0.3, PI + 0.3, TAU - 0.3, 8, INK, 2.2, true)
		"flinch":
			for side in [-1, 1]:
				canvas.draw_polyline(PackedVector2Array([Vector2(side * ex - 3 * side, ey - 3), Vector2(side * ex + 2 * side, ey), Vector2(side * ex - 3 * side, ey + 3)]), INK, 2.0, true)
			canvas.draw_polyline(PackedVector2Array([Vector2(-5, r * 0.45), Vector2(-2, r * 0.35), Vector2(1, r * 0.45), Vector2(4, r * 0.35)]), INK, 1.8, true)
		_:
			for side in [-1, 1]:
				canvas.draw_circle(Vector2(side * ex, ey) + look * 0.6, 2.4, INK)
			canvas.draw_arc(Vector2(0, r * 0.12), r * 0.32, 0.4, PI - 0.4, 8, INK, 2.0, true)
	canvas.draw_set_transform(Vector2.ZERO)


func set_flick_ready(ready: bool, aim_slot: int = -1) -> void:
	if ready != _flick_ready or aim_slot != _aim_slot:
		_flick_ready = ready
		_aim_slot = aim_slot
		queue_redraw()

func slot_at(local_point: Vector2) -> int:
	var point := to_stage(local_point)
	return clampi(int(round((point.x - 90.0) / _spacing())), 0, int(_page.get("width", 11)) - 1)

func _draw_spare_bulb(centre: Vector2, alpha: float, label: String = "") -> void:
	draw_line(Vector2(centre.x, 6), centre - Vector2(0, 22), Color(0.32, 0.29, 0.32, alpha), 2, true)
	draw_circle(centre, 24, Color(1, 0.8, 0.86, 0.25 * alpha))
	draw_rect(Rect2(centre + Vector2(-6, 9), Vector2(12, 7)), Color(0.55, 0.59, 0.67, alpha))
	draw_circle(centre, 12, Color(1, 0.78, 0.85, alpha))
	draw_arc(centre, 12, 0, TAU, 24, Color(INK, alpha), 2.2, true)
	for side in [-1, 1]:
		draw_circle(centre + Vector2(side * 4, -2), 1.8, Color(INK, alpha))
	draw_arc(centre + Vector2(0, 1), 4, 0.3, PI - 0.3, 6, Color(INK, alpha), 1.6, true)
	if not label.is_empty():
		_label(self, centre + Vector2(18, 6), label, Color(Color("ffd27a"), alpha), 15)

func _draw_flick(world: Dictionary) -> void:
	_flick_ghost_rect = Rect2()
	var on_lamp: Dictionary = {}
	for lamp in world.get("lamps", []):
		if lamp.get("id", "") == "flick" and lamp.get("on", false):
			on_lamp = lamp
	if not on_lamp.is_empty():
		var centre := Vector2(_x((float(on_lamp.zone[0]) + float(on_lamp.zone[1])) * 0.5), 60)
		_draw_spare_bulb(centre, 1.0)
	var flick: Dictionary = _plan.get("flick", {})
	if _planning and not flick.is_empty():
		# Ghost of the kept flick; clicking it clears the flick.
		var ghost := Vector2(_x(float(flick.centre)), 60)
		var left := _x(float(flick.centre) - 1.45)
		var right := _x(float(flick.centre) + 1.45)
		for x in range(int(left), int(right), 14):
			draw_line(Vector2(x, FLOOR_Y + 10), Vector2(x + 7, FLOOR_Y + 10), Color(1, 0.78, 0.85, 0.8), 3)
		_draw_spare_bulb(ghost, 0.55, "FLICK at beat %d  (click to clear)" % int(flick.beat))
		_flick_ghost_rect = Rect2(ghost - Vector2(20, 30), Vector2(40, 54))
	if _flick_ready:
		if _aim_slot >= 0:
			var left := _x(float(_aim_slot) - 1.45)
			var right := _x(float(_aim_slot) + 1.45)
			draw_rect(Rect2(left, 70, right - left, FLOOR_Y - 60), Color(1, 0.86, 0.55, 0.12))
			for y in range(70, int(FLOOR_Y + 10), 14):
				draw_line(Vector2(left, y), Vector2(left, y + 7), Color(1, 0.86, 0.55, 0.8), 2)
				draw_line(Vector2(right, y), Vector2(right, y + 7), Color(1, 0.86, 0.55, 0.8), 2)
			_draw_spare_bulb(Vector2(_x(float(_aim_slot)), 60), 1.0, "click to FLICK")
		else:
			var wiggle := 0.0 if _reduced_motion else sin(_bulb_clock * 9.0) * 3.0
			_draw_spare_bulb(Vector2(40 + wiggle, 60), 1.0, "spare bulb: click the room!")


func _radial_texture() -> Texture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.set_color(1, Color(1, 1, 1, 0))
	gradient.add_point(0.45, Color(1, 1, 1, 0.55))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 128
	texture.height = 128
	return texture

func _draw_glow(canvas: CanvasItem) -> void:
	var world := _shown()
	var warm := Color(1.0, 0.78, 0.42)
	var t := 0.0 if _reduced_motion else _bulb_clock
	for index in _plan.get("lanterns", []).size():
		var light: Dictionary = _plan.lanterns[index]
		if not light.get("enabled", false):
			continue
		var at := _light_position(light)
		var radius := LIGHTING.radius(_page) * _spacing() * 1.15
		var flicker := 1.0 + 0.05 * sin(t * 7.3 + index) + 0.03 * sin(t * 17.1)
		canvas.draw_texture_rect(_glow_texture, Rect2(at - Vector2(radius, radius), Vector2(radius, radius) * 2.0), false, Color(warm, 0.30 * flicker))
		# Dust motes drift up through the pool.
		for mote in 14:
			var seed := float(mote) * 12.9898 + float(index) * 78.233
			var angle := fmod(seed * 43.7, TAU)
			var distance := radius * 0.75 * fmod(seed * 0.618, 1.0)
			var rise := fmod(t * (6.0 + fmod(seed, 5.0)) + seed * 9.0, 60.0)
			var point := at + Vector2(cos(angle), sin(angle)) * distance - Vector2(0, rise)
			if point.distance_to(at) < radius * 0.85:
				canvas.draw_circle(point, 1.6, Color(1, 0.9, 0.65, 0.35 * (1.0 - rise / 60.0)))
	for lamp in world.get("lamps", []):
		if not lamp.get("on", false):
			continue
		# Cone from the fixture to the exact lit floor footprint (zone +/- 0.45).
		var left := _x(float(lamp.zone[0]) - 0.45)
		var right := _x(float(lamp.zone[1]) + 0.45)
		var top := Vector2((left + right) * 0.5, 86.0 if lamp.get("id", "") != "flick" else 74.0)
		var polygon := PackedVector2Array([top + Vector2(-22, 0), top + Vector2(22, 0), Vector2(right, FLOOR_Y + 30), Vector2(left, FLOOR_Y + 30)])
		var colours := PackedColorArray([Color(warm, 0.38), Color(warm, 0.38), Color(warm, 0.05), Color(warm, 0.05)])
		canvas.draw_polygon(polygon, colours)
	for zone in _page.get("fixed_lights", []):
		var left := _x(float(zone[0]) - 0.45)
		var right := _x(float(zone[1]) + 0.45)
		var top := Vector2((left + right) * 0.5, 74.0)
		canvas.draw_polygon(PackedVector2Array([top + Vector2(-18, 0), top + Vector2(18, 0), Vector2(right, FLOOR_Y + 30), Vector2(left, FLOOR_Y + 30)]), PackedColorArray([Color(warm, 0.22), Color(warm, 0.22), Color(warm, 0.03), Color(warm, 0.03)]))


func _draw_thought_cloud(rect: Rect2, head: Vector2, colour: Color) -> void:
	# Comic thought bubble: a puffy cloud plus shrinking puffs down to the head.
	var centre := rect.get_center()
	var puffs: Array[Vector3] = []
	var rx := rect.size.x * 0.5
	var ry := rect.size.y * 0.5
	for k in 9:
		var angle := TAU * k / 9.0
		puffs.append(Vector3(centre.x + cos(angle) * rx * 0.78, centre.y + sin(angle) * ry * 0.72, 17.0 if k % 2 == 0 else 15.0))
	var bottom := Vector2(centre.x, rect.end.y + 2)
	var trail: Array[Vector3] = []
	for k in 3:
		var t := (k + 1) / 4.0
		var point := bottom.lerp(head, t)
		trail.append(Vector3(point.x, point.y, 6.0 - k * 1.6))
	for puff in puffs + trail:
		draw_circle(Vector2(puff.x, puff.y), puff.z + 2.5, INK)
	draw_rect(Rect2(rect.position + Vector2(6, 6), rect.size - Vector2(12, 12)), INK)
	for puff in puffs + trail:
		draw_circle(Vector2(puff.x, puff.y), puff.z, PAPER)
	draw_rect(Rect2(rect.position + Vector2(8, 8), rect.size - Vector2(16, 16)), PAPER)
	draw_arc(centre, minf(rx, ry) * 1.2, 0, TAU, 32, Color(colour, 0.0), 1.0)

var _spark_start: Dictionary = {}

func _draw_spark(wire: PackedVector2Array, id: String) -> void:
	# A spark runs along the wire once when the lamp switches on.
	if _reduced_motion:
		return
	if not _spark_start.has(id):
		_spark_start[id] = _bulb_clock
	var t := (_bulb_clock - float(_spark_start[id])) / 0.45
	if t > 1.0:
		return
	var total := 0.0
	for i in range(1, wire.size()):
		total += wire[i - 1].distance_to(wire[i])
	var travelled := total * t
	for i in range(1, wire.size()):
		var length := wire[i - 1].distance_to(wire[i])
		if travelled <= length:
			var point := wire[i - 1].lerp(wire[i], travelled / maxf(length, 0.001))
			draw_circle(point, 9, Color(1, 0.9, 0.5, 0.45))
			draw_circle(point, 4, Color("fff4d6"))
			return
		travelled -= length

func _draw_name_plates(world: Dictionary, positions: Dictionary) -> void:
	# Lit (or, during ACTION, active) characters show their name so nobody is
	# confused about who is who. Dark characters show none.
	for actor in world.get("characters", []):
		if actor.status == "EXITED" or not positions.has(actor.id):
			continue
		var shown: bool = _lit(actor.slot, world) or (not _planning and actor.get("active", false))
		if not shown:
			continue
		var name := str(actor.get("name", actor.id)).replace("_", " ").to_upper()
		var at: Vector2 = positions[actor.id]
		var width := TEXT_FONT.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x + 14
		var plate := Rect2(at + Vector2(-width * 0.5, 8), Vector2(width, 19))
		draw_rect(plate, Color("f6e27a"))
		draw_rect(plate, INK, false, 1.5)
		draw_string(TEXT_FONT, plate.position + Vector2(7, 14), name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, INK)


var _sayings: Array[Dictionary] = []

## A short speech balloon over a lit/active character (dialogue is never a thought).
func say(id: String, text: String, life: float = 1.0) -> void:
	for record in _world.get("characters", []):
		if record.id == id and record.status != "EXITED":
			var at := _actor_position(record)
			_sayings = _sayings.filter(func(saying): return saying.id != id)
			_sayings.append({"id": id, "text": text, "at": at - Vector2(0, _figure_height(str(record.get("art", ""))) + 18.0), "age": 0.0, "life": life})
	queue_redraw()

func _draw_saying(saying: Dictionary) -> void:
	var alpha := clampf((float(saying.get("life", 1.0)) - float(saying.age)) * 5.0, 0.0, 1.0)
	var pop := 1.0 if _reduced_motion else minf(1.0, float(saying.age) / 0.08)
	var width := TEXT_FONT.get_string_size(saying.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x + 18.0
	var at: Vector2 = saying.at + Vector2(34, -10)
	draw_set_transform(_offset() + at * _fit(), 0, Vector2.ONE * pop * _fit())
	var rect := Rect2(Vector2(-width * 0.5, -16), Vector2(width, 28))
	var tail := PackedVector2Array([Vector2(-14, 10), Vector2(-4, 10), Vector2(-26, 24)])
	draw_colored_polygon(tail, Color(Color.WHITE, alpha))
	draw_polyline(PackedVector2Array([tail[0], tail[2], tail[1]]), Color(INK, alpha), 2, true)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(Color.WHITE, alpha)
	style.border_color = Color(INK, alpha)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	draw_style_box(style, rect)
	draw_string(TEXT_FONT, Vector2(-width * 0.5 + 9, 4), saying.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(INK, alpha))
	draw_set_transform(_offset(), 0, Vector2.ONE * _fit())


var _caption_text := ""
var _caption_left := 0.0

## Narrator caption box (comic panel caption, top-left). seconds <= 0 keeps it.
func set_caption(text: String, seconds: float = 0.0) -> void:
	_caption_text = text
	_caption_left = seconds
	queue_redraw()

func _draw_caption_box() -> void:
	if _caption_text.is_empty():
		return
	var width := 600.0
	var lines := TEXT_FONT.get_multiline_string_size(_caption_text, HORIZONTAL_ALIGNMENT_LEFT, width - 24, 17).y
	var rect := Rect2(Vector2(_hook_area().end.x + 12 if _planning else 12.0, 12), Vector2(width, lines + 16))
	draw_rect(rect, Color("f6e27a"))
	draw_rect(rect, INK, false, 2.5)
	draw_multiline_string(TEXT_FONT, rect.position + Vector2(12, 24), _caption_text, HORIZONTAL_ALIGNMENT_LEFT, width - 24, 17, -1, INK)


func _lantern_count() -> int:
	return int(_page.get("lanterns", {}).get("count", 2))

func _hook_position(index: int) -> Vector2:
	return Vector2(44 + index * 52, 74)

func _hook_area() -> Rect2:
	return Rect2(Vector2(14, 20), Vector2(56 + 52 * _lantern_count(), 96))

func _draw_parked_bulb(at: Vector2, index: int) -> void:
	# Hook rail, cord and a sleeping bulb waiting to be dragged into the room.
	draw_line(Vector2(20, 26), Vector2(_hook_area().end.x - 6, 26), Color("524b51"), 4, true)
	draw_arc(at - Vector2(0, 40), 6, 0, PI, 8, Color("524b51"), 3, true)
	draw_line(at - Vector2(0, 34), at - Vector2(0, 16), Color("524b51"), 2, true)
	var tint := Color("ffc7d9") if index == 1 else Color("ffe17a")
	draw_circle(at, 14, tint.darkened(0.25))
	draw_arc(at, 14, 0, TAU, 24, INK, 2.2, true)
	draw_rect(Rect2(at + Vector2(-6, 11), Vector2(12, 7)), Color("8e97aa"))
	for side in [-1, 1]:
		draw_line(at + Vector2(side * 5 - 3, -2), at + Vector2(side * 5 + 3, -2), INK, 2, true)
	if _planning:
		_label(self, at + Vector2(-18, 40), "drag", Color("d8c79a"), 12)


func _draw_screen(start: Vector2, end: Vector2) -> void:
	# A folding paper screen drawn exactly on its blocking segment, so the art
	# and the shadow it casts can never disagree.
	var top := Vector2(start.x, minf(start.y, end.y))
	var bottom := Vector2(end.x, maxf(start.y, end.y))
	if absf(start.x - end.x) > 1.0:
		draw_line(start, end, Color("7b5a3c"), 10, true)
		draw_line(start, end, INK, 2, true)
		return
	var height := bottom.y - top.y
	var panels := [Vector2(-21, 4), Vector2(-7, 0), Vector2(7, 4)]
	for offset in panels:
		var rect := Rect2(Vector2(top.x + offset.x, top.y + offset.y), Vector2(14, height - offset.y))
		draw_rect(rect, Color("c9a77c"))
		draw_rect(rect.grow(-3), Color("efe1c4"))
		draw_line(rect.position + Vector2(7, 8), rect.position + Vector2(7, rect.size.y - 8), Color(0.6, 0.45, 0.3, 0.35), 1)
		draw_rect(rect, INK, false, 2)
	draw_line(Vector2(top.x - 24, bottom.y), Vector2(top.x + 24, bottom.y), INK, 3)
