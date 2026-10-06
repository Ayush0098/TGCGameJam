extends SceneTree
## Keyboard-only QA driver. Pushes real key events through the engine's input
## path (Input.parse_input_event), so focus handling, ui_accept on buttons and
## the game's own _input hotkeys behave as for a player without a mouse.
## Run windowed (story cards are skipped headless) and point APPDATA at a
## scratch folder so the real save is untouched:
##   APPDATA=<scratch> Godot --path src --audio-driver Dummy --script res://tools/keyboard_qa.gd -- menus

const MAIN_SCENE = preload("res://scenes/main.tscn")

var main
var problems := 0


func _initialize() -> void:
	_run.call_deferred()


func say(text: String) -> void:
	print(text)


func bad(text: String) -> void:
	problems += 1
	print("BUG: " + text)


func expect(condition: bool, text: String) -> void:
	if condition:
		print("ok: " + text)
	else:
		bad(text)


func frames(count := 3) -> void:
	for i in count:
		await process_frame


func key(code: int, shift := false) -> void:
	var down := InputEventKey.new()
	down.keycode = code
	down.physical_keycode = code
	down.pressed = true
	down.shift_pressed = shift
	Input.parse_input_event(down)
	Input.flush_buffered_events()
	await frames(2)
	var up := InputEventKey.new()
	up.keycode = code
	up.physical_keycode = code
	up.pressed = false
	up.shift_pressed = shift
	Input.parse_input_event(up)
	Input.flush_buffered_events()
	await frames(1)


func award_up() -> bool:
	return is_instance_valid(main._star_award) and main._star_award.visible


func focus_name() -> String:
	var owner := root.gui_get_focus_owner()
	if owner == null:
		return "<none>"
	var text: String = owner.text if "text" in owner else ""
	return "%s '%s'" % [owner.name, text.strip_edges()]


func overlays() -> String:
	var shown: Array[String] = []
	var map := {"front": main._front, "pause": main._pause_sheet, "settings": main._settings_sheet, "intro": main._intro_card, "story": main._story_card, "book": main._endings_book, "stars": main._star_award, "result": main._result_card}
	for name in map:
		var node = map[name]
		if is_instance_valid(node) and node.visible:
			shown.append(name)
	return ",".join(shown)


func state() -> String:
	return "mode=%s page=%d overlays=[%s] focus=%s" % [main.mode, main.page_index + 1, overlays(), focus_name()]


## Run the game's own clock while overlays or playback need it.
func tick(seconds: float) -> void:
	var steps := int(seconds * 30.0)
	for i in steps:
		main._process(1.0 / 30.0)
		if i % 6 == 0:
			await process_frame


func boot() -> void:
	main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await frames(4)
	main.set_process(false)


func _run() -> void:
	var scenario := "menus"
	if not OS.get_cmdline_user_args().is_empty():
		scenario = OS.get_cmdline_user_args()[0]
	await boot()
	await call(scenario)
	print("QA DONE: %d problem(s)" % problems)
	quit()


# ---------------------------------------------------------------- title menus
## Walk Down (or Right) until the focused control's name or text starts with `wanted`.
func goto(wanted: String, code := KEY_DOWN, limit := 12) -> bool:
	for i in limit:
		if focus_name().to_lower().contains(wanted.to_lower()):
			return true
		await key(code)
	return focus_name().to_lower().contains(wanted.to_lower())


func menus() -> void:
	say("title: " + state())
	expect(main._front.visible and focus_name().begins_with("Start"), "title opens with PLAY focused")
	expect(await goto("CREDITS"), "Down reaches CREDITS: " + focus_name())
	await key(KEY_ENTER)
	await frames(3)
	expect(main._front._credits_panel.visible and focus_name().contains("BACK"), "Enter opens Credits with BACK focused: " + state())
	await key(KEY_TAB)
	await key(KEY_DOWN)
	expect(focus_name().contains("BACK"), "Tab/Down inside Credits stay on BACK: " + focus_name())
	await key(KEY_ESCAPE)
	await frames(3)
	expect(not main._front._credits_panel.visible and focus_name().contains("CREDITS"), "Esc closes Credits, focus back on CREDITS: " + focus_name())
	expect(await goto("SETTINGS", KEY_UP), "Up reaches SETTINGS: " + focus_name())
	await key(KEY_ENTER)
	await frames(3)
	expect(is_instance_valid(main._settings_sheet) and main._settings_sheet.visible, "Enter opens Settings: " + state())
	var sliders: Array = main._settings_sheet.find_children("*", "Range", true, false)
	var master: float = sliders[0].value
	await key(KEY_LEFT)
	expect(sliders[0].value < master, "Left lowers the first volume slider: %s" % sliders[0].value)
	await key(KEY_RIGHT)
	var cycle: Array[String] = []
	for i in 12:
		await key(KEY_DOWN)
		cycle.append(focus_name())
	say("Settings Down x12: " + str(cycle))
	cycle.clear()
	for i in 12:
		await key(KEY_TAB)
		cycle.append(focus_name())
	say("Settings Tab x12: " + str(cycle))
	await key(KEY_ESCAPE)
	await frames(3)
	expect(not main._settings_sheet.visible and focus_name().contains("SETTINGS"), "Esc closes Settings, focus back on SETTINGS: " + focus_name())
	expect(await goto("LEVELS", KEY_UP), "Up reaches LEVELS: " + focus_name())
	await key(KEY_ENTER)
	await frames(4)
	say("levels: " + state())
	var trail: Array[String] = []
	for k in [KEY_RIGHT, KEY_DOWN, KEY_LEFT, KEY_UP, KEY_DOWN, KEY_DOWN, KEY_DOWN, KEY_DOWN]:
		await key(k)
		trail.append(focus_name())
	say("grid walk: " + str(trail))
	await key(KEY_ESCAPE)
	await frames(3)
	expect(main._front.visible and focus_name() != "<none>", "Esc from Levels returns to the title with a focus: " + state())


## A first visit to page N (default 8): what does Enter-mashing do while its cards show?
func cards() -> void:
	var page_number := 8
	for arg in OS.get_cmdline_user_args():
		if arg.is_valid_int():
			page_number = int(arg)
	main._front.hide()
	main.tutorial_done = true
	main._load_page(page_number - 1)
	await tick(1.0)
	trace("loaded")
	for i in 14:
		await key(KEY_ENTER)
		await tick(0.7)
		trace("Enter %d" % (i + 1))


func gate_text() -> String:
	if main._tutorial_panel < 0:
		return "-"
	return "panel %d step %d gate '%s'" % [main._tutorial_panel, main._tutorial_step, main._tutorial_gate()]


func trace(label: String) -> void:
	say("%s: %s | tut %s | story=%d" % [label, state(), gate_text(), main._story_queue.size()])


## Exploratory: what does a fresh player see after PLAY, pressing Enter/Space?
func flow() -> void:
	trace("title")
	await key(KEY_ENTER)
	await tick(0.5)
	trace("after PLAY")
	for i in 14:
		await key(KEY_ENTER)
		await tick(0.6)
		trace("Enter %d" % (i + 1))
	for i in 6:
		await key(KEY_SPACE)
		await tick(0.6)
		trace("Space %d" % (i + 1))


## Advance the game's clock (and real time, for voice and timers) until `cond` holds.
func wait_until(cond: Callable, limit := 20.0) -> bool:
	var spent := 0.0
	while spent < limit:
		if cond.call():
			return true
		await tick(0.1)
		await create_timer(0.05).timeout
		spent += 0.1
	return cond.call()


func skip_tutorial() -> void:
	await key(KEY_ENTER)
	await tick(0.5)
	# Welcome card: its own SKIP TUTORIAL button, by keyboard.
	expect(await goto("SKIP TUTORIAL", KEY_TAB, 6), "welcome card: Tab reaches SKIP TUTORIAL: " + state())
	await key(KEY_ENTER)
	await tick(0.6)
	trace("after skip")


func start() -> void:
	await skip_tutorial()
	await wait_until(func(): return main._story_queue.is_empty() and main.mode == "PLAN" or (is_instance_valid(main._story_card) and main._story_card.visible), 30.0)
	trace("settled")
	for i in 12:
		await key(KEY_ENTER)
		await tick(0.6)
		trace("Enter %d" % (i + 1))


# ------------------------------------------------------------ scripted play
const STAGE = preload("res://presentation/stage_view.gd")
var plans: Dictionary = {}


func load_plans() -> void:
	var path := ""
	for arg in OS.get_cmdline_user_args():
		if arg.ends_with(".json"):
			path = arg
	plans = JSON.parse_string(FileAccess.get_file_as_string(path))


## Dismiss whatever card is up with Enter until the page is playable.
func clear_cards(limit := 12) -> void:
	for i in limit:
		await wait_until(func(): return main.mode == "PLAN" or (is_instance_valid(main._story_card) and main._story_card.visible) or (is_instance_valid(main._intro_card) and main._intro_card.visible) or main._front.visible, 25.0)
		if main.mode == "PLAN" and not (is_instance_valid(main._story_card) and main._story_card.visible):
			return
		if main.mode == "INTRO" or main.mode == "ORIGINAL_END":
			if not overlays().contains("story"):
				await key(KEY_SPACE)
				await tick(0.8)
				continue
		await key(KEY_ENTER)
		await tick(0.3)


func move_bulb(index: int, target: Vector2) -> void:
	await key(KEY_1 if index == 0 else KEY_2)
	for guard in 90:
		var lantern: Dictionary = main.plan.lanterns[index]
		var dx: float = target.x - lantern.x
		var dy: float = target.y - lantern.y
		if lantern.enabled and absf(dx) < 0.02 and absf(dy) < 0.02:
			return
		if absf(dx) >= 0.02:
			var direction := 1 if dx > 0.0 else -1
			var coarse: float = STAGE._grid_step(lantern.x, direction, STAGE.KEY_STEP_X, false) - lantern.x
			await key(KEY_RIGHT if direction > 0 else KEY_LEFT, absf(coarse) > absf(dx) + 0.001)
		else:
			var direction := 1 if dy > 0.0 else -1
			var coarse: float = STAGE._grid_step(lantern.y, direction, STAGE.KEY_STEP_Y, false) - lantern.y
			await key(KEY_DOWN if direction > 0 else KEY_UP, absf(coarse) > absf(dy) + 0.001)
	bad("bulb %d never reached %s, ended at %s" % [index, str(target), str(main.plan.lanterns[index])])


func cursor_to(id: String) -> bool:
	if id not in main._lit_ids():
		return false
	for i in 10:
		if main._stage.key_cursor == id:
			return true
		await key(KEY_TAB)
	return main._stage.key_cursor == id


func swap_pair(first: String, other: String) -> void:
	if not await cursor_to(first):
		bad("Tab never reached %s (lit: %s)" % [first, str(main._lit_ids())])
		return
	await key(KEY_ENTER)
	if main._stage.key_picked != first:
		bad("Enter did not pick %s's thought (picked '%s', lit: %s)" % [first, main._stage.key_picked, str(main._lit_ids())])
		return
	if not await cursor_to(other):
		bad("Tab never reached %s to swap (lit: %s)" % [other, str(main._lit_ids())])
		await key(KEY_ESCAPE)
		return
	var before: Dictionary = main.plan.thoughts.duplicate()
	await key(KEY_ENTER)
	await tick(0.5)
	if main.plan.thoughts[first] != before[other] or main.plan.thoughts[other] != before[first]:
		bad("Enter on %s did not swap with %s" % [other, first])


## Put the bulbs where `lanterns` says, parking any that should be away.
func set_lanterns(lanterns: Array) -> void:
	for index in mini(lanterns.size(), 2):
		var want: Dictionary = lanterns[index]
		if want.enabled:
			await move_bulb(index, Vector2(snappedf(want.x, 0.01), snappedf(want.y, 0.01)))
		elif main.plan.lanterns[index].enabled:
			await key(KEY_1 if index == 0 else KEY_2)
			await key(KEY_P)
			expect(not main.plan.lanterns[index].enabled, "P parks bulb %d" % (index + 1))


func play_plan(page_id: String) -> Dictionary:
	var plan: Dictionary = plans[page_id]
	for step in plan.get("route", []):
		await set_lanterns(step.lanterns)
		await swap_pair(step.swap[0], step.swap[1])
	await set_lanterns(plan.lanterns)
	expect(main.plan.thoughts == plan.thoughts, "%s: thoughts match the plan %s (got %s)" % [page_id, str(plan.thoughts), str(main.plan.thoughts)])
	return plan


func press_action(plan: Dictionary) -> void:
	await key(KEY_SPACE)
	expect(main.mode == "PLAY", "%s: Space starts ACTION (mode %s)" % [main.page.id, main.mode])
	var flick: Dictionary = plan.get("flick", {})
	if not flick.is_empty():
		var width := int(main.page.width)
		var start := width / 2
		var goal := int(flick.centre)
		for i in absi(goal - start):
			await key(KEY_RIGHT if goal > start else KEY_LEFT)
		await wait_until(func(): return main._flick_beat() >= int(flick.beat), 10.0)
		await key(KEY_F)
		expect(main.plan.flick.get("centre", -1) == goal, "%s: F drops the spare bulb on slot %d (got %s)" % [main.page.id, goal, str(main.plan.flick)])
	await key(KEY_SPACE)


func campaign() -> void:
	load_plans()
	await skip_tutorial()
	var wanted := []
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("page_"):
			wanted.append(arg)
	for index in 15:
		await clear_cards()
		var page_id: String = main.page.id
		say("---- page %d %s | %s" % [main.page_index + 1, page_id, state()])
		if main.mode != "PLAN":
			bad("%s never became playable: %s" % [page_id, state()])
			return
		# Fail first: ACTION on the default plan, Enter retries.
		await key(KEY_SPACE)
		await key(KEY_SPACE)
		await tick(0.3)
		expect(main.mode == "RESULT", "%s: default plan ends in RESULT (%s)" % [page_id, state()])
		if main.mode == "RESULT" and not main._won_current:
			await wait_until(func(): return not award_up(), 6.0)
			await key(KEY_ENTER)
			await tick(0.3)
			expect(main.mode == "PLAN", "%s: Enter on RETRY returns to PLAN (%s)" % [page_id, state()])
		var plan: Dictionary = await play_plan(page_id)
		await press_action(plan)
		await tick(0.4)
		expect(main.mode == "RESULT" and main._won_current, "%s: the keyboard-built plan wins (%s)" % [page_id, state()])
		var level: int = main._run_star_level()
		expect(level == int(plan.stars), "%s: run earns %d stars (got %d)" % [page_id, int(plan.stars), level])
		expect(main._stars(main.page) == int(plan.total), "%s: progress shows %d stars (got %d)" % [page_id, int(plan.total), main._stars(main.page)])
		say("result: " + state() + " star_award=%s" % str(is_instance_valid(main._star_award) and main._star_award.visible))
		# First Enter finishes the star award, the next one goes on.
		var before_page: int = main.page_index
		for press in 3:
			await key(KEY_ENTER)
			await tick(0.4)
			say("  Enter -> " + state())
			if main.page_index != before_page or main._front.visible or main.mode == "REVEAL" or overlays().contains("story"):
				break
		if index == 14:
			break
		await wait_until(func(): return main.page_index != before_page or overlays().contains("story"), 8.0)
		expect(main.page_index == before_page + 1 or overlays().contains("story"), "%s: Enter leads on to the next page (%s)" % [page_id, state()])
		if main.page_index == before_page and not overlays().contains("story"):
			return
		if wanted.size() > 0 and page_id in wanted:
			return


func shot(name: String) -> void:
	await frames(3)
	await RenderingServer.frame_post_draw
	var image := root.get_viewport().get_texture().get_image()
	var path := OS.get_environment("QA_SHOTS")
	if path.is_empty():
		path = OS.get_user_data_dir()
	image.save_png("%s/%s.png" % [path, name])
	say("shot " + path + "/" + name + ".png")


## Thought colours: hover/cursor, picked and swap-target halos on a page with several lit characters.
func halo() -> void:
	load_plans()
	await skip_tutorial()
	await clear_cards()
	for index in [1]:
		main._load_page(index)
		await clear_cards()
	var plan: Dictionary = plans[main.page.id]
	await move_bulb(0, Vector2(plan.lanterns[0].x, plan.lanterns[0].y))
	say("lit: " + str(main._lit_ids()))
	await key(KEY_TAB)
	main._process(0.1)
	await tick(0.5)
	await shot("halo_cursor")
	await key(KEY_ENTER)
	await tick(0.5)
	await shot("halo_picked")
	await key(KEY_TAB)
	await tick(0.5)
	await shot("halo_target")


## Page 15 to the credits and back to the title, keyboard only.
func finale() -> void:
	load_plans()
	await skip_tutorial()
	await clear_cards()
	main._load_page(14)
	await clear_cards()
	var plan: Dictionary = await play_plan("page_15")
	await press_action(plan)
	await tick(0.4)
	expect(main.mode == "RESULT" and main._won_current, "page 15 keyboard plan wins: " + state())
	expect(main._run_star_level() == int(plan.stars), "page 15 earns %d stars (got %d)" % [int(plan.stars), main._run_star_level()])
	await key(KEY_ENTER)
	await tick(0.4)
	await key(KEY_ENTER)
	await tick(0.6)
	say("after Enter x2: " + state())
	await wait_until(func(): return overlays().contains("story"), 10.0)
	expect(overlays().contains("story"), "Next on page 15 opens the reveal card: " + state())
	for i in 6:
		if main._front.visible and main._front._credits_panel.visible:
			break
		if main.mode == "PLAY":
			await key(KEY_SPACE)
			await tick(0.5)
		if overlays().contains("story"):
			await key(KEY_ENTER)
			await tick(0.5)
		await wait_until(func(): return overlays().contains("story") or (main._front.visible and main._front._credits_panel.visible) or main.mode == "PLAY", 8.0)
		say("reveal step %d: %s" % [i, state()])
	expect(main._front.visible and main._front._credits_panel.visible, "reveal ends in the credits: " + state())
	expect(focus_name().contains("BACK"), "credits focus on BACK: " + focus_name())
	await key(KEY_ENTER)
	await frames(3)
	expect(not main._front._credits_panel.visible and focus_name().contains("CREDITS"), "BACK closes the credits, focus on CREDITS: " + state())
	await goto("CONTINUE", KEY_UP, 6)
	expect(focus_name().contains("CONTINUE") or focus_name().contains("PLAY"), "Up reaches CONTINUE/PLAY: " + focus_name())
	await key(KEY_ENTER)
	await tick(0.6)
	say("continue: " + state())
	expect(not main._front.visible, "CONTINUE leaves the title")


## Pause, settings, endings book, hint, restart, original, levels and main menu from the keyboard.
func hud() -> void:
	load_plans()
	await skip_tutorial()
	await clear_cards()
	expect(main.mode == "PLAN", "page 1 playable: " + state())
	# Pause
	await key(KEY_ESCAPE)
	await tick(0.3)
	expect(main._pause_sheet.visible and focus_name().contains("RESUME"), "Esc opens pause on RESUME: " + state())
	var names: Array[String] = []
	for i in 9:
		await key(KEY_DOWN)
		names.append(focus_name().get_slice("'", 1).strip_edges())
	say("pause walk: " + str(names))
	expect(names.has("MAIN MENU") and names.has("LEVELS") and names.has("SETTINGS"), "Down reaches every pause entry")
	await key(KEY_ESCAPE)
	await tick(0.3)
	expect(not main._pause_sheet.visible, "Esc closes pause")
	# Settings from pause and back
	await key(KEY_ESCAPE)
	expect(await goto("SETTINGS"), "pause: SETTINGS reachable: " + focus_name())
	await key(KEY_ENTER)
	await tick(0.3)
	expect(main._settings_sheet.visible and not main._pause_sheet.visible, "Enter opens Settings from pause: " + state())
	await key(KEY_ESCAPE)
	await tick(0.3)
	expect(not main._settings_sheet.visible and main._pause_sheet.visible and focus_name() != "<none>", "Esc returns from Settings to pause with focus: " + state())
	# Resume by Enter on RESUME (focus is the first entry)
	await key(KEY_ESCAPE)
	await tick(0.2)
	# Hint, restart, original, endings book hotkeys
	await key(KEY_H)
	say("hint: " + main._subtitle.text)
	expect(main._hints_shown == 1, "H shows a hint")
	await set_lanterns([{"enabled": true, "x": 4.5, "y": -0.5}, {"enabled": false, "x": 0.0, "y": -0.6}])
	await key(KEY_R)
	await tick(0.3)
	expect(main.plan.to_data().lanterns == main.page.lanterns.defaults, "R restarts the page")
	await key(KEY_O)
	await tick(0.3)
	expect(main.mode == "INTRO" or main.mode == "ORIGINAL_END", "O replays the Original: " + state())
	await key(KEY_SPACE)
	await wait_until(func(): return main.mode == "PLAN", 15.0)
	expect(main.mode == "PLAN", "Space skips the Original back to PLAN: " + state())
	await key(KEY_B)
	await tick(0.3)
	expect(overlays().contains("book") and focus_name().contains("CLOSE"), "B opens the Endings book on CLOSE: " + state())
	await key(KEY_ENTER)
	await tick(0.3)
	expect(not overlays().contains("book"), "Enter closes the Endings book: " + state())
	await key(KEY_B)
	await tick(0.3)
	await key(KEY_ESCAPE)
	await tick(0.3)
	expect(not overlays().contains("book") and not overlays().contains("pause"), "Esc closes the Endings book without opening pause: " + state())
	# Pause -> Levels -> a page card
	await key(KEY_ESCAPE)
	expect(await goto("LEVELS"), "pause: LEVELS reachable")
	await key(KEY_ENTER)
	await tick(0.4)
	expect(main._front.visible and focus_name().begins_with("Page"), "LEVELS opens the page grid on a page card: " + state())
	await key(KEY_ENTER)
	await tick(0.6)
	expect(not main._front.visible, "Enter on a card enters the page: " + state())
	await clear_cards()
	# Pause -> Main menu -> CONTINUE
	await key(KEY_ESCAPE)
	expect(await goto("MAIN MENU"), "pause: MAIN MENU reachable")
	await key(KEY_ENTER)
	await tick(0.4)
	expect(main._front.visible and focus_name().contains("PLAY") or focus_name().contains("CONTINUE"), "MAIN MENU shows the title with a focused button: " + state())
	await key(KEY_ENTER)
	await tick(0.5)
	expect(not main._front.visible, "PLAY/CONTINUE returns to the game: " + state())
	await clear_cards()
	# Win page 1 and use the result card's buttons by keyboard
	var plan: Dictionary = await play_plan("page_01")
	await press_action(plan)
	await tick(0.4)
	expect(main.mode == "RESULT" and main._won_current, "page 1 won: " + state())
	await key(KEY_ENTER)   # finishes the star award
	await tick(0.3)
	var seen: Array[String] = []
	for i in 8:
		await key(KEY_TAB)
		seen.append(focus_name().get_slice("'", 1).strip_edges())
	say("result Tab walk: " + str(seen))
	expect(seen.has("REPLAY") and seen.has("COMPARE") and seen.has("LEVELS"), "Tab reaches REPLAY, COMPARE and LEVELS on the result card")
	expect(await goto("COMPARE", KEY_TAB, 9), "focus COMPARE")
	await key(KEY_ENTER)
	await tick(0.3)
	expect(main.mode == "RESULT" and not main._result_card.visible, "Enter on COMPARE hides the card: " + state())
	await key(KEY_TAB)
	say("after compare Tab: " + state())
	expect(await goto("RESULT", KEY_TAB, 9), "tab bar RESULT button reachable: " + focus_name())
	await key(KEY_ENTER)
	await tick(0.3)
	expect(main._result_card.visible, "RESULT tab brings the card back: " + state())
	expect(await goto("REPLAY", KEY_TAB, 12), "focus REPLAY: " + focus_name())
	await key(KEY_ENTER)
	await tick(0.4)
	expect(main.mode == "PLAN", "Enter on REPLAY returns to PLAN: " + state())
	await press_action(plan)
	await tick(0.4)
	await key(KEY_ENTER)
	await tick(0.3)
	expect(await goto("LEVELS", KEY_TAB, 12), "focus LEVELS on result: " + focus_name())
	await key(KEY_SPACE)
	await tick(0.4)
	expect(main._front.visible, "Space on LEVELS opens the page grid: " + state())
	await key(KEY_ESCAPE)
	await tick(0.3)
	say("after levels Esc: " + state())
	expect(not main._front.visible and main.mode == "RESULT", "Esc from the grid returns to the result: " + state())
	await key(KEY_ENTER)
	await tick(0.5)
	say("Enter on result: " + state())
	await key(KEY_M)
	expect(not main._sound.button_pressed, "M mutes")
	await key(KEY_M)


## A long Endings book scrolls with the arrow and Page keys; Enter / Space work after a menu lost focus.
func book() -> void:
	load_plans()
	await skip_tutorial()
	await clear_cards()
	main._load_page(1)
	await clear_cards()
	var captions: Array = []
	for i in 21:
		captions.append("Dummy ending number %d with a few more words so it takes real space" % (i + 1))
	main.endings_found["page_02"] = captions
	await key(KEY_B)
	await tick(0.3)
	var list: RichTextLabel = main._endings_book.find_children("*", "RichTextLabel", true, false)[0]
	var bar := list.get_v_scroll_bar()
	say("list height %s content %s max %s" % [list.size.y, list.get_content_height(), bar.max_value])
	expect(bar.max_value > bar.page, "the long list needs scrolling")
	await key(KEY_DOWN)
	await key(KEY_DOWN)
	expect(bar.value > 0.0, "Down scrolls the Endings list (value %s)" % bar.value)
	var before := bar.value
	await key(KEY_PAGEDOWN)
	expect(bar.value >= bar.max_value - bar.page - 1.0, "Page Down scrolls to the end (value %s)" % bar.value)
	await key(KEY_UP)
	await key(KEY_PAGEUP)
	expect(bar.value < 1.0, "Up and Page Up scroll back (value %s)" % bar.value)
	expect(focus_name().contains("CLOSE"), "CLOSE keeps focus while scrolling: " + focus_name())
	await key(KEY_ESCAPE)
	await tick(0.3)
	# Focus recovery: open pause, drop focus, Enter should re-focus rather than do nothing.
	await key(KEY_ESCAPE)
	await tick(0.3)
	root.gui_release_focus()
	await frames(2)
	await key(KEY_ENTER)
	expect(focus_name().contains("RESUME") and main._pause_sheet.visible, "Enter after losing focus puts it back on RESUME: " + state())
	await key(KEY_ENTER)
	await tick(0.3)
	expect(not main._pause_sheet.visible, "Enter on RESUME closes pause")
