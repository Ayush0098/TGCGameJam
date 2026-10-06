extends SceneTree
## Dev shot: the whole re-skinned cast side by side. Run windowed: Godot --path src --script res://tools/dassi_shot.gd
## Writes build/shots/cast_rigs.png.

const ACTOR = preload("res://presentation/character_actor.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://../build/shots"))
	var back := ColorRect.new()
	back.color = Color("55607a")
	back.size = Vector2(1280, 720)
	root.add_child(back)
	var x := 90.0
	for entry in [["prof", ""], ["kassi", ""], ["saap", ""], ["prompt", ""], ["aunty", ""], ["faccha", ""], ["dassi", ""], ["dog", ""]]:
		var actor = ACTOR.new()
		root.add_child(actor)
		actor.configure(entry[0])
		actor.position = Vector2(x, 560)
		actor.scale = Vector2.ONE * 0.8
		if entry[1] != "":
			actor.play_action(entry[1], 1.0)
		x += 152.0
	for i in 20:
		await process_frame
	var image := root.get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("res://../build/shots/cast_rigs.png"))
	quit()
