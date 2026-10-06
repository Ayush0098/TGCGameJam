extends Control
## MVP flow: recorded simulation -> playback -> result -> exact-plan retry.

## The IIIT-H story, all fifteen pages (design/build_p1_3, design/build_p4_15).
const CAMPAIGN = [
	preload("res://data/campaign/page_01.gd"), preload("res://data/campaign/page_02.gd"),
	preload("res://data/campaign/page_03.gd"), preload("res://data/campaign/page_04.gd"),
	preload("res://data/campaign/page_05.gd"), preload("res://data/campaign/page_06.gd"),
	preload("res://data/campaign/page_07.gd"), preload("res://data/campaign/page_08.gd"),
	preload("res://data/campaign/page_09.gd"), preload("res://data/campaign/page_10.gd"),
	preload("res://data/campaign/page_11.gd"), preload("res://data/campaign/page_12.gd"),
	preload("res://data/campaign/page_13.gd"), preload("res://data/campaign/page_14.gd"),
	preload("res://data/campaign/page_15.gd"),
]
## Integration tests swap in the original MVP fixture pages before instancing.
static var page_override: Array = []
var PAGE_SCRIPTS: Array = []
const VALIDATOR = preload("res://core/page_validator.gd")
const PLAN = preload("res://core/plan_state.gd")
const RULES = preload("res://core/rules.gd")
const SIMULATOR = preload("res://core/simulator.gd")
const GOALS = preload("res://core/goal_evaluator.gd")
const STAGE = preload("res://presentation/stage_view.gd")
const BACKDROP_SHADER = preload("res://presentation/backdrop.gdshader")
var _backdrop: ColorRect
const FRONT = preload("res://presentation/front_end.gd")

var page: Dictionary = {}
var plan: RefCounted
var page_index := 0
var mode := "PLAN"
var knowledge: Dictionary = {}
var attempts := 0
var failures := 0
var completed: Dictionary = {}
var run_history: Array[Dictionary] = []
var _run: Dictionary = {}
var _original_run: Dictionary = {}
var _saved_plan: Dictionary = {}
var _cursor := 0
var _clock := 0.0
var _anticipation := 0.0
var _fast := false
var _is_original := false
var _won_current := false
var _ding_count := 0
var _audio_index := 0
var _players: Array[AudioStreamPlayer] = []
var _character_players: Array[AudioStreamPlayer] = []
var _character_index := 0
## Mix: narration on top, character lines just under it, effects and music below.
const NARRATOR_DB := 0.0
const CHARACTER_DB := -3.0
const SFX_DB := -9.0
var _stage: Control
var _original_stage: Control
var _result_stage: Control
var _comparison: HBoxContainer
var _title: Label
var _goal: Label
var _facts: RichTextLabel
var _caption: Label
var _original_caption: Label
var _twist_caption: Label
var _status: Label
var _pop: Label
var _action: Button
var _rewind: Button
var _restart: Button
var _original: Button
var _fast_button: Button
var _skip_run: Button
var _next: Button
var _skip_page: Button
var _sound: CheckButton
var _motion: CheckButton
var _ui: Control
var _voice: AudioStreamPlayer
var _voice_replay: Button
var _voice_skip: Button
var _subtitle: Label
var _cues: Dictionary = {}
var _active_cue := ""
var _story_waiting := false
var _voice_elapsed := 0.0
var _initial_events_pending := false
var _effect_streams: Dictionary = {}
var _last_cue := ""
var _hooks: Array[Button] = []
var _hook_drag := -1
var _frame_cursor := 0
var _playback_world: Dictionary = {}
# Front end (title / Sunday Edition), contextual help and campaign progress.
var _front: Control
var _instructions: Label
var _pages_button: Button
var _lanterns_useful := true
var skipped: Dictionary = {}
var _hint_button: Button
# Game HUD (design/ui.md §5): title top-centre, goal clipping, ☰ / ⟲ / ACTION.
var _pause_button: Button
var _goal_card: Panel
var _result_card: Panel
var _result_title: Label
var _result_caption: Label
var _result_facts: RichTextLabel
var _result_restart: Button
var _levels_button: Button
var _compare_button: Button
var _tab_bar: HBoxContainer
var _tab_original: Button
var _tab_twist: Button
var _legend: RichTextLabel
var _tier_band: ColorRect
var _bonus_line: RichTextLabel
var _hint_hud: Button
const TIER_COLOURS := [Color("3a8d4f"), Color("d9a521"), Color("c0392b")]
var _hints_shown := 0
var _stamp: Label
var _stamp_tween: Tween
var _missing: Label
# Stars (main twist + bonus challenges) and the endings collection, per page id.
var bonus_done: Dictionary = {}
var endings_found: Dictionary = {}
var _progress_label: RichTextLabel
# Hitstop: impact frames pause the playback clock (not Engine.time_scale).
var _hitstop := 0.0
const HITSTOP := {"BONK": 0.12, "CLASH": 0.12, "EXIT": 0.1, "EAT": 0.08}
## FLICK: a run with an unused spare bulb keeps playing quiet beats this long.
const FLICK_WINDOW_BEATS := 8
const AIM_SLOWDOWN := 0.4
## Slow motion on the beat that completes the twist (known from the event log).
const DECISIVE_SLOWDOWN := 0.45
var _decisive_beat := -1
const INK := Color("1e1b2e")
const PAPER := Color("f4e9d2")
const TEXT_FONT = preload("res://assets/fonts/ComicNeue-Bold.ttf")
const COMIC_FONT = preload("res://assets/fonts/Bangers-Regular.ttf")
const SAVE_PATH := "user://lightbulb_campaign_v2.json"
const BEAT_SECONDS := 0.4
## Visual walk time per beat; arrival lands just before CLAIMS (0.35).
const MOVE_SECONDS := 0.34
const RECOVERY_SECONDS := 0.45
const PHASE_TIME := {"DECIDE": 0.04, "MOVE": 0.26, "SWITCHES": 0.27, "BONKS": 0.31, "CLAIMS": 0.35}


func _ready() -> void:
	if OS.has_feature("production_reference") or "--production-reference" in OS.get_cmdline_user_args():
		get_tree().change_scene_to_file.call_deferred("res://scenes/production_reference.tscn")
		return
	PAGE_SCRIPTS = page_override if not page_override.is_empty() else CAMPAIGN
	_build_ui()
	_load_settings()
	_setup_music()
	_build_vignette()
	get_tree().node_added.connect(_juice_button)
	for node in find_children("*", "BaseButton", true, false):
		_juice_button(node)
	_load_progress()
	_load_page(0)
	_front = FRONT.new()
	# Menus sit above every in-game card (result card z 160, star award z 220).
	_front.z_index = 360
	_front.name = "FrontEnd"
	_ui.add_child(_front)
	_front.start_requested.connect(_on_front_start)
	_front.page_requested.connect(_on_front_page)
	_front.closed.connect(_update_buttons)
	_front.levels_requested.connect(_open_edition)
	_front.settings_requested.connect(_open_settings)
	_update_star_total()
	_update_star_total()
	_front.show_title(not completed.is_empty())


func _exit_tree() -> void:
	_stop_voice()
	for player in _players + _character_players:
		player.stop()
		player.stream = null


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = PAPER
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	# The room painting fills the whole window; the HUD floats on top of it.
	_backdrop = ColorRect.new()
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var backdrop_material := ShaderMaterial.new()
	backdrop_material.shader = BACKDROP_SHADER
	_backdrop.material = backdrop_material
	add_child(_backdrop)
	_ui = Control.new()
	_ui.size = Vector2(1280, 720)
	_ui.theme = _comic_theme()
	add_child(_ui)
	resized.connect(_layout_ui)
	get_window().focus_exited.connect(func(): _hook_drag = -1)
	_layout_ui()
	var heading := HBoxContainer.new()
	heading.position = Vector2(16, 8)
	heading.size = Vector2(1248, 34)
	_ui.add_child(heading)
	_title = _label("LIGHTBULB MOMENT", 28)
	_title.add_theme_font_override("font", COMIC_FONT)
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(_title)
	_pages_button = Button.new()
	_pages_button.text = "PAGES"
	_pages_button.name = "Pages"
	_pages_button.add_theme_font_size_override("font_size", 15)
	_pages_button.pressed.connect(_open_edition)
	heading.add_child(_pages_button)
	_sound = CheckButton.new()
	_sound.text = "Sound"
	_sound.button_pressed = true
	heading.add_child(_sound)
	_sound.toggled.connect(_sound_changed)
	_motion = CheckButton.new()
	_motion.text = "Reduce motion"
	heading.add_child(_motion)
	_motion.toggled.connect(_motion_changed)
	for toggle in [_sound, _motion]:
		for state in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
			toggle.add_theme_color_override(state, INK)
	_goal = _label("", 24)
	_goal.add_theme_font_override("font", COMIC_FONT)
	_goal.position = Vector2(16, 46)
	_goal.size = Vector2(1248, 26)
	_goal.add_theme_color_override("font_color", Color("a4383e"))
	_ui.add_child(_goal)
	# Rich text with icon images: the web build has no system glyph fallback.
	_progress_label = _rich(18)
	_progress_label.name = "Progress"
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_progress_label.position = Vector2(860, 46)
	_progress_label.size = Vector2(404, 28)
	_progress_label.mouse_filter = Control.MOUSE_FILTER_STOP
	_progress_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_progress_label.tooltip_text = "Open the Endings book"
	_progress_label.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_open_endings_book())
	_ui.add_child(_progress_label)
	_facts = _rich(15)
	_facts.position = Vector2(16, 75)
	_facts.size = Vector2(1248, 24)
	_ui.add_child(_facts)
	_instructions = _label("", 15)
	_instructions.position = Vector2(16, 101)
	_instructions.size = Vector2(1010, 23)
	_instructions.clip_text = true
	_ui.add_child(_instructions)
	for index in range(2):
		var hook := Button.new()
		hook.position = Vector2(1040 + index * 108, 98)
		hook.size = Vector2(100, 28)
		hook.add_theme_font_size_override("font_size", 14)
		hook.gui_input.connect(func(event):
			if mode == "PLAN" and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				_hook_drag = index
		)
		_ui.add_child(hook)
		_hooks.append(hook)
	_stage = STAGE.new()
	_stage.name = "Stage"
	_stage.position = Vector2(16, 132)
	_stage.size = Vector2(1248, 460)
	_ui.add_child(_stage)
	_stage.spotlight_moved.connect(_move_light)
	_stage.lantern_moved.connect(_move_lantern)
	_stage.thought_swapped.connect(_swap)
	_stage.bubble_picked.connect(func(_id: String):
		_play_effect("PICK")
		_tutorial_event("choose")
		_tutorial_event("picked"))
	_stage.swap_landed.connect(_on_swap_landed)
	_stage.actor_revealed.connect(func(id: String, thought: String):
		_play_effect("REVEAL_" + thought)
		_say_scripted("lit", [id]))
	_stage.actor_poked.connect(func(_id: String, kind: String): _play_effect(kind))
	_stage.flick_cleared.connect(_clear_flick)
	_stage.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mode == "PLAN":
			_tutorial_click())
	_stage.preview_requested.connect(_preview)
	_stage.preview_cleared.connect(_stage.clear_preview)
	_comparison = HBoxContainer.new()
	_comparison.position = Vector2(16, 132)
	_comparison.size = Vector2(1248, 460)
	_comparison.add_theme_constant_override("separation", 12)
	_ui.add_child(_comparison)
	for side in range(2):
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_comparison.add_child(column)
		column.add_child(_label("ORIGINAL" if side == 0 else "YOUR TWIST", 18))
		var view = STAGE.new()
		view.size_flags_vertical = Control.SIZE_EXPAND_FILL
		view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(view)
		var caption := _label("", 16)
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		caption.custom_minimum_size.y = 64
		column.add_child(caption)
		if side == 0:
			_original_stage = view
			_original_caption = caption
		else:
			_result_stage = view
			_twist_caption = caption
	_comparison.hide()
	_stamp = _label("", 64)
	_stamp.add_theme_font_override("font", COMIC_FONT)
	_stamp.name = "Stamp"
	_stamp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stamp.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_stamp.size = Vector2(420, 96)
	_stamp.position = Vector2(745, 168)
	_stamp.pivot_offset = _stamp.size * 0.5
	_stamp.add_theme_constant_override("outline_size", 12)
	_stamp.z_index = 150
	_stamp.hide()
	_ui.add_child(_stamp)
	_missing = _label("", 18)
	_missing.name = "Missing"
	_missing.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_missing.position = Vector2(16, 462)
	_missing.size = Vector2(1248, 56)
	_missing.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_missing.add_theme_color_override("font_color", Color("a4383e"))
	_missing.z_index = 150
	_missing.hide()
	_ui.add_child(_missing)
	_pop = _label("", 15)
	_pop.hide()
	_ui.add_child(_pop)
	_caption = _label("", 16)
	_caption.position = Vector2(16, 595)
	_caption.size = Vector2(1248, 24)
	_ui.add_child(_caption)
	_subtitle = _label("", 16)
	_subtitle.position = Vector2(16, 618)
	_subtitle.size = Vector2(994, 46)
	_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ui.add_child(_subtitle)
	var voice_buttons := HBoxContainer.new()
	voice_buttons.position = Vector2(1016, 625)
	_ui.add_child(voice_buttons)
	_voice_replay = _button(voice_buttons, "Replay voice", _replay_voice)
	_voice_skip = _button(voice_buttons, "Skip voice", _stop_voice)
	var buttons := HBoxContainer.new()
	buttons.position = Vector2(16, 665)
	buttons.add_theme_constant_override("separation", 8)
	_ui.add_child(buttons)
	_action = _button(buttons, "ACTION!", _start_action)
	_rewind = _button(buttons, "REWIND", _return_to_plan)
	_restart = _button(buttons, "RESTART", _restart_page)
	_original = _button(buttons, "ORIGINAL", _replay_original)
	_fast_button = _button(buttons, "FAST", _toggle_fast)
	_skip_run = _button(buttons, "SKIP RUN", _finish_run)
	_next = _button(buttons, "NEXT PAGE", _next_page)
	_skip_page = _button(buttons, "SKIP PAGE", _skip_current_page)
	_hint_button = _button(buttons, "HINT", _show_hint)
	_status = _label("", 12)
	_status.position = Vector2(16, 705)
	_status.size = Vector2(1248, 15)
	_ui.add_child(_status)
	for i in range(8):
		var player := AudioStreamPlayer.new()
		player.volume_db = SFX_DB
		add_child(player)
		_players.append(player)
	# Recorded character lines get their own pool on the Voice bus so a burst of
	# sound effects never cuts them off.
	for i in range(3):
		var player := AudioStreamPlayer.new()
		player.volume_db = CHARACTER_DB
		add_child(player)
		_character_players.append(player)
	_voice = AudioStreamPlayer.new()
	_voice.volume_db = NARRATOR_DB
	_voice.finished.connect(_on_voice_finished)
	add_child(_voice)
	var lines: Variant = JSON.parse_string(FileAccess.get_file_as_string(VOICE_ROOT + "lines.json"))
	if lines is Dictionary:
		_lines = lines
	var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/reference/cues.json"))
	if manifest is Dictionary:
		for cue in manifest.get("cues", []):
			if cue is Dictionary and ResourceLoader.exists(cue.get("audio", "")):
				_cues[cue.id] = cue
	_update_voice_buttons()
	_restyle_hud()


func _layout_ui() -> void:
	var factor := minf(size.x / 1280.0, size.y / 720.0)
	_ui.scale = Vector2.ONE * factor
	_ui.position = (size - Vector2(1280, 720) * factor) * 0.5
	_update_backdrop()


## Map the painting onto the window so it lines up exactly with the stage band
## (room_light.gdshader shows crop y 0.20..0.84 across the 1280x460 band).
func _update_backdrop() -> void:
	if not is_instance_valid(_backdrop) or not is_instance_valid(_stage) or _ui.scale.x <= 0.0:
		return
	var painting: Texture2D = _stage.painting()
	if painting != null:
		_backdrop.material.set_shader_parameter("painting", painting)
	var band_top: float = _stage.position.y
	var corner: Vector2 = -_ui.position / _ui.scale.x
	var span: Vector2 = size / _ui.scale.x
	var crop := Vector4(corner.x / 1280.0, 0.20 + 0.64 * (corner.y - band_top) / 460.0, span.x / 1280.0, 0.64 * span.y / 460.0)
	_backdrop.material.set_shader_parameter("crop", crop)
	_backdrop.visible = _stage.full_bleed and painting != null


func _rich(font_size: int) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = false
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("normal_font_size", font_size)
	label.add_theme_font_size_override("bold_font_size", font_size)
	label.add_theme_font_override("bold_font", TEXT_FONT)
	label.add_theme_color_override("default_color", INK)
	return label


func _icon(name: String, size: int = 16) -> String:
	return "[img=%dx%d]res://assets/ui/%s.svg[/img] " % [size, size, name]


func _label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", INK)
	return label


func _button(parent: Node, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.name = text.replace("!", "").replace(" ", "_")
	button.add_theme_font_size_override("font_size", 16)
	button.custom_minimum_size.y = 40
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _load_page(index: int, override: Dictionary = {}) -> void:
	_cancel_presentation()
	# A tutorial welcome still waiting for the title menu belongs to page 1 only.
	_intro_pending = false
	_redpen_done = false
	# Cards belong to the page that queued them.
	_story_queue.clear()
	if is_instance_valid(_story_card):
		_story_card.queue_free()
	if is_instance_valid(_stage):
		_stage.set_caption("", 0.0)
	_last_cue = ""
	page_index = index
	if override.is_empty():
		_tutorial_panel = -1
		var tutorial: Variant = PAGE_SCRIPTS[index].definition().get("tutorial")
		if tutorial is Dictionary and not tutorial_done and _persistent_or_campaign():
			# First visit: the tutorial panels come before Dinner Time itself.
			_start_tutorial(index)
			return
	var validated: Dictionary = VALIDATOR.new().validate(PAGE_SCRIPTS[index].definition() if override.is_empty() else override)
	if not validated.errors.is_empty():
		mode = "ERROR"
		_caption.text = "Content error: " + "; ".join(validated.errors)
		_update_buttons()
		return
	page = validated.page
	GOALS.set_page(page)
	_lanterns_useful = _needs_lanterns(page)
	plan = PLAN.from_page(page)
	knowledge.clear()
	_hints_shown = 0
	attempts = 0
	failures = 0
	_saved_plan = plan.to_data()
	for view in [_stage, _original_stage, _result_stage]:
		view.configure(page)
	_title.text = "LIGHTBULB MOMENT  ·  Page %d: %s" % [index + 1, page.title]
	_update_subject()
	_tutorial_step = 0
	_tutorial_gate_hold = false
	_goal.text = "TWIST: " + page.goal.twist_caption
	_original_run = SIMULATOR.run(page, plan.to_data(), true)
	_begin(_original_run, true)
	_fail_count = 0
	_said_scripted.clear()
	if is_instance_valid(_legend):
		_legend.text = _legend_text()
	_queue_story_cards()
	_update_backdrop()
	_iris_open()
	_narrate("intro")
	if page.id == "page_02" and not page.has("narration") and _cues.has("narrator_intro"):
		_story_waiting = true
		_last_cue = "narrator_intro"
		_subtitle.text = "Start the story to hear the narrator, or skip voice to watch the Original."
		_update_voice_buttons()
		if is_instance_valid(_front) and not _front.visible:
			# Audio is already unlocked by an earlier click; start straight away.
			_replay_voice()


func _start_action() -> void:
	if mode != "PLAN":
		return
	_tutorial_event("action")
	_coach_event("action")
	attempts += 1
	_stage.set_caption("")
	_saved_plan = plan.to_data()
	_begin(SIMULATOR.run(page, _saved_plan, true), false)


func _begin(recorded: Dictionary, original: bool) -> void:
	_cancel_presentation()
	_run_said.clear()
	_last_cue = ""
	_update_voice_buttons()
	_run = recorded
	_won_current = false
	_is_original = original
	mode = "INTRO" if original else "PLAY"
	_cursor = 0
	_hitstop = 0.0
	_decisive_beat = -1 if original else _find_decisive_beat(recorded)
	_frame_cursor = 0
	_playback_world = _run.snapshots[0]
	_clock = 0.0
	_anticipation = 0.6
	_fast = false
	_ding_count = 0
	_caption.text = "ORIGINAL" if original else "AND THEN..."
	_pop.text = ""
	_stage.show()
	_comparison.hide()
	_stage.clear_preview()
	_stage.set_playback_speed(1.0)
	_stage.set_mood("watch")
	_display(_run.snapshots[0], false)
	_initial_events_pending = true
	_update_buttons()


func _process(delta: float) -> void:
	_hold_repeat(delta)
	_coach_tick(delta)
	_update_music(delta)
	_update_narration_line()
	if _intro_pending and _tutorial_panel == 0 and not (is_instance_valid(_front) and _front.visible):
		_show_intro_card()
	if not _pending_narration.is_empty() and not _screen_covered() and page_index >= 0:
		_narrate(_pending_narration)
	if _narrator_hold and not _voice_busy():
		_narrator_hold = false
	if _read_hold > 0.0 and not _screen_covered():
		_read_hold = maxf(0.0, _read_hold - delta)
	if not _story_queue.is_empty() and not (_title_voice and _voice_busy()) and not (is_instance_valid(_front) and _front.visible) and not (is_instance_valid(_intro_card) and _intro_card.visible) and not (is_instance_valid(_story_card) and _story_card.visible):
		_show_story_card(_story_queue.pop_front())
	if not _active_cue.is_empty():
		_voice_elapsed += delta
		# A suspended/unavailable audio device cannot hold gameplay forever.
		if _voice_elapsed > float(_cues[_active_cue].duration_seconds) + 0.75:
			_stop_voice()
	if _story_waiting:
		return
	if mode == "ORIGINAL_END":
		_clock += delta
		if _clock >= 0.6 and _active_cue.is_empty() and _read_hold <= 0.0 and (not _voice_busy() or _clock >= 12.0):
			_return_to_plan()
		return
	if mode not in ["INTRO", "PLAY"]:
		return
	# The story prologue finishes before the Original acts; skip voice is explicit.
	if _is_original and (_active_cue == "narrator_intro" or _screen_covered() or not _pending_narration.is_empty() or (_narrator_hold and _voice_busy()) or _read_hold > 0.0):
		return
	var elapsed := delta * (3.0 if _fast else 1.0)
	var aim := _aim_slot()
	_stage.set_flick_ready(_flick_available(), aim)
	if aim >= 0:
		elapsed *= AIM_SLOWDOWN
	elif _decisive_beat > 0 and not _fast and not _motion.button_pressed and int(_clock / BEAT_SECONDS) + 1 == _decisive_beat:
		elapsed *= DECISIVE_SLOWDOWN
	if _hitstop > 0.0:
		_hitstop = maxf(0.0, _hitstop - delta)
		return
	if _anticipation > 0:
		_anticipation -= elapsed
		return
	if _initial_events_pending:
		_events_at(0)
		_initial_events_pending = false
	_clock += elapsed
	var frames: Array = _run.get("presentation_frames", [])
	while _frame_cursor < frames.size():
		var frame: Dictionary = frames[_frame_cursor]
		var due := (float(frame.beat) - 1.0) * BEAT_SECONDS + float(PHASE_TIME[frame.phase])
		if _clock < due:
			break
		_playback_world = frame.world
		_cursor = int(frame.beat)
		_display(_playback_world, false, str(frame.phase))
		_events_at(int(frame.beat), str(frame.phase))
		_frame_cursor += 1
	# Hold the final contact/recovery before presenting the comparison panels.
	var end_time := float(_run.end_beat) * BEAT_SECONDS + RECOVERY_SECONDS
	if _flick_available():
		end_time = maxf(end_time, float(FLICK_WINDOW_BEATS) * BEAT_SECONDS + RECOVERY_SECONDS)
	if _clock >= end_time:
		_finish_run(true)
		return
	var positions: Dictionary = {}
	var headings: Dictionary = {}
	if not _motion.button_pressed:
		# Walk across (almost) the whole beat at constant speed, so consecutive
		# steps join into one continuous stroll instead of stop-go hops. The
		# visual position keeps overriding the slot after the MOVE phase lands.
		var next_beat := int(_clock / BEAT_SECONDS) + 1
		var local_time := fmod(_clock, BEAT_SECONDS)
		var walkers: Dictionary = {}
		for event in _run.events:
			if event.type == "MOVE" and absi(int(event.beat) - next_beat) <= 1:
				walkers[str(event.actor) + ":" + str(event.beat)] = true
		for event in _run.events:
			if event.beat == next_beat and event.type == "MOVE":
				var before: bool = walkers.has(str(event.actor) + ":" + str(next_beat - 1))
				var after: bool = walkers.has(str(event.actor) + ":" + str(next_beat + 1))
				# A step that continues into the next one uses the whole beat at
				# constant speed; a single step eases in and out.
				var fraction := clampf(local_time / (BEAT_SECONDS if after else MOVE_SECONDS), 0.0, 1.0)
				if not before and not after:
					fraction = smoothstep(0.0, 1.0, fraction)
				positions[event.actor] = lerpf(float(event.from), float(event.to), fraction)
				headings[event.actor] = signf(float(event.to) - float(event.from))
	_stage.motion_headings = headings
	_stage.pose(_playback_world, _run.plan, knowledge, false, [], positions)


func _display(world: Dictionary, planning: bool, phase: String = "") -> void:
	var data: Dictionary = plan.to_data() if planning else _run.plan
	_remember(world, data, planning)
	var intentions: Array = RULES.decisions(world, RULES.lit_slots(page, data, world)) if planning else []
	_stage.pose(world, data, knowledge, planning, intentions)
	if not planning:
		var partial := {"plan": _run.plan, "snapshots": [world], "events": _run.events.filter(func(event):
			return event.beat < world.beat or (event.beat == world.beat and (phase.is_empty() or float(PHASE_TIME.get(event.phase, 0.0)) <= float(PHASE_TIME[phase]))))}
		_show_facts(GOALS.evaluate(page, partial))


func _remember(world: Dictionary, data: Dictionary, planning: bool) -> void:
	for actor in world.characters:
		var visible: bool = RULES.is_lit(page, data, world, actor.slot) if planning else actor.active
		if visible and actor.status != "EXITED":
			knowledge[actor.id] = actor.thought


func _events_at(beat: int, phase: String = "ACTIVATE") -> void:
	var events: Array = _run.events.filter(func(event): return event.beat == beat and event.phase == phase and event.type != "MOVE")
	if phase == "DECIDE":
		events.append_array(_run.events.filter(func(event): return event.beat == beat and event.type == "MOVE"))
	_stage.present_events(events, 3.0 if _fast else 1.0, _motion.button_pressed)
	_speak(events)
	for event in events:
		if HITSTOP.has(event.type) and not _fast:
			_hitstop = maxf(_hitstop, float(HITSTOP[event.type]))
		if event.type == "DING":
			_ding(480.0 * pow(1.12, _ding_count))
			_ding_count += 1
		elif event.type in ["MOVE", "EAT", "SIT", "BONK", "CLASH", "WHIFF", "LAMP_ON", "HUG"]:
			_play_effect(event.type)


func _finish_run(natural := false) -> void:
	if mode == "ORIGINAL_END":
		_return_to_plan()
		return
	if mode not in ["INTRO", "PLAY"]:
		return
	_cancel_presentation(natural)
	_cursor = _run.snapshots.size() - 1
	_display(_run.snapshots.back(), false)
	if _is_original:
		# Show the final Original snapshot before returning: it is player evidence.
		mode = "ORIGINAL_END"
		_clock = 0.0
		_caption.text = "ORIGINAL: " + GOALS.evaluate(page, _run).caption
		_narrate("original")
		_update_buttons()
		return
	if _revealing:
		mode = "REVEAL"
		for view in [_stage, _result_stage]:
			view.set_mood("win")
		_play_effect("EXIT")
		get_tree().create_timer(1.2).timeout.connect(_finish_reveal)
		_update_buttons()
		return
	mode = "RESULT"
	var stars_before := _stars(page)
	var result: Dictionary = GOALS.evaluate(page, _run)
	_won_current = result.won
	_show_facts(result)
	if result.won:
		if _tutorial_panel < 0:
			completed[page.id] = true
	else:
		failures += 1
	run_history.append({"page": page.id, "attempt": attempts, "won": result.won, "plan": _saved_plan.duplicate(true), "end_beat": _run.end_beat})
	_caption.text = ("TWIST! " if result.won else "THE END...? ") + result.caption
	_original_caption.text = GOALS.evaluate(page, _original_run).caption
	_twist_caption.text = result.caption
	_original_stage.pose(_original_run.snapshots.back(), _original_run.plan, {}, false)
	_result_stage.pose(_run.snapshots.back(), _run.plan, knowledge, false)
	_stage.show()
	_comparison.hide()
	var rewards := _record_progress(result)
	rewards.append_array(_gag_lines(result))
	_show_payoff(result, rewards)
	_show_result_card(result)
	var stars_after := _stars(page)
	if _tutorial_panel < 0 and page_override.is_empty() and (result.won or stars_after > stars_before):
		_show_star_award(stars_before, stars_after, result.won)
	if result.won:
		_narrate("twist")
		_say_scripted("win", [])
		if page.get("finale", false) and str(page.get("voice", "")).is_empty():
			get_tree().create_timer(3.5).timeout.connect(func():
				if mode == "RESULT":
					_narrate_key("narr_finale_end"))
	else:
		_fail_count += 1
		_narrate("fail_%d" % _fail_count)
	for view in [_stage, _result_stage]:
		view.set_mood("win" if result.won else "fail")
	if page.id == "page_02" and result.won and not page.has("narration"):
		_play_voice("narrator_success")
	_update_buttons()


func _show_facts(result: Dictionary) -> void:
	var labels: Array[String] = []
	for item in result.facts:
		var fact: Dictionary = item.fact
		var mark := _icon("check") if item.met else (_icon("cross") if mode == "RESULT" else _icon("box"))
		labels.append(mark + GOALS.fact_text(fact))
	# Bonus goals are always visible on their own line of the goal card.
	var bonus_lines: Array[String] = []
	var ladder := page.has("ladder")
	for bonus in _star_steps(page):
		var done: bool = bonus.id in bonus_done.get(page.id, [])
		var caption := str(bonus.caption) if ladder else _sentence_case(str(bonus.caption))
		bonus_lines.append(_icon("star_on" if done else "star_off") + ("[color=#6f6a5e][i]%s[/i][/color]" % caption if ladder else caption))
	_facts.text = "   /   ".join(labels)
	if is_instance_valid(_bonus_line):
		var heading := "[b]Fine-tunes:[/b]  " if ladder else "[b]Bonus stars:[/b]  "
		_bonus_line.text = (heading + "     ".join(bonus_lines)) if not bonus_lines.is_empty() else ""
	_facts.mouse_filter = Control.MOUSE_FILTER_PASS
	_facts.add_theme_color_override("default_color", Color("a4383e") if mode == "RESULT" and not result.won else INK)


func _return_to_plan() -> void:
	var from_original := mode == "ORIGINAL_END" or (mode == "INTRO" and _is_original)
	_cancel_presentation()
	# The result's "YOUR TWIST:" caption belongs to the result, not the plan.
	_stage.set_caption("", 0.0)
	if from_original and not _redpen_done:
		_redpen_done = true
		_narrate.call_deferred("redpen")
	_last_cue = ""
	_update_voice_buttons()
	if mode == "ERROR":
		return
	mode = "PLAN"
	plan.restore(_saved_plan)
	# Known bubbles describe the restored PLAN, even after replaying defaults.
	# Reconcile only known identities so hidden actors remain hidden.
	for id in knowledge:
		if plan.thoughts.has(id):
			knowledge[id] = plan.thoughts[id]
	_stage.show()
	_comparison.hide()
	_caption.text = ""
	_stage.set_mood("idle")
	_pop.text = ""
	_refresh_plan()
	_update_buttons()


func _refresh_plan() -> void:
	call_deferred("_check_tutorial_gates")
	_display(RULES.initial_world(page, plan.to_data()), true)
	_show_facts({"facts": page.goal.facts.map(func(fact): return {"fact": fact, "met": false})})
	_facts.add_theme_color_override("default_color", INK)
	_update_hooks()
	_update_instructions()


func _move_light(index: int, centre: int) -> void:
	if mode == "PLAN" and plan.place(page, index, centre):
		_stage.clear_preview()
		_refresh_plan()


func _move_lantern(index: int, position: Vector2, enabled: bool = true) -> void:
	if mode == "PLAN" and plan.move_lantern(page, index, position, enabled):
		_stage.clear_preview()
		_refresh_plan()
		_coach_event("move")


func _lit_ids() -> Array[String]:
	var ids: Array[String] = []
	var world: Dictionary = RULES.initial_world(page, plan.to_data())
	for actor in world.characters:
		if actor.active:
			ids.append(actor.id)
	return ids


var _last_land_msec := 0


## One chime per swap, however many thoughts land together.
func _on_swap_landed(_id: String) -> void:
	var now := Time.get_ticks_msec()
	if now - _last_land_msec > 120:
		_last_land_msec = now
		_play_effect("LAND")


func _swap(first: String, second: String) -> void:
	if mode == "PLAN" and plan.swap(first, second, _lit_ids()):
		_stage.clear_preview()
		_refresh_plan()
		_stage.react_swap(first, second)
		_coach_event("pick")
		_coach_event("swap")
		_tutorial_event("swap")
		_play_effect("SWAP")
		_say_scripted("swap", [first, second])
		for id in [first, second]:
			_say_scripted("gets_" + str(plan.thoughts.get(id, "")), [id])


func _preview(first: String, second: String) -> void:
	if mode != "PLAN":
		return
	_coach_event("pick")
	var hypothetical = PLAN.from_page(page)
	hypothetical.restore(plan.to_data())
	if hypothetical.swap(first, second, _lit_ids()):
		var data: Dictionary = hypothetical.to_data()
		var world: Dictionary = RULES.initial_world(page, data)
		_stage.set_preview(world, RULES.decisions(world, RULES.lit_slots(page, data, world)))


func _restart_page() -> void:
	if mode not in ["PLAN", "RESULT"]:
		return
	plan = PLAN.from_page(page)
	_saved_plan = plan.to_data()
	_return_to_plan()


func _replay_original() -> void:
	_tutorial_event("clipping_opened")
	if mode not in ["PLAN", "RESULT"]:
		return
	_saved_plan = plan.to_data()
	_begin(_original_run, true)


func _toggle_fast() -> void:
	_fast = not _fast
	_stage.set_playback_speed(3.0 if _fast else 1.0)
	_update_buttons()


func _next_page() -> void:
	if mode != "RESULT" or not _won_current:
		return
	if _tutorial_panel >= 0:
		_advance_tutorial_panel()
		return
	if page_index < PAGE_SCRIPTS.size() - 1:
		var next := page_index + 1
		var turn := func(): _iris_close(func(): _load_page(next))
		if _between_pages_card(turn):
			return
		turn.call()
	elif page.has("reveal") and page_override.is_empty():
		_start_reveal()
	else:
		_open_edition()


func _skip_current_page() -> void:
	if failures < 3 or mode not in ["PLAN", "RESULT"]:
		return
	skipped[page.id] = true
	_save_progress()
	if page_index < PAGE_SCRIPTS.size() - 1:
		_load_page(page_index + 1)
	else:
		_load_page(0)


func _update_buttons() -> void:
	_update_hooks()
	var playing := mode in ["INTRO", "PLAY", "ORIGINAL_END"]
	_action.disabled = mode != "PLAN"
	_rewind.disabled = mode != "RESULT"
	_restart.disabled = mode not in ["PLAN", "RESULT"]
	_original.disabled = mode not in ["PLAN", "RESULT"]
	_fast_button.disabled = not playing
	_fast_button.text = "1x" if _fast else "FAST"
	_skip_run.disabled = not playing
	_next.disabled = mode != "RESULT" or not _won_current
	_next.text = "THE END" if page_index == PAGE_SCRIPTS.size() - 1 else "NEXT PAGE"
	_skip_page.disabled = failures < 3 or mode not in ["PLAN", "RESULT"]
	var hints: Array = _all_hints()
	_hint_button.visible = not hints.is_empty() and _hints_shown < hints.size()
	if is_instance_valid(_hint_hud):
		_hint_hud.visible = mode == "PLAN" and not hints.is_empty()
		_hint_hud.disabled = _hints_shown >= hints.size()
		_hint_hud.tooltip_text = "Hint %d of %d" % [mini(_hints_shown + 1, hints.size()), hints.size()] if _hints_shown < hints.size() else "No more hints"
	_hint_button.disabled = mode not in ["PLAN", "RESULT"]
	_hint_button.text = "HINT %d/%d" % [_hints_shown + 1, hints.size()]
	_status.text = "Page %d of %d   ·   Runs %d   ·   Pages solved %d / %d" % [page_index + 1, PAGE_SCRIPTS.size(), attempts, completed.size(), PAGE_SCRIPTS.size()]
	if completed.size() == PAGE_SCRIPTS.size():
		_status.text = "Every page solved. Try for different endings!"
	_update_instructions()
	_update_progress_label()
	_emphasise(_action, mode == "PLAN")
	_gated_key = ""
	_apply_tutorial_gating()
	if is_instance_valid(_pause_button):
		var playing_now := mode in ["INTRO", "PLAY", "ORIGINAL_END"]
		_action.visible = mode == "PLAN"
		_restart.visible = mode == "PLAN"
		_fast_button.visible = playing_now
		_skip_run.visible = playing_now
		_legend.visible = mode == "PLAN"
		_title.text = "PAGE %d  ·  %s" % [page_index + 1, str(page.get("title", "")).to_upper()]
		if _tutorial_panel >= 0:
			_title.text = "TUTORIAL %d/%d  ·  %s" % [_tutorial_panel + 1, _tutorial_data().get("panels", []).size(), str(page.get("title", "")).to_upper()]
		_progress_label.visible = _tutorial_panel < 0 or _tutorial_has_gate("endings_opened")
		if is_instance_valid(_tutorial_skip):
			_tutorial_skip.visible = _tutorial_panel >= 0
		_tier_band.color = TIER_COLOURS[_tier(page_index)]
		_action.text = " ACTION!"
		_fast_button.text = ""
	_emphasise(_next, mode == "RESULT" and _won_current)
	_emphasise(_rewind, mode == "RESULT" and not _won_current)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE and not _stage.key_picked.is_empty() and mode == "PLAN":
		# Esc first drops a thought picked with the keyboard.
		_stage.key_picked = ""
		_stage.clear_preview()
		_stage.queue_redraw()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		# Esc always goes back one step.
		if is_instance_valid(_settings_sheet) and _settings_sheet.visible:
			_close_settings()
		elif is_instance_valid(_front) and _front.visible:
			_front.go_back()
		elif is_instance_valid(_endings_book):
			_endings_book.queue_free()
		elif is_instance_valid(_pause_sheet) and _pause_sheet.visible:
			_close_pause()
		elif not (is_instance_valid(_front) and _front.visible):
			_open_pause()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M and not event.ctrl_pressed:
		# M mutes / unmutes from anywhere.
		_sound.button_pressed = not _sound.button_pressed
		get_viewport().set_input_as_handled()
		return
	if (is_instance_valid(_pause_sheet) and _pause_sheet.visible) or (is_instance_valid(_settings_sheet) and _settings_sheet.visible) or (is_instance_valid(_intro_card) and _intro_card.visible):
		return
	if is_instance_valid(_front) and _front.visible:
		# The title / Sunday Edition owns input; its buttons handle it via the GUI.
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and mode == "PLAN":
		var mouse := get_global_mouse_position()
		if _hook_drag >= 0:
			var index := _hook_drag
			_hook_drag = -1
			if _stage.get_global_rect().has_point(mouse):
				var local: Vector2 = _stage.get_global_transform().affine_inverse() * mouse
				_move_lantern(index, _stage.stage_to_world(_stage.to_stage(local)), true)
			elif _hooks[index].get_global_rect().has_point(mouse):
				var lantern: Dictionary = plan.lanterns[index]
				_move_lantern(index, Vector2(lantern.x, lantern.y), not lantern.enabled)
			get_viewport().set_input_as_handled()
			return
		if _stage._drag_bulb >= 0:
			for hook in _hooks:
				if hook.get_global_rect().has_point(mouse):
					var index: int = _stage._drag_bulb
					var lantern: Dictionary = plan.lanterns[index]
					_stage._cancel_drag()
					_move_lantern(index, Vector2(lantern.x, lantern.y), false)
					get_viewport().set_input_as_handled()
					return
	# UI controls retain their input while the Original is running.
	if event is InputEventMouseButton and event.pressed:
		for button in [_sound, _motion, _voice_replay, _voice_skip, _skip_run, _fast_button]:
			if button.get_global_rect().has_point(get_global_mouse_position()):
				return
	var pressed_key: bool = event is InputEventKey and event.pressed and not event.echo
	var pressed_mouse: bool = event is InputEventMouseButton and event.pressed
	if mode == "PLAY" and pressed_mouse and event.button_index == MOUSE_BUTTON_LEFT and _flick_available():
		var slot := _aim_slot()
		if slot >= 0:
			_drop_flick(slot)
			get_viewport().set_input_as_handled()
			return
	if mode in ["INTRO", "ORIGINAL_END"] and (pressed_key or pressed_mouse):
		_finish_run()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		if mode == "PLAN":
			if _tutorial_pass():
				get_viewport().set_input_as_handled()
				return
			if not _tutorial_allows("action"):
				get_viewport().set_input_as_handled()
				return
			_start_action()
		elif mode in ["INTRO", "PLAY", "ORIGINAL_END"]:
			_finish_run()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and _keyboard(event):
		get_viewport().set_input_as_handled()


func _ding(frequency: float) -> void:
	if not _sound.button_pressed or DisplayServer.get_name() == "headless":
		return
	var sample_rate := 22050
	var samples := int(sample_rate * 0.18)
	var bytes := PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / sample_rate
		var envelope := minf(1.0, t * 150.0) * exp(-t * 22.0)
		var value := int(16000.0 * envelope * (sin(TAU * frequency * t) + 0.25 * sin(TAU * frequency * 2.0 * t)))
		bytes.encode_s16(i * 2, clampi(value, -32768, 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = bytes
	var player := _players[_audio_index % _players.size()]
	_audio_index += 1
	player.stream = stream
	player.play()


func _cancel_presentation(keep_audio := false) -> void:
	_hook_drag = -1
	_hide_payoff()
	if not keep_audio:
		_stop_voice()
		for player in _players + _character_players:
			if player in _character_players:
				_fade_out(player, 0.15)
			else:
				player.stop()
	for view in [_stage, _original_stage, _result_stage]:
		if is_instance_valid(view):
			view.cancel_presentation()


func _sound_changed(enabled: bool) -> void:
	if not enabled:
		_stop_voice()
		for player in _players + _character_players:
			player.stop()
	_update_voice_buttons()


func _motion_changed(enabled: bool) -> void:
	for view in [_stage, _original_stage, _result_stage]:
		view.set_reduced_motion(enabled)


func _play_voice(id: String) -> void:
	if not _cues.has(id):
		return
	_stop_voice()
	_last_cue = id
	if not _sound.button_pressed:
		_update_voice_buttons()
		return
	var cue: Dictionary = _cues[id]
	_active_cue = id
	_voice_elapsed = 0.0
	_cancel_fade(_voice)
	_voice.stream = load(cue.audio)
	_subtitle.text = cue.speaker + ": " + cue.text
	if DisplayServer.get_name() != "headless":
		_voice.play()
	else:
		# Headless checks inspect cues without waiting for real-time audio.
		_active_cue = ""
	_update_voice_buttons()


func _replay_voice() -> void:
	if _story_waiting:
		# Starting the story is the explicit gesture that also leaves the title.
		if is_instance_valid(_front):
			_front.hide()
		_story_waiting = false
		# This callback runs inside the deliberate user gesture that unlocks Web audio.
		_events_at(0)
		_initial_events_pending = false
	if not _last_cue.is_empty():
		_play_voice(_last_cue)


func _stop_voice() -> void:
	_story_waiting = false
	_narrator_hold = false
	_voice_queue.clear()
	if is_instance_valid(_voice):
		if _voice.playing:
			_fade_out(_voice)
		else:
			_voice.stream = null
	_active_cue = ""
	if is_instance_valid(_subtitle):
		_subtitle.text = ""
	_update_voice_buttons()


func _update_voice_buttons() -> void:
	if is_instance_valid(_voice_replay):
		_voice_replay.text = "Start story" if _story_waiting else "Replay voice"
		_voice_replay.disabled = _last_cue.is_empty() or (not _sound.button_pressed and not _story_waiting)
		_voice_skip.disabled = _active_cue.is_empty() and not _story_waiting


func _update_hooks() -> void:
	for index in _hooks.size():
		var enabled: bool = index < plan.lanterns.size() and plan.lanterns[index].enabled if plan != null else false
		_hooks[index].text = "Hook %d: %s" % [index + 1, "out" if enabled else "park"]
		_hooks[index].disabled = mode != "PLAN"
		_hooks[index].visible = _lanterns_useful and index < int(page.get("lanterns", {}).get("count", 2))


func _play_effect(kind: String) -> void:
	if not _sound.button_pressed or DisplayServer.get_name() == "headless":
		return
	if not _effect_streams.has(kind):
		_effect_streams[kind] = _make_effect(kind)
	var player := _players[_audio_index % _players.size()]
	_audio_index += 1
	player.stream = _effect_streams[kind]
	player.play()


func _make_effect(kind: String) -> AudioStreamWAV:
	# Original procedural sound design; no imported sound library or random state.
	var sample_rate := 22050
	var duration := 0.28 if kind in ["EAT", "SIT"] else 0.16
	if kind.begins_with("REVEAL_") or kind.begins_with("POKE_") or kind in ["HMPH"]:
		duration = 0.32
	if kind == "SWAP":
		duration = 0.24
	if kind == "PICK":
		duration = 0.11
	if kind == "LAND":
		duration = 0.22
	if kind == "HUG":
		duration = 0.24
	var bytes := PackedByteArray()
	bytes.resize(int(sample_rate * duration) * 2)
	for index in bytes.size() / 2:
		var t := float(index) / sample_rate
		var noise := sin(t * 92371.0) * sin(t * 17639.0)
		var value := 0.0
		match kind:
			"MOVE":
				var step_time := t if t < 0.08 else t - 0.08
				value = exp(-step_time * 70.0) * (sin(TAU * 105.0 * step_time) + noise * 0.16) * 0.28
			"EAT":
				value = (noise * 0.65 + sin(TAU * 340.0 * t) * 0.12) * exp(-t * 13.0) * (0.5 + 0.5 * sin(TAU * 18.0 * t))
			"SIT":
				value = sin(TAU * (220.0 * t - 120.0 * t * t)) * exp(-t * 15.0) * 0.35
			"BONK", "CLASH":
				value = (sin(TAU * (155.0 * t - 180.0 * t * t)) + noise * 0.3) * exp(-t * 27.0) * 0.65
			"WHIFF":
				value = noise * sin(PI * t / duration) * 0.22
			"LAMP_ON":
				value = (noise + sin(TAU * 1300.0 * t) * 0.3) * exp(-t * 90.0) * 0.4
			"REVEAL_HUNGRY", "POKE_HUNGRY":
				# Stomach growl: low wobbling rumble.
				value = sin(TAU * (70.0 + 25.0 * sin(TAU * 9.0 * t)) * t) * (0.6 + noise * 0.4) * sin(PI * t / duration) * 0.5
			"REVEAL_SLEEPY", "POKE_SLEEPY":
				# Yawn: a slow falling tone.
				value = sin(TAU * (420.0 * t - 380.0 * t * t)) * sin(PI * t / duration) * 0.35
			"REVEAL_ANGRY", "POKE_ANGRY":
				# Grumble: buzzing low saw.
				value = (fmod(t * 95.0, 1.0) * 2.0 - 1.0) * sin(PI * t / duration) * (0.5 + 0.5 * sin(TAU * 14.0 * t)) * 0.35
			"REVEAL_SCARED", "POKE_SCARED":
				# Teeth chatter: rapid clicks.
				value = noise * (1.0 if fmod(t * 28.0, 1.0) < 0.25 else 0.0) * 0.5
			"HMPH":
				# Generic sleepy grumble used for every dark actor.
				value = sin(TAU * 140.0 * t) * exp(-t * 10.0) * 0.4
			"SWAP":
				# Whoosh: a quick rising sweep with a breath of noise.
				value = (sin(TAU * (300.0 * t + 1400.0 * t * t)) * 0.8 + noise * 0.25) * sin(PI * t / duration) * 0.28
			"PICK":
				# Pluck: a bright little bubble blip going up.
				value = sin(TAU * (520.0 * t + 3200.0 * t * t)) * exp(-t * 26.0) * 0.4
			"LAND":
				# Pop and two-note chime: satisfying and short.
				var chime := 880.0 if t < 0.07 else 1175.0
				value = (sin(TAU * chime * t) + 0.35 * sin(TAU * chime * 2.0 * t)) * exp(-t * 17.0) * 0.32 + noise * exp(-t * 120.0) * 0.3
			"HUG":
				# Squeeze: a warm two-note "aww".
				value = (sin(TAU * 523.0 * t) + sin(TAU * (659.0 if t > 0.07 else 523.0) * t)) * sin(PI * t / duration) * 0.22
			"REVEAL_SHY", "POKE_SHY":
				# Nervous giggle: tiny high trills.
				value = sin(TAU * 900.0 * t) * (0.5 + 0.5 * sin(TAU * 22.0 * t)) * sin(PI * t / duration) * 0.22
			"REVEAL_IN_LOVE", "POKE_IN_LOVE":
				# Dreamy sigh: a slow rising sweep.
				value = sin(TAU * (380.0 * t + 500.0 * t * t)) * sin(PI * t / duration) * 0.28
			"REVEAL_JEALOUS", "POKE_JEALOUS":
				# Sour hmph: a low wobbling buzz.
				value = (fmod(t * 120.0, 1.0) * 2.0 - 1.0) * sin(PI * t / duration) * (0.6 + 0.4 * sin(TAU * 6.0 * t)) * 0.28
		var attack := minf(1.0, t * 1000.0)
		bytes.encode_s16(index * 2, clampi(int(value * attack * 16000.0), -32768, 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = bytes
	return stream


func _needs_lanterns(definition: Dictionary) -> bool:
	# Lanterns are pointless (and their hooks confusing) when fixed lights
	# already cover every slot.
	if definition.get("lanterns", {}).is_empty():
		return false
	for slot in range(int(definition.get("width", 11))):
		var covered := false
		for zone in definition.get("fixed_lights", []):
			if slot >= zone[0] and slot <= zone[1]:
				covered = true
		if not covered:
			return true
	return false


func _update_instructions() -> void:
	if not is_instance_valid(_instructions) or plan == null or page.is_empty():
		return
	var text := ""
	match mode:
		"INTRO", "ORIGINAL_END":
			text = "The Original strip. Watch what normally happens, or click to skip it."
		"PLAY":
			text = "AND THEN...   (Space skips to the end)"
			if _flick_available():
				text = "Drop your spare bulb: click the room, or aim with left/right and press F. It lights 3 spots from the next beat."
		"RESULT":
			text = "TWIST! Press NEXT PAGE, or hunt for another ending." if _won_current else "Not quite. REWIND keeps your plan; RESTART resets the page."
		"PLAN":
			var lit := _lit_ids()
			var tutorial: Variant = page.get("tutorial")
			if page.has("coach") and not completed.has(page.id):
				text = str(page.coach)
			elif tutorial is Array and not tutorial.is_empty() and not completed.has(page.id):
				text = str(tutorial[0])
			elif not _lanterns_useful:
				text = "Everyone is lit. Drag one thought bubble onto the other character to swap, then ACTION! (Space)."
			elif lit.is_empty():
				text = "Nobody is lit. Drag the bulb into the room (or use the arrow keys) to reveal what someone is thinking."
			elif lit.size() == 1:
				text = "Light a second character to swap thoughts, or press ACTION!
WASD bulb · Tab pick · Enter swap · Space go · H hint"
			else:
				text = "Drag a lit thought onto another lit character to swap.
WASD bulb · Tab pick · Enter swap · Space go · H hint"
	_instructions.text = text
	if is_instance_valid(_action):
		# The label never changes length (it must fit its button); a dark stage
		# is explained in the hint line and the tooltip instead.
		_action.text = " ACTION!"
		_action.tooltip_text = "Nobody is lit, so nothing will happen" if mode == "PLAN" and _lit_ids().is_empty() else "Play the scene (Space)"


func _progress() -> Array:
	var pages: Array = []
	for index in PAGE_SCRIPTS.size():
		var definition: Dictionary = PAGE_SCRIPTS[index].definition()
		var previous_done := index == 0
		if index > 0:
			var previous_id: String = PAGE_SCRIPTS[index - 1].definition().id
			previous_done = completed.has(previous_id) or skipped.has(previous_id)
		pages.append({
			"title": definition.title,
			"solved": completed.has(definition.id),
			"unlocked": previous_done or index == page_index or completed.has(definition.id),
			"current": index == page_index,
			"caption": definition.goal.twist_caption,
			"tier": _tier(index),
			"stars": _stars(definition),
			"max_stars": 1 + _star_steps(definition).size(),
			"endings": endings_found.get(definition.id, []).size(),
			"max_endings": maxi(int(definition.get("endings_total", 0)), endings_found.get(definition.id, []).size()),
		})
	return pages


func _update_star_total() -> void:
	if not is_instance_valid(_front):
		return
	var stars := 0
	var total := 0
	for script in PAGE_SCRIPTS:
		var definition: Dictionary = script.definition()
		stars += _stars(definition)
		total += 1 + _star_steps(definition).size()
	_front.set_star_total(stars, total)


func _open_edition() -> void:
	_update_star_total()
	if mode in ["INTRO", "PLAY"]:
		_finish_run()
	var note := "Every page solved! Each page hides other endings too." if completed.size() == PAGE_SCRIPTS.size() else "Pick a page. Solved pages stay inked."
	_front.set_pages(_progress(), note)
	_front.show_edition()


func _on_front_start() -> void:
	if _story_waiting:
		_replay_voice()
	_front.hide()
	# The Narrator introduces the show once per session; the page waits for him.
	if not _title_said and page_override.is_empty():
		_title_said = true
		_title_voice = _play_voice_file("narrator/" + _first_voice(["v_title", "narr15_title"]), _voice)
		if _title_voice:
			_stage.set_caption("The Bulb Family Funnies! Narrated by me. Obviously.", _voice_length() + 0.5)
	_update_buttons()


func _on_front_page(index: int) -> void:
	_front.hide()
	if index != page_index or mode == "ERROR":
		_load_page(index)
	if _story_waiting:
		_replay_voice()
	_update_buttons()


func _show_payoff(result: Dictionary, rewards: Array[String] = []) -> void:
	# Win: TWIST! stamp slams onto the strip. Fail: THE END...? plus what is missing.
	var won: bool = result.won
	_stamp.text = "TWIST!" if won else "THE END...?"
	_stamp.add_theme_font_size_override("font_size", 72 if won else 56)
	_stamp.add_theme_color_override("font_color", Color("e0453a") if won else Color("f3ead8"))
	_stamp.add_theme_color_override("font_outline_color", INK)
	_stamp.rotation = -0.12 if won else 0.06
	_stamp.show()
	var missing: Array[String] = []
	for item in result.facts:
		if not item.met:
			missing.append(GOALS.fact_text(item.fact))
	if won:
		_missing.text = "   ".join(rewards)
		_missing.add_theme_color_override("font_color", Color("9a6b00"))
	else:
		var lines: Array[String] = ["Still needed:  " + "   •   ".join(missing)]
		if not rewards.is_empty():
			lines.append("   ".join(rewards))
		_missing.text = "\n".join(lines)
		_missing.add_theme_color_override("font_color", Color("a4383e"))
	_missing.visible = not _missing.text.is_empty()
	if is_instance_valid(_stamp_tween):
		_stamp_tween.kill()
	if _motion.button_pressed:
		_stamp.scale = Vector2.ONE
		_stamp.modulate.a = 1.0
	else:
		_stamp.scale = Vector2.ONE * (2.2 if won else 1.5)
		_stamp.modulate.a = 0.0
		_stamp_tween = create_tween().set_parallel(true)
		_stamp_tween.tween_property(_stamp, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_stamp_tween.tween_property(_stamp, "modulate:a", 1.0, 0.12)
		if won:
			var home := _ui.position
			var shake := create_tween()
			shake.tween_interval(0.2)
			for offset in [Vector2(7, -4), Vector2(-6, 5), Vector2(4, 2), Vector2.ZERO]:
				shake.tween_property(_ui, "position", home + offset, 0.04)
	if won:
		for frequency in [523.25, 659.25, 783.99]:
			_ding(frequency)
	else:
		_play_effect("WHIFF")
	_play_sting(won)


func _hide_payoff() -> void:
	_hide_result_card()
	if is_instance_valid(_stamp_tween):
		_stamp_tween.kill()
	if is_instance_valid(_stamp):
		_stamp.hide()
	if is_instance_valid(_missing):
		_missing.hide()


func _emphasise(button: Button, primary: bool) -> void:
	if not is_instance_valid(button):
		return
	if not primary:
		for state in ["normal", "hover", "pressed", "focus"]:
			button.remove_theme_stylebox_override(state)
		for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			button.remove_theme_color_override(state)
		return
	for state in ["normal", "hover", "pressed", "focus"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color("c0392b").lightened(0.1 if state == "hover" else 0.0)
		box.border_color = INK
		box.set_border_width_all(2)
		box.set_corner_radius_all(3)
		box.content_margin_left = 14
		box.content_margin_right = 14
		button.add_theme_stylebox_override(state, box)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(state, Color.WHITE)


func _stars(definition: Dictionary) -> int:
	return (1 if completed.has(definition.id) else 0) + bonus_done.get(definition.id, []).size()


func _record_progress(result: Dictionary) -> Array[String]:
	if _tutorial_panel >= 0:
		# Tutorial endings are shown but never saved.
		var seen: Array = _tutorial_endings.get(page.id, [])
		if str(result.caption) in seen:
			return []
		seen.append(str(result.caption))
		_tutorial_endings[page.id] = seen
		_update_progress_label()
		return ["NEW ENDING! (%d)" % seen.size()] as Array[String]
	# Every player run can find a new ending; any run can also earn bonus stars.
	var rewards: Array[String] = []
	var found: Array = endings_found.get(page.id, [])
	if str(result.caption) not in found:
		found.append(str(result.caption))
		endings_found[page.id] = found
		rewards.append("NEW ENDING! (%d / %d)" % [found.size(), maxi(int(page.get("endings_total", 0)), found.size())])
	var done: Array = bonus_done.get(page.id, [])
	for bonus in _star_steps(page):
		if bonus.id in done:
			continue
		var challenge := page.duplicate()
		challenge.goal = {"facts": bonus.facts, "twist_caption": bonus.caption}
		if GOALS.evaluate(challenge, _run).won:
			done.append(bonus.id)
			# Ladder pages show their stars on the answer sheet and the star award.
			if not page.has("ladder"):
				rewards.append("BONUS STAR! " + str(bonus.caption))
	bonus_done[page.id] = done
	var achievement: Variant = page.get("achievement")
	if achievement is Dictionary and not achievements.has(str(achievement.id)):
		var needed := int(str(achievement.get("when", "star_2")).get_slice(" ", 0).trim_prefix("star_"))
		if _run_star_level() >= needed:
			achievements[str(achievement.id)] = true
			rewards.append("ACHIEVEMENT: " + str(achievement.name))
	_save_progress()
	return rewards


func _update_progress_label() -> void:
	if not is_instance_valid(_progress_label) or page.is_empty():
		return
	var total: int = 1 + _star_steps(page).size()
	var stars := _stars(page)
	var found: int = endings_found.get(page.id, []).size()
	if _tutorial_panel >= 0:
		_progress_label.text = "[u]Endings book: %d[/u]" % _found_endings().size()
		return
	_progress_label.text = _icon("star_on", 20).repeat(stars) + _icon("star_off", 20).repeat(total - stars) + "    Endings %d / %d" % [found, maxi(int(page.get("endings_total", 0)), found)]


func _persistent() -> bool:
	# Headless test runs must start from a clean slate.
	return DisplayServer.get_name() != "headless"


func _save_progress() -> void:
	if not _persistent():
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify({"version": 1, "completed": completed.keys(), "skipped": skipped.keys(), "bonus": bonus_done, "endings": endings_found, "tutorial_done": tutorial_done, "seen_cards": seen_cards.keys(), "gags": gags, "achievements": achievements.keys(), "coach_done": coach_done.keys()}))


func _load_progress() -> void:
	if not _persistent() or not FileAccess.file_exists(SAVE_PATH):
		return
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if not data is Dictionary:
		return
	for id in data.get("completed", []):
		completed[str(id)] = true
	for id in data.get("skipped", []):
		skipped[str(id)] = true
	if data.get("bonus") is Dictionary:
		bonus_done = data.bonus
	if data.get("endings") is Dictionary:
		endings_found = data.endings
	tutorial_done = data.get("tutorial_done", false) == true
	for id in data.get("seen_cards", []):
		seen_cards[str(id)] = true
	if data.get("gags") is Dictionary:
		gags = data.gags
	for id in data.get("achievements", []):
		achievements[str(id)] = true
	for id in data.get("coach_done", []):
		coach_done[str(id)] = true


func _comic_theme() -> Theme:
	# Printed-comic buttons: paper, ink border, hard offset shadow (no blur).
	var theme := Theme.new()
	theme.default_font = TEXT_FONT
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box := StyleBoxFlat.new()
		box.bg_color = PAPER if state != "hover" else Color("fff4d6")
		box.border_color = INK if state != "disabled" else Color("a9a28f")
		box.set_border_width_all(3 if state != "disabled" else 2)
		box.set_corner_radius_all(2)
		box.shadow_color = INK if state != "disabled" else Color(0, 0, 0, 0)
		box.shadow_size = 0
		box.shadow_offset = Vector2(1, 1) if state == "pressed" else Vector2(4, 4)
		box.content_margin_left = 12
		box.content_margin_right = 12
		box.content_margin_top = 4
		box.content_margin_bottom = 4
		if state == "focus":
			# Keyboard focus: warm tint, a thick orange frame and a glow, plus a
			# small zoom from _juice_button. Impossible to miss.
			box.bg_color = UI_FOCUS
			box.border_color = Color("e8731a")
			box.set_border_width_all(5)
			box.shadow_color = Color(1.0, 0.72, 0.2, 0.75)
			box.shadow_size = 10
			box.shadow_offset = Vector2.ZERO
		theme.set_stylebox(state, "Button", box)
	# Tooltips look like the game's speech balloons.
	var tip := StyleBoxFlat.new()
	tip.bg_color = Color("fffaf0")
	tip.border_color = INK
	tip.set_border_width_all(2)
	tip.set_corner_radius_all(14)
	tip.corner_radius_bottom_left = 2
	tip.shadow_color = Color(0, 0, 0, 0.35)
	tip.shadow_size = 6
	tip.shadow_offset = Vector2(2, 3)
	tip.content_margin_left = 12
	tip.content_margin_right = 12
	tip.content_margin_top = 7
	tip.content_margin_bottom = 7
	theme.set_stylebox("panel", "TooltipPanel", tip)
	theme.set_color("font_color", "TooltipLabel", INK)
	theme.set_font("font", "TooltipLabel", TEXT_FONT)
	theme.set_font_size("font_size", "TooltipLabel", 15)
	theme.set_color("font_color", "Button", INK)
	theme.set_color("font_hover_color", "Button", INK)
	theme.set_color("font_pressed_color", "Button", INK)
	theme.set_color("font_focus_color", "Button", INK)
	theme.set_color("font_disabled_color", "Button", Color("a9a28f"))
	theme.set_color("font_color", "Label", INK)
	return theme



func _flick_available() -> bool:
	return mode == "PLAY" and not _is_original and int(page.get("flick", 0)) > 0 and _run.get("plan", {}).get("flick", {}).is_empty()


func _aim_slot() -> int:
	if not _flick_available() or not is_instance_valid(_stage) or not _stage.is_inside_tree():
		return -1
	if _key_aim >= 0:
		return _key_aim
	var local: Vector2 = _stage.get_local_mouse_position()
	if not Rect2(Vector2.ZERO, _stage.size).has_point(local):
		return -1
	return _stage.slot_at(local)


func _flick_beat() -> int:
	# The first beat whose SWITCHES phase has not been shown yet, so the
	# replayed prefix is identical to what the player already watched.
	var beat := 1
	while (float(beat) - 1.0) * BEAT_SECONDS + float(PHASE_TIME.SWITCHES) <= _clock:
		beat += 1
	return beat


func _drop_flick(slot: int) -> void:
	if not _flick_available():
		return
	var flick := {"beat": _flick_beat(), "centre": slot}
	var flicked: Dictionary = _run.plan.duplicate(true)
	flicked.flick = flick
	plan.flick = flick.duplicate()
	_saved_plan = plan.to_data()
	# Pure re-simulation; playback continues from the same clock and frame.
	_run = SIMULATOR.run(page, flicked, true)
	_decisive_beat = _find_decisive_beat(_run)
	_stage.set_flick_ready(false)
	_tutorial_event("flick")
	_ding(880.0)
	_play_effect("LAMP_ON")
	_update_instructions()


func _clear_flick() -> void:
	if mode == "PLAN" and not plan.flick.is_empty():
		plan.flick = {}
		_saved_plan = plan.to_data()
		_refresh_plan()



func _show_hint() -> void:
	# Bulby's hints: a nudge, the key character, then the move itself.
	var hints: Array = _all_hints()
	_tutorial_event("hint_opened")
	if _hints_shown >= hints.size() or mode not in ["PLAN", "RESULT"]:
		return
	var text := str(hints[_hints_shown]).trim_prefix("ghost: ")
	if str(hints[_hints_shown]).begins_with("ghost: "):
		text = "Try this: " + text
	_hints_shown += 1
	_subtitle.text = "Bulby whispers: " + text
	_stage.set_caption("HINT %d/%d: %s" % [_hints_shown, hints.size(), text], 8.0)
	_stage.set_mood("scheme", 1.5)
	_play_effect("SWAP")
	_update_buttons()



func _find_decisive_beat(recorded: Dictionary) -> int:
	if not GOALS.evaluate(page, recorded).won:
		return -1
	for beat in range(1, int(recorded.end_beat) + 1):
		var partial := {"snapshots": [recorded.snapshots[mini(beat, recorded.snapshots.size() - 1)]], "events": recorded.events.filter(func(event): return event.beat <= beat)}
		if GOALS.evaluate(page, partial).won:
			return beat
	return -1



## Gibberish voices: pitch per character, a few syllables per line.
const VOICE_PITCH := {"boss": 120.0, "intern": 190.0, "grandma": 260.0, "kid": 320.0, "dog": 380.0, "cat": 520.0, "dassi": 430.0, "prof": 120.0, "kassi": 220.0, "saap": 300.0, "prompt": 280.0, "aunty": 250.0, "faccha": 420.0, "mouse": 760.0}
const LINES := {
	"DING": ["Aha!", "Ooh!", "Hmm!", "Oh!"],
	"EAT": ["Yum!", "Mine!", "Nom!"],
	"BONKED": ["Ow!", "Hey!", "Oof!"],
	"EXIT": ["Bye!", "Nope!", "Eek!"],
	"CLASH": ["Mine!", "No, mine!"],
}
var _blip_cache: Dictionary = {}
const VOICE_ROOT := "res://assets/audio/voice/"
const MOMENTS := {"DING": "wake", "EAT": "eat", "SIT": "sleep", "STARTLE": "flee", "IDLE": "huh"}
var _lines: Dictionary = {}
var _fail_count := 0


func _speak(events: Array) -> void:
	# Lit/active characters react in speech balloons (events only exist for
	# active actors, so darkness stays silent). Voiced if the file exists.
	var said: Array = []
	for event in events:
		var pairs: Array = []
		match str(event.type):
			"BONK":
				pairs.append([str(event.actor), "bonk"])
				pairs.append([str(event.get("target", "")), "bonked"])
			"CLASH":
				for actor in event.get("actors", [event.actor]):
					pairs.append([str(actor), "clash"])
			"HUG":
				pairs.append([str(event.actor), "hug"])
				pairs.append([str(event.get("target", "")), "hugged"])
			"MOVE":
				# A shy character ducking out of the light, a jealous one picking a target: once per run.
				var thought := _thought_now(str(event.actor))
				var moment: String = {"SHY": "hide", "JEALOUS": "jealous"}.get(thought, "")
				if not moment.is_empty() and not _run_said.has(str(event.actor) + moment):
					_run_said[str(event.actor) + moment] = true
					pairs.append([str(event.actor), moment])
			_:
				if MOMENTS.has(str(event.type)):
					pairs.append([str(event.actor), MOMENTS[str(event.type)]])
		for pair in pairs:
			var speaker: String = pair[0]
			if speaker.is_empty() or speaker in said:
				continue
			var art := _art_of(speaker)
			var line: String = _lines.get("characters", {}).get(art, {}).get(pair[1], "")
			if line.is_empty():
				continue
			said.append(speaker)
			var life := 1.3
			# Stagger voices so a burst of DINGs doesn't turn into noise.
			if said.size() <= 2:
				if _play_voice_file("characters/%s_%s" % [art, pair[1]]):
					var player: AudioStreamPlayer = _character_players[(_character_index - 1) % _character_players.size()]
					if player.stream != null:
						life = maxf(life, player.stream.get_length() + 0.3)
				else:
					_blip(speaker, line)
			_stage.say(speaker, line, life)


var _run_said: Dictionary = {}


func _thought_now(id: String) -> String:
	for record in _playback_world.get("characters", []) if _playback_world is Dictionary else []:
		if record.id == id:
			return str(record.thought)
	for record in page.get("characters", []):
		if record.id == id:
			return str(plan.thoughts.get(id, record.thought)) if plan != null else str(record.thought)
	return ""


func _name_of(id: String) -> String:
	for record in page.get("characters", []):
		if record.id == id:
			return str(record.get("name", id))
	return id.capitalize()


func _art_of(id: String) -> String:
	for record in page.get("characters", []):
		if record.id == id:
			return str(record.art)
	return id


func _blip(speaker: String, line: String) -> void:
	if not _sound.button_pressed or DisplayServer.get_name() == "headless":
		return
	var art := _art_of(speaker)
	# Recorded babble syllables (design/voice_request.md Part D) beat synthesis.
	if _play_voice_file("characters/%s_blip_%d" % [art, 1 + absi(line.hash()) % 4]):
		return
	var syllables := clampi(line.length() / 2, 1, 4)
	var key := art + ":" + str(syllables)
	if not _blip_cache.has(key):
		_blip_cache[key] = _make_blips(float(VOICE_PITCH.get(art, 240.0)), syllables, art.hash())
	var player := _players[_audio_index % _players.size()]
	_audio_index += 1
	player.stream = _blip_cache[key]
	player.play()


func _make_blips(pitch: float, syllables: int, seed: int) -> AudioStreamWAV:
	# Original procedural "voice": short vowel-like syllables with a little glide.
	var sample_rate := 22050
	var syllable := 0.075
	var gap := 0.025
	var total := syllables * (syllable + gap)
	var bytes := PackedByteArray()
	bytes.resize(int(sample_rate * total) * 2)
	for index in bytes.size() / 2:
		var t := float(index) / sample_rate
		var n := int(t / (syllable + gap))
		var local := t - n * (syllable + gap)
		var value := 0.0
		if local < syllable:
			var step := float((seed + n * 7) % 5) / 4.0
			var f := pitch * (0.85 + 0.35 * step) * (1.0 + 0.08 * local / syllable)
			var envelope := sin(PI * local / syllable)
			value = envelope * (sin(TAU * f * local) * 0.6 + sin(TAU * f * 2.0 * local) * 0.25 + sin(TAU * f * 3.0 * local) * 0.1)
		bytes.encode_s16(index * 2, clampi(int(value * 9000.0), -32768, 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = bytes
	return stream



func _voice_path(base: String) -> String:
	for extension in [".ogg", ".mp3", ".wav"]:
		if ResourceLoader.exists(VOICE_ROOT + base + extension):
			return VOICE_ROOT + base + extension
	return ""


func _play_voice_file(base: String, player: AudioStreamPlayer = null) -> bool:
	var path := _voice_path(base)
	if path.is_empty() or not _sound.button_pressed or DisplayServer.get_name() == "headless":
		return false
	if player == null:
		player = _character_players[_character_index % _character_players.size()]
		_character_index += 1
	_cancel_fade(player)
	player.stream = load(path)
	player.play()
	return true


## Narrator caption + voice: page intro, the Original's ending, a win, a fail.
func _narrate(moment: String) -> void:
	var key := ""
	var voice_key := str(page.get("narration_key", page.get("narration", ""))) if not page.get("narration") is Dictionary else str(page.get("narration_key", ""))
	if moment.begins_with("fail_"):
		key = "narr_" + moment
	elif not voice_key.is_empty():
		key = "narr_%s_%s" % [voice_key, moment]
	var text: String = _lines.get("narrator", {}).get(key, "")
	var queue: Array[String] = []
	# Story pages: the written script is the caption, voiced by the narr15 set
	# (design/voice_request.md Part F: intro, original, red pen, TWIST stamp + win).
	var written: Variant = page.get("narration")
	if written is Dictionary:
		var slug := str(page.get("voice", ""))
		var line := ""
		key = ""
		if moment.begins_with("fail_"):
			var fails: Array = Array(written.get("fails", [])) if written.has("fails") else [written.get("fail", "")] + Array(written.get("fail_alt", []))
			fails = fails.filter(func(entry): return not str(entry).is_empty())
			if not fails.is_empty():
				var index := (_fail_count - 1) % fails.size()
				line = str(fails[index])
				# Story pages voice their own fail lines, so caption and voice match.
				key = "%s_fails_%d" % [slug, index + 1] if written.has("fails") else "narr15_fail_%d" % (1 + (_fail_count - 1) % 4)
		else:
			var field: String = {"intro": "intro", "original": "original", "redpen": "twist", "twist": "win"}.get(moment, moment)
			line = str(written.get(field, ""))
			var prefix := "%s_" % slug if slug.begins_with("page_") else "narr15_%s_" % slug
			if not slug.is_empty():
				key = prefix + field
				if moment == "twist":
					# "TWIST?!" first, then the win line, then one line per star earned.
					queue.append(key)
					key = _first_voice(["v_twist_stamp", "narr15_twist_stamp"])
			if moment == "twist":
				_voice_texts.clear()
				_voice_texts[prefix + field] = _spoken_text(line)
				var extra := _win_extras(prefix)
				for item in extra:
					_voice_texts[str(item[1])] = _spoken_text(str(item[0]))
					line += "  " + str(item[0])
					queue.append(str(item[1]))
		text = _spoken_text(line)
	if text.is_empty():
		return
	if moment in ["intro", "original"] and _screen_covered():
		# Never narrate behind the title menu or the intro card: speak when they close.
		_pending_narration = moment
		return
	_pending_narration = ""
	# Without a recording, the comic waits long enough to read the line.
	_read_hold = clampf(text.split(" ").size() / 3.2, 2.0, 9.0) if moment in ["intro", "original"] and DisplayServer.get_name() != "headless" else 0.0
	var seconds := _read_hold + 1.5 if moment in ["intro", "original"] else (5.0 if moment == "redpen" else 0.0)
	_stage.set_caption(text, seconds)
	if is_instance_valid(_result_stage):
		_result_stage.set_caption(text if moment == "twist" or moment.begins_with("fail") else "", 0.0)
	var voiced := not key.is_empty() and _play_voice_file("narrator/" + key, _voice)
	_voice_queue = queue if voiced else ([] as Array[String])
	_narrator_hold = voiced and moment == "intro"
	if voiced:
		_read_hold = 0.0
		if moment == "twist" and not queue.is_empty() and _voice_texts.has(queue[0]):
			# Each recorded line gets its own subtitle as it plays.
			_stage.set_caption(_voice_texts[queue[0]], 0.0)
		if moment == "intro" or moment == "original":
			# The recording sets the pace; keep its caption up while it plays.
			_stage.set_caption(text, maxf(seconds, _voice_length() + 0.8))


## Captions show the words only; [acting directions] are for the voice.
func _spoken_text(line: String) -> String:
	var regex := RegEx.create_from_string("\\s*\\[[^\\]]*\\]\\s*")
	return regex.sub(line, " ", true).strip_edges().replace("  ", " ")


func _voice_length() -> float:
	if is_instance_valid(_voice) and _voice.stream != null:
		return _voice.stream.get_length()
	return 0.0


## Narrator lines that follow each other (TWIST?! then the win line).
var _voice_queue: Array[String] = []
var _voice_texts: Dictionary = {}


func _on_voice_finished() -> void:
	if not _voice_queue.is_empty():
		var next: String = _voice_queue.pop_front()
		if _play_voice_file("narrator/" + next, _voice):
			if _voice_texts.has(next) and mode == "RESULT":
				_stage.set_caption(_voice_texts[next], 0.0)
			return
	_stop_voice()



## The Original waits while the intro is being read, so voice and pictures match.
var _narrator_hold := false
var _redpen_done := false
var _pending_narration := ""
var _read_hold := 0.0


var _title_said := false
var _title_voice := false


func _screen_covered() -> bool:
	if _title_voice and not _voice_busy():
		_title_voice = false
	return _title_voice or (is_instance_valid(_front) and _front.visible) or (is_instance_valid(_intro_card) and _intro_card.visible) or _intro_pending or (is_instance_valid(_story_card) and _story_card.visible) or not _story_queue.is_empty()


func _voice_busy() -> bool:
	return is_instance_valid(_voice) and _voice.playing


## Ends a sound with a short fade instead of a hard click.
func _fade_out(player: AudioStreamPlayer, seconds := 0.25) -> void:
	if not is_instance_valid(player) or not player.playing:
		return
	_cancel_fade(player)
	var base := player.volume_db
	var tween := create_tween()
	player.set_meta("fade", tween)
	player.set_meta("fade_base", base)
	tween.tween_property(player, "volume_db", base - 30.0, seconds)
	tween.tween_callback(func():
		player.stop()
		_cancel_fade(player))


## A new sound on a fading player cancels the fade and restores its volume.
func _cancel_fade(player: AudioStreamPlayer) -> void:
	if not player.has_meta("fade"):
		return
	var tween: Tween = player.get_meta("fade")
	if tween != null and tween.is_valid():
		tween.kill()
	player.volume_db = float(player.get_meta("fade_base"))
	player.remove_meta("fade")
	player.remove_meta("fade_base")


func _icon_texture(name: String) -> Texture2D:
	return load("res://assets/ui/%s.svg" % name)


func _icon_button(parent: Node, name: String, tip: String, callback: Callable, size := Vector2(56, 56)) -> Button:
	var button := Button.new()
	button.name = name.capitalize().replace(" ", "")
	button.icon = _icon_texture(name)
	button.expand_icon = true
	button.tooltip_text = tip
	button.custom_minimum_size = size
	button.size = size
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _paper_panel(rect: Rect2, tilt: float = 0.0) -> Panel:
	var panel := Panel.new()
	var box := StyleBoxFlat.new()
	box.bg_color = Color("fffaf0")
	box.border_color = INK
	box.set_border_width_all(3)
	box.shadow_color = Color(INK, 0.9)
	box.shadow_offset = Vector2(5, 5)
	box.shadow_size = 0
	panel.add_theme_stylebox_override("panel", box)
	panel.position = rect.position
	panel.size = rect.size
	panel.rotation = tilt
	return panel


func _restyle_hud() -> void:
	# Structure is standard game UI; the skin is the newspaper (ui.md §0).
	var heading: Node = _title.get_parent()
	heading.remove_child(_title)
	_ui.add_child(_title)
	heading.hide()
	for node in [_sound, _motion, _pages_button]:
		node.hide()
	_title.position = Vector2(240, 4)
	_title.size = Vector2(800, 44)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 34)
	_title.add_theme_color_override("font_color", UI_LIGHT)
	_title.add_theme_constant_override("outline_size", 10)
	_title.add_theme_color_override("font_outline_color", INK)
	_title.add_theme_constant_override("shadow_offset_y", 4)
	_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.45))
	_tier_band = ColorRect.new()
	_tier_band.position = Vector2(520, 46)
	_tier_band.size = Vector2(240, 5)
	_tier_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_tier_band)
	_pause_button = _icon_button(_ui, "pause", "Pause menu (Esc)", _open_pause, Vector2(48, 48))
	_pause_button.position = Vector2(14, 2)
	# A translucent round emblem instead of a boxed button.
	_pause_button.icon = _icon_texture("menu")
	for state in ["normal", "hover", "pressed", "focus"]:
		var emblem := StyleBoxFlat.new()
		# A warm ink-ringed badge with a little bulb: the menu, in the comic's own style.
		emblem.bg_color = Color("e08a3c").lerp(Color("ffd27a"), {"normal": 0.0, "hover": 0.35, "pressed": 0.5, "focus": 0.35}[state])
		emblem.shadow_color = Color(0, 0, 0, 0.4)
		emblem.shadow_size = 4
		emblem.shadow_offset = Vector2(0, 2)
		emblem.border_color = INK
		emblem.set_border_width_all(2)
		emblem.set_corner_radius_all(24)
		_pause_button.add_theme_stylebox_override(state, emblem)
	_pause_button.add_theme_color_override("icon_normal_color", Color.WHITE)
	_pause_button.add_theme_color_override("icon_hover_color", Color.WHITE)
	_pause_button.add_theme_color_override("icon_focus_color", Color.WHITE)
	_pause_button.add_theme_color_override("icon_pressed_color", Color.WHITE)
	_progress_label.position = Vector2(1012, 11)
	_progress_label.size = Vector2(250, 30)
	# Goal clipping: twist in red pen plus the headline (bonus) lines.
	_goal_card = _paper_panel(Rect2(16, 56, 900, 86), 0.0)
	_goal_card.mouse_filter = Control.MOUSE_FILTER_STOP
	_goal_card.tooltip_text = "Click to watch the Original strip"
	_goal_card.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mode in ["PLAN", "RESULT"] and _tutorial_allows("original"):
			_replay_original())
	_ui.add_child(_goal_card)
	_ui.move_child(_goal_card, _goal.get_index())
	_goal.position = Vector2(30, 58)
	_goal.size = Vector2(880, 30)
	_goal.add_theme_font_size_override("font_size", 22)
	_facts.position = Vector2(30, 90)
	_bonus_line = _rich(14)
	_bonus_line.position = Vector2(30, 114)
	_bonus_line.size = Vector2(880, 24)
	_ui.add_child(_bonus_line)
	_facts.size = Vector2(880, 24)
	_instructions.position = Vector2(934, 60)
	_instructions.size = Vector2(330, 78)
	_instructions.clip_text = false
	_instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_instructions.add_theme_font_size_override("font_size", 13)
	for hook in _hooks:
		hook.position = Vector2(-400, -400)
	_stage.position = Vector2(0, 146)
	_stage.size = Vector2(1280, 460)
	_stage.set_full_bleed(true)
	_comparison.position = Vector2(16, 146)
	# Floating HUD: translucent paper cards over the painting, readable ink on top.
	for rect in [Rect2(924, 56, 348, 86), Rect2(1008, 6, 262, 38)]:
		var card := _glass_panel(rect)
		_ui.add_child(card)
		_ui.move_child(card, 0)
	_update_backdrop()
	# Bottom bar: legend, narration line, ⟲ and ACTION.
	_footer_shade = _build_footer_shade()
	_ui.add_child(_footer_shade)
	_ui.move_child(_footer_shade, 0)
	_narration = _build_narration_label()
	_ui.add_child(_narration)
	_legend = _rich(14)
	_legend.text = LEGEND_BASE
	_legend.position = Vector2(16, 690)
	_legend.mouse_filter = Control.MOUSE_FILTER_STOP
	_legend.tooltip_text = "What each thought makes a character do"
	_legend.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			_tutorial_click())
	_legend.size = Vector2(900, 26)
	_legend.add_theme_color_override("default_color", UI_LIGHT)
	_ui.add_child(_legend)
	# The narration line replaces the old caption/subtitle labels.
	_caption.position = Vector2(-2000, 0)
	_subtitle.position = Vector2(-2000, 0)
	_stage.external_caption = true
	_status.hide()
	for node in [_voice_replay, _voice_skip]:
		node.get_parent().hide()
	var bar: Node = _action.get_parent()
	for node in [_action, _restart, _fast_button, _skip_run]:
		bar.remove_child(node)
		_ui.add_child(node)
	_restart.text = ""
	_restart.icon = _icon_texture("restart")
	_restart.expand_icon = true
	_restart.tooltip_text = "Restart the page (clears your plan)"
	_restart.position = Vector2(1000, 624)
	_hint_hud = _icon_button(_ui, "hint", "Hint: reveals the next step of the solution", _show_hint, Vector2(64, 64))
	_hint_hud.position = Vector2(920, 624)
	_restart.size = Vector2(64, 64)
	_restart.custom_minimum_size = Vector2(64, 64)
	_action.icon = _icon_texture("play")
	_action.expand_icon = false
	_action.add_theme_constant_override("icon_max_width", 30)
	_action.add_theme_font_override("font", COMIC_FONT)
	_action.add_theme_font_size_override("font_size", 30)
	_action.position = Vector2(1080, 620)
	_action.size = Vector2(184, 72)
	_action.custom_minimum_size = Vector2(184, 72)
	_action.clip_text = true
	_fast_button.text = ""
	_fast_button.icon = _icon_texture("fast")
	_fast_button.expand_icon = true
	_fast_button.tooltip_text = "Fast forward"
	_fast_button.position = Vector2(1080, 624)
	_fast_button.size = Vector2(88, 64)
	_skip_run.text = ""
	_skip_run.icon = _icon_texture("skip")
	_skip_run.expand_icon = true
	_skip_run.tooltip_text = "Skip to the end (Space)"
	_skip_run.position = Vector2(1176, 624)
	_skip_run.size = Vector2(88, 64)
	_build_result_card()
	bar.hide()


func _build_result_card() -> void:
	# Completion popup (ui.md §7): pasted clipping over the stage's right side.
	_result_card = _paper_panel(Rect2(724, 140, 520, 466), 0.012)
	_result_card.z_index = 160
	_result_card.hide()
	_ui.add_child(_result_card)
	_result_title = _label("", 18)
	_result_title.position = Vector2(24, 112)
	_result_title.size = Vector2(472, 24)
	_result_card.add_child(_result_title)
	_result_caption = _label("", 20)
	_result_caption.position = Vector2(24, 136)
	_result_caption.size = Vector2(472, 60)
	_result_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_result_card.add_child(_result_caption)
	_result_facts = _rich(16)
	_result_facts.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_result_facts.position = Vector2(24, 200)
	_result_facts.size = Vector2(472, 92)
	_result_card.add_child(_result_facts)
	var row := HBoxContainer.new()
	row.position = Vector2(24, 346)
	row.size = Vector2(472, 56)
	row.add_theme_constant_override("separation", 12)
	_result_card.add_child(row)
	for node in [_rewind, _next]:
		node.get_parent().remove_child(node)
		row.add_child(node)
		node.custom_minimum_size = Vector2(150, 52)
		node.add_theme_font_override("font", COMIC_FONT)
		node.add_theme_font_size_override("font_size", 24)
	_result_restart = _button(row, "RESTART", _restart_page)
	_result_restart.custom_minimum_size = Vector2(130, 52)
	var small := HBoxContainer.new()
	small.position = Vector2(24, 408)
	small.add_theme_constant_override("separation", 8)
	_result_card.add_child(small)
	_levels_button = _button(small, "LEVELS", _open_edition)
	_compare_button = _button(small, "COMPARE", _toggle_compare)
	for node in [_hint_button, _skip_page]:
		node.get_parent().remove_child(node)
		small.add_child(node)
	# Original / Your Twist tabs replay on the one full-size stage.
	_tab_bar = HBoxContainer.new()
	_tab_bar.position = Vector2(16, 614)
	_tab_bar.z_index = 150
	_tab_bar.add_theme_constant_override("separation", 4)
	_tab_bar.hide()
	_ui.add_child(_tab_bar)
	_tab_original = _button(_tab_bar, "THE ORIGINAL", func():
		_show_tab(false)
		_tutorial_event("tabs_viewed"))
	_tab_twist = _button(_tab_bar, "YOUR TWIST", func():
		_show_tab(true)
		_tutorial_event("tabs_viewed"))
	_button(_tab_bar, "RESULT", func(): _result_card.show())
	# The stamp sits at the top of the card.
	_stamp.get_parent().remove_child(_stamp)
	_result_card.add_child(_stamp)
	_stamp.position = Vector2(50, 8)
	_stamp.size = Vector2(420, 96)
	_stamp.pivot_offset = _stamp.size * 0.5
	_missing.get_parent().remove_child(_missing)
	_result_card.add_child(_missing)
	# Inside the card they only need to sit above its own text, not above menus.
	_stamp.z_index = 1
	_missing.z_index = 1
	_missing.position = Vector2(24, 296)
	_missing.size = Vector2(472, 44)
	_missing.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_missing.add_theme_font_size_override("font_size", 14)


func _show_result_card(result: Dictionary) -> void:
	var won: bool = result.won
	_result_title.text = "YOUR ENDING:"
	# A win names the twist itself; the event caption can omit a goal fact.
	_result_caption.text = str(page.goal.twist_caption) if won else str(result.caption)
	_caption.text = ""
	var lines: Array[String] = []
	if page.has("ladder"):
		# The TA marks the answer sheet: Q1 twist, Q2/Q3 the fine-tunes.
		lines.append("[b]Q1[/b]  " + (_icon("check") if won else _icon("cross")) + str(page.goal.twist_caption))
		var level := _run_star_level()
		var steps: Array = page.get("ladder", [])
		for i in steps.size():
			lines.append("[b]Q%d[/b]  " % (i + 2) + (_icon("check") if level >= i + 2 else "[color=#8c8a80]–[/color]  ") + str(steps[i].caption))
	else:
		for item in result.facts:
			lines.append((_icon("check") if item.met else _icon("cross")) + ("Twist: " if lines.is_empty() else "") + GOALS.fact_text(item.fact))
		for bonus in _star_steps(page):
			var done: bool = bonus.id in bonus_done.get(page.id, [])
			lines.append(_icon("star_on" if done else "star_off") + str(bonus.caption))
	_result_facts.text = "\n".join(lines)
	_show_stickers("result", won)
	_rewind.text = "REPLAY" if won else "RETRY"
	_next.visible = won
	_result_restart.visible = not won
	_compare_button.visible = true
	_result_card.show()
	(_next if won else _rewind).grab_focus.call_deferred()
	_stage.show()
	_comparison.hide()
	_tab_bar.show()
	_tab_twist.button_pressed = true
	if won and not _motion.button_pressed:
		# After a win, first show the Original's ending struck out, then flip to yours.
		_show_tab(false)
		_stage.set_caption("~~ " + GOALS.evaluate(page, _original_run).caption + " ~~", 0.0)
		get_tree().create_timer(1.3).timeout.connect(func():
			if mode == "RESULT":
				# The narrator's win line (and star lines) stay up; tabs can still be clicked.
				_show_tab(true, _voice_busy() or page.get("narration") is Dictionary)
				_stage.celebrate())
	else:
		_show_tab(true)


func _show_tab(twist: bool, keep_caption := false) -> void:
	if mode != "RESULT":
		return
	var shown: Dictionary = _run if twist else _original_run
	_stage.pose(shown.snapshots.back(), shown.plan, knowledge if twist else {}, false)
	var ending: Dictionary = GOALS.evaluate(page, shown)
	var line: String = str(page.goal.twist_caption) if twist and ending.won else str(ending.caption)
	if not keep_caption:
		_stage.set_caption(("YOUR TWIST: " if twist else "THE ORIGINAL: ") + line, 0.0)
	_tab_original.disabled = not twist
	_tab_twist.disabled = twist


func _toggle_compare() -> void:
	_result_card.visible = not _result_card.visible
	_compare_button.text = "COMPARE"


func _hide_result_card() -> void:
	if is_instance_valid(_result_card):
		_result_card.hide()
	if is_instance_valid(_tab_bar):
		_tab_bar.hide()



func _tier(index: int) -> int:
	# Each page names its band: green 1–5, yellow 6–10, red 11–15.
	var band := str(PAGE_SCRIPTS[index].definition().get("difficulty", "green")) if index < PAGE_SCRIPTS.size() else "green"
	return {"green": 0, "yellow": 1, "red": 2}.get(band, 0)


# ------------------------------------------------------------ pause sheet
var _pause_sheet: Control
var _pause_hint: Button
var _pause_skip: Button
var _pause_tutorial: Button


func _open_pause() -> void:
	if not is_instance_valid(_pause_sheet):
		_build_pause_sheet()
	_pause_hint.visible = _hint_button.visible
	_pause_skip.visible = failures >= 3 and _tutorial_panel < 0
	_pause_tutorial.visible = _tutorial_panel >= 0
	_pause_sheet.show()
	# Keyboard: Up/Down walk the list, Enter picks, Esc resumes.
	for child in _pause_hint.get_parent().get_children():
		if child is Button and child.visible:
			child.grab_focus.call_deferred()
			break


func _close_pause() -> void:
	if is_instance_valid(_pause_sheet):
		_pause_sheet.hide()


func _build_pause_sheet() -> void:
	_pause_sheet = Control.new()
	_pause_sheet.size = Vector2(1280, 720)
	_pause_sheet.z_index = 250
	_pause_sheet.mouse_filter = Control.MOUSE_FILTER_STOP
	_ui.add_child(_pause_sheet)
	var dim := ColorRect.new()
	dim.color = Color(INK, 0.5)
	dim.size = Vector2(1280, 720)
	dim.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			_close_pause())
	_pause_sheet.add_child(dim)
	var sheet := _paper_panel(Rect2(40, 60, 380, 600), -0.012)
	_pause_sheet.add_child(sheet)
	var heading := _label("PAUSED", 40)
	heading.add_theme_font_override("font", COMIC_FONT)
	heading.position = Vector2(30, 16)
	sheet.add_child(heading)
	var sub := _label("", 16)
	sub.name = "Sub"
	sub.position = Vector2(30, 68)
	sheet.add_child(sub)
	var list := VBoxContainer.new()
	list.position = Vector2(30, 110)
	list.size = Vector2(320, 460)
	list.add_theme_constant_override("separation", 10)
	sheet.add_child(list)
	var entries := [
		["play", "RESUME", _close_pause],
		["restart", "RESTART PAGE", func(): _close_pause(); _restart_page()],
		["eye", "WATCH THE ORIGINAL", func(): _close_pause(); _replay_original()],
		["hint", "HINT", func(): _close_pause(); _show_hint()],
		["skip", "SKIP PAGE", func(): _close_pause(); _skip_current_page()],
		["skip", "SKIP TUTORIAL", func(): _close_pause(); _finish_tutorial()],
		["settings", "SETTINGS", func(): _open_settings()],
		["levels", "LEVELS", func(): _close_pause(); _open_edition()],
		["home", "MAIN MENU", func(): _close_pause(); _front.show_title(not completed.is_empty())],
	]
	for entry in entries:
		var button := Button.new()
		button.text = "  " + entry[1]
		button.icon = _icon_texture(entry[0])
		button.add_theme_constant_override("icon_max_width", 30)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(320, 46)
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(entry[2])
		list.add_child(button)
		if entry[1] == "HINT":
			_pause_hint = button
		elif entry[1] == "SKIP PAGE":
			_pause_skip = button
		elif entry[1] == "SKIP TUTORIAL":
			_pause_tutorial = button
	_pause_sheet.visibility_changed.connect(func():
		sub.text = "Page %d  ·  %s" % [page_index + 1, str(page.get("title", ""))])
	_pause_sheet.hide()


# ------------------------------------------------------------ settings sheet
var _settings_sheet: Control
const SETTINGS_PATH := "user://settings.cfg"
const BUSES := ["Music", "SFX", "Voice"]


func _setup_audio_buses() -> void:
	for bus in BUSES:
		if AudioServer.get_bus_index(bus) == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
			AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")
	for player in _players:
		player.bus = "SFX"
	for player in _character_players:
		player.bus = "Voice"
	if is_instance_valid(_voice):
		_voice.bus = "Voice"


func _set_volume(bus: String, value: float) -> void:
	var index := AudioServer.get_bus_index(bus)
	if index >= 0:
		AudioServer.set_bus_volume_db(index, linear_to_db(maxf(value, 0.0001)))
		AudioServer.set_bus_mute(index, value <= 0.001)


func _save_settings() -> void:
	if not _persistent():
		return
	var config := ConfigFile.new()
	for bus in ["Master"] + BUSES:
		config.set_value("audio", bus, db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus))))
	config.set_value("game", "reduce_motion", _motion.button_pressed)
	config.set_value("game", "sound", _sound.button_pressed)
	config.save(SETTINGS_PATH)


func _load_settings() -> void:
	_setup_audio_buses()
	if not _persistent():
		return
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	for bus in ["Master"] + BUSES:
		_set_volume(bus, float(config.get_value("audio", bus, 1.0)))
	_motion.button_pressed = bool(config.get_value("game", "reduce_motion", false))
	_sound.button_pressed = bool(config.get_value("game", "sound", true))


func _open_settings() -> void:
	if not is_instance_valid(_settings_sheet):
		_build_settings_sheet()
	_settings_from_pause = is_instance_valid(_pause_sheet) and _pause_sheet.visible
	if _settings_from_pause:
		_pause_sheet.hide()
	_settings_sheet.show()
	for child in _settings_sheet.find_children("*", "Control", true, false):
		if child.focus_mode == Control.FOCUS_ALL and child.is_visible_in_tree():
			child.grab_focus.call_deferred()
			break


## Closing Settings returns to whichever menu opened it.
func _close_settings() -> void:
	if is_instance_valid(_settings_sheet):
		_settings_sheet.hide()
	if _settings_from_pause:
		_settings_from_pause = false
		_open_pause()
	elif is_instance_valid(_front) and _front.visible:
		_front.focus_settings()


var _settings_from_pause := false


func _build_settings_sheet() -> void:
	_settings_sheet = Control.new()
	_settings_sheet.size = Vector2(1280, 720)
	_settings_sheet.z_index = 380
	_settings_sheet.mouse_filter = Control.MOUSE_FILTER_STOP
	_ui.add_child(_settings_sheet)
	var dim := ColorRect.new()
	dim.color = Color(INK, 0.5)
	dim.size = Vector2(1280, 720)
	_settings_sheet.add_child(dim)
	var sheet := _paper_panel(Rect2(400, 70, 480, 580), 0.01)
	_settings_sheet.add_child(sheet)
	var heading := _label("SETTINGS", 40)
	heading.add_theme_font_override("font", COMIC_FONT)
	heading.position = Vector2(30, 16)
	sheet.add_child(heading)
	var y := 84.0
	for bus in ["Master", "Music", "SFX", "Voice"]:
		var name := _label({"Master": "Master", "Music": "Music", "SFX": "Sound effects", "Voice": "Voices"}[bus], 18)
		name.position = Vector2(30, y)
		sheet.add_child(name)
		var slider := HSlider.new()
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus)))
		slider.position = Vector2(200, y + 4)
		slider.size = Vector2(240, 24)
		slider.value_changed.connect(func(value: float):
			_set_volume(bus, value)
			_save_settings())
		sheet.add_child(slider)
		y += 44
	for toggle in [_sound, _motion]:
		toggle.get_parent().remove_child(toggle)
		sheet.add_child(toggle)
		toggle.show()
		toggle.position = Vector2(30, y)
		toggle.add_theme_font_size_override("font_size", 18)
		toggle.toggled.connect(func(_on: bool): _save_settings())
		y += 44
	_sound.text = "Sound on"
	var fullscreen := CheckButton.new()
	fullscreen.text = "Fullscreen"
	fullscreen.position = Vector2(30, y)
	fullscreen.add_theme_font_size_override("font_size", 18)
	fullscreen.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen.toggled.connect(func(on: bool):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED))
	sheet.add_child(fullscreen)
	y += 56
	var replay := Button.new()
	replay.text = "REPLAY TUTORIAL"
	replay.position = Vector2(30, y - 4)
	replay.add_theme_font_size_override("font_size", 15)
	replay.pressed.connect(_replay_tutorial)
	sheet.add_child(replay)
	y += 48
	var reset := Button.new()
	reset.text = "THROW AWAY ALL PROGRESS"
	reset.position = Vector2(30, y)
	reset.add_theme_font_size_override("font_size", 15)
	reset.pressed.connect(func():
		if reset.text == "SURE? CLICK AGAIN":
			completed.clear()
			skipped.clear()
			bonus_done.clear()
			endings_found.clear()
			tutorial_done = false
			coach_done.clear()
			seen_cards.clear()
			gags = {"exit": 0, "dog": 0}
			_tutorial_endings.clear()
			_save_progress()
			reset.text = "PROGRESS CLEARED"
			_update_buttons()
		else:
			reset.text = "SURE? CLICK AGAIN")
	sheet.add_child(reset)
	var back := Button.new()
	back.text = "BACK"
	back.position = Vector2(340, 510)
	back.custom_minimum_size = Vector2(110, 48)
	back.add_theme_font_override("font", COMIC_FONT)
	back.add_theme_font_size_override("font_size", 24)
	back.pressed.connect(_close_settings)
	sheet.add_child(back)
	_settings_sheet.hide()



## Page dialogue (levels.md): lines spoken when a character is first lit, after a
## swap, or on a win. Only lit/active characters speak (theme rule).
var _said_scripted: Dictionary = {}


func _say_scripted(when: String, ids: Array) -> void:
	for entry in page.get("dialogue", []):
		if not entry is Dictionary or str(entry.get("when", "")) != when:
			continue
		var id := str(entry.get("character", ""))
		if not ids.is_empty() and id not in ids:
			continue
		var key: String = str(page.id) + ":" + when + ":" + id
		if when == "lit" and _said_scripted.has(key):
			continue
		_said_scripted[key] = true
		var life := 2.2
		var slug := str(page.get("voice", ""))
		# Story pages voice their balloons: <page>_dialogue_<character>_<when>.
		if slug.begins_with("page_") and _play_voice_file("characters/%s_dialogue_%s_%s" % [slug, id, when]):
			var player: AudioStreamPlayer = _character_players[(_character_index - 1) % _character_players.size()]
			if player.stream != null:
				life = maxf(life, player.stream.get_length() + 0.3)
		else:
			_blip(id, str(entry.get("line", "")))
		_stage.say(id, str(entry.get("line", "")), life)



# ------------------------------------------------------------ coach pop-ups
## Contextual "press this key" chips with drawn key caps. Each one appears when
## it is relevant and goes away once the player does the thing (or, for the
## optional ones, after a few seconds). What was learned is remembered in the save.
const COACH_CHIP = preload("res://presentation/coach_chip.gd")
const COACH_PARTS := {
	"move": [{"keys": ["A", "D"], "or": ["←", "→"], "label": "slide the light"}],
	"light2": [{"keys": ["1", "2"], "label": "pick a bulb"}, {"keys": ["P"], "label": "hang / park it"}],
	"tilt": [{"keys": ["W", "S"], "or": ["↑", "↓"], "label": "raise / lower the light"}],
	"pick": [{"keys": ["Tab"], "label": "choose who"}, {"keys": ["Enter"], "label": "pick up their thought"}],
	"swap": [{"keys": ["Tab"], "label": "pick another lit one"}, {"keys": ["Enter"], "label": "swap"}, {"keys": ["Esc"], "label": "cancel"}],
	"action": [{"keys": ["Space"], "label": "ACTION!"}],
}
## Optional hints give up after this many seconds on screen.
const COACH_PATIENCE := 12.0
var coach_done := {}
var _coach: Control
var _coach_timer := 0.0
var _coach_shown_for := 0.0
var _coach_clock := 0.0


func _coach_event(name: String) -> void:
	if coach_done.has(name):
		return
	coach_done[name] = true
	_save_progress()
	_coach_tick(0.0, true)


## During the tutorial one card teaches the current step: why first, keys second.
func _tutorial_card_tick() -> bool:
	if _tutorial_panel < 0:
		return false
	var steps := _tutorial_steps()
	var step: Dictionary = steps[_tutorial_step] if _tutorial_step < steps.size() else {}
	var gate := str(step.get("gate", ""))
	if step.is_empty() or not TUTORIAL_ALLOW.has(gate):
		if is_instance_valid(_coach):
			_coach.hide_hint()
		return true
	if _coach_blocked():
		if is_instance_valid(_coach):
			_coach.hide_hint()
		return true
	if not is_instance_valid(_coach):
		_coach = COACH_CHIP.new()
		_coach.position = Vector2(16, 560)
		_ui.add_child(_coach)
	_coach.reduce_motion = _motion.button_pressed
	var note := "Space: skip this step" if gate != "action" else ""
	_coach.show_hint("tut:%d:%d" % [_tutorial_panel, _tutorial_step], _tutorial_parts(step), str(step.get("caption", "")), note)
	return true


func _coach_blocked() -> bool:
	if mode != "PLAN" or page.is_empty() or _screen_covered():
		return true
	for sheet in [_pause_sheet, _settings_sheet, _intro_card, _story_card, _result_card]:
		if is_instance_valid(sheet) and sheet.visible:
			return true
	return is_instance_valid(_endings_book)


func _coach_wanted() -> String:
	var lanterns: Dictionary = page.get("lanterns", {})
	if lanterns.is_empty():
		return ""
	if not coach_done.has("move"):
		return "move"
	if int(lanterns.get("count", 1)) >= 2 and not coach_done.has("light2"):
		return "light2"
	if not _stage.key_picked.is_empty():
		return "swap"
	if not coach_done.has("tilt") and not coach_done.has("pick"):
		return "tilt"
	if _lit_ids().size() >= 2 and not coach_done.has("pick"):
		return "pick"
	if not coach_done.has("action"):
		return "action"
	return ""


func _coach_tick(delta: float, force: bool = false) -> void:
	_coach_timer -= delta
	if _coach_timer > 0.0 and not force:
		return
	_coach_timer = 0.2
	if DisplayServer.get_name() == "headless":
		return
	if _tutorial_card_tick():
		return
	var wanted := "" if _coach_blocked() else _coach_wanted()
	if wanted.is_empty():
		if is_instance_valid(_coach):
			_coach.hide_hint()
		_coach_shown_for = 0.0
		return
	if not is_instance_valid(_coach):
		_coach = COACH_CHIP.new()
		_coach.position = Vector2(16, 604)
		_ui.add_child(_coach)
	_coach.reduce_motion = _motion.button_pressed
	if _coach.hint_id != wanted:
		_coach_shown_for = 0.0
		_coach.show_hint(wanted, COACH_PARTS[wanted])
	_coach_shown_for += 0.2 if not force else 0.0
	if wanted in ["tilt", "light2"] and _coach_shown_for > COACH_PATIENCE:
		coach_done[wanted] = true


# ------------------------------------------------------------ tutorial (ui.md §8)
var tutorial_done := false
var _tutorial_panel := -1
var _tutorial_step := 0
var _tutorial_gate_hold := false
var _tutorial_skip: Button


func _persistent_or_campaign() -> bool:
	# Legacy MVP fixtures never run the tutorial.
	return page_override.is_empty()


func _tutorial_data() -> Dictionary:
	var tutorial: Variant = PAGE_SCRIPTS[page_index].definition().get("tutorial")
	return tutorial if tutorial is Dictionary else {}


func _start_tutorial(index: int, panel: int = 0) -> void:
	var data := _tutorial_data()
	var panels: Array = data.get("panels", [])
	if panel >= panels.size():
		_finish_tutorial()
		return
	var definition: Dictionary = panels[panel].duplicate(true)
	definition.id = "%s_tutorial_%d" % [PAGE_SCRIPTS[index].definition().id, panel + 1]
	definition.room = PAGE_SCRIPTS[index].definition().get("room", "living_room")
	_load_page(index, definition)
	_tutorial_panel = panel
	_tutorial_step = 0
	_title.text = "TUTORIAL %d/%d  ·  %s" % [panel + 1, panels.size(), str(definition.get("title", "")).to_upper()]
	_ensure_skip_tab()
	_show_tutorial_step()
	if panel == 0:
		_show_intro_card()


func _ensure_skip_tab() -> void:
	if not is_instance_valid(_tutorial_skip):
		_tutorial_skip = Button.new()
		_tutorial_skip.text = "SKIP TUTORIAL"
		_tutorial_skip.position = Vector2(770, 640)
		_tutorial_skip.size = Vector2(140, 36)
		_tutorial_skip.add_theme_font_size_override("font_size", 13)
		_tutorial_skip.pressed.connect(func():
			if _tutorial_skip.text == "SKIP TUTORIAL":
				_tutorial_skip.text = "SURE? CLICK AGAIN"
				get_tree().create_timer(3.0).timeout.connect(func():
					if is_instance_valid(_tutorial_skip):
						_tutorial_skip.text = "SKIP TUTORIAL")
			else:
				_finish_tutorial())
		_ui.add_child(_tutorial_skip)
	_tutorial_skip.visible = _tutorial_panel >= 0


func _tutorial_steps() -> Array:
	var panels: Array = _tutorial_data().get("panels", [])
	if _tutorial_panel < 0 or _tutorial_panel >= panels.size():
		return []
	return panels[_tutorial_panel].get("steps", [])


## What each tutorial gate lets the player do. One thing at a time: anything not
## listed for the current step is switched off. Gateless (info) steps allow all.
const TUTORIAL_ALLOW := {
	"lit": ["move_x"], "unlit": ["move_x"], "lit_set": ["move_x", "move_y"],
	"lantern_deployed": ["move_x", "move_y", "bulbs"], "lantern_parked": ["move_x", "move_y", "bulbs"],
	"choose": ["choose"], "picked": ["choose", "pick"], "swap": ["choose", "pick"],
	"action": ["action"], "clipping_opened": ["original"], "hint_opened": ["hint"],
	"endings_opened": ["book"], "click": [], "legend_opened": [],
}
var _gated_key := ""


func _tutorial_gate() -> String:
	var steps := _tutorial_steps()
	if _tutorial_panel < 0 or _tutorial_step >= steps.size():
		return ""
	return str(steps[_tutorial_step].get("gate", ""))


## Whether the current tutorial step lets the player use `action` (always true
## outside the tutorial, in later modes, and on gateless info steps).
func _tutorial_allows(action: String) -> bool:
	if mode != "PLAN":
		return true
	var gate := _tutorial_gate()
	if gate.is_empty() or not TUTORIAL_ALLOW.has(gate):
		return true
	return action in TUTORIAL_ALLOW[gate]


## The key caps for a tutorial step, derived from what it asks the player to do.
func _tutorial_parts(step: Dictionary) -> Array:
	var caption := str(step.get("caption", ""))
	var move := {"keys": ["A", "D"], "or": ["←", "→"], "label": "slide the light"}
	var tilt := {"keys": ["W", "S"], "or": ["↑", "↓"], "label": "raise / lower"}
	match str(step.get("gate", "")):
		"lit", "unlit", "lit_set":
			return [move, tilt] if (" S " in caption or " W " in caption or "lower" in caption) else [move]
		"lantern_deployed":
			return [{"keys": ["2"], "label": "take out the 2nd bulb"}]
		"lantern_parked":
			return [{"keys": ["P"], "label": "park it"}]
		"choose":
			return [{"keys": ["Tab"], "label": "choose someone"}]
		"picked":
			return [{"keys": ["Enter"], "label": "pick up their thought"}]
		"swap":
			return [{"keys": ["Tab"], "label": "the other one"}, {"keys": ["Enter"], "label": "swap"}, {"keys": ["Esc"], "label": "cancel"}]
		"action":
			return [{"keys": ["Space"], "label": "ACTION!"}]
		"clipping_opened":
			return [{"keys": ["O"], "label": "watch the Original"}]
		"hint_opened":
			return [{"keys": ["H"], "label": "hint"}]
		"endings_opened":
			return [{"keys": ["B"], "label": "Endings book"}]
		"click", "legend_opened":
			return [{"keys": ["Space"], "label": "got it"}]
	return []


## Space passes the current tutorial step (on the ACTION step it starts ACTION).
func _tutorial_pass() -> bool:
	var steps := _tutorial_steps()
	if _tutorial_panel < 0 or mode != "PLAN" or _tutorial_step >= steps.size():
		return false
	var gate := str(steps[_tutorial_step].get("gate", ""))
	if gate.is_empty() or gate == "action":
		return false
	_tutorial_step += 1
	_show_tutorial_step()
	_play_effect("PICK")
	return true


## Switch off the controls the current step has not introduced.
func _apply_tutorial_gating() -> void:
	if not is_instance_valid(_stage) or not is_instance_valid(_action):
		return
	var key := "%s:%s:%s" % [_tutorial_panel, _tutorial_step, mode]
	if key == _gated_key:
		return
	_gated_key = key
	_stage.lock_bulbs = not _tutorial_allows("move_x")
	_stage.lock_bubbles = not _tutorial_allows("choose")
	for hook in _hooks:
		hook.mouse_filter = Control.MOUSE_FILTER_IGNORE if not _tutorial_allows("bulbs") else Control.MOUSE_FILTER_STOP
	if not _tutorial_allows("action"):
		_action.disabled = true
	if not _tutorial_allows("restart"):
		_restart.disabled = true
	if is_instance_valid(_hint_hud) and not _tutorial_allows("hint"):
		_hint_hud.disabled = true


func _show_tutorial_step() -> void:
	var steps := _tutorial_steps()
	_gated_key = ""
	_update_buttons()
	if _tutorial_step < steps.size():
		if TUTORIAL_ALLOW.has(str(steps[_tutorial_step].get("gate", ""))):
			# Gated steps are taught by the tutorial card (_coach_tick), one thing at a time.
			_stage.set_caption("", 0.0)
		else:
			_stage.set_caption("Bulby: " + str(steps[_tutorial_step].get("caption", "")), 0.0)
		_stage.set_mood("scheme", 1.0)
		_instructions.text = "Tutorial step %d / %d" % [_tutorial_step + 1, steps.size()]
		_coach_timer = 0.0


func _tutorial_event(gate: String) -> void:
	var steps := _tutorial_steps()
	if _tutorial_step >= steps.size():
		return
	if str(steps[_tutorial_step].get("gate", "")) == gate:
		_tutorial_step += 1
		_show_tutorial_step()


func _check_tutorial_gates() -> void:
	# State-based gates are checked every frame during PLAN.
	var steps := _tutorial_steps()
	if _tutorial_step >= steps.size() or mode != "PLAN":
		return
	var step: Dictionary = steps[_tutorial_step]
	var gate := str(step.get("gate", ""))
	var lit := _lit_ids()
	var world: Dictionary = RULES.initial_world(page, plan.to_data())
	var lit_slots: Array = RULES.lit_slots(page, plan.to_data(), world)
	var targets: Array = step.get("target", []) if step.get("target") is Array else [step.get("target", "")]
	var satisfied := false
	match gate:
		"lit":
			satisfied = targets.all(func(id): return id in lit)
		"unlit":
			satisfied = targets.all(func(id): return id not in lit and not _object_lit(world, lit_slots, str(id)))
		"lit_set":
			satisfied = targets.all(func(id): return id in lit or _object_lit(world, lit_slots, str(id)))
		"lantern_deployed":
			satisfied = plan.lanterns.filter(func(l): return l.enabled).size() >= 2
		"lantern_parked":
			satisfied = plan.lanterns.filter(func(l): return l.enabled).size() <= 1
	if satisfied:
		_tutorial_step += 1
		_show_tutorial_step()


func _tutorial_has_gate(gate: String) -> bool:
	return _tutorial_steps().any(func(step): return str(step.get("gate", "")) == gate)


func _object_lit(world: Dictionary, lit_slots: Array, id: String) -> bool:
	for object in world.objects:
		if object.id == id:
			return int(object.slot) in lit_slots
	return false


func _tutorial_click() -> bool:
	var steps := _tutorial_steps()
	if _tutorial_step < steps.size() and str(steps[_tutorial_step].get("gate", "")) in ["click", "legend_opened"]:
		_tutorial_step += 1
		_show_tutorial_step()
		return true
	return false


func _advance_tutorial_panel() -> void:
	_start_tutorial(page_index, _tutorial_panel + 1)


func _finish_tutorial() -> void:
	tutorial_done = true
	_save_progress()
	_tutorial_panel = -1
	if is_instance_valid(_tutorial_skip):
		_tutorial_skip.hide()
	_load_page(page_index)
	var final: Array = _tutorial_data().get("final", {}).get("steps", [])
	if not final.is_empty():
		_stage.set_caption("Bulby: " + str(final[0].get("caption", "")), 6.0)


func _replay_tutorial() -> void:
	tutorial_done = false
	coach_done.clear()
	_save_progress()
	if is_instance_valid(_settings_sheet):
		_settings_sheet.hide()
	_close_pause()
	if is_instance_valid(_front):
		_front.hide()
	_load_page(0)



# ------------------------------------------------------------ music
## Original procedural jazz (assets/audio/generate_music.py): a PLAN layer and an
## ACTION layer of the same length play in sync and crossfade; narration ducks them.
var _music_plan: AudioStreamPlayer
var _music_action: AudioStreamPlayer
var _sting: AudioStreamPlayer
const MUSIC_DB := -12.0
const DUCK_DB := -9.0
const SILENT_DB := -60.0


func _loop_stream(path: String) -> AudioStream:
	var stream: Variant = load(path)
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = stream.data.size() / 2
	return stream


func _setup_music() -> void:
	if not ResourceLoader.exists("res://assets/audio/music/plan_loop.wav"):
		return
	_music_plan = AudioStreamPlayer.new()
	_music_plan.stream = _loop_stream("res://assets/audio/music/plan_loop.wav")
	_music_action = AudioStreamPlayer.new()
	_music_action.stream = _loop_stream("res://assets/audio/music/action_loop.wav")
	_sting = AudioStreamPlayer.new()
	for player in [_music_plan, _music_action]:
		player.bus = "Music"
		player.volume_db = SILENT_DB
		add_child(player)
	_sting.bus = "Music"
	add_child(_sting)


func _update_music(delta: float) -> void:
	if not is_instance_valid(_music_plan):
		return
	var allowed: bool = _sound.button_pressed and DisplayServer.get_name() != "headless" and not (is_instance_valid(_front) and _front.visible and _story_waiting)
	if not allowed:
		if _music_plan.playing:
			_music_plan.stop()
			_music_action.stop()
		return
	if not _music_plan.playing:
		# Start both layers together so they stay in phase.
		_music_plan.play()
		_music_action.play()
	var duck := DUCK_DB if is_instance_valid(_voice) and _voice.playing else 0.0
	var action := mode == "PLAY"
	var plan_target := MUSIC_DB + duck if not action else SILENT_DB
	var action_target := MUSIC_DB + duck if action else SILENT_DB
	var rate := clampf(delta / 0.3, 0.0, 1.0)
	_music_plan.volume_db = lerpf(_music_plan.volume_db, plan_target, rate)
	_music_action.volume_db = lerpf(_music_action.volume_db, action_target, rate)


func _play_sting(won: bool) -> void:
	if not is_instance_valid(_sting) or not _sound.button_pressed or DisplayServer.get_name() == "headless":
		return
	_sting.stream = load("res://assets/audio/music/%s_sting.wav" % ("win" if won else "fail"))
	_sting.volume_db = -6.0
	_sting.play()


func _narrate_key(key: String) -> void:
	var text: String = _lines.get("narrator", {}).get(key, "")
	if not text.is_empty():
		_stage.set_caption(text, 0.0)
		_play_voice_file("narrator/" + key, _voice)



# The tutorial opens with the big picture, as short paged cards: the story and
# the Original, how light and thoughts work, the Twist goal, stars and endings.
var _intro_card: Control
var _intro_page := 0
var _intro_pending := false
var _intro_heading: Label
var _intro_body: RichTextLabel
var _intro_next: Button
var _intro_back: Button
var _intro_dots: Label


func _intro_pages() -> Array:
	var intro: Array = _tutorial_data().get("intro", [])
	var line := func(index: int) -> String: return str(intro[index]) if index < intro.size() else ""
	var panels: int = _tutorial_data().get("panels", []).size()
	var tick := _icon("star_on")
	return [
		["THE STORY", "\n".join([
			line.call(0),
			"",
			"It is narrated by the [b]Official Narrator[/b], who talks like an institute circular and has never allowed a twist in four thousand pages.",
			"",
			"Tonight, the only working bulb in OBH falls into his comic. That's you.",
		])],
		["HOW IT WORKS", "\n".join([
			line.call(1),
			"",
			"  " + tick + "[b]HUNGRY[/b] eats food     " + tick + "[b]SLEEPY[/b] sits on a seat",
			"  " + tick + "[b]ANGRY[/b] bonks someone     " + tick + "[b]SCARED[/b] runs out of the comic",
			"",
			"In the dark, characters do nothing and their thoughts stay secret. Drag one lit thought onto another lit character to [b]swap[/b] what they're thinking.",
			"",

		])],
		["THE GOAL", "\n".join([
			line.call(2),
			"",
			"The red line at the top is the [color=#a4383e][b]TWIST[/b][/color]; the grey pencil lines under it are the [i]fine-tunes[/i]. Set up your light and thoughts, press [b]ACTION![/b] and watch it play out.",
			"",
			"Not right? Retry as often as you like. Every attempt is free.",
		])],
		["STARS & ENDINGS", "\n".join([
			line.call(3),
			"",
			"This tutorial is [b]%d short panels[/b], one idea each, then the real Biryani Sunday page. You can skip it any time and replay it from Settings." % panels,
		])],
	]


func _show_intro_card() -> void:
	# Wait until the title menu is gone; the card must never sit on top of it.
	if not is_instance_valid(_front) or _front.visible:
		_intro_pending = true
		return
	_intro_pending = false
	if not is_instance_valid(_intro_card):
		_intro_card = Control.new()
		_intro_card.size = Vector2(1280, 720)
		_intro_card.z_index = 230
		_intro_card.mouse_filter = Control.MOUSE_FILTER_STOP
		_ui.add_child(_intro_card)
		var dim := ColorRect.new()
		dim.color = Color(INK, 0.6)
		dim.size = Vector2(1280, 720)
		_intro_card.add_child(dim)
		var card := _paper_panel(Rect2(240, 90, 800, 540), -0.008)
		_intro_card.add_child(card)
		_intro_heading = _label("", 46)
		_intro_heading.add_theme_font_override("font", COMIC_FONT)
		_intro_heading.position = Vector2(0, 24)
		_intro_heading.size = Vector2(800, 60)
		_intro_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(_intro_heading)
		_intro_body = _rich(21)
		_intro_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_intro_body.position = Vector2(56, 104)
		_intro_body.size = Vector2(688, 320)
		card.add_child(_intro_body)
		_intro_dots = _label("", 22)
		_intro_dots.position = Vector2(0, 420)
		_intro_dots.size = Vector2(800, 30)
		_intro_dots.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(_intro_dots)
		_intro_next = Button.new()
		_intro_next.add_theme_font_override("font", COMIC_FONT)
		_intro_next.add_theme_font_size_override("font_size", 28)
		_intro_next.position = Vector2(540, 460)
		_intro_next.size = Vector2(200, 56)
		_emphasise(_intro_next, true)
		_intro_next.pressed.connect(func():
			_play_effect("SWAP")
			if _intro_page >= _intro_pages().size() - 1:
				_intro_card.hide()
			else:
				_intro_page += 1
				_fill_intro_card())
		card.add_child(_intro_next)
		_intro_back = Button.new()
		_intro_back.text = "BACK"
		_intro_back.add_theme_font_size_override("font_size", 16)
		_intro_back.position = Vector2(400, 466)
		_intro_back.size = Vector2(120, 44)
		_intro_back.pressed.connect(func():
			_intro_page = maxi(0, _intro_page - 1)
			_fill_intro_card())
		card.add_child(_intro_back)
		var skip := Button.new()
		skip.text = "SKIP TUTORIAL"
		skip.add_theme_font_size_override("font_size", 14)
		skip.position = Vector2(56, 470)
		skip.size = Vector2(170, 38)
		skip.pressed.connect(func():
			_intro_card.hide()
			_finish_tutorial())
		card.add_child(skip)
	_intro_page = 0
	_fill_intro_card()
	_intro_card.show()
	_intro_next.grab_focus.call_deferred()


func _fill_intro_card() -> void:
	var pages := _intro_pages()
	_intro_page = clampi(_intro_page, 0, pages.size() - 1)
	_intro_heading.text = pages[_intro_page][0]
	_intro_body.text = pages[_intro_page][1]
	_intro_dots.text = "%d / %d" % [_intro_page + 1, pages.size()]
	if _voice_path("narrator/v_tut_%d" % (_intro_page + 1)) != "":
		_play_voice_file("narrator/v_tut_%d" % (_intro_page + 1), _voice)
	_intro_next.text = "LET'S GO!" if _intro_page == pages.size() - 1 else "NEXT"
	_intro_back.visible = _intro_page > 0


# ------------------------------------------------------------ endings book
var _endings_book: Control
var _tutorial_endings: Dictionary = {}


func _found_endings() -> Array:
	return (_tutorial_endings if _tutorial_panel >= 0 else endings_found).get(page.get("id", ""), [])


func _open_endings_book() -> void:
	if page.is_empty():
		return
	if is_instance_valid(_endings_book):
		_endings_book.queue_free()
	_endings_book = Control.new()
	_endings_book.size = Vector2(1280, 720)
	_endings_book.z_index = 220
	_endings_book.mouse_filter = Control.MOUSE_FILTER_STOP
	_ui.add_child(_endings_book)
	var dim := ColorRect.new()
	dim.color = Color(INK, 0.55)
	dim.size = Vector2(1280, 720)
	dim.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			_endings_book.queue_free())
	_endings_book.add_child(dim)
	var card := _paper_panel(Rect2(290, 80, 700, 560), 0.006)
	_endings_book.add_child(card)
	var heading := _label("ENDINGS BOOK", 40)
	heading.add_theme_font_override("font", COMIC_FONT)
	heading.position = Vector2(0, 18)
	heading.size = Vector2(700, 50)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(heading)
	var found := _found_endings()
	var total := maxi(int(page.get("endings_total", 0)), found.size()) if _tutorial_panel < 0 else found.size()
	var sub := _label("%s  ·  %d of %d endings found" % [str(page.get("title", "")).to_upper(), found.size(), total] if _tutorial_panel < 0 else "Every different result lands here.", 16)
	sub.position = Vector2(0, 70)
	sub.size = Vector2(700, 24)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(sub)
	var list := _rich(17)
	list.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	list.scroll_active = true
	list.position = Vector2(40, 108)
	list.size = Vector2(620, 370)
	var lines: Array[String] = []
	var twist := str(page.get("goal", {}).get("twist_caption", ""))
	for i in found.size():
		var caption := str(found[i])
		var won := caption == twist or caption.to_lower() == twist.to_lower()
		lines.append("[b]%d.[/b]  %s%s" % [i + 1, caption, "   [color=#a4383e][b]TWIST![/b][/color]" if won else ""])
	var missing := total - found.size()
	if missing > 0:
		lines.append("")
		lines.append("[color=#8a8578]??? x%d still hidden. Try lighting different characters or swapping thoughts.[/color]" % missing)
	if found.is_empty():
		lines = ["[color=#8a8578]No endings yet. Press ACTION to print your first one![/color]"]
	list.text = "\n".join(lines)
	card.add_child(list)
	var close := Button.new()
	close.text = "CLOSE"
	close.add_theme_font_size_override("font_size", 18)
	close.position = Vector2(270, 494)
	close.size = Vector2(160, 46)
	_emphasise(close, true)
	close.pressed.connect(func(): _endings_book.queue_free())
	card.add_child(close)
	close.grab_focus.call_deferred()
	_play_effect("SWAP")
	_tutorial_event("endings_opened")


func _all_hints() -> Array:
	# Main-goal hints first (step by step), then one hint per bonus headline.
	var hints: Array = page.get("hints", []).duplicate()
	for line in page.get("bonus_hints", []):
		hints.append("Bonus: " + str(line))
	return hints



# ------------------------------------------------------------ story: acts, new feelings, running gags
const LEGEND_BASE := ""
const NEW_FEELINGS := {
	"SHY": ["SHY", "Hates being seen. In the light it scurries to the nearest dark spot and hides. Your light pushes it around!"],
	"IN_LOVE": ["IN LOVE", "Walks to the nearest lit character and hugs them. Whoever gets hugged falls in love too and goes looking for someone else to hug!"],
	"JEALOUS": ["JEALOUS", "Wants whatever the nearest busy character is going for, and races them to it. Arrive together? CLONK!"],
}
var STORY: Dictionary = {}
var seen_cards: Dictionary = {}
var gags: Dictionary = {"exit": 0, "dog": 0}
var _story_card: Control
var _story_queue: Array = []


func _story() -> Dictionary:
	if STORY.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/campaign/story15.json"))
		STORY = parsed if parsed is Dictionary else {"acts": []}
	return STORY


func _legend_text() -> String:
	# One chip per feeling on this page: icon, name in its colour, what it does.
	var present := {"HUNGRY": true, "SLEEPY": true, "ANGRY": true, "SCARED": true}
	for character in page.get("characters", []):
		present[str(character.thought)] = true
	var chips: Array[String] = []
	for thought in ["HUNGRY", "SLEEPY", "ANGRY", "SCARED", "SHY", "IN_LOVE", "JEALOUS"]:
		if not present.has(thought):
			continue
		var colour: Color = STAGE.COLOURS[thought].lightened(0.25)
		chips.append("[img=18x18]res://assets/thoughts/%s.svg[/img] [color=#%s][b]%s[/b][/color] %s" % [thought.to_lower(), colour.to_html(false), thought.replace("_", " "), FEELING_VERBS[thought]])
	return "      ".join(chips)


const FEELING_VERBS := {"HUNGRY": "eats", "SLEEPY": "naps", "ANGRY": "bonks", "SCARED": "flees", "SHY": "hides", "IN_LOVE": "hugs", "JEALOUS": "copies"}


## Called after a campaign page loads: queue the act card and the NEW FEELING card.
func _queue_story_cards() -> void:
	if not page_override.is_empty() or _tutorial_panel >= 0 or "_tutorial_" in str(page.get("id", "")) or DisplayServer.get_name() == "headless":
		return
	var number := int(page.get("number", page_index + 1))
	var act_card: Variant = page.get("act_card_before")
	if act_card is Dictionary and not seen_cards.has("act_%d" % int(act_card.number)):
		var act_title := str(act_card.title)
		_story_queue.append({"id": "act_%d" % int(act_card.number), "kicker": act_title.get_slice(": ", 0), "title": act_title.substr(act_title.find(": ") + 2), "body": "The Narrator: \"%s\"" % act_card.text, "thought": ""})
	for act in _story().get("acts", []):
		var id := "act_%d" % int(act.number)
		if int(act.first_page) == number and not seen_cards.has(id) and not act_card is Dictionary:
			_story_queue.append({"id": id, "kicker": "ACT %s" % ["ONE", "TWO", "THREE"][clampi(int(act.number) - 1, 0, 2)], "title": str(act.title).get_slice(": ", 1), "body": "The Narrator: \"%s\"" % act.card, "thought": ""})
	var feeling := str(page.get("new_feeling", ""))
	# Pages 4-15 carry their own card text ("tutorial") and a recording "<page>_card".
	var card_text: Array = page.get("tutorial") if page.get("tutorial") is Array else []
	var card_voice := "%s_card" % str(page.get("voice", page.id))
	if NEW_FEELINGS.has(feeling) and not seen_cards.has("feeling_" + feeling):
		var body := str(NEW_FEELINGS[feeling][1])
		if not card_text.is_empty():
			body = str(card_text[0])
			var prefix := "NEW FEELING: %s. " % NEW_FEELINGS[feeling][0]
			if body.begins_with(prefix):
				body = body.substr(prefix.length())
		var card := {"id": "feeling_" + feeling, "kicker": "NEW FEELING!", "title": NEW_FEELINGS[feeling][0], "body": body, "thought": feeling}
		if _voice_path("narrator/" + card_voice) != "":
			card.voice = card_voice
		_story_queue.append(card)
	elif not card_text.is_empty() and not seen_cards.has(page.id + "_card"):
		var card := {"id": page.id + "_card", "kicker": "REMEMBER!", "title": "YOUR SPARE BULB" if int(page.get("flick", 0)) > 0 else "TIP", "body": str(card_text[0]), "thought": ""}
		if _voice_path("narrator/" + card_voice) != "":
			card.voice = card_voice
		_story_queue.append(card)


func _show_story_card(card: Dictionary) -> void:
	seen_cards[card.id] = true
	_save_progress()
	if is_instance_valid(_story_card):
		_story_card.queue_free()
	_story_card = Control.new()
	_story_card.size = Vector2(1280, 720)
	_story_card.z_index = 235
	_story_card.mouse_filter = Control.MOUSE_FILTER_STOP
	_ui.add_child(_story_card)
	var dim := ColorRect.new()
	dim.color = Color(INK, 0.7)
	dim.size = Vector2(1280, 720)
	_story_card.add_child(dim)
	var wide := card.has("image")
	var panel := _paper_panel(Rect2(160, 50, 960, 620) if wide else Rect2(260, 120, 760, 470), 0.01 if card.thought == "" else -0.012)
	_story_card.add_child(panel)
	var width := panel.size.x
	var kicker := _label(str(card.kicker), 26)
	kicker.add_theme_font_override("font", COMIC_FONT)
	kicker.add_theme_color_override("font_color", Color("a4383e"))
	kicker.position = Vector2(0, 26)
	kicker.size = Vector2(width, 34)
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(kicker)
	var title := _label(str(card.title), 54)
	title.add_theme_font_override("font", COMIC_FONT)
	title.position = Vector2(0, 62)
	title.size = Vector2(width, 70)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(title)
	var top := 150.0
	if card.thought != "":
		var icon := TextureRect.new()
		icon.texture = load("res://assets/thoughts/%s.svg" % str(card.thought).to_lower())
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.position = Vector2(320, 140)
		icon.size = Vector2(120, 120)
		panel.add_child(icon)
		top = 270.0
		_play_effect("REVEAL_" + str(card.thought))
	elif card.get("ding", false):
		_ding(392.0)
	else:
		_play_sting(true)
	if wide:
		var picture := TextureRect.new()
		picture.texture = load(str(card.image))
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.position = Vector2(36, 140)
		picture.size = Vector2(512, 288)
		picture.rotation = -0.02
		panel.add_child(picture)
	var card_voice := {"act_1": _first_voice(["v_act1", "story_act1"]), "act_2": _first_voice(["act2", "narr15_act2"]), "act_3": _first_voice(["act3", "narr15_act3"]), "feeling_SHY": _first_voice(["page_05_card", "narr15_new_shy"]), "feeling_IN_LOVE": _first_voice(["page_08_card", "narr15_new_love"]), "feeling_JEALOUS": _first_voice(["page_10_card", "narr15_new_jealous"])}
	if card.has("voice"):
		card_voice[card.id] = card.voice
	if card_voice.has(card.id):
		_play_voice_file("narrator/" + card_voice[card.id], _voice)
	var body := _rich(22)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.position = Vector2(60, top)
	body.size = Vector2(640, 380 - top)
	if wide:
		body.add_theme_font_size_override("normal_font_size", 18)
		body.add_theme_font_size_override("bold_font_size", 18)
		body.position = Vector2(572, 136)
		body.size = Vector2(356, 380)
	elif card.has("small"):
		body.add_theme_font_size_override("normal_font_size", 18)
		body.add_theme_font_size_override("bold_font_size", 18)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.text = str(card.body)
	panel.add_child(body)
	var go := Button.new()
	go.text = str(card.get("button", "GOT IT!" if card.thought != "" else "ON WITH THE SHOW"))
	go.add_theme_font_override("font", COMIC_FONT)
	go.add_theme_font_size_override("font_size", 26)
	go.size = Vector2(300, 56)
	go.position = Vector2((width - go.size.x) * 0.5, panel.size.y - 78)
	_emphasise(go, true)
	go.pressed.connect(func():
		_play_effect("SWAP")
		_stop_voice()
		_story_card.hide()
		_story_card.queue_free()
		if card.get("then") is Callable:
			card.then.call())
	panel.add_child(go)
	go.grab_focus.call_deferred()


## Running gags (story.md §4): where the runaway was last seen, and the Dog's career.
func _gag_lines(result: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	if _tutorial_panel >= 0 or not page_override.is_empty():
		return lines
	var places: Array = _story().get("exit_places", [])
	for event in _run.get("events", []):
		if event.type == "EXIT" and not places.is_empty():
			lines.append("Last seen at: %s." % places[int(gags.get("exit", 0)) % places.size()])
			gags.exit = int(gags.get("exit", 0)) + 1
			break
	var titles: Array = _story().get("dog_titles", [])
	if result.won and not titles.is_empty():
		for event in _run.get("events", []):
			if event.type == "EAT" and event.actor == "dog" and _object_art(str(event.object)) in ["cake", "slice", "pie"]:
				var index := mini(int(gags.get("dog", 0)), titles.size() - 1)
				lines.append("%s has been promoted to %s!" % [GOALS._character_name("dog", true), titles[index]])
				gags.dog = int(gags.get("dog", 0)) + 1
				break
	if not lines.is_empty():
		_save_progress()
	return lines


func _object_art(id: String) -> String:
	for object in page.get("objects", []):
		if object.id == id:
			return str(object.get("art", id))
	return id



## "THE BOSS BONKS GRANDMA" -> "The Boss bonks Grandma": names keep their capitals.
func _sentence_case(text: String) -> String:
	var words := text.to_lower()
	words = words.left(1).to_upper() + words.substr(1)
	for keep in ["HR", "Kevin", "Brian", "Gary", "Steve", "Doug", "Dave", "Nigel"]:
		words = RegEx.create_from_string("\\b%s\\b" % keep.to_lower()).sub(words, keep, true)
	for character in page.get("characters", []):
		var name := str(character.get("name", character.id))
		var regex := RegEx.create_from_string("\\b%s\\b" % name.to_lower())
		words = regex.sub(words, name, true)
	return words



func _glass_panel(rect: Rect2) -> Panel:
	var panel := Panel.new()
	var box := StyleBoxFlat.new()
	box.bg_color = Color(Color("fffaf0"), 0.9)
	box.border_color = Color(INK, 0.85)
	box.set_border_width_all(2)
	box.set_corner_radius_all(10)
	box.shadow_color = Color(0, 0, 0, 0.35)
	box.shadow_size = 8
	box.shadow_offset = Vector2(0, 3)
	panel.add_theme_stylebox_override("panel", box)
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel



# ------------------------------------------------------------ star award
const STAR_AWARD = preload("res://presentation/star_award.gd")
var _star_award: Control


## Bulbs light up one by one after a page; the fresh ones pop in with sparks.
func _show_star_award(before: int, after: int, won: bool) -> void:
	if not is_instance_valid(_star_award):
		_star_award = STAR_AWARD.new()
		_star_award.z_index = 220
		_ui.add_child(_star_award)
		_star_award.star_landed.connect(func(index: int, _fresh: bool):
			_ding(587.33 * pow(1.26, index))
			_play_effect("SWAP"))
	_star_award.position = _stage.position
	_star_award.size = _stage.size
	var total: int = 1 + _star_steps(page).size()
	var title := "PERFECT PAGE!" if after == total else ("PAGE CLEAR!" if won else "BONUS STAR!")
	_star_award.play(before, after, total, title, COMIC_FONT, _motion.button_pressed)



# ------------------------------------------------------------ keyboard play
## Every action has a key, like a usual game:
##   PLAN   arrows/WASD move the bulb (up/down raise/lower), 1/2 pick a bulb,
##          P park/hang it, Tab/Q/E cycle lit characters, Enter picks a thought
##          and Enter on another swaps them, Esc drops it, H hint, R restart,
##          O replay the Original, B Endings book, Space ACTION.
##   PLAY   Space skips, left/right aim the spare bulb, F/Enter drops it.
##   RESULT Enter next page (after a win) or retry, R restart, L levels.
var _key_aim := -1


func _keyboard(event: InputEventKey) -> bool:
	var key := event.keycode
	match mode:
		"PLAN":
			# Tutorial gating: only what the current step introduced works.
			var needed := ""
			match key:
				KEY_A, KEY_D, KEY_LEFT, KEY_RIGHT:
					needed = "move_x"
				KEY_W, KEY_S, KEY_UP, KEY_DOWN:
					needed = "move_y"
				KEY_1, KEY_2, KEY_P:
					needed = "bulbs"
				KEY_TAB, KEY_Q, KEY_E:
					needed = "choose"
				KEY_ENTER, KEY_KP_ENTER:
					needed = "pick"
				KEY_H:
					needed = "hint"
				KEY_R:
					needed = "restart"
				KEY_O:
					needed = "original"
				KEY_B:
					needed = "book"
			if not needed.is_empty() and not _tutorial_allows(needed):
				if key in [KEY_ENTER, KEY_KP_ENTER] and not event.echo:
					_tutorial_pass_or_click()
				return true
			if key in [KEY_A, KEY_D, KEY_W, KEY_S, KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]:
				# One press = one grid step. The OS key-repeat is ignored; holding
				# the key repeats from _hold_repeat() at a gentler rate.
				if not event.echo:
					_hold_key = key
					_hold_time = 0.0
					_hold_move(key, event.shift_pressed)
				return true
			if key in [KEY_1, KEY_2, KEY_P]:
				_coach_event("light2")
			if (key in [KEY_1, KEY_2, KEY_P]) and not _stage.has_focus():
				_stage.grab_focus()
				_stage._gui_input(event)
				return true
			if event.echo:
				return false
			match key:
				KEY_TAB, KEY_E, KEY_Q:
					_cycle_cursor(-1 if key == KEY_Q or event.shift_pressed else 1)
					return true
				KEY_ENTER, KEY_KP_ENTER:
					# Enter also dismisses the tutorial's "click to continue" steps.
					if not _tutorial_click():
						_key_select()
					return true
				KEY_H:
					_show_hint()
					return true
				KEY_R:
					_restart_page()
					return true
				KEY_O:
					_replay_original()
					return true
				KEY_B:
					_open_endings_book()
					return true
		"PLAY":
			if not _flick_available():
				return false
			if key in [KEY_LEFT, KEY_RIGHT, KEY_A, KEY_D]:
				var start := _key_aim if _key_aim >= 0 else int(page.width) / 2
				_key_aim = clampi(start + (-1 if key in [KEY_LEFT, KEY_A] else 1), 0, int(page.width) - 1)
				return true
			if key in [KEY_F, KEY_ENTER, KEY_KP_ENTER] and not event.echo:
				var slot := _aim_slot()
				if slot < 0:
					slot = int(page.width) / 2
				_drop_flick(slot)
				_key_aim = -1
				return true
		"RESULT":
			if event.echo:
				return false
			match key:
				KEY_ENTER, KEY_KP_ENTER, KEY_N:
					if is_instance_valid(_star_award) and _star_award.visible and not _star_award._done:
						_star_award._finish()
					elif _won_current and _next.visible:
						_next_page()
					else:
						_return_to_plan()
					return true
				KEY_R:
					_restart_page()
					return true
				KEY_L:
					_open_edition()
					return true
				KEY_H:
					_show_hint()
					return true
	return false


const HOLD_DELAY := 0.38
const HOLD_RATE := 0.17
var _hold_key := 0
var _hold_time := 0.0


func _hold_move(key: int, fine: bool) -> void:
	var arrow: int = {KEY_A: KEY_LEFT, KEY_D: KEY_RIGHT, KEY_W: KEY_UP, KEY_S: KEY_DOWN}.get(key, key)
	_nudge_lantern(arrow, fine)
	_tutorial_event("moved")
	if arrow in [KEY_UP, KEY_DOWN]:
		_coach_event("tilt")


## A held direction key repeats after a pause, a step at a time.
func _hold_repeat(delta: float) -> void:
	if _hold_key == 0:
		return
	if mode != "PLAN" or not Input.is_key_pressed(_hold_key):
		_hold_key = 0
		return
	_hold_time += delta
	if _hold_time >= HOLD_DELAY:
		_hold_time -= HOLD_RATE
		_hold_move(_hold_key, Input.is_key_pressed(KEY_SHIFT))


## Enter dismisses an info step (same as Space).
func _tutorial_pass_or_click() -> void:
	if not _tutorial_click():
		_tutorial_pass()


func _nudge_lantern(arrow: int, fine: bool) -> void:
	var fake := InputEventKey.new()
	fake.keycode = arrow
	fake.pressed = true
	fake.shift_pressed = fine
	var lantern: Dictionary = plan.lanterns[_stage._selected_lantern]
	if not lantern.enabled:
		# The first nudge hangs a parked bulb where it was last placed.
		_move_lantern(_stage._selected_lantern, Vector2(lantern.x, lantern.y), true)
	_stage._gui_input(fake)


func _cycle_cursor(direction: int) -> void:
	var lit := _lit_ids()
	if lit.is_empty():
		_instructions.text = "Nobody is lit yet. Move the bulb with the arrow keys (or WASD) first."
		return
	var order: Array[String] = []
	for character in _stage._shown().get("characters", []):
		if character.id in lit:
			order.append(character.id)
	var index := order.find(_stage.key_cursor)
	index = (index + direction + order.size()) % order.size() if index >= 0 else (0 if direction > 0 else order.size() - 1)
	_stage.key_cursor = order[index]
	_tutorial_event("choose")
	if not _stage.key_picked.is_empty() and _stage.key_picked != _stage.key_cursor:
		_preview(_stage.key_picked, _stage.key_cursor)
	_play_effect("POKE_" + _thought_now(_stage.key_cursor))
	_stage.queue_redraw()


func _key_select() -> void:
	var cursor: String = _stage.key_cursor
	if cursor.is_empty() or cursor not in _lit_ids():
		_cycle_cursor(1)
		return
	if _stage.key_picked.is_empty():
		_stage.key_picked = cursor
		_coach_event("pick")
		_tutorial_event("picked")
		_play_effect("PICK")
		_instructions.text = "Picked %s's thought. Tab to another lit character, Enter to swap, Esc to cancel." % _name_of(cursor)
	elif _stage.key_picked == cursor:
		_stage.key_picked = ""
		_stage.clear_preview()
	else:
		var first: String = _stage.key_picked
		_stage.key_picked = ""
		_swap(first, cursor)
	_stage.queue_redraw()



# ------------------------------------------------------------ juice: iris, vignette, button pops
const IRIS_SHADER = preload("res://presentation/iris.gdshader")
var _iris: ColorRect
var _iris_tween: Tween
var _vignette: TextureRect


func _ensure_iris() -> void:
	if is_instance_valid(_iris):
		return
	_iris = ColorRect.new()
	_iris.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_iris.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_iris.z_index = 400
	var material := ShaderMaterial.new()
	material.shader = IRIS_SHADER
	material.set_shader_parameter("radius", 1.5)
	_iris.material = material
	add_child(_iris)


func _iris_set(radius: float) -> void:
	_iris.material.set_shader_parameter("radius", radius)
	_iris.material.set_shader_parameter("aspect", size.x / maxf(1.0, size.y))


## Close the iris on Bulby, then run the callback (which loads the next page).
func _iris_close(then: Callable) -> void:
	if DisplayServer.get_name() == "headless" or _motion.button_pressed:
		then.call()
		return
	_ensure_iris()
	if is_instance_valid(_iris_tween):
		_iris_tween.kill()
	_iris.show()
	_iris_tween = create_tween()
	_iris_tween.tween_method(_iris_set, 1.3, 0.0, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_iris_tween.tween_callback(then)


## Open the iris on the new page.
func _iris_open() -> void:
	if DisplayServer.get_name() == "headless" or _motion.button_pressed or not page_override.is_empty():
		return
	_ensure_iris()
	if is_instance_valid(_iris_tween):
		_iris_tween.kill()
	_iris.show()
	_iris_set(0.0)
	_iris_tween = create_tween()
	_iris_tween.tween_interval(0.06)
	_iris_tween.tween_method(_iris_set, 0.0, 1.3, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_iris_tween.tween_callback(_iris.hide)


## Every button in the game grows a little under the cursor and squashes on press.
func _juice_button(node: Node) -> void:
	if not node is BaseButton or node.has_meta("juiced"):
		return
	node.set_meta("juiced", true)
	var button: Control = node
	var bounce := func(target: float, seconds: float):
		if not button.is_inside_tree() or _motion.button_pressed:
			return
		button.pivot_offset = button.size * 0.5
		var tween := button.create_tween()
		tween.tween_property(button, "scale", Vector2.ONE * target, seconds).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	button.mouse_entered.connect(func(): bounce.call(1.06, 0.12))
	button.mouse_exited.connect(func(): bounce.call(1.0, 0.12))
	button.focus_entered.connect(func():
		bounce.call(1.07, 0.12)
		button.self_modulate = Color(1.08, 1.04, 0.92))
	button.focus_exited.connect(func():
		bounce.call(1.0, 0.12)
		button.self_modulate = Color.WHITE)
	button.button_down.connect(func(): bounce.call(0.94, 0.06))
	button.button_up.connect(func(): bounce.call(1.04, 0.1))


func _build_vignette() -> void:
	# A soft dark edge around the whole screen pulls the eye to the lit stage.
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0, 0, 0, 0))
	gradient.set_color(1, Color(0.02, 0.02, 0.06, 0.55))
	gradient.add_point(0.6, Color(0, 0, 0, 0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.05, 1.05)
	texture.width = 256
	texture.height = 144
	_vignette = TextureRect.new()
	_vignette.texture = texture
	_vignette.stretch_mode = TextureRect.STRETCH_SCALE
	_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_vignette)
	move_child(_vignette, _ui.get_index())



# ------------------------------------------------------------ HUD theme and footer
## Shared HUD colours: the lore re-skin swaps these in one place.
const UI_LIGHT := Color("f6eedc")
const UI_FOCUS := Color("ffe9a8")
const UI_SHADE := Color(0.03, 0.04, 0.09)
var _footer_shade: TextureRect
var _narration: Label
var _narration_text := ""
var _narration_centred := false


func _build_footer_shade() -> TextureRect:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(UI_SHADE, 0.0))
	gradient.set_color(1, Color(UI_SHADE, 0.88))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0, 0)
	texture.fill_to = Vector2(0, 1)
	texture.width = 4
	texture.height = 64
	var shade := TextureRect.new()
	shade.texture = texture
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	shade.position = Vector2(0, 560)
	shade.size = Vector2(1280, 160)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return shade


func _build_narration_label() -> Label:
	var label := _label("", 19)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", UI_LIGHT)
	label.add_theme_constant_override("outline_size", 7)
	label.add_theme_color_override("font_outline_color", Color(UI_SHADE, 0.95))
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 170
	return label


## Narration subtitles: bottom-left, or bottom-centre while a card floats on screen.
func _update_narration_line() -> void:
	if not is_instance_valid(_narration) or not is_instance_valid(_stage):
		return
	var floating := (is_instance_valid(_result_card) and _result_card.visible) or (is_instance_valid(_story_card) and _story_card.visible) or (is_instance_valid(_intro_card) and _intro_card.visible) or is_instance_valid(_endings_book)
	var text: String = _stage._caption_text
	if text == _narration_text and floating == _narration_centred:
		return
	var changed := text != _narration_text
	_narration_text = text
	_narration_centred = floating
	_narration.text = text
	_narration.add_theme_font_size_override("font_size", 19 if text.length() < 150 else (16 if text.length() < 260 else 14))
	_narration.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if floating else HORIZONTAL_ALIGNMENT_LEFT
	var rect := Rect2(352, 604, 560, 112) if floating else Rect2(20, 606, 860, 80)
	_narration.size = rect.size
	_narration.position = rect.position
	if changed and not text.is_empty() and not _motion.button_pressed:
		# New lines rise into place.
		_narration.position.y += 14
		_narration.modulate.a = 0.0
		var tween := create_tween().set_parallel(true)
		tween.tween_property(_narration, "position:y", rect.position.y, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(_narration, "modulate:a", 1.0, 0.2)



# ------------------------------------------------------------ star ladder (IIIT-H story)
## Stars after the twist. Ladder pages: each step adds its fact to the twist and
## the steps before it (cumulative). Older pages: independent bonus headlines.
func _star_steps(definition: Dictionary) -> Array:
	if not definition.has("ladder"):
		return definition.get("bonus", [])
	var steps: Array = []
	var facts: Array = Array(definition.get("goal", {}).get("facts", [])).duplicate(true)
	for step in definition.get("ladder", []):
		facts = facts + Array(step.get("facts", [])).duplicate(true)
		steps.append({"id": step.id, "caption": step.caption, "facts": facts.duplicate(true)})
	return steps


## How many stars this run earned on its own (0 = twist missed).
func _run_star_level() -> int:
	if _run.is_empty() or not GOALS.evaluate(page, _run).won:
		return 0
	var level := 1
	for step in _star_steps(page):
		var challenge := page.duplicate()
		challenge.goal = {"facts": step.facts, "twist_caption": step.caption}
		if not GOALS.evaluate(challenge, _run).won:
			break
		level += 1
	return level


## Star lines and hidden lines read after the win line: [[text, voice key], ...].
func _win_extras(prefix: String) -> Array:
	var written: Dictionary = page.get("narration", {})
	var extras: Array = []
	var level := _run_star_level()
	var stars: Array = written.get("stars", written.get("star_lines", []))
	for i in range(mini(level - 1, stars.size())):
		extras.append([stars[i], prefix + "stars_%d" % (i + 1)])
	var hidden: Array = written.get("hidden", [])
	for i in hidden.size():
		var entry: Variant = hidden[i]
		if not entry is Dictionary:
			continue
		var challenge := page.duplicate()
		challenge.goal = {"facts": entry.get("facts", []), "twist_caption": ""}
		if GOALS.evaluate(challenge, _run).won:
			extras.append([str(entry.get("line", "")), prefix + "hidden_%d" % (i + 1)])
	return extras


# ------------------------------------------------------------ between pages
var achievements: Dictionary = {}
var _revealing := false
var _reveal_source: Dictionary = {}
## Page 4's three-star plan (tools/finale_plan.gd): the page 15 reveal replays it.
const REVEAL_PLAN := {"thoughts": {"cat": "SCARED", "dog": "HUNGRY", "grandma": "SCARED", "prompt": "SLEEPY"}, "lanterns": [{"enabled": true, "x": 1.4, "y": 0.0}, {"enabled": false, "x": 0.0, "y": -0.6}]}


## Page 5's mail and page 12's postcard play once, between that page and the next.
func _between_pages_card(then: Callable) -> bool:
	var mail: Variant = page.get("cliffhanger")
	if mail is Dictionary and not seen_cards.has(page.id + "_mail"):
		_show_story_card({"id": page.id + "_mail", "kicker": "NEW MAIL  ·  %s" % mail.get("sent", ""), "title": "TO: " + str(mail.get("to", "")).to_upper(), "thought": "", "ding": true, "small": true, "voice": "page_05_cliffhanger", "button": "…WHO?!", "then": then,
			"body": "[b]From:[/b] %s\n[b]To:[/b] %s   [b]CC:[/b] %s\n[b]Sent:[/b] %s\n[b]Subject:[/b] [color=#a4383e]%s[/color]\n\nThe Narrator: \"%s\"" % [mail.get("mail_from", ""), mail.get("to", ""), mail.get("cc", ""), mail.get("sent", ""), mail.get("subject", ""), mail.get("line", "")]})
		return true
	var postcard: Variant = page.get("postcard_after")
	if postcard is Dictionary and not seen_cards.has(page.id + "_postcard"):
		_show_story_card({"id": page.id + "_postcard", "kicker": "MEANWHILE…", "title": "POSTCARD FROM GOA", "thought": "", "image": "res://assets/art/story/postcard_goa.png", "voice": "postcard_goa", "button": "TURN THE PAGE", "then": then,
			"body": str(postcard.get("text", ""))})
		return true
	return false


## Page 15: "the sender has been found", page 4 replayed with its three-star plan, the confession, credits.
func _start_reveal() -> void:
	var reveal: Dictionary = page.reveal
	var steps: Array = reveal.get("steps", [])
	_show_story_card({"id": "reveal_1", "kicker": "DEAR ALL", "title": "THE SENDER HAS BEEN FOUND", "thought": "", "voice": str(steps[0].get("voice", "")), "button": "TURN BACK TO PAGE 4", "body": "The Narrator: \"%s\"" % steps[0].get("say", ""),
		"then": func(): _iris_close(_replay_page_four)})


func _replay_page_four() -> void:
	_reveal_source = page.duplicate(true)
	_load_page(3, PAGE_SCRIPTS[3].definition())
	_revealing = true
	_stop_voice()
	var replay: Dictionary = plan.to_data()
	if not REVEAL_PLAN.is_empty():
		replay.thoughts = REVEAL_PLAN.thoughts.duplicate()
		replay.lanterns = REVEAL_PLAN.lanterns.duplicate(true)
	_title.text = "PAGE 4  ·  1:03 AM, JC  ·  THE REPLAY"
	_saved_plan = replay
	_begin(SIMULATOR.run(page, replay, true), false)
	_stage.set_caption("Page 4. 1:03 AM. JC. Watch Chintu's paw.", 0.0)


func _finish_reveal() -> void:
	_revealing = false
	var reveal: Dictionary = _reveal_source.get("reveal", {})
	var steps: Array = reveal.get("steps", [])
	var achievement: Dictionary = reveal.get("achievement", {})
	if not achievement.is_empty():
		achievements[str(achievement.id)] = true
		_save_progress()
	var last := func():
		_front.set_credits_extra(Array(reveal.get("credits_additions", [])).filter(func(line): return not "Oreo" in str(line)))
		_load_page(PAGE_SCRIPTS.size() - 1)
		_front.show_title(true)
		_front.show_credits()
	var confession := func():
		_show_story_card({"id": "reveal_3", "kicker": "THE NARRATOR", "title": "YOU. YOU DID THIS.", "thought": "", "small": true, "voice": str(steps[3].get("voice", "")), "button": "ROLL CREDITS", "then": last,
			"body": "\"%s\"\n\n[i]%s[/i]\n\n[color=#a4383e][b]ACHIEVEMENT: %s[/b][/color]" % [steps[3].get("say", ""), str(reveal.get("final_panel", "")).replace("👌", "thumbs-up"), achievement.get("name", "")]})
	_show_story_card({"id": "reveal_2", "kicker": "1:04 AM", "title": "PAW. SEND. WHOOSH.", "thought": "", "small": true, "voice": str(steps[2].get("voice", "")), "button": "…WAIT. WHO LIT HIM?", "then": confession,
		"body": "Drafts (1): 'write the angriest possible mail to a dean (testing AI for hackathon, DO NOT SEND)'\n\nThe Narrator: \"%s\"" % steps[2].get("say", "")})


# ------------------------------------------------------------ manhunt inbox
var _subject: RichTextLabel


## Acts 2-3: the mail subject of the day sits on the goal clipping, right-aligned.
func _update_subject() -> void:
	var hunt: Variant = page.get("manhunt")
	if not is_instance_valid(_subject):
		_subject = _rich(14)
		_subject.position = Vector2(400, 31)
		_subject.size = Vector2(488, 24)
		_subject.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_subject.autowrap_mode = TextServer.AUTOWRAP_OFF
		_subject.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_goal_card.add_child(_subject)
	_subject.visible = hunt is Dictionary and _tutorial_panel < 0
	if _subject.visible:
		_subject.text = "[color=#a4383e][b]INBOX[/b][/color]  %s   [color=#8c8a80]Unread: %s[/color]" % [hunt.get("subject", ""), hunt.get("unread", "?")]


# ------------------------------------------------------------ margin stickers
var _stickers: Array[Control] = []


## Margin notes left of the result card: stickers ("result" any ending,
## "result_win" twist wins only), then the manhunt case file (pages 6-15).
func _show_stickers(when: String, won := false) -> void:
	for old in _stickers:
		if is_instance_valid(old):
			old.queue_free()
	_stickers.clear()
	var notes: Array = []
	for entry in page.get("stickers", []):
		if entry is Dictionary and (str(entry.get("when", "result")) == when or (won and str(entry.get("when", "")) == when + "_win")):
			var raw := str(entry.get("text", ""))
			notes.append([raw.replace("✗", "").strip_edges() + ("  " + _icon("cross", 18) if "✗" in raw else ""), Color("ffe9a8"), 74.0])
	var hunt: Variant = page.get("manhunt")
	if when == "result" and hunt is Dictionary:
		notes.append(["[b]THE MANHUNT[/b]  ·  Unread: %s
[b]Suspect:[/b] %s
[b]Clue:[/b] %s" % [hunt.get("unread", "?"), hunt.get("suspect", ""), hunt.get("clue", "")], Color("e6f1ff"), 150.0])
	var y := 64.0
	for i in notes.size():
		var note: Array = notes[i]
		var card := _paper_panel(Rect2(0, 0, 230, 40), 0.0)
		var box: StyleBoxFlat = card.get_theme_stylebox("panel").duplicate()
		box.bg_color = note[1]
		box.shadow_offset = Vector2(3, 3)
		card.add_theme_stylebox_override("panel", box)
		var label := _rich(14 if float(note[2]) < 100 else 13)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.fit_content = true
		label.position = Vector2(10, 6)
		label.size = Vector2(210, 20)
		label.text = str(note[0])
		card.add_child(label)
		card.position = Vector2(-216, y)
		card.rotation = -0.09 if i % 2 == 0 else -0.04
		card.z_index = 2
		_result_card.add_child(card)
		_stickers.append(card)
		y += 60
		if not _motion.button_pressed:
			card.scale = Vector2.ONE * 1.6
			card.pivot_offset = card.size * 0.5
			card.create_tween().tween_property(card, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.6 + 0.2 * i)
	_restack_stickers.call_deferred()


## Once their text has laid out, each note is as tall as its text, stacked down the margin.
func _restack_stickers() -> void:
	var y := 64.0
	for card in _stickers:
		if not is_instance_valid(card):
			continue
		var label: RichTextLabel = card.get_child(0)
		card.size.y = label.get_content_height() + 14
		card.pivot_offset = card.size * 0.5
		card.position.y = y
		y += card.size.y + 10



## The first recorded narrator file that exists (new Hinglish takes win over old ones).
func _first_voice(keys: Array) -> String:
	for key in keys:
		if _voice_path("narrator/" + str(key)) != "":
			return str(key)
	return str(keys.back())
