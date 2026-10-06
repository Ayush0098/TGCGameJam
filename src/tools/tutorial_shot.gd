extends SceneTree
## Dev shots of the tutorial card. Run windowed: Godot --path src --script res://tools/tutorial_shot.gd
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
	game._front.hide()
	game._sound.button_pressed = false
	game.tutorial_done = false
	game._load_page(0)
	await _settle(40)
	if is_instance_valid(game._intro_card):
		game._intro_card.hide()
	game._finish_run()
	await _settle(50)
	game._finish_run()
	await _settle(40)
	_save("tut_1")
	_key(game, KEY_D)
	await _settle(30)
	_key(game, KEY_SPACE)
	await _settle(30)
	_save("tut_2")
	for i in 3:
		_key(game, KEY_SPACE)
		await _settle(30)
	_save("tut_3")
	quit()


func _settle(frames: int) -> void:
	for i in frames:
		await process_frame


func _save(name: String) -> void:
	root.get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../build/shots/%s.png" % name))
