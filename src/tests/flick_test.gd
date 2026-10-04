extends RefCounted
## FLICK: one spare bulb dropped during ACTION, a lamp the player times (Claude batch 7).

const PAGE = preload("res://data/pages/page_06.gd")
const MAIN = preload("res://scenes/main.tscn")
const PLAN = preload("res://core/plan_state.gd")
const SIM = preload("res://core/simulator.gd")
const RULES = preload("res://core/rules.gd")


func run(check: Callable) -> bool:
	var page := PAGE.definition()
	page.flick = 1
	var plan: Dictionary = PLAN.from_page(page).to_data()
	var plain: Dictionary = SIM.run(page, plan, true)
	plan.flick = {"beat": 2, "centre": 9}
	var flicked: Dictionary = SIM.run(page, plan, true)
	var dog_ding: Array = flicked.events.filter(func(e): return e.type == "DING" and e.actor == "dog")
	check.call(dog_ding.size() == 1 and dog_ding[0].beat == 2 and dog_ding[0].phase == "SWITCHES" and dog_ding[0].get("lamp") == "flick", "A FLICK wakes dark actors in its 3 slots at the SWITCHES phase of its beat")
	var prefix := true
	for i in plain.presentation_frames.size():
		var frame: Dictionary = plain.presentation_frames[i]
		if frame.beat > 2 or (frame.beat == 2 and frame.phase not in ["DECIDE", "MOVE"]):
			break
		prefix = prefix and frame.world.characters == flicked.presentation_frames[i].world.characters
	check.call(prefix, "Everything before the flick replays identically")
	var no_grant: Dictionary = page.duplicate(true)
	no_grant.flick = 0
	check.call(SIM.run(no_grant, plan).events == SIM.run(no_grant, PLAN.from_page(no_grant).to_data()).events, "Pages without a spare bulb ignore a flick in the plan")
	var dark: Dictionary = page.duplicate(true)
	var dark_plan: Dictionary = PLAN.from_page(dark).to_data()
	dark_plan.lanterns[0].enabled = false
	dark_plan.flick = {"beat": 5, "centre": 9}
	var quiet: Dictionary = SIM.run(dark, dark_plan)
	check.call(quiet.events.any(func(e): return e.type == "DING" and e.beat == 5) and quiet.end_beat > 5, "Quiet beats keep passing until a pending flick switches on")
	var game = MAIN.instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(game)
	game._on_front_page(2)
	game._finish_run()
	game._process(0.7)
	game.page.flick = 1
	game._start_action()
	check.call(game._flick_available(), "A page with a spare bulb offers a FLICK during ACTION")
	game._clock = 0.5
	game._drop_flick(9)
	check.call(game._run.plan.flick == {"beat": 2, "centre": 9} and not game._flick_available(), "The flick lands on the next unseen SWITCHES beat and is used once")
	game._finish_run()
	game._return_to_plan()
	check.call(game.plan.flick == {"beat": 2, "centre": 9}, "REWIND keeps the flick so a timed solution repeats")
	game._clear_flick()
	check.call(game.plan.flick.is_empty(), "Clicking the ghost clears the kept flick")
	game.free()
	return true
