extends SceneTree
## Screenshots of campaign pages for review: the plan screen and a three-star result.
## Run windowed (not headless): Godot --path src --script res://tools/page_shots.gd -- 4 5 6
## Writes build/shots/page_NN_plan.png and page_NN_result.png.

const MAIN = preload("res://scenes/main.tscn")
const AUDIT = preload("res://tools/campaign_audit.gd")
const SIM = preload("res://core/simulator.gd")
const GOALS = preload("res://core/goal_evaluator.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://../build/shots"))
	var game = MAIN.instantiate()
	root.add_child(game)
	game.tutorial_done = true
	game._front.hide()
	game._sound.button_pressed = false
	var numbers: Array = Array(OS.get_cmdline_user_args()).map(func(a): return int(a))
	for number in numbers:
		game._load_page(number - 1)
		await _settle(game, 40)
		game._story_queue.clear()
		if is_instance_valid(game._story_card):
			_save("page_%02d_card" % number)
			game._story_card.queue_free()
		await _settle(game, 10)
		_save("page_%02d_plan" % number)
		var plan := _best_plan(game.page)
		if plan.is_empty():
			print("page %d: no three-star plan found" % number)
			continue
		game._saved_plan = plan
		game._begin(SIM.run(game.page, plan, true), false)
		game._finish_run()
		await _settle(game, 120)
		_save("page_%02d_result" % number)
		# Between-page cards (page 5 mail, page 12 postcard) and the page 15 reveal.
		if game.page.has("cliffhanger") or game.page.has("postcard_after") or game.page.has("reveal"):
			game._next_page()
			await _settle(game, 30)
			for step in 4:
				if not is_instance_valid(game._story_card) or not game._story_card.visible:
					break
				_save("page_%02d_after_%d" % [number, step])
				_press(game._story_card)
				await _settle(game, 90)
				if game._revealing:
					await _settle(game, 120)
					_save("page_%02d_replay" % number)
					game._finish_run()
					await _settle(game, 120)
			if game._front.visible:
				_save("page_%02d_credits" % number)
	quit()


func _press(node: Node) -> void:
	for child in node.find_children("*", "Button", true, false):
		if child.visible:
			child.pressed.emit()
			return


func _settle(game: Node, frames: int) -> void:
	for i in frames:
		await process_frame


func _save(name: String) -> void:
	var image := root.get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("res://../build/shots/%s.png" % name))
	print("saved ", name)


func _best_plan(page: Dictionary) -> Dictionary:
	var audit = AUDIT.new()
	var space: Dictionary = audit.plan_space(page)
	var steps: Array = AUDIT.star_steps(page)
	var full: Dictionary = page.duplicate()
	full.goal = {"facts": steps.back().facts if not steps.is_empty() else page.goal.facts, "twist_caption": ""}
	for key in space.configs:
		for thoughts in space.arrangements:
			for flick in space.flicks:
				var plan := {"centres": [], "lanterns": space.configs[key].lanterns, "thoughts": thoughts}
				if not flick.is_empty():
					plan.flick = flick
				if GOALS.evaluate(full, SIM.run(page, plan)).won:
					audit.free()
					return plan
	audit.free()
	return {}
