extends SceneTree
## Dev shots of the coach pop-ups on a PLAN screen. Run windowed:
## Godot --path src --script res://tools/coach_shot.gd -- 5
## Writes build/shots/coach_*.png.

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
	await _settle(40)
	print("mode ", game.mode, " wanted ", game._coach_wanted())
	_save("coach_1_move")
	_key(game, KEY_D)
	await _settle(30)
	_save("coach_2_after_move")
	game._coach_event("tilt")
	await _settle(30)
	_save("coach_3_next")
	quit()


func _settle(frames: int) -> void:
	for i in frames:
		await process_frame


func _save(name: String) -> void:
	var image := root.get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("res://../build/shots/%s.png" % name))
	print("saved ", name)
