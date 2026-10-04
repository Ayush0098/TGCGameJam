extends RefCounted

const EVALUATOR = preload("res://core/goal_evaluator.gd")


func run(check: Callable) -> bool:
	var page := _page()
	var run_result := _run()
	var unchanged_page := page.duplicate(true)
	var unchanged_run := run_result.duplicate(true)
	var result: Dictionary = EVALUATOR.evaluate(page, run_result)
	check.call(result.won and result.facts[0].met, "ATE is historical even when its eater is finally KO")
	check.call(result.caption == "The Dog ate the cake. The Boss ran out of the comic.", "Caption reports meaningful events in chronological order")
	check.call(page == unchanged_page and run_result == unchanged_run, "Goal evaluation does not mutate page or run")
	result.facts[0].fact.object = "changed"
	check.call(page.goal.facts[0].object == "cake", "Returned fact dictionaries are independent copies")

	var no_history := _run()
	no_history.events = []
	check.call(not EVALUATOR.evaluate(page, no_history).won, "Final eater metadata does not fabricate an EAT event")
	check.call(EVALUATOR.evaluate(page, no_history).caption == "Nobody did anything. Riveting.", "Absent events produce the idle caption, not an inferred outcome")
	check.call(_evaluate({"type": "ATE", "character": "dog", "object": "chair"}).won == false, "ATE requires an authored FOOD reference")
	check.call(_evaluate({"type": "ATE", "character": "missing", "object": "cake"}).won == false, "ATE rejects a missing authored actor")
	check.call(_evaluate({"type": "ATE", "character": "dog", "object": "missing"}).won == false, "ATE rejects a missing authored food")
	check.call(not _evaluate({"type": "ATE", "character": "dog", "object": "broccoli"}).won, "An EAT event for another food does not satisfy ATE")
	check.call(not _evaluate({"type": "ATE", "character": "boss", "object": "cake"}).won, "An EAT event by another actor does not satisfy ATE")

	check.call(_evaluate({"type": "ASLEEP", "character": "grandma"}).won, "ASLEEP without a seat reads final actor status")
	check.call(_evaluate({"type": "ASLEEP", "character": "grandma", "object": "chair"}).won, "ASLEEP with a seat requires its matching occupant")
	check.call(not _evaluate({"type": "ASLEEP", "character": "grandma", "object": "other_chair"}).won, "A different occupied seat does not satisfy the requested seat")
	check.call(not _evaluate({"type": "ASLEEP", "character": "grandma", "object": "cake"}).won, "ASLEEP rejects a food reference")
	var awake := _run()
	awake.snapshots[-1].characters[2].status = "KO"
	check.call(not _evaluate({"type": "ASLEEP", "character": "grandma", "object": "chair"}, awake).won, "Seat occupancy alone cannot replace final ASLEEP status")
	check.call(not _evaluate({"type": "ASLEEP", "character": "missing"}).won, "ASLEEP rejects a missing actor")

	check.call(_evaluate({"type": "BONKED", "character": "dog", "target": "boss"}).won, "BONKED remains historical after the bonker is KO")
	check.call(not _evaluate({"type": "BONKED", "character": "boss", "target": "dog"}).won, "BONKED requires the requested direction of the event")
	check.call(not _evaluate({"type": "BONKED", "character": "dog", "target": "missing"}).won, "BONKED rejects a missing target")
	check.call(not _evaluate({"type": "BONKED", "character": "dog", "target": "boss"}, no_history).won, "Final KO status does not fabricate BONK history")
	check.call(_evaluate({"type": "KO", "character": "dog"}).won, "KO reads final status")
	check.call(not _evaluate({"type": "KO", "character": "boss"}).won, "Historical damage does not replace final KO status")
	check.call(_evaluate({"type": "EXITED", "character": "boss"}).won, "EXITED reads final status")
	check.call(not _evaluate({"type": "EXITED", "character": "missing"}).won, "EXITED rejects a missing actor")
	check.call(not _evaluate({"type": "UNEATEN", "object": "cake"}).won, "Consumed food is not UNEATEN")
	check.call(_evaluate({"type": "UNEATEN", "object": "broccoli"}).won, "Present authored food is UNEATEN")
	check.call(not _evaluate({"type": "UNEATEN", "object": "chair"}).won, "UNEATEN rejects a seat reference")
	check.call(not _evaluate({"type": "UNEATEN", "object": "missing"}).won, "UNEATEN rejects a missing food")

	check.call(_evaluate({"type": "ALL_ACTIVATED"}).won, "ALL_ACTIVATED includes active KO, asleep and exited characters")
	var dark := _run()
	dark.snapshots[-1].characters[2].active = false
	check.call(not _evaluate({"type": "ALL_ACTIVATED"}, dark).won, "One inactive cast member fails ALL_ACTIVATED")
	var missing_cast := _run()
	missing_cast.snapshots[-1].characters.pop_back()
	check.call(not _evaluate({"type": "ALL_ACTIVATED"}, missing_cast).won, "Missing final cast member fails ALL_ACTIVATED")
	var no_snapshots := _run()
	no_snapshots.snapshots = []
	check.call(not _evaluate({"type": "KO", "character": "dog"}, no_snapshots).won, "State facts do not infer a final state when snapshots are absent")
	check.call(not _evaluate({"type": "ALL_ACTIVATED"}, no_snapshots).won, "ALL_ACTIVATED cannot pass without a final snapshot")
	var two_snapshots := _run()
	var first_world: Dictionary = two_snapshots.snapshots[0].duplicate(true)
	first_world.characters[0].status = "READY"
	two_snapshots.snapshots.push_front(first_world)
	check.call(_evaluate({"type": "KO", "character": "dog"}, two_snapshots).won, "State facts read the final snapshot rather than beat zero")
	two_snapshots.snapshots[-1].characters[2].status = "READY"
	check.call(not _evaluate({"type": "ASLEEP", "character": "grandma"}, two_snapshots).won, "An earlier ASLEEP snapshot cannot replace final state")
	var missing_final_actor := _run()
	missing_final_actor.snapshots[-1].characters.pop_front()
	check.call(not _evaluate({"type": "KO", "character": "dog"}, missing_final_actor).won, "A missing final actor cannot satisfy a state fact")
	var missing_final_food := _run()
	missing_final_food.snapshots[-1].objects.remove_at(1)
	check.call(not _evaluate({"type": "UNEATEN", "object": "broccoli"}, missing_final_food).won, "A missing final food is not assumed uneaten")

	var pair_page := _page()
	pair_page.goal.facts.append({"type": "UNEATEN", "object": "broccoli"})
	check.call(EVALUATOR.evaluate(pair_page, _run()).won, "Every requested fact must pass for a win")
	pair_page.goal.facts[1].object = "cake"
	var pair_result: Dictionary = EVALUATOR.evaluate(pair_page, _run())
	check.call(not pair_result.won and pair_result.facts[0].met and not pair_result.facts[1].met, "Mixed fact truth preserves individual results and fails the AND goal")
	pair_page.goal.facts = []
	check.call(not EVALUATOR.evaluate(pair_page, _run()).won, "An empty goal never wins vacuously")

	for example in [
		[{"type": "SIT", "actor": "grandma", "object": "chair"}, "Grandma fell asleep."],
		[{"type": "BONK", "actor": "dog", "target": "boss"}, "The Dog bonked the Boss."],
		[{"type": "CLASH", "object": "cake"}, "They fought over the cake. CLONK!"],
		[{"type": "EXIT", "actor": "boss"}, "The Boss ran out of the comic."],
	]:
		var caption_run := _run()
		caption_run.events = [example[0]]
		check.call(EVALUATOR.evaluate(_page(), caption_run).caption == example[1], "Caption template uses actual %s event" % example[0].type)
	var unknown_event := _run()
	unknown_event.events = [{"type": "EAT", "actor": "missing", "object": "cake"}]
	check.call(EVALUATOR.evaluate(_page(), unknown_event).caption == "Nobody did anything. Riveting.", "Unknown event participants do not invent caption names")
	return true


func _evaluate(fact: Dictionary, run_result := {}) -> Dictionary:
	var page := _page()
	page.goal.facts = [fact]
	return EVALUATOR.evaluate(page, _run() if run_result.is_empty() else run_result)


func _page() -> Dictionary:
	return {
		"id": "page_08",
		"characters": [{"id": "dog"}, {"id": "boss"}, {"id": "grandma"}],
		"objects": [
			{"id": "cake", "type": "FOOD"}, {"id": "broccoli", "type": "FOOD"},
			{"id": "chair", "type": "SEAT"}, {"id": "other_chair", "type": "SEAT"},
		],
		"goal": {"facts": [{"type": "ATE", "character": "dog", "object": "cake"}]},
	}


func _run() -> Dictionary:
	return {
		"events": [
			{"type": "BONK", "actor": "dog", "target": "boss"},
			{"type": "EAT", "actor": "dog", "object": "cake"},
			{"type": "EXIT", "actor": "boss"},
		],
		"snapshots": [{
			"characters": [
				{"id": "dog", "status": "KO", "active": true},
				{"id": "boss", "status": "EXITED", "active": true},
				{"id": "grandma", "status": "ASLEEP", "active": true},
			],
			"objects": [
				{"id": "cake", "type": "FOOD", "present": false, "eater": "dog"},
				{"id": "broccoli", "type": "FOOD", "present": true, "eater": ""},
				{"id": "chair", "type": "SEAT", "present": true, "occupant": "grandma"},
				{"id": "other_chair", "type": "SEAT", "present": true, "occupant": "boss"},
			],
		}],
	}
