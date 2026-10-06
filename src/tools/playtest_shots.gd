extends SceneTree
## Dev: for every campaign page, a PLAN shot and a mid-ACTION shot (default plan).
## Windowed: Godot --path src --script res://tools/playtest_shots.gd [-- 4 5]
## Writes build/shots/pt_NN_plan.png and pt_NN_action.png.
const MAIN = preload("res://scenes/main.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://../build/shots"))
	var game = MAIN.instantiate()
	root.add_child(game)
	game.tutorial_done = true
	game._front.hide()
	game._sound.button_pressed = false
	var args := OS.get_cmdline_user_args()
	var numbers: Array = Array(args).map(func(a): return int(a)) if args.size() > 0 else range(1, 16)
	for number in numbers:
		game._load_page(number - 1)
		await _settle(30)
		game._story_queue.clear()
		if is_instance_valid(game._story_card):
			game._story_card.queue_free()
		game._finish_run()
		await _settle(40)
		game._finish_run()
		await _settle(40)
		_save("pt_%02d_plan" % number)
		game._start_action()
		await _settle(70)
		_save("pt_%02d_action" % number)
		game._finish_run()
		await _settle(20)
	quit()


func _settle(frames: int) -> void:
	for i in frames:
		await process_frame


func _save(name: String) -> void:
	root.get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../build/shots/%s.png" % name))
