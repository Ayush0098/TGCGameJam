extends RefCounted

const PAGE = preload("res://data/pages/page_06.gd")
const RULES = preload("res://core/rules.gd")
const SIMULATOR = preload("res://core/simulator.gd")


func run(check: Callable) -> bool:
	_reference_page_06(check)
	_reference_page_04(check)
	_simultaneous_resolution(check)
	_targeting_and_light(check)
	_isolation_and_bounds(check)
	_presentation_capture(check)
	return true


func _reference_page_06(check: Callable) -> void:
	var page := PAGE.definition()
	var original := SIMULATOR.run(page, _plan(page, [5]))
	check.call(original.end_beat == 3 and not original.capped, "Page 6 Original settles at beat 3")
	check.call(_events(original, "DING") == [[0, "boss", "", ""]], "Page 6 Original activates only Boss")
	check.call(_events(original, "EAT") == [[2, "boss", "", "cake"]], "Page 6 Original Boss eats Cake at beat 2")
	check.call(_slots(original, ["boss"]) == [[4], [5], [6], [6]], "Original snapshots reproduce every traced position")
	var plan := _plan(page, [3])
	plan.thoughts.boss = "SCARED"
	plan.thoughts.grandma = "HUNGRY"
	var solution := SIMULATOR.run(page, plan)
	check.call(solution.end_beat == 8 and not solution.capped, "Page 6 intended solution settles at beat 8")
	check.call(_events(solution, "DING") == [[0, "grandma", "", ""], [0, "boss", "", ""], [3, "dog", "", ""]], "Lamp DING occurs on reference beat 3")
	check.call(_events(solution, "EAT") == [[6, "dog", "", "cake"]], "Dog wins the reference race at beat 6")
	check.call(_events(solution, "EXIT") == [[7, "boss", "", ""]], "Boss exits the comic at beat 7")
	check.call(_events(solution, "LAMP_ON") == [[3, "", "", "pedal"]], "Dark pedal turns its lamp on when entered")
	check.call(_events(solution, "STEP_SWITCH") == [[3, "boss", "", "pedal"]], "Switch event preserves the causal walker for captions and playback")
	check.call(_slots(solution, ["grandma", "boss", "dog"]) == [
		[2, 4, 9], [2, 5, 9], [2, 6, 9], [2, 7, 9], [3, 8, 8],
		[4, 9, 7], [5, 10, 6], [5, 11, 6], [5, 11, 6],
	], "Intended solution snapshots reproduce all Appendix B positions")
	check.call(_events(solution, "IDLE") == [[1, "grandma", "", ""], [7, "grandma", "", ""]], "Idle emits on entry, permits retargeting, and does not prevent END")
	check.call(_actor(solution.snapshots[3], "dog").slot == 9 and _actor(solution.snapshots[3], "dog").active, "Newly lit Dog remains still on activation beat")
	check.call(_actor(solution.snapshots[6], "grandma").active and _actor(solution.snapshots[6], "grandma").slot == 5, "Activation persists outside the original spotlight")
	var fail_two := SIMULATOR.run(page, _plan(page, [2]))
	check.call(_events(fail_two, "BONK") == [[8, "intern", "dog", ""]], "Centre 2 failure: Intern bonks Dog at beat 8")
	check.call(_events(fail_two, "EAT").is_empty() and _object(fail_two.snapshots[-1], "cake").present, "Bonk prevents Dog's simultaneous food claim")
	check.call(_events(fail_two, "LAMP_ON") == [[5, "", "", "pedal"]], "Centre 2 failure: Grandma crosses pedal on beat 5")
	var fail_three := SIMULATOR.run(page, _plan(page, [3]))
	check.call(_events(fail_three, "EXIT") == [[3, "grandma", "", ""]] and fail_three.end_beat == 4, "Centre 3 failure: Grandma flees left and run settles")
	check.call(_events(fail_three, "DING") == [[0, "grandma", "", ""], [0, "boss", "", ""]] and _events(fail_three, "EAT").is_empty(), "Centre 3 failure: Dog stays dark and Boss cannot see Cake")


func _reference_page_04(check: Callable) -> void:
	var page := _page([
		_actor_def("grandma", 0, "SLEEPY"), _actor_def("kid", 2, "HUNGRY"), _actor_def("dog", 10, "HUNGRY", "L"),
	], [_object_def("pedal", "SWITCH", 3), _object_def("armchair", "SEAT", 4), _object_def("pie", "FOOD", 6)], [])
	page.fixed_lights = [[6, 6]]
	page.lamps = [{"id": "fridge_lamp", "zone": [6, 10], "switch_id": "pedal", "initially_on": false}]
	var original := SIMULATOR.run(page, _plan(page, [2]))
	check.call(_events(original, "LAMP_ON") == [[1, "", "", "pedal"]] and _events(original, "EAT") == [[4, "kid", "", "pie"]], "Page 4 Original: Kid switches at beat 1, eats at beat 4")
	check.call(_actor(original.snapshots[4], "dog").slot == 7, "Page 4 Original: Dog finishes one step behind")
	var solution_plan := _plan(page, [3])
	solution_plan.thoughts.kid = "SLEEPY"
	solution_plan.thoughts.grandma = "HUNGRY"
	var solution := SIMULATOR.run(page, solution_plan)
	check.call(_events(solution, "SIT") == [[2, "kid", "", "armchair"]] and _events(solution, "EAT") == [[5, "dog", "", "pie"]], "Page 4 solution: Kid sits at beat 2; Dog eats at beat 5")
	check.call(not _actor(solution.snapshots[-1], "grandma").active, "Page 4 solution leaves hungry Grandma inactive")
	var fail_plan: Dictionary = solution_plan.duplicate(true)
	fail_plan.centres = [1]
	var fail := SIMULATOR.run(page, fail_plan)
	check.call(_events(fail, "EAT") == [[6, "grandma", "", "pie"]], "Page 4 fail: leaving Grandma lit lets her eat on beat 6")


func _simultaneous_resolution(check: Callable) -> void:
	var mutual_page := _page([_actor_def("left", 3, "ANGRY"), _actor_def("right", 4, "ANGRY", "L")])
	var mutual := SIMULATOR.run(mutual_page, _plan(mutual_page))
	check.call(_actor(mutual.snapshots[1], "left").status == "KO" and _actor(mutual.snapshots[1], "right").status == "KO", "Mutual bonk KOs both attackers, with KO taking precedence")
	check.call(_events(mutual, "BONK").size() == 2 and _events(mutual, "DOUBLE_KO").size() == 1, "Mutual bonk records both facts and one double-KO effect")
	var chain_page := _page([
		_actor_def("a", 2, "ANGRY"), _actor_def("b", 3, "ANGRY"), _actor_def("c", 4, "HUNGRY"),
	], [_object_def("cake", "FOOD", 4)])
	var chain := SIMULATOR.run(chain_page, _plan(chain_page))
	check.call(_events(chain, "BONK") == [[1, "a", "b", ""], [1, "b", "c", ""]], "Simultaneous bonks: struck B still hits C")
	check.call(_actor(chain.snapshots[1], "a").status == "SATISFIED" and _actor(chain.snapshots[1], "b").status == "KO" and _actor(chain.snapshots[1], "c").status == "KO", "Simultaneous status resolution preserves KO precedence")
	check.call(_object(chain.snapshots[1], "cake").present and _events(chain, "EAT").is_empty(), "Bonked hungry character cannot claim food on the same beat")
	for object_type in ["FOOD", "SEAT"]:
		var thought := "HUNGRY" if object_type == "FOOD" else "SLEEPY"
		var page := _page([_actor_def("a", 2, thought), _actor_def("b", 4, thought, "L")], [_object_def("prize", object_type, 3)])
		var clash := SIMULATOR.run(page, _plan(page))
		check.call(_events(clash, "CLASH") == [[1, "a", "", "prize"]] and _actor(clash.snapshots[1], "a").status == "KO" and _actor(clash.snapshots[1], "b").status == "KO", "%s simultaneous claims clash and KO all claimants" % object_type)
		check.call(_object(clash.snapshots[1], "prize").present and _object(clash.snapshots[1], "prize").occupant == "", "%s remains unclaimed after clash" % object_type)
	var moving_page := _page([_actor_def("bonker", 2, "ANGRY"), _actor_def("eater", 4, "HUNGRY", "L")], [_object_def("cake", "FOOD", 3)])
	var moving := SIMULATOR.run(moving_page, _plan(moving_page))
	check.call(_actor(moving.snapshots[1], "bonker").slot == 3 and _actor(moving.snapshots[1], "eater").slot == 3 and _actor(moving.snapshots[1], "eater").status == "KO", "Movement is simultaneous, non-blocking, and resolved before bonks")
	var start_switch := _page([_actor_def("walker", 3, "HUNGRY")], [_object_def("pedal", "SWITCH", 3), _object_def("cake", "FOOD", 4)])
	start_switch.lamps = [{"id": "lamp", "zone": [7, 10], "switch_id": "pedal", "initially_on": false}]
	check.call(_events(SIMULATOR.run(start_switch, _plan(start_switch)), "LAMP_ON").is_empty(), "Standing on a switch at beat 0 does not count as entering it")


func _targeting_and_light(check: Callable) -> void:
	var page := _page([_actor_def("hungry", 3, "HUNGRY", "L")], [_object_def("left", "FOOD", 2), _object_def("right", "FOOD", 4)])
	var plan := _plan(page)
	var world := RULES.initial_world(page, plan)
	check.call(RULES.decisions(world, RULES.lit_slots(page, plan, world))[0].object == "left", "Facing selects the left equidistant food")
	world.characters[0].facing = "R"
	check.call(RULES.decisions(world, RULES.lit_slots(page, plan, world))[0].object == "right", "Facing selects the right equidistant food")
	world.objects[1].present = false
	check.call(RULES.decisions(world, RULES.lit_slots(page, plan, world))[0].object == "left", "Removed food is excluded when retargeting")
	var co_located := _page([_actor_def("scared", 3, "SCARED"), _actor_def("threat", 3, "HUNGRY")])
	var fear := SIMULATOR.run(co_located, _plan(co_located))
	check.call(_actor(fear.snapshots[1], "scared").slot == 4 and _actor(fear.snapshots[1], "scared").flee_direction == 1, "Same-slot fear uses facing as the flee direction")
	check.call(_events(fear, "STARTLE").size() == 1 and _events(fear, "EXIT").size() == 1, "Fear locks its direction and keeps fleeing after the trigger recedes")
	var flanked := _page([_actor_def("left", 2, "HUNGRY"), _actor_def("scared", 3, "SCARED", "L"), _actor_def("right", 4, "SLEEPY")])
	var flanked_world := RULES.initial_world(flanked, _plan(flanked))
	check.call(RULES.decisions(flanked_world, RULES.lit_slots(flanked, _plan(flanked), flanked_world))[1].step == -1, "Equal threats on both sides make fear flee in its facing direction")
	var calm_page := _page([_actor_def("scared", 3, "SCARED")])
	var calm := SIMULATOR.run(calm_page, _plan(calm_page))
	check.call(calm.end_beat == 1 and _events(calm, "IDLE").is_empty(), "Untriggered fear is a persistent pose and settles without repeated events")
	var tie_page := _page([_actor_def("second", 4, "HUNGRY"), _actor_def("angry", 2, "ANGRY"), _actor_def("third", 4, "SLEEPY")])
	var tie_world := RULES.initial_world(tie_page, _plan(tie_page))
	check.call(tie_world.characters[0].id == "angry" and RULES.decisions(tie_world, RULES.lit_slots(tie_page, _plan(tie_page), tie_world))[0].target == "second", "Reading order starts by initial slot and uses authored order for co-location")
	tie_world.characters[1].status = "ASLEEP"
	check.call(RULES.decisions(tie_world, RULES.lit_slots(tie_page, _plan(tie_page), tie_world))[0].target == "third", "Sleeping characters cannot be bonk or fear targets")
	var dark_page := _page([_actor_def("lit", 2, "HUNGRY"), _actor_def("dark", 7, "ANGRY")], [_object_def("cake", "FOOD", 4)], [])
	var dark_plan := _plan(dark_page, [2])
	var dark_world := RULES.initial_world(dark_page, dark_plan)
	var dark_decisions := RULES.decisions(dark_world, RULES.lit_slots(dark_page, dark_plan, dark_world))
	check.call(dark_decisions.size() == 1 and dark_decisions[0].type == "IDLE", "Dark actors never decide; dark food cannot be targeted")
	dark_world.characters[1].active = true
	dark_world.characters[0].thought = "ANGRY"
	check.call(RULES.decisions(dark_world, RULES.lit_slots(dark_page, dark_plan, dark_world))[0].target == "dark", "Active characters remain visible outside lit zones")
	check.call(not RULES.is_lit(dark_page, dark_plan, dark_world, 4), "An active character's glow does not illuminate objects")
	dark_plan.centres = [0, 10, 10]
	check.call(RULES.lit_slots(dark_page, dark_plan, dark_world) == [0, 1, 9, 10], "Spotlights clip to panel edges and overlapping zones are unique")


func _isolation_and_bounds(check: Callable) -> void:
	var page := PAGE.definition()
	var plan := _plan(page, [5])
	var page_before: Dictionary = page.duplicate(true)
	var plan_before: Dictionary = plan.duplicate(true)
	var first := SIMULATOR.run(page, plan)
	var again := SIMULATOR.run(page, plan)
	check.call(JSON.stringify(first) == JSON.stringify(again), "Identical plans produce byte-identical canonical results")
	check.call(page == page_before and plan == plan_before, "Simulation does not mutate input page or plan")
	first.snapshots[0].characters[2].slot = 99
	first.snapshots[0].lamps[0].zone[0] = 0
	first.plan.thoughts.boss = "SLEEPY"
	check.call(_actor(first.snapshots[1], "boss").slot == 5 and first.snapshots[1].lamps[0].zone == [6, 10], "Snapshots own nested state independently of prior snapshots")
	check.call(page == page_before and plan == plan_before and JSON.stringify(again) == JSON.stringify(SIMULATOR.run(page, plan)), "Mutating a result cannot corrupt inputs or later runs")
	var guard_page := _page([_actor_def("walker", 0, "HUNGRY")], [_object_def("cake", "FOOD", 99)], [[0, 99]])
	# Deliberately oversized synthetic stage exercises the hard safety guard.
	guard_page.width = 100
	var guarded := SIMULATOR.run(guard_page, _plan(guard_page))
	check.call(guarded.capped and guarded.end_beat == 40 and guarded.snapshots.size() == 41, "Safety guard caps even a synthetic long run at 40 beats")


func _presentation_capture(check: Callable) -> void:
	var page := PAGE.definition()
	var plan := _plan(page, [3])
	plan.thoughts.boss = "SCARED"
	plan.thoughts.grandma = "HUNGRY"
	var plain := SIMULATOR.run(page, plan)
	var captured := SIMULATOR.run(page, plan, true)
	var frames: Array = captured.presentation_frames
	var legacy: Dictionary = captured.duplicate(true)
	legacy.erase("presentation_frames")
	check.call(not plain.has("presentation_frames") and JSON.stringify(plain) == JSON.stringify(legacy), "Presentation capture preserves default schema and byte-identical simulation results")
	check.call(JSON.stringify(captured) == JSON.stringify(SIMULATOR.run(page, plan, true)), "Presentation phase capture is deterministic")
	check.call(frames.size() == captured.end_beat * 5, "Capture includes all five phases, including the settling beat")
	var order_valid := true
	var ends_match := true
	var phases := ["DECIDE", "MOVE", "SWITCHES", "BONKS", "CLAIMS"]
	for index in range(frames.size()):
		var frame: Dictionary = frames[index]
		var beat := int(index / 5) + 1
		order_valid = order_valid and frame.beat == beat and frame.world.beat == beat and frame.phase == phases[index % 5]
		if frame.phase == "CLAIMS":
			ends_match = ends_match and frame.world == captured.snapshots[beat]
	check.call(order_valid, "Presentation frames retain authoritative beat and phase order")
	check.call(ends_match, "Final phase world matches each existing end-of-beat snapshot")
	# Beat 3 moves Boss onto the pedal; light and activation belong to SWITCHES.
	var before_switch: Dictionary = frames[11].world
	var after_switch: Dictionary = frames[12].world
	check.call(not before_switch.lamps[0].on and not _actor(before_switch, "dog").active and after_switch.lamps[0].on and _actor(after_switch, "dog").active, "Phase worlds prevent lamp activation leaking into movement presentation")
	check.call(_actor(before_switch, "boss").slot == 7 and _actor(after_switch, "dog").slot == 9, "Phase capture preserves movement and newly activated actor timing")
	var collision_page := _page([_actor_def("bonker", 2, "ANGRY"), _actor_def("eater", 4, "HUNGRY", "L")], [_object_def("cake", "FOOD", 3)])
	var collision := SIMULATOR.run(collision_page, _plan(collision_page), true)
	check.call(_actor(collision.presentation_frames[1].world, "eater").status == "READY" and _actor(collision.presentation_frames[3].world, "eater").status == "KO" and _object(collision.presentation_frames[4].world, "cake").present, "Bonk presentation resolves after movement and before claims")
	var eater_page := _page([_actor_def("eater", 2, "HUNGRY")], [_object_def("cake", "FOOD", 3)])
	var eating := SIMULATOR.run(eater_page, _plan(eater_page), true)
	check.call(_object(eating.presentation_frames[3].world, "cake").present and not _object(eating.presentation_frames[4].world, "cake").present and _actor(eating.presentation_frames[4].world, "eater").status == "FULL", "Food consumption first appears in the claims phase")
	var later_before: Dictionary = frames[1].world.duplicate(true)
	frames[0].world.characters[0].slot = 99
	frames[0].world.lamps[0].zone[0] = 99
	check.call(frames[1].world == later_before and captured.snapshots[1] == plain.snapshots[1] and captured.snapshots[0] == plain.snapshots[0], "Phase frames own nested state independently of other frames and beat snapshots")
	check.call(JSON.stringify(SIMULATOR.run(page, plan)) == JSON.stringify(plain), "Mutating phase frames cannot corrupt input data or subsequent simulations")


func _plan(page: Dictionary, centres: Array = []) -> Dictionary:
	var thoughts := {}
	for actor in page.characters:
		thoughts[actor.id] = actor.thought
	return {"centres": centres.duplicate(), "thoughts": thoughts}


func _page(characters: Array, objects: Array = [], fixed_lights: Array = [[0, 10]]) -> Dictionary:
	return {"width": 11, "characters": characters, "objects": objects, "lamps": [], "fixed_lights": fixed_lights}


func _actor_def(id: String, slot: int, thought: String, facing: String = "R") -> Dictionary:
	return {"id": id, "art": id, "slot": slot, "thought": thought, "facing": facing, "contradiction": false}


func _object_def(id: String, type: String, slot: int) -> Dictionary:
	return {"id": id, "art": id, "type": type, "slot": slot}


func _events(result: Dictionary, type: String) -> Array:
	var matches := []
	for event in result.events:
		if event.type == type:
			matches.append([event.beat, event.actor, event.target, event.object])
	return matches


func _slots(result: Dictionary, ids: Array) -> Array:
	var beats := []
	for snapshot in result.snapshots:
		var slots := []
		for id in ids:
			slots.append(_actor(snapshot, id).slot)
		beats.append(slots)
	return beats


func _actor(world: Dictionary, id: String) -> Dictionary:
	for actor in world.characters:
		if actor.id == id:
			return actor
	return {}


func _object(world: Dictionary, id: String) -> Dictionary:
	for object in world.objects:
		if object.id == id:
			return object
	return {}
