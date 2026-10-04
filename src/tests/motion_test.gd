extends RefCounted
## Walking is continuous: no per-frame jumps, no facing flips mid-walk.

const MAIN = preload("res://scenes/main.tscn")


func run(check: Callable) -> bool:
	var game = MAIN.instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(game)
	game._on_front_start()
	game._stop_voice()
	game._load_page(5)
	game._finish_run()
	game._process(0.7)
	game._move_lantern(0, Vector2(3.0, -0.6))
	game._swap("grandma", "boss")
	game._start_action()
	game._anticipation = 0.0
	var last: Dictionary = {}
	var facing: Dictionary = {}
	var max_step := 0.0
	var flips := 0
	var moving_frames := 0
	for frame in 400:
		if game.mode != "PLAY":
			break
		game._process(1.0 / 60.0)
		if game.mode != "PLAY":
			break
		for id in game._stage._rigs:
			var rig = game._stage._rigs[id]
			if last.has(id):
				var step: float = absf(rig.position.x - last[id])
				max_step = maxf(max_step, step)
				if step > 0.01:
					moving_frames += 1
					if facing[id] != signf(rig.scale.x):
						flips += 1
			last[id] = rig.position.x
			facing[id] = signf(rig.scale.x)
	check.call(moving_frames > 200 and max_step <= 6.0, "Walking moves a few pixels every frame with no jumps (max %.1f px)" % max_step)
	check.call(flips == 0, "Walking actors never flip facing mid-step")
	game.free()
	return true
