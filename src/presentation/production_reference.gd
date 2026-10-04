extends Control
## Asset audition scene. The playable MVP remains the normal project launch.

const ACTOR = preload("res://scenes/character_actor.tscn")
const EXPRESSIONS = ["neutral", "hungry", "sleepy", "angry", "frightened", "surprised", "pleased"]
const ACTIONS = ["idle", "walk", "startle", "run", "eat", "sit", "sleep", "bonk", "ko", "exit", "celebrate"]
const PAPER := Color("f5eddf")
const INK := Color("382d3c")
const GOLD := Color("d5a354")

var _actors: Dictionary = {}
var _selected := "boss"
var _artboard: Control
var _subtitle: Label
var _status: Label
var _voice: AudioStreamPlayer
var _cues: Dictionary = {}
var _voice_buttons: Array[Button] = []
var _motion: CheckButton
var _speed: OptionButton
var _active_cue := ""
var _clock := 0.0
var _portrait_label: Label


func _ready() -> void:
	_build()
	_load_voices()
	_layout_actors()
	_actors.boss.play_action("idle")
	_actors.dog.play_action("idle")


func _label(text: String, font_size := 18) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", INK)
	label.add_theme_font_size_override("font_size", font_size)
	return label


func _button(parent: Node, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_font_size_override("font_size", 14)
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("e8d8bc") if state in ["hover", "pressed"] else PAPER
		style.border_color = GOLD if state in ["hover", "focus"] else Color("bcab96")
		style.set_border_width_all(1)
		style.set_corner_radius_all(5)
		style.content_margin_left = 12
		style.content_margin_right = 12
		style.content_margin_top = 4
		style.content_margin_bottom = 4
		button.add_theme_stylebox_override(state, style)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _build() -> void:
	var paper := ColorRect.new()
	paper.color = PAPER
	paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(paper)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 9)
	margin.add_child(column)
	var heading := HBoxContainer.new()
	column.add_child(heading)
	var title := _label("LIGHTBULB MOMENT", 28)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	heading.add_child(_label("THE FIRST LITTLE IDEA  /  ART & VOICE STUDY", 14))
	column.add_child(_label("A painted room. Two unlikely friends. A different ending.", 17))
	var study := HBoxContainer.new()
	study.size_flags_vertical = Control.SIZE_EXPAND_FILL
	study.add_theme_constant_override("separation", 18)
	column.add_child(study)
	_artboard = Control.new()
	_artboard.custom_minimum_size = Vector2(0, 390)
	_artboard.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_artboard.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_artboard.clip_contents = true
	_artboard.mouse_filter = Control.MOUSE_FILTER_IGNORE
	study.add_child(_artboard)
	var backdrop := TextureRect.new()
	backdrop.texture = load("res://assets/backgrounds/living_room_reference.png")
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_artboard.add_child(backdrop)
	for id in ["boss", "dog"]:
		var actor = ACTOR.instantiate()
		_artboard.add_child(actor)
		if not actor.configure(id):
			push_error("Missing reference character: " + id)
		_actors[id] = actor
	_artboard.resized.connect(_layout_actors)
	var sidebar := VBoxContainer.new()
	sidebar.custom_minimum_size.x = 300
	sidebar.add_theme_constant_override("separation", 6)
	study.add_child(sidebar)
	_portrait_label = _label("Studying: BOSS", 19)
	sidebar.add_child(_portrait_label)
	var tools := HBoxContainer.new()
	tools.add_theme_constant_override("separation", 8)
	sidebar.add_child(tools)
	for id in ["boss", "dog"]:
		_button(tools, id.capitalize(), func(): _select(id))
	_button(tools, "Reset", _reset)
	var feelings := OptionButton.new()
	for expression in EXPRESSIONS:
		feelings.add_item(expression.capitalize())
	feelings.item_selected.connect(func(index): _feel(EXPRESSIONS[index]))
	sidebar.add_child(_label("EXPRESSION", 13))
	sidebar.add_child(feelings)
	var actions := OptionButton.new()
	for action in ACTIONS:
		actions.add_item(action.capitalize())
	actions.item_selected.connect(func(index): _play(ACTIONS[index]))
	sidebar.add_child(_label("ANIMATION STUDY", 13))
	sidebar.add_child(actions)
	var playback := HBoxContainer.new()
	sidebar.add_child(playback)
	_speed = OptionButton.new()
	for text in ["Normal speed", "Half speed", "Fast"]:
		_speed.add_item(text)
	_speed.item_selected.connect(func(index):
		for actor in _actors.values():
			actor.animation_player.speed_scale = [1.0, 0.5, 2.0][index]
	)
	playback.add_child(_speed)
	_motion = CheckButton.new()
	_motion.text = "Reduce motion"
	_motion.add_theme_color_override("font_color", INK)
	_motion.toggled.connect(func(value):
		for actor in _actors.values():
			actor.play_action("idle", [1.0, 0.5, 2.0][_speed.selected], value)
		_status.text = "Reduced motion enabled." if value else "Idle animation restored."
	)
	sidebar.add_child(_motion)
	sidebar.add_child(_label("VOICE AUDITION", 13))
	for item in [["narrator_intro", "Meet the narrator"], ["boss_reaction", "Hear the Boss"], ["narrator_success", "Listen to the ending"]]:
		var id: String = item[0]
		_voice_buttons.append(_button(sidebar, item[1], func(): _play_cue(id)))
	_button(sidebar, "Stop voice", _stop_voice)
	var thoughts := HBoxContainer.new()
	thoughts.add_theme_constant_override("separation", 12)
	column.add_child(thoughts)
	thoughts.add_child(_label("THE FOUR IDEAS", 14))
	for id in ["hungry", "sleepy", "angry", "scared"]:
		var icon := TextureRect.new()
		icon.texture = load("res://assets/thoughts/" + id + ".svg")
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(44, 44)
		thoughts.add_child(icon)
		thoughts.add_child(_label(id.to_upper(), 15))
	_subtitle = _label("Choose a voice sample. These are production auditions, not final game dialogue.", 17)
	_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_subtitle.custom_minimum_size.y = 64
	column.add_child(_subtitle)
	_status = _label("Illustrated cutouts and authored animation tracks / Gameplay remains in the MVP.", 14)
	column.add_child(_status)
	_voice = AudioStreamPlayer.new()
	_voice.volume_db = -3
	_voice.finished.connect(_voice_finished)
	add_child(_voice)


func _layout_actors() -> void:
	if _actors.is_empty():
		return
	# Boss occupies roughly half the room height; Dog is about 60% of Boss height.
	var scale_factor := minf(0.64, _artboard.size.y * 0.48 / 340.0)
	for id in _actors:
		_actors[id].position = Vector2(_artboard.size.x * (0.34 if id == "boss" else 0.70), _artboard.size.y * 0.95)
		_actors[id].scale = Vector2.ONE * scale_factor * (0.64 if id == "dog" else 1.0)


func _select(id: String) -> void:
	_selected = id
	_portrait_label.text = "Studying: " + id.to_upper()


func _feel(expression: String) -> void:
	_actors[_selected].stop()
	_actors[_selected].set_expression(expression)
	_status.text = _selected.capitalize() + " / " + expression + " expression"


func _play(action: String) -> void:
	var speeds := [1.0, 0.5, 2.0]
	_actors[_selected].play_action(action, speeds[_speed.selected], _motion.button_pressed)
	_status.text = _selected.capitalize() + " / " + action + (" / reduced motion" if _motion.button_pressed else "")


func _reset() -> void:
	for actor in _actors.values():
		actor.stop()
		actor.set_expression("neutral")
		actor.play_action("idle", 1.0, _motion.button_pressed)
	_stop_voice()


func _load_voices() -> void:
	var path := "res://assets/audio/reference/cues.json"
	if FileAccess.file_exists(path):
		var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if manifest is Dictionary:
			for cue in manifest.get("cues", []):
				if cue is Dictionary and ResourceLoader.exists(cue.get("audio", "")):
					_cues[cue.id] = cue
	for index in _voice_buttons.size():
		_voice_buttons[index].disabled = not _cues.has(["narrator_intro", "boss_reaction", "narrator_success"][index])
	if _cues.is_empty():
		_status.text = "Voice generation pending; art and animation audition available."


func _play_cue(id: String) -> void:
	if not _cues.has(id):
		return
	_stop_voice()
	var cue: Dictionary = _cues[id]
	_voice.stream = load(cue.audio)
	_active_cue = id
	_clock = 0.0
	_voice.play()
	_update_subtitle()
	_status.text = "%s / %.1f seconds / locally generated voice" % [cue.speaker, cue.duration_seconds]


func _process(delta: float) -> void:
	if not _active_cue.is_empty():
		_clock += delta
		_update_subtitle()


func _update_subtitle() -> void:
	var cue: Dictionary = _cues[_active_cue]
	# Audition clips show their full text for their exact playback lifetime.
	# Campaign dialogue will use shorter individually timed clips.
	_subtitle.text = cue.speaker + ": " + cue.text


func _voice_finished() -> void:
	_active_cue = ""
	_subtitle.text = "Audition finished. Replay a voice, or explore the expressions and animation studies."


func _stop_voice() -> void:
	if not _active_cue.is_empty() and _status != null:
		_status.text = "Voice stopped. Choose another audition to replay."
	if _voice != null:
		_voice.stop()
		_voice.stream = null
	_active_cue = ""
	if _subtitle != null:
		_subtitle.text = "Choose a voice sample."


func _exit_tree() -> void:
	_stop_voice()
