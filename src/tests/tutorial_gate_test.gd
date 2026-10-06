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
	return true
