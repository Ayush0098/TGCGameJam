extends RefCounted
## The tutorial teaches one mechanic at a time: controls the current step has not
## introduced are switched off, Space passes a step, and the steps advance in order.

const MAIN = preload("res://scenes/main.tscn")


func _key(game, code: int, shift := false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	event.shift_pressed = shift
	game._input(event)


## Once the stage has keyboard focus an allowed P/1/2 reaches it as GUI input, as in the game.
func _key_to_stage(game, code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	if game._tutorial_allows("bulbs"):
		game._stage._gui_input(event)


func run(check: Callable) -> bool:
	var game = MAIN.instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(game)
	game._front.hide()
	game.tutorial_done = false
	game._load_page(0)
	if is_instance_valid(game._intro_card):
		game._intro_card.hide()
	game._finish_run()
	game._process(0.7)
	game._finish_run()
	check.call(game._tutorial_panel == 0 and game.mode == "PLAN", "The first tutorial panel starts in PLAN")
	check.call(game._tutorial_gate() == "lit", "Step one teaches the light (what it is for, then sliding it)")
	var y: float = game.plan.lanterns[0].y
	_key(game, KEY_S)
	check.call(is_equal_approx(game.plan.lanterns[0].y, y), "Raise/lower is switched off until it is taught")
	_key(game, KEY_TAB)
	check.call(game._stage.key_cursor == "", "Choosing a character is switched off while teaching the light")
	var before: String = game.mode
	game._tutorial_shown_msec = 0
	_key(game, KEY_SPACE)
	check.call(game.mode == before and game._tutorial_gate() != "lit", "Space passes the first step instead of starting ACTION")
	game._tutorial_step = 0
	game._show_tutorial_step()
	var x: float = game.plan.lanterns[0].x
	_key(game, KEY_D)
	check.call(not is_equal_approx(game.plan.lanterns[0].x, x), "Sliding the light works on its own step")
	check.call(game._action.disabled, "The ACTION button stays off until the tutorial reaches it")
	# The ACTION step re-enables ACTION and the Space key starts it.
	var steps: Array = game._tutorial_steps()
	var action_step := -1
	for index in steps.size():
		if str(steps[index].get("gate", "")) == "action":
			action_step = index
	game._tutorial_step = action_step
	game._show_tutorial_step()
	check.call(not game._action.disabled and game._tutorial_allows("action"), "ACTION is allowed on the ACTION step")
	# The swap panel splits choosing, picking and swapping into separate steps.
	game._tutorial_panel = 1
	game._tutorial_step = 0
	var gates: Array = game._tutorial_steps().map(func(step): return str(step.get("gate", "")))
	var order := [gates.find("choose"), gates.find("picked"), gates.find("swap")]
	check.call(order[0] >= 0 and order[0] < order[1] and order[1] < order[2], "Swap is taught as choose, then pick up, then swap")
	game.free()
	_keyboard_walk(check)
	return true


func _settle(game) -> void:
	game._process(0.3)
	game._check_tutorial_gates()


func _step_until(game, code: int, gate_after: String, limit := 12) -> bool:
	for i in limit:
		if game._tutorial_gate() == gate_after:
			return true
		_key(game, code)
		_settle(game)
	return game._tutorial_gate() == gate_after


## A keyboard-only pass through the first tutorial panels, one mechanic per step.
func _keyboard_walk(check: Callable) -> void:
	var game = MAIN.instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(game)
	game._front.hide()
	game.tutorial_done = false
	game._load_page(0)
	if is_instance_valid(game._intro_card):
		game._intro_card.hide()
	game._finish_run()
	game._process(0.7)
	game._finish_run()
	# Step 1: the light. Everything else is hidden or off.
	check.call(not game._action.visible and not game._restart.visible and not game._legend.visible and not game._progress_label.visible, "Step one hides ACTION, RESTART, the legend and the Endings counter")
	check.call(not game._hint_hud.visible and not game._tutorial_allows("hint"), "Step one hides the hint button")
	for blocked in [KEY_S, KEY_TAB, KEY_1, KEY_P, KEY_H, KEY_R, KEY_O, KEY_B]:
		_key(game, blocked)
	check.call(game._tutorial_gate() == "lit" and game.mode == "PLAN", "None of the later controls does anything on step one")
	check.call(game._tutorial_can_pass(), "Space can pass step one")
	# Slide onto Dassi, then off again.
	check.call(_step_until(game, KEY_A, "unlit"), "Sliding the light onto Dassi finishes step one")
	check.call(_step_until(game, KEY_D, "click"), "Sliding off Dassi finishes step two")
	check.call(not game._tutorial_allows("move_x"), "An info step switches the light off until it is dismissed")
	_key(game, KEY_D)
	check.call(game._tutorial_gate() == "click", "Keys do nothing on an info step")
	_key(game, KEY_SPACE)
	check.call(game._tutorial_gate() == "clipping_opened", "Space dismisses an info step")
	check.call(not game._tutorial_can_pass(), "Space cannot skip a step that teaches a control")
	_key(game, KEY_SPACE)
	check.call(game._tutorial_gate() == "clipping_opened" and game.mode == "PLAN", "Space does not start ACTION early")
	_key(game, KEY_O)
	game._finish_run()
	game._process(0.7)
	check.call(game._tutorial_gate() == "lit_set" and game.mode == "PLAN", "Watching the Original finishes its step")
	var y: float = game.plan.lanterns[0].y
	check.call(_step_until(game, KEY_S, "click", 20), "Lowering the light until Dassi and the biryani are lit finishes the step")
	check.call(game.plan.lanterns[0].y != y, "Raise / lower works on the step that teaches it")
	_key(game, KEY_SPACE)
	check.call(game._tutorial_gate() in ["unlit", "action"], "The next step follows in order")
	for i in 6:
		_settle(game)
		if game._tutorial_gate() == "action":
			break
		_key(game, KEY_SPACE)
	check.call(game._tutorial_gate() == "action" and game._action.visible and not game._action.disabled, "ACTION appears only on its own step")
	_key(game, KEY_SPACE)
	check.call(game.mode != "PLAN", "Space starts ACTION on the ACTION step")
	game._finish_run()
	game._start_tutorial(0, 1)
	_swap_panel_walk(game, check)
	game._finish_run()
	game._start_tutorial(0, 4)
	_bulb_panel_walk(game, check)
	game.free()


## The swap panel: legend, choose (Tab), pick up (Enter), swap (Tab + Enter), ACTION.
func _swap_panel_walk(game, check: Callable) -> void:
	game._finish_run()
	game._process(0.7)
	game._finish_run()
	check.call(game._tutorial_panel == 1 and game.mode == "PLAN", "The swap panel starts after the light panel")
	check.call(game._tutorial_gate() == "legend_opened" and game._legend.visible, "The swap panel opens by introducing the legend")
	check.call(not game._action.visible, "ACTION is hidden again at the start of the next panel")
	_key(game, KEY_TAB)
	check.call(game._stage.key_cursor == "", "Tab does nothing before choosing is taught")
	_key(game, KEY_SPACE)
	check.call(game._tutorial_gate() == "choose", "Space dismisses the legend step")
	_key(game, KEY_ENTER)
	check.call(game._stage.key_picked == "", "Enter cannot pick up a thought while choosing is being taught")
	_key(game, KEY_TAB)
	check.call(game._tutorial_gate() == "picked", "Tab chooses someone and finishes the choose step")
	_key(game, KEY_ENTER)
	check.call(game._tutorial_gate() == "swap" and game._stage.key_picked != "", "Enter picks the thought up and finishes the pick-up step")
	_key(game, KEY_SPACE)
	check.call(game._tutorial_gate() == "swap" and game.mode == "PLAN", "Space cannot skip the swap")
	_key(game, KEY_TAB)
	_key(game, KEY_ENTER)
	check.call(game._tutorial_gate() == "action", "Dropping the thought on the other character swaps and finishes the step")
	check.call(game._action.visible and game._tutorial_allows("action"), "ACTION shows up once the swap is done")




## The two-bulb panel: a second bulb is taken out (2), then parked (P).
func _bulb_panel_walk(game, check: Callable) -> void:
	game._finish_run()
	game._process(0.7)
	game._finish_run()
	check.call(game._tutorial_panel == 4 and game._tutorial_gate() == "lantern_deployed", "The bulb panel opens by taking out the second bulb")
	_key(game, KEY_2)
	_key_to_stage(game, KEY_P)
	_settle(game)
	check.call(game._tutorial_gate() == "lantern_parked", "Picking the second bulb (2) and hanging it (P) finishes its step")
	_key_to_stage(game, KEY_P)
	_settle(game)
	check.call(game._tutorial_gate() == "action", "Parking a bulb finishes its step and ACTION follows")
	# Every gated step in the tutorial has a purpose line, key caps and a short caption.
	for panel in game._tutorial_data().get("panels", []):
		for step in panel.get("steps", []):
			var gate := str(step.get("gate", ""))
			if game.TUTORIAL_ALLOW.has(gate):
				check.call(not game._tutorial_parts(step).is_empty(), "Tutorial step '%s' shows key caps" % gate)
				check.call(str(step.caption).length() <= 140 and "Press " not in str(step.caption), "Tutorial step '%s' is short and leaves the keys to the key caps" % gate)
