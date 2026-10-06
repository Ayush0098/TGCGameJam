extends SceneTree
## Dev shots of the thought-swap animation. Run windowed:
## Godot --path src --script res://tools/swap_shot.gd -- 5
## Writes build/shots/swap_*.png.

const MAIN = preload("res://scenes/main.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _key(game, code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	game._input(event)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://../build/shots"))
	var game = MAIN.instantiate()
	root.add_child(game)
	game.tutorial_done = true
	game._front.hide()
	game._sound.button_pressed = false
	var number := int(OS.get_cmdline_user_args()[0]) if OS.get_cmdline_user_args().size() > 0 else 5
	game._load_page(number - 1)
	await _settle(40)
	game._story_queue.clear()
	if is_instance_valid(game._story_card):
		game._story_card.queue_free()
	game._finish_run()
	await _settle(60)
	game._finish_run()
	await _settle(30)
	game._move_lantern(0, Vector2(2.5, -0.6), true)
	await _settle(20)
	print("lit ", game._lit_ids())
	_key(game, KEY_TAB)
	_key(game, KEY_ENTER)
	await _settle(14)
	_save("swap_1_picked")
	_key(game, KEY_TAB)
	_key(game, KEY_ENTER)
	for i in 4:
		await _settle(5)
		_save("swap_2_flight_%d" % i)
	await _settle(30)
	_save("swap_3_done")
	quit()


func _settle(frames: int) -> void:
	for i in frames:
		await process_frame


func _save(name: String) -> void:
	var image := root.get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("res://../build/shots/%s.png" % name))
	print("saved ", name)
