extends SceneTree
## Automated campaign playthrough through the real game flow (Main scene):
## for each page, finds one winning plan with the audit's search, applies it in
## PLAN, presses ACTION, drops the FLICK at its beat during playback if needed,
## plays the run to the end and checks the result popup shows a win.
## Optional screenshots: pass a directory after "--" (non-headless only).

const MAIN_SCENE = preload("res://scenes/main.tscn")
const AUDIT = preload("res://tools/campaign_audit.gd")
const RULES = preload("res://core/rules.gd")
const SIM = preload("res://core/simulator.gd")
const GOALS = preload("res://core/goal_evaluator.gd")


func _initialize() -> void:
	_run.call_deferred()


func _find_win(page: Dictionary) -> Dictionary:
	var audit = AUDIT.new()
	var base := {}
	for c in page.characters:
		base[c.id] = c.thought
	var ids: Array = base.keys()
	var arrangements := []
	var seen := {}
	for values in audit._perms(ids.map(func(id): return base[id])):
		var thoughts := {}
		for k in ids.size():
			thoughts[ids[k]] = values[k]
		if not seen.has(str(thoughts)):
			seen[str(thoughts)] = true
			arrangements.append(thoughts)
	var flicks := [{}]
	if int(page.get("flick", 0)) > 0:
		for beat in range(1, 9):
			for centre in range(int(page.width)):
				flicks.append({"beat": beat, "centre": centre})
	for ls in audit._lantern_sets(page):
		for thoughts in arrangements:
			for flick in flicks:
				var plan := {"centres": [], "lanterns": ls, "thoughts": thoughts}
				if not flick.is_empty():
					plan.flick = flick
				if GOALS.evaluate(page, SIM.run(page, plan)).won:
					return plan
	return {}


func _run() -> void:
	var shots := ""
	for arg in OS.get_cmdline_user_args():
		shots = arg
	var main = MAIN_SCENE.instantiate()
	main.tutorial_done = true
	root.add_child(main)
	await process_frame
	main.tutorial_done = true
	var passed := 0
	for index in main.PAGE_SCRIPTS.size():
		main._front.hide()
		main._load_page(index)
		main._stop_voice()
		main._finish_run()
		main._process(0.7)
		var plan_data := _find_win(main.page)
		if plan_data.is_empty():
			print("PAGE %d %s: NO WINNING PLAN FOUND" % [index + 1, main.page.title])
			continue
		var flick: Dictionary = plan_data.get("flick", {})
		var setup: Dictionary = plan_data.duplicate(true)
		setup.erase("flick")
		# Thought arrangements are reachable by swaps in play; apply directly here.
		main.plan.restore(setup)
		main._saved_plan = main.plan.to_data()
		main._refresh_plan()
		main._start_action()
		main._anticipation = 0.0
		var dropped := flick.is_empty()
		for frame in 4000:
			if main.mode != "PLAY":
				break
			if not dropped and main._flick_beat() == int(flick.beat):
				main._drop_flick(int(flick.centre))
				dropped = true
			main._process(1.0 / 60.0)
			if not shots.is_empty() and frame % 20 == 0:
				await process_frame
		if not shots.is_empty():
			for i in 40:
				await process_frame
			await RenderingServer.frame_post_draw
			root.get_viewport().get_texture().get_image().save_png(shots + "/win_%02d.png" % (index + 1))
		var ok: bool = main.mode == "RESULT" and main._won_current and main._result_card.visible
		passed += 1 if ok else 0
		print("PAGE %d %s: %s%s" % [index + 1, main.page.title, "WIN" if ok else "FAILED (mode %s)" % main.mode, " with FLICK at beat %d" % flick.beat if not flick.is_empty() else ""])
	print("PLAYTHROUGH %d / %d pages won in the game flow" % [passed, main.PAGE_SCRIPTS.size()])
	quit()
