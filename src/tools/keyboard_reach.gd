extends SceneTree
## Keyboard reachability audit: can every star (twist + bonus/ladder steps) still be
## earned when the bulb can only stand on the keyboard grid? One press moves the
## bulb 0.5 sideways / 0.2 up-down, Shift halves both (see stage_view.KEY_STEP_*).
## The reference is the audit's 0.2 grid used by the level solver.
##   Godot --headless --path src --script res://tools/keyboard_reach.gd [-- page_04 ...]

const MAIN = preload("res://game/main.gd")
const VALIDATOR = preload("res://core/page_validator.gd")
const RULES = preload("res://core/rules.gd")
const SIM = preload("res://core/simulator.gd")
const GOALS = preload("res://core/goal_evaluator.gd")
const AUDIT = preload("res://tools/campaign_audit.gd")
const STAGE = preload("res://presentation/stage_view.gd")


func _initialize() -> void:
	var only := Array(OS.get_cmdline_user_args())
	var audit = AUDIT.new()
	var failures := 0
	for script in MAIN.CAMPAIGN:
		var page: Dictionary = VALIDATOR.new().validate(script.definition()).page
		if page.is_empty() or (not only.is_empty() and page.id not in only):
			continue
		var full := _stars(audit, page, _grid(page, 0.2, 0.2))
		var keys := _stars(audit, page, _keyboard_grid(page))
		var missing: Array = []
		for id in full:
			if not keys.has(id):
				missing.append(id)
		failures += 1 if not missing.is_empty() else 0
		print("%s %s: solver stars %s, keyboard stars %s%s" % [page.id, page.title, str(full.keys()), str(keys.keys()), "   <-- NOT REACHABLE BY KEYBOARD: " + str(missing) if not missing.is_empty() else ""])
	print("KEYBOARD REACH: %d page(s) with stars out of keyboard reach" % failures)
	quit()


func _range(low: float, high: float, step: float) -> Array:
	var out := []
	var value := ceilf(low / step - 0.0001) * step
	if low < value - 0.0001:
		out.append(low)
	while value <= high + 0.001:
		out.append(snappedf(value, 0.01))
		value += step
	if absf(float(out.back()) - high) > 0.001:
		out.append(high)
	return out


func _grid(page: Dictionary, step_x: float, step_y: float) -> Array:
	var b: Array = page.lanterns.bounds
	var out := []
	for x in _range(b[0], b[2], step_x):
		for y in _range(b[1], b[3], step_y):
			out.append(Vector2(x, y))
	return out


func _keyboard_grid(page: Dictionary) -> Array:
	return _grid(page, STAGE.KEY_STEP_X * 0.5, STAGE.KEY_STEP_Y * 0.5)


## Distinct single-bulb lighting signatures (who is lit where), one position each.
func _classes(page: Dictionary, positions: Array) -> Array:
	var parked := {"x": 0.0, "y": -0.6, "enabled": false}
	var seen := {}
	var reps := []
	for position in positions:
		var plan := {"centres": [], "lanterns": [{"x": position.x, "y": position.y, "enabled": true}, parked], "thoughts": {}}
		var world: Dictionary = RULES.initial_world(page, plan)
		var key := str(RULES.lit_slots(page, plan, world))
		if not seen.has(key):
			seen[key] = true
			reps.append(position)
	return reps


func _stars(audit, page: Dictionary, positions: Array) -> Dictionary:
	var parked := {"x": 0.0, "y": -0.6, "enabled": false}
	var reps := _classes(page, positions)
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
	var steps: Array = audit.star_steps(page)
	var found := {}
	for lanterns in sets:
		for thoughts in arrangements:
			for flick in flicks:
				var plan := {"centres": [], "lanterns": lanterns, "thoughts": thoughts}
				if not flick.is_empty():
					plan.flick = flick
				var run: Dictionary = SIM.run(page, plan)
				if not GOALS.evaluate(page, run).won:
					continue
				found["twist"] = true
				for step in steps:
					var challenge: Dictionary = page.duplicate()
					challenge.goal = {"facts": step.facts, "twist_caption": step.caption}
					if GOALS.evaluate(challenge, run).won:
						found[step.id] = true
	return found
