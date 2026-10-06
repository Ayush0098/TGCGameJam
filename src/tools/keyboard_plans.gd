extends SceneTree
## Finds, for every campaign page, a plan that earns every star using only
## positions the keyboard can reach, and writes them as JSON for keyboard_qa.gd.
##   Godot --headless --path src --script res://tools/keyboard_plans.gd -- <out.json> [page_04 ...]

const MAIN = preload("res://game/main.gd")
const VALIDATOR = preload("res://core/page_validator.gd")
const RULES = preload("res://core/rules.gd")
const SIM = preload("res://core/simulator.gd")
const GOALS = preload("res://core/goal_evaluator.gd")
const AUDIT = preload("res://tools/campaign_audit.gd")
const REACH = preload("res://tools/keyboard_reach.gd")
const TIME_BUDGET_MSEC := 90000


func _initialize() -> void:
	var args := Array(OS.get_cmdline_user_args())
	var out_path: String = args.pop_front()
	var audit = AUDIT.new()
	var reach = REACH.new()
	var plans := {}
	for script in MAIN.CAMPAIGN:
		var page: Dictionary = VALIDATOR.new().validate(script.definition()).page
		if page.is_empty() or (not args.is_empty() and page.id not in args):
			continue
		plans[page.id] = _best(audit, reach, page)
		print("%s: %s" % [page.id, JSON.stringify(plans[page.id])])
	var file := FileAccess.open(out_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(plans, "  "))
	file.close()
	quit()


func _level(audit, page: Dictionary, run: Dictionary) -> int:
	if not GOALS.evaluate(page, run).won:
		return 0
	var level := 1
	for step in audit.star_steps(page):
		var challenge: Dictionary = page.duplicate()
		challenge.goal = {"facts": step.facts, "twist_caption": step.caption}
		if GOALS.evaluate(challenge, run).won:
			level += 1
	return level


func _lit(page: Dictionary, lanterns: Array, base: Dictionary) -> Array:
	var world: Dictionary = RULES.initial_world(page, {"centres": [], "lanterns": lanterns, "thoughts": base})
	var ids := []
	for actor in world.characters:
		if actor.active:
			ids.append(actor.id)
	return ids


## Swaps are only allowed between lit characters, so each swap may need its own lighting:
## a list of {lanterns, swap: [a, b]} to do, in order, before settling on the final lanterns.
## Breadth-first over swaps between characters that some lantern set lights together.
func _route(page: Dictionary, sets: Array, lits: Array, base: Dictionary, target: Dictionary, final: Array) -> Variant:
	var final_lit := _lit(page, final, base)
	var ids: Array = base.keys()
	ids.sort()
	var pairs := []
	for i in ids.size():
		for j in range(i + 1, ids.size()):
			var chosen: Variant = null
			if ids[i] in final_lit and ids[j] in final_lit:
				chosen = final
			else:
				for index in sets.size():
					if ids[i] in lits[index] and ids[j] in lits[index]:
						chosen = sets[index]
						break
			if chosen != null:
				pairs.append({"a": ids[i], "b": ids[j], "lanterns": chosen})
	var key_of := func(state: Dictionary) -> String:
		return ",".join(ids.map(func(id): return state[id]))
	var goal: String = key_of.call(target)
	var start: String = key_of.call(base)
	if start == goal:
		return []
	var parents := {start: ""}
	var states := {start: base.duplicate()}
	var how := {}
	var frontier := [start]
	for depth in 7:
		var next := []
		for key in frontier:
			for pair in pairs:
				var state: Dictionary = states[key].duplicate()
				var held: String = state[pair.a]
				state[pair.a] = state[pair.b]
				state[pair.b] = held
				var next_key: String = key_of.call(state)
				if parents.has(next_key):
					continue
				parents[next_key] = key
				states[next_key] = state
				how[next_key] = pair
				if next_key == goal:
					var route := []
					var walk: String = next_key
					while walk != start:
						var step: Dictionary = how[walk]
						route.push_front({"lanterns": step.lanterns, "swap": [step.a, step.b]})
						walk = parents[walk]
					return route
				next.append(next_key)
		frontier = next
	return null


func _best(audit, reach, page: Dictionary) -> Dictionary:
	var started := Time.get_ticks_msec()
	var parked := {"x": 0.0, "y": -0.6, "enabled": false}
	var reps: Array = reach._classes(page, reach._keyboard_grid(page))
	var count := int(page.lanterns.get("count", 2))
	var sets := [[parked, parked]]
	for i in reps.size():
		var first := {"x": reps[i].x, "y": reps[i].y, "enabled": true}
		sets.append([first, parked])
		if count >= 2:
			for j in range(i, reps.size()):
				sets.append([first, {"x": reps[j].x, "y": reps[j].y, "enabled": true}])
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
	var total: int = 1 + audit.star_steps(page).size()
	var lits := sets.map(func(set): return _lit(page, set, base))
	var best := {"stars": 0, "total": total}
	for flick in flicks:
		for lanterns in sets:
			for thoughts in arrangements:
				var plan := {"centres": [], "lanterns": lanterns, "thoughts": thoughts}
				if not flick.is_empty():
					plan.flick = flick
				var level := _level(audit, page, SIM.run(page, plan))
				if level > int(best.stars):
					var route: Variant = _route(page, sets, lits, base, thoughts, lanterns)
					if route == null:
						continue
					best = {"stars": level, "total": total, "lanterns": lanterns, "thoughts": thoughts, "flick": flick, "route": route}
					if level >= total:
						return best
		if Time.get_ticks_msec() - started > TIME_BUDGET_MSEC:
			best["timed_out"] = true
			return best
	return best
