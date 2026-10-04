extends RefCounted
## Foundation checks only. Gameplay suites will be added with the simulator.

const MAIN_SCENE = preload("res://scenes/main.tscn")


func run(check: Callable) -> bool:
	var scene := MAIN_SCENE.instantiate()
	check.call(scene is Control, "Main scene instantiates as the responsive game root")
	check.call(
		ProjectSettings.get_setting("application/run/main_scene") == MAIN_SCENE.resource_path,
		"Project launch points to the tested main scene"
	)
	scene.free()
	return true
