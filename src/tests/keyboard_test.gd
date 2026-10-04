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
		if game.PAGE_SCRIPTS[index].definition().title == "Nap Time":
			nap = index
	game._load_page(nap)
	game._finish_run()
	game._process(0.7)
	game._finish_run()
	check.call(game.mode == "PLAN", "Keyboard test starts in PLAN")
	var start: float = game.plan.lanterns[0].x
	_key(game, KEY_A)
	check.call(game.plan.lanterns[0].x < start, "A moves the bulb left")
	_key(game, KEY_D)
	_key(game, KEY_D, true)
	game._move_lantern(0, Vector2(5.4, 0.0), true)
	var lit: Array = game._lit_ids()
	check.call("dog" in lit and "boss" in lit, "Bulb lights the Dog and the Boss")
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
	check.call(game.mode == "PLAN" or game.page_index != nap, "Enter leaves the result (retry or next page)")
	game.free()
	return true
