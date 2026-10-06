extends RefCounted
## The whole PLAN loop works from the keyboard: move the bulb, pick and swap
## thoughts, start ACTION and move on from the result.

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
	_key(game, KEY_D)
	_key(game, KEY_D, true)
	game._move_lantern(0, Vector2(6.0, 0.0), true)
	var lit: Array = game._lit_ids()
	check.call("dog" in lit and "boss" in lit, "Bulb lights Chintu and the Prof")
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
	game.free()
	return true
