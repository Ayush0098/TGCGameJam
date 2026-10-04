extends Node2D
## Presentation-only cutout rig. Positions and outcomes belong to the simulator.

const ART_ROOT := "res://assets/characters/"
const ACTIONS := ["idle", "walk", "startle", "run", "eat", "sit", "sleep", "bonk", "ko", "exit", "celebrate"]
const EXPRESSIONS := {"startle": "frightened", "run": "frightened", "eat": "hungry", "sleep": "sleepy", "bonk": "angry", "ko": "surprised", "celebrate": "pleased"}
var animation_player: AnimationPlayer
var art_id := ""
var canvas := Vector2(320, 400)
var anchor := Vector2(160, 380)
var _visual: Node2D
var _parts: Dictionary = {}
var _rest: Dictionary = {}
var _faces: Dictionary = {}
var _face: Sprite2D
var _lighting_material: ShaderMaterial
var expression_name := "neutral"


func configure(id: String) -> bool:
	if id not in ["boss", "dog"]:
		return false
	var file := FileAccess.open(ART_ROOT + id + "/rig.json", FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return false
	stop()
	if is_instance_valid(_visual):
		remove_child(_visual)
		_visual.queue_free()
	if is_instance_valid(animation_player):
		remove_child(animation_player)
		animation_player.queue_free()
	_parts.clear()
	_rest.clear()
	_faces = parsed["expressions"].duplicate()
	_lighting_material = ShaderMaterial.new()
	_lighting_material.shader = preload("res://presentation/actor_light.gdshader")
	art_id = id
	canvas = Vector2(parsed["canvas"][0], parsed["canvas"][1])
	anchor = Vector2(parsed["anchor"][0], parsed["anchor"][1])
	_visual = Node2D.new()
	_visual.name = "Visual"
	# Back limbs use negative local depth but must still sit above scenery at z=0.
	_visual.z_index = 10
	_visual.position = -anchor
	add_child(_visual)
	for record: Dictionary in parsed["parts"]:
		var part := Node2D.new()
		part.name = String(record["name"])
		part.position = Vector2(record["pivot"][0], record["pivot"][1])
		part.z_index = int(record["z"])
		var image := Sprite2D.new()
		image.centered = false
		image.material = _lighting_material
		image.texture = load(record["texture"])
		image.position = -part.position
		part.add_child(image)
		_visual.add_child(part)
		_parts[part.name] = part
		_rest[part.name] = part.position
	_face = Sprite2D.new()
	_face.name = "Expression"
	_face.centered = false
	_face.material = _lighting_material
	_face.position = -_parts["head"].position
	_face.z_index = 1
	_parts["head"].add_child(_face)
	set_expression("neutral")
	animation_player = AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	animation_player.root_node = NodePath("..")
	add_child(animation_player)
	var library := AnimationLibrary.new()
	for action: String in ACTIONS:
		library.add_animation(action, _build_animation(action))
	animation_player.add_animation_library("", library)
	return true


func set_expression(expression: String) -> void:
	if is_instance_valid(_face) and _faces.has(expression):
		expression_name = expression
		_face.texture = load(_faces[expression])
		_apply_expression_pose(expression)


func set_lit(lit: bool) -> void:
	if _lighting_material != null:
		_lighting_material.set_shader_parameter("lit", 1.0 if lit else 0.0)


func set_plan_expression(expression: String) -> void:
	set_expression(expression)
	# Compact standing silhouettes keep adjacent slot faces unobstructed.
	for joint in ["arm_left", "arm_right"]:
		if _parts.has(joint):
			_parts[joint].rotation = clampf(_parts[joint].rotation, -0.20, 0.20)


func show_terminal(status: String) -> void:
	stop()
	set_expression({"ASLEEP": "sleepy", "FULL": "pleased", "SATISFIED": "pleased", "KO": "surprised"}.get(status, "neutral"))
	if status == "ASLEEP":
		_visual.position = -anchor + Vector2(0, 20)
		if _parts.has("leg_left"):
			_parts.leg_left.rotation = deg_to_rad(-40)
		if _parts.has("leg_right"):
			_parts.leg_right.rotation = deg_to_rad(40)
	elif status == "KO":
		_visual.rotation = 0.16
		_visual.position = -anchor + Vector2(0, 12)


func _apply_expression_pose(expression: String) -> void:
	# Body language supports the face. Action tracks override the joints they animate.
	for part in _parts.values():
		part.rotation = 0.0
	var angles: Dictionary = {}
	match expression:
		"hungry":
			angles = {"head": -5, "arm_left": -18, "arm_right": 18, "tail": -22}
		"sleepy":
			angles = {"head": 12, "arm_left": 7, "arm_right": -7, "ear_left": 10, "ear_right": -10, "tail": 14}
		"angry":
			angles = {"head": -7, "arm_left": -28, "arm_right": 28, "ear_left": -15, "ear_right": 15, "tail": 20}
		"frightened":
			angles = {"head": 7, "arm_left": 42, "arm_right": -42, "ear_left": 24, "ear_right": -24, "tail": 35}
		"surprised":
			angles = {"head": -8, "arm_left": 24, "arm_right": -24, "ear_left": -20, "ear_right": 20, "tail": -30}
		"pleased":
			angles = {"head": -5, "arm_left": 15, "arm_right": -15, "ear_left": -8, "ear_right": 8, "tail": -18}
	for joint in angles:
		if _parts.has(joint):
			_parts[joint].rotation = deg_to_rad(float(angles[joint]))


func play_action(action: String, speed: float = 1.0, reduced_motion: bool = false) -> void:
	if not is_instance_valid(animation_player) or action not in ACTIONS:
		return
	stop()
	set_expression(EXPRESSIONS.get(action, "neutral"))
	if reduced_motion:
		return
	animation_player.speed_scale = clampf(speed, 0.1, 8.0)
	animation_player.play(action)


func stop() -> void:
	if is_instance_valid(animation_player):
		animation_player.stop()
	set_expression("neutral")
	if is_instance_valid(_visual):
		_visual.position = -anchor
		_visual.rotation = 0.0
		_visual.scale = Vector2.ONE
		_visual.modulate = Color.WHITE
	for key: String in _parts:
		var part: Node2D = _parts[key]
		part.position = _rest[key]
		part.rotation = 0.0
		part.scale = Vector2.ONE


func _track(animation: Animation, target: String, keys: Array) -> void:
	var index := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(index, NodePath(target))
	animation.value_track_set_update_mode(index, Animation.UPDATE_CONTINUOUS)
	for key: Array in keys:
		animation.track_insert_key(index, float(key[0]), key[1])


func _rotation(animation: Animation, part: String, angles: Array) -> void:
	if not _parts.has(part):
		return
	var keys: Array = []
	for key: Array in angles:
		keys.append([key[0], deg_to_rad(float(key[1]))])
	_track(animation, "Visual/" + part + ":rotation", keys)


func _build_animation(action: String) -> Animation:
	var animation := Animation.new()
	animation.length = 0.8
	if action in ["idle", "walk", "run", "sleep"]:
		animation.loop_mode = Animation.LOOP_LINEAR
	var b := -anchor
	match action:
		"idle":
			_track(animation, "Visual:scale", [[0.0, Vector2.ONE], [0.4, Vector2(1.009, 1.012)], [0.8, Vector2.ONE]])
			_rotation(animation, "head", [[0, 0], [0.4, -1.5], [0.8, 0]])
		"walk", "run":
			var amount := 17.0 if action == "walk" else 30.0
			_rotation(animation, "leg_left", [[0, -amount], [0.4, amount], [0.8, -amount]])
			_rotation(animation, "leg_right", [[0, amount], [0.4, -amount], [0.8, amount]])
			_rotation(animation, "arm_left", [[0, amount * 0.55], [0.4, -amount * 0.55], [0.8, amount * 0.55]])
			_rotation(animation, "arm_right", [[0, -amount * 0.55], [0.4, amount * 0.55], [0.8, -amount * 0.55]])
			_track(animation, "Visual:position", [[0, b], [0.2, b + Vector2(0, -7)], [0.4, b], [0.6, b + Vector2(0, -7)], [0.8, b]])
			_rotation(animation, "ear_left", [[0, -8], [0.4, 12], [0.8, -8]])
			_rotation(animation, "ear_right", [[0, 8], [0.4, -12], [0.8, 8]])
		"startle":
			_track(animation, "Visual:position", [[0, b], [0.15, b + Vector2(0, 6)], [0.32, b + Vector2(0, -22)], [0.55, b], [0.8, b]])
			_track(animation, "Visual:scale", [[0, Vector2.ONE], [0.15, Vector2(1.07, 0.94)], [0.32, Vector2(0.96, 1.04)], [0.8, Vector2.ONE]])
			_rotation(animation, "arm_left", [[0, 0], [0.32, 35], [0.8, 0]])
			_rotation(animation, "arm_right", [[0, 0], [0.32, -35], [0.8, 0]])
		"eat":
			_rotation(animation, "head", [[0, 0], [0.18, 11], [0.33, -6], [0.5, 8], [0.66, -3], [0.8, 0]])
			_rotation(animation, "arm_right", [[0, 0], [0.18, -42], [0.6, -42], [0.8, 0]])
		"sit":
			_track(animation, "Visual:position", [[0, b], [0.2, b + Vector2(0, -6)], [0.55, b + Vector2(0, 20)], [0.8, b + Vector2(0, 20)]])
			_rotation(animation, "leg_left", [[0, 0], [0.55, -40], [0.8, -40]])
			_rotation(animation, "leg_right", [[0, 0], [0.55, 40], [0.8, 40]])
		"sleep":
			_rotation(animation, "head", [[0, 12], [0.4, 15], [0.8, 12]])
			_track(animation, "Visual:scale", [[0, Vector2.ONE], [0.4, Vector2(1.015, 1.012)], [0.8, Vector2.ONE]])
		"bonk":
			_rotation(animation, "arm_right", [[0, 0], [0.2, 34], [0.36, -70], [0.6, -25], [0.8, 0]])
		"ko":
			_track(animation, "Visual:rotation", [[0, 0.0], [0.12, -0.12], [0.3, 0.17], [0.5, -0.1], [0.8, 0.16]])
			_track(animation, "Visual:position", [[0, b], [0.2, b + Vector2(0, -8)], [0.8, b + Vector2(0, 12)]])
		"exit":
			_track(animation, "Visual:modulate", [[0, Color.WHITE], [0.45, Color.WHITE], [0.8, Color(1, 1, 1, 0)]])
		"celebrate":
			_track(animation, "Visual:position", [[0, b], [0.15, b + Vector2(0, 7)], [0.38, b + Vector2(0, -20)], [0.6, b], [0.8, b]])
			_rotation(animation, "arm_left", [[0, 0], [0.38, 55], [0.8, 0]])
			_rotation(animation, "arm_right", [[0, 0], [0.38, -55], [0.8, 0]])
	if _parts.has("tail"):
		_rotation(animation, "tail", [[0, -7], [0.2, 13], [0.4, -7], [0.6, 13], [0.8, -7]])
	return animation
