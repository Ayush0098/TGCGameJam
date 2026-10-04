extends Control
## MVP flow: recorded simulation -> playback -> result -> exact-plan retry.

## The eight-page campaign in story order (design/levels.md).
const CAMPAIGN = [
	preload("res://data/campaign/page_01.gd"), preload("res://data/campaign/page_02.gd"),
	preload("res://data/campaign/page_03.gd"), preload("res://data/campaign/page_04.gd"),
	preload("res://data/campaign/page_05.gd"), preload("res://data/campaign/page_06.gd"),
	preload("res://data/campaign/page_07.gd"), preload("res://data/campaign/page_08.gd"),
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
const INK := Color("243043")
const PAPER := Color("f2e8cf")
const TEXT_FONT = preload("res://assets/fonts/ComicNeue-Bold.ttf")
const COMIC_FONT = preload("res://assets/fonts/Bangers-Regular.ttf")
const SAVE_PATH := "user://lightbulb_campaign_v1.json"
const BEAT_SECONDS := 0.4
const RECOVERY_SECONDS := 0.45
const PHASE_TIME := {"DECIDE": 0.04, "MOVE": 0.26, "SWITCHES": 0.27, "BONKS": 0.31, "CLAIMS": 0.35}


func _ready() -> void:
	if OS.has_feature("production_reference") or "--production-reference" in OS.get_cmdline_user_args():
		get_tree().change_scene_to_file.call_deferred("res://scenes/production_reference.tscn")
		return
	PAGE_SCRIPTS = page_override if not page_override.is_empty() else CAMPAIGN
	_build_ui()
	_load_progress()
	_load_page(0)
	_front = FRONT.new()
	_front.name = "FrontEnd"
	# Above the stage, which draws its overlay at z 100.
	_front.z_index = 200
	_ui.add_child(_front)
	_front.start_requested.connect(_on_front_start)
	_front.page_requested.connect(_on_front_page)
	_front.closed.connect(_update_buttons)
	_front.show_title(not completed.is_empty())


func _exit_tree() -> void:
	_stop_voice()
	for player in _players:
		player.stop()
		player.stream = null


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = PAPER
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
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
			toggle.add_theme_color_override(state, Color("243043"))
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
	_stage.actor_revealed.connect(func(_id: String, thought: String): _play_effect("REVEAL_" + thought))
	_stage.actor_poked.connect(func(_id: String, kind: String): _play_effect(kind))
	_stage.flick_cleared.connect(_clear_flick)
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
		player.volume_db = -15
		add_child(player)
		_players.append(player)
	_voice = AudioStreamPlayer.new()
	_voice.volume_db = -3
	_voice.finished.connect(_stop_voice)
	add_child(_voice)
	var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/reference/cues.json"))
	if manifest is Dictionary:
		for cue in manifest.get("cues", []):
			if cue is Dictionary and ResourceLoader.exists(cue.get("audio", "")):
				_cues[cue.id] = cue
	_update_voice_buttons()


func _layout_ui() -> void:
	var factor := minf(size.x / 1280.0, size.y / 720.0)
	_ui.scale = Vector2.ONE * factor
	_ui.position = (size - Vector2(1280, 720) * factor) * 0.5


func _rich(font_size: int) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = false
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("normal_font_size", font_size)
	label.add_theme_color_override("default_color", INK)
	return label


func _icon(name: String, size: int = 16) -> String:
	return "[img=%dx%d]res://assets/ui/%s.svg[/img] " % [size, size, name]


func _label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("243043"))
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


func _load_page(index: int) -> void:
	_cancel_presentation()
	_last_cue = ""
	page_index = index
	var validated: Dictionary = VALIDATOR.new().validate(PAGE_SCRIPTS[index].definition())
	if not validated.errors.is_empty():
		mode = "ERROR"
		_caption.text = "Content error: " + "; ".join(validated.errors)
		_update_buttons()
		return
	page = validated.page
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
	_goal.text = "TWIST: " + page.goal.twist_caption
	_original_run = SIMULATOR.run(page, plan.to_data(), true)
	_begin(_original_run, true)
	if page.id == "page_02" and _cues.has("narrator_intro"):
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
	attempts += 1
	_saved_plan = plan.to_data()
	_begin(SIMULATOR.run(page, _saved_plan, true), false)


func _begin(recorded: Dictionary, original: bool) -> void:
	_cancel_presentation()
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
	if not _active_cue.is_empty():
		_voice_elapsed += delta
		# A suspended/unavailable audio device cannot hold gameplay forever.
		if _voice_elapsed > float(_cues[_active_cue].duration_seconds) + 0.75:
			_stop_voice()
	if _story_waiting:
		return
	if mode == "ORIGINAL_END":
		_clock += delta
		if _clock >= 0.6 and _active_cue.is_empty():
			_return_to_plan()
		return
	if mode not in ["INTRO", "PLAY"]:
		return
	# The story prologue finishes before the Original acts; skip voice is explicit.
	if _is_original and _active_cue == "narrator_intro":
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
		_finish_run()
		return
	var positions: Dictionary = {}
	if not _motion.button_pressed:
		var next_beat := int(_clock / BEAT_SECONDS) + 1
		var local_time := fmod(_clock, BEAT_SECONDS)
		if local_time >= 0.04 and local_time < 0.26:
			var fraction := (local_time - 0.04) / 0.22
			for event in _run.events:
				if event.beat == next_beat and event.type == "MOVE":
					positions[event.actor] = lerpf(float(event.from), float(event.to), fraction)
	_stage.pose(_playback_world, _run.plan, knowledge, false, [], positions)


func _display(world: Dictionary, planning: bool, phase: String = "") -> void:
	var data: Dictionary = plan.to_data() if planning else _run.plan
	_remember(world, data, planning)
	var intentions: Array = RULES.decisions(world, RULES.lit_slots(page, data, world)) if planning else []
	_stage.pose(world, data, knowledge, planning, intentions)
	if not planning:
		var partial := {"snapshots": [world], "events": _run.events.filter(func(event):
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
	for event in events:
		if HITSTOP.has(event.type) and not _fast:
			_hitstop = maxf(_hitstop, float(HITSTOP[event.type]))
		if event.type == "DING":
			_ding(480.0 * pow(1.12, _ding_count))
			_ding_count += 1
		elif event.type in ["MOVE", "EAT", "SIT", "BONK", "CLASH", "WHIFF", "LAMP_ON"]:
			_play_effect(event.type)


func _finish_run() -> void:
	if mode == "ORIGINAL_END":
		_return_to_plan()
		return
	if mode not in ["INTRO", "PLAY"]:
		return
	_cancel_presentation()
	_cursor = _run.snapshots.size() - 1
	_display(_run.snapshots.back(), false)
	if _is_original:
		# Show the final Original snapshot before returning: it is player evidence.
		mode = "ORIGINAL_END"
		_clock = 0.0
		_caption.text = "ORIGINAL: " + GOALS.evaluate(page, _run).caption
		_update_buttons()
		return
	mode = "RESULT"
	var result: Dictionary = GOALS.evaluate(page, _run)
	_won_current = result.won
	_show_facts(result)
	if result.won:
		completed[page.id] = true
	else:
		failures += 1
	run_history.append({"page": page.id, "attempt": attempts, "won": result.won, "plan": _saved_plan.duplicate(true), "end_beat": _run.end_beat})
	_caption.text = ("TWIST! " if result.won else "THE END...? ") + result.caption
	_original_caption.text = GOALS.evaluate(page, _original_run).caption
	_twist_caption.text = result.caption
	_original_stage.pose(_original_run.snapshots.back(), _original_run.plan, {}, false)
	_result_stage.pose(_run.snapshots.back(), _run.plan, knowledge, false)
	_stage.hide()
	_comparison.show()
	_show_payoff(result, _record_progress(result))
	for view in [_stage, _result_stage]:
		view.set_mood("win" if result.won else "fail")
	if page.id == "page_02" and result.won:
		_play_voice("narrator_success")
	_update_buttons()


func _show_facts(result: Dictionary) -> void:
	var labels: Array[String] = []
	for item in result.facts:
		var fact: Dictionary = item.fact
		var mark := _icon("check") if item.met else (_icon("cross") if mode == "RESULT" else _icon("box"))
		labels.append(mark + GOALS.fact_text(fact))
	for bonus in page.get("bonus", []):
		var done: bool = bonus.id in bonus_done.get(page.id, [])
		labels.append(_icon("star_on" if done else "star_off") + "Bonus: " + str(bonus.caption).trim_suffix("."))
	_facts.text = "   /   ".join(labels)
	_facts.add_theme_color_override("default_color", Color("a4383e") if mode == "RESULT" and not result.won else Color("243043"))


func _return_to_plan() -> void:
	_cancel_presentation()
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
	_caption.text = "HUNGRY > food   /   SLEEPY > seat   /   ANGRY > bonk   /   SCARED > flee"
	_stage.set_mood("idle")
	_pop.text = ""
	_refresh_plan()
	_update_buttons()


func _refresh_plan() -> void:
	_display(RULES.initial_world(page, plan.to_data()), true)
	_show_facts({"facts": page.goal.facts.map(func(fact): return {"fact": fact, "met": false})})
	_facts.add_theme_color_override("default_color", Color("243043"))
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


func _lit_ids() -> Array[String]:
	var ids: Array[String] = []
	var world: Dictionary = RULES.initial_world(page, plan.to_data())
	for actor in world.characters:
		if actor.active:
			ids.append(actor.id)
	return ids


func _swap(first: String, second: String) -> void:
	if mode == "PLAN" and plan.swap(first, second, _lit_ids()):
		_stage.clear_preview()
		_refresh_plan()
		_stage.react_swap(first, second)
		_play_effect("SWAP")


func _preview(first: String, second: String) -> void:
	if mode != "PLAN":
		return
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
	if page_index < PAGE_SCRIPTS.size() - 1:
		_load_page(page_index + 1)
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
	_next.text = "ALL PAGES" if page_index == PAGE_SCRIPTS.size() - 1 else "NEXT PAGE"
	_skip_page.disabled = failures < 3 or mode not in ["PLAN", "RESULT"]
	var hints: Array = page.get("hints", [])
	_hint_button.visible = not hints.is_empty() and failures >= 2 and _hints_shown < hints.size()
	_hint_button.disabled = mode not in ["PLAN", "RESULT"]
	_hint_button.text = "HINT %d/%d" % [_hints_shown + 1, hints.size()]
	_status.text = "Page %d of %d   ·   Runs %d   ·   Pages solved %d / %d" % [page_index + 1, PAGE_SCRIPTS.size(), attempts, completed.size(), PAGE_SCRIPTS.size()]
	if completed.size() == PAGE_SCRIPTS.size():
		_status.text = "Every page solved. Try for different endings!"
	_update_instructions()
	_update_progress_label()
	_emphasise(_action, mode == "PLAN")
	_emphasise(_next, mode == "RESULT" and _won_current)
	_emphasise(_rewind, mode == "RESULT" and not _won_current)


func _input(event: InputEvent) -> void:
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
			_start_action()
		elif mode in ["INTRO", "PLAY", "ORIGINAL_END"]:
			_finish_run()
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


func _cancel_presentation() -> void:
	_hook_drag = -1
	_hide_payoff()
	_stop_voice()
	for player in _players:
		player.stop()
	for view in [_stage, _original_stage, _result_stage]:
		if is_instance_valid(view):
			view.cancel_presentation()


func _sound_changed(enabled: bool) -> void:
	if not enabled:
		_stop_voice()
		for player in _players:
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
	if is_instance_valid(_voice):
		_voice.stop()
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
	if kind.begins_with("REVEAL_") or kind.begins_with("POKE_") or kind in ["HMPH", "SWAP"]:
		duration = 0.32
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
				value = sin(TAU * (300.0 * t + 900.0 * t * t)) * sin(PI * t / duration) * 0.3
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
				text = "Click the room to drop your spare bulb: it lights 3 slots from the next beat (FLICK!)"
		"RESULT":
			text = "TWIST! Press NEXT PAGE, or hunt for another ending." if _won_current else "Not quite. REWIND keeps your plan; RESTART resets the page."
		"PLAN":
			var lit := _lit_ids()
			if page.has("coach") and not completed.has(page.id):
				text = str(page.coach)
			elif not _lanterns_useful:
				text = "Everyone is lit. Drag one thought bubble onto the other character to swap, then ACTION! (Space)."
			elif lit.is_empty():
				text = "Nobody is lit. Drag a lantern from its hook into the room to reveal what someone is thinking."
			elif lit.size() == 1:
				text = "Light a second character to swap thoughts, or press ACTION! (Space).   Keys: 1/2 lantern, arrows move, P park"
			else:
				text = "Drag a lit thought onto another lit character to swap. ACTION! = Space.   Keys: 1/2 lantern, arrows move, P park"
	_instructions.text = text
	if is_instance_valid(_action):
		_action.text = "ACTION! (nobody lit)" if mode == "PLAN" and _lit_ids().is_empty() else "ACTION!"


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
			"stars": _stars(definition),
			"max_stars": 1 + definition.get("bonus", []).size(),
			"endings": endings_found.get(definition.id, []).size(),
			"max_endings": maxi(int(definition.get("endings_total", 0)), endings_found.get(definition.id, []).size()),
		})
	return pages


func _open_edition() -> void:
	if mode in ["INTRO", "PLAY"]:
		_finish_run()
	var note := "Every page solved! Each page hides other endings too." if completed.size() == PAGE_SCRIPTS.size() else "Pick a page. Solved pages stay inked."
	_front.set_pages(_progress(), note)
	_front.show_edition()


func _on_front_start() -> void:
	if _story_waiting:
		_replay_voice()
	_front.hide()
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
	_stamp.add_theme_color_override("font_outline_color", Color("243043"))
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
		lines.append("   ".join(rewards) if not rewards.is_empty() else "REWIND keeps your plan so you can adjust it.")
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


func _hide_payoff() -> void:
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
		box.border_color = Color("243043")
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
	# Every player run can find a new ending; any run can also earn bonus stars.
	var rewards: Array[String] = []
	var found: Array = endings_found.get(page.id, [])
	if str(result.caption) not in found:
		found.append(str(result.caption))
		endings_found[page.id] = found
		rewards.append("NEW ENDING! (%d / %d)" % [found.size(), maxi(int(page.get("endings_total", 0)), found.size())])
	var done: Array = bonus_done.get(page.id, [])
	for bonus in page.get("bonus", []):
		if bonus.id in done:
			continue
		var challenge := page.duplicate()
		challenge.goal = {"facts": bonus.facts, "twist_caption": bonus.caption}
		if GOALS.evaluate(challenge, _run).won:
			done.append(bonus.id)
			rewards.append("BONUS STAR! " + str(bonus.caption))
	bonus_done[page.id] = done
	_save_progress()
	return rewards


func _update_progress_label() -> void:
	if not is_instance_valid(_progress_label) or page.is_empty():
		return
	var total: int = 1 + page.get("bonus", []).size()
	var stars := _stars(page)
	var found: int = endings_found.get(page.id, []).size()
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
	file.store_string(JSON.stringify({"version": 1, "completed": completed.keys(), "skipped": skipped.keys(), "bonus": bonus_done, "endings": endings_found}))


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
			box.bg_color = Color(0, 0, 0, 0)
			box.shadow_color = Color(0, 0, 0, 0)
			box.border_color = Color("c8102e")
		theme.set_stylebox(state, "Button", box)
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
	var hints: Array = page.get("hints", [])
	if _hints_shown >= hints.size() or mode not in ["PLAN", "RESULT"]:
		return
	var text := str(hints[_hints_shown]).trim_prefix("ghost: ")
	if str(hints[_hints_shown]).begins_with("ghost: "):
		text = "Try this: " + text
	_hints_shown += 1
	_subtitle.text = "Bulby whispers: " + text
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
