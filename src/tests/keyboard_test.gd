extends RefCounted
## The whole PLAN loop works from the keyboard: move the bulb, pick and swap
## thoughts, start ACTION and move on from the result.

const MAIN = preload("res://scenes/main.tscn")


func _key(game, code: int, shift := false, echo := false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	event.shift_pressed = shift
	event.echo = echo
	game._input(event)


func run(check: Callable) -> bool:
	var game = MAIN.instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(game)
	game.tutorial_done = true
	game._front.hide()
	var nap := 0
	for index in game.PAGE_SCRIPTS.size():
		if game.PAGE_SCRIPTS[index].definition().title == "Office Hours":
			nap = index
	game._load_page(nap)
	game._finish_run()
	game._process(0.7)
	game._finish_run()
	check.call(game.mode == "PLAN", "Keyboard test starts in PLAN")
	_key(game, KEY_2)
	var start: float = game.plan.lanterns[0].x
	_key(game, KEY_A)
	check.call(game.plan.lanterns[0].x < start, "Key 2 on a one-bulb page keeps the bulb movable")
	# One press is one fixed grid step (half a slot); OS key-repeat is ignored.
	game._move_lantern(0, Vector2(2.0, -0.6), true)
	_key(game, KEY_D)
	check.call(is_equal_approx(game.plan.lanterns[0].x, 2.5), "One press moves the bulb exactly half a slot")
	_key(game, KEY_D, false, true)
	check.call(is_equal_approx(game.plan.lanterns[0].x, 2.5), "OS key-repeat events do not move the bulb")
	_key(game, KEY_A)
	check.call(is_equal_approx(game.plan.lanterns[0].x, 2.0), "A steps back to the previous grid line")
	_key(game, KEY_S)
	check.call(is_equal_approx(game.plan.lanterns[0].y, -0.4), "S lowers the bulb one grid step")
	game._move_lantern(0, Vector2(2.3, -0.6), true)
	_key(game, KEY_D)
	check.call(is_equal_approx(game.plan.lanterns[0].x, 2.5), "An off-grid bulb snaps to the next grid line")
	_key(game, KEY_D)
	_key(game, KEY_D, true)
	game._move_lantern(0, Vector2(6.0, 0.0), true)
	var lit: Array = game._lit_ids()
	check.call("dog" in lit and "boss" in lit, "Bulb lights Chintu and the Prof")
	# A thought held back while the narrator talks is spoken once it stops.
	game._said_scripted.clear()
	game._lit_waiting = ["dog"] as Array[String]
	game._lit_wait_timer = 0.0
	game._flush_lit_waiting(1.0)
	check.call(game._said_scripted.has(str(game.page.id) + ":lit:dog") and game._lit_waiting.is_empty(), "A held-back lit thought is spoken after the narration")
	_key(game, KEY_TAB)
	var first: String = game._stage.key_cursor
	_key(game, KEY_ENTER)
	check.call(game._stage.key_picked == first, "Enter picks the thought under the cursor")
	_key(game, KEY_TAB)
	var second: String = game._stage.key_cursor
	check.call(second != first and second in lit, "Tab moves to another lit character")
	var before: String = game.plan.thoughts.get(first, "")
	_key(game, KEY_ENTER)
	check.call(game.plan.thoughts.get(second, "") == before, "Enter on a second character swaps their thoughts")
	_key(game, KEY_SPACE)
	check.call(game.mode == "PLAY", "Space starts ACTION")
	_key(game, KEY_SPACE)
	check.call(game.mode == "RESULT", "Space skips to the result")
	_key(game, KEY_ENTER)
	if game.mode == "RESULT":
		_key(game, KEY_ENTER)
	check.call(game.mode == "PLAN" or game.page_index != nap or game._front.visible, "Enter leaves the result (retry, next page or the levels screen)")
	# Live goal check during playback uses the player's lanterns (SHY HIDING).
	var stage_fright: Dictionary = game.VALIDATOR.new().validate(load("res://data/campaign/page_05.gd").definition()).page
	game._load_page(0, stage_fright)
	var lit_plan: Dictionary = game.plan.to_data()
	var world: Dictionary = game.RULES.initial_world(game.page, lit_plan)
	var hiding := {"type": "HIDING", "character": "boss"}
	var page_copy: Dictionary = game.page.duplicate(true)
	page_copy.goal = {"facts": [hiding], "twist_caption": "x"}
	for actor in world.characters:
		actor.active = true
	var lit_kid := false
	for actor in world.characters:
		if actor.id == "boss":
			lit_kid = game.RULES.is_lit(game.page, lit_plan, world, actor.slot)
	var judged: bool = game.GOALS.evaluate(page_copy, {"plan": lit_plan, "snapshots": [world], "events": []}).won
	check.call(judged == (not lit_kid), "HIDING follows the player's lantern plan")
	# At the start of a page the arrow keys must not cut off the narration.
	game._load_page(nap)
	check.call(game.mode == "INTRO", "A page opens on the Original strip")
	var bulb_before: float = game.plan.lanterns[0].x
	_key(game, KEY_D)
	check.call(game.mode == "PLAN", "A gameplay key during the Original goes straight to the plan")
	check.call(not is_equal_approx(game.plan.lanterns[0].x, bulb_before), "...and acts on that very press")
	game._load_page(nap)
	_key(game, KEY_SPACE)
	check.call(game.mode != "INTRO", "Space still skips the Original strip")
	game.free()
	_menus(check)
	return true


## Menus and cards keep the keyboard to themselves: focus never leaks into the HUD behind them.
func _menus(check: Callable) -> void:
	var game = MAIN.instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(game)
	var focus := func() -> String:
		var owner: Control = game.get_viewport().gui_get_focus_owner()
		return str(owner.name) if owner != null else ""
	check.call(game._front.visible and focus.call() == "Start", "Title opens with PLAY focused")
	# No frame has run yet: lay the button column out by hand.
	game._front._start.get_parent().notification(Container.NOTIFICATION_SORT_CHILDREN)
	var walk: Array[String] = []
	for i in 5:
		_key(game, KEY_DOWN)
		walk.append(focus.call())
	check.call(walk == ["Pages", "Settings", "Credits", "Exit", "Start"], "Down walks LEVELS, SETTINGS, CREDITS, EXIT and wraps without leaving the title: " + str(walk))
	_key(game, KEY_UP)
	check.call(focus.call() == "Exit", "Up wraps from PLAY to EXIT")
	game._front.show_credits()
	game.get_viewport().gui_release_focus()
	_key(game, KEY_DOWN)
	check.call(game._front._credits_panel.visible and game._front.menu_scope() == game._front._credits_panel and game.get_viewport().gui_get_focus_owner() != null, "Focus lost under the Credits is recovered by a direction key")
	game._front._credits_panel.hide()
	# A story card owns Enter: it must not skip the Original underneath.
	game._front.hide()
	game._show_story_card({"id": "test_card", "kicker": "K", "title": "T", "body": "B", "thought": ""})
	game._story_card.get_child(1).get_children()
	var mode_before: String = game.mode
	_key(game, KEY_SPACE)
	check.call(game.mode == mode_before and game._story_card.visible, "Space on a story card is left to its button, not used to skip the Original")
	check.call(game.get_viewport().gui_get_focus_owner() == null or game._story_card.is_ancestor_of(game.get_viewport().gui_get_focus_owner()), "Story card focus stays on the card")
	game._story_card.hide()
	game.free()
