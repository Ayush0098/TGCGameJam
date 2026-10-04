extends SceneTree
## Solution-space audit for every campaign page, using the real rules, lighting,
## goal evaluator and FLICK. Run from the repository root:
##   Godot --headless --path src --script res://tools/campaign_audit.gd
## Lanterns sample a 0.2-unit grid inside page bounds (respecting lanterns.count);
## swaps reach any arrangement inside groups of actors that can be lit together;
## flicks try beats 1..8 on every centre slot. Plan classes are deduplicated by
## the lit actors and lit slots they produce.

const MAIN = preload("res://game/main.gd")
const VALIDATOR = preload("res://core/page_validator.gd")
const RULES = preload("res://core/rules.gd")
const SIM = preload("res://core/simulator.gd")
const GOALS = preload("res://core/goal_evaluator.gd")
const FLICK_BEATS := 8


func _initialize() -> void:
	var only := Array(OS.get_cmdline_user_args()).filter(func(arg): return arg != "dump")
	for script in MAIN.CAMPAIGN:
		var checked: Dictionary = VALIDATOR.new().validate(script.definition())
		if not checked.errors.is_empty():
			print("== INVALID ", script.resource_path, " ", checked.errors)
			continue
		var page: Dictionary = checked.page
		if not only.is_empty() and page.id not in only:
			continue
		_audit(page)
	quit()


func _positions(page: Dictionary) -> Array:
	var b: Array = page.lanterns.bounds
	var out := []
	var x: float = b[0]
	while x <= b[2] + 0.001:
		var y: float = b[1]
		while y <= b[3] + 0.001:
			out.append(Vector2(snappedf(x, 0.01), snappedf(y, 0.01)))
			y += 0.2
		x += 0.2
	return out


func _lantern_sets(page: Dictionary) -> Array:
	var pos := _positions(page)
	var count := int(page.lanterns.get("count", 2))
	var parked := {"x": 0.0, "y": -0.6, "enabled": false}
	var sets := [[parked, parked]]
	for i in pos.size():
		var first := {"x": pos[i].x, "y": pos[i].y, "enabled": true}
		sets.append([first, parked])
		if count >= 2:
			for j in range(i, pos.size()):
				sets.append([first, {"x": pos[j].x, "y": pos[j].y, "enabled": true}])
	return sets


func _perms(arr: Array) -> Array:
	if arr.size() <= 1:
		return [arr.duplicate()]
	var out := []
	for i in arr.size():
		var rest := arr.duplicate()
		var head = rest.pop_at(i)
		for p in _perms(rest):
			out.append([head] + p)
	return out


func _find(parent: Dictionary, id: String) -> String:
	while parent[id] != id:
		id = parent[id]
	return id


func _audit(page: Dictionary) -> void:
	var start := Time.get_ticks_msec()
	var base := {}
	for c in page.characters:
		base[c.id] = c.thought
	var configs := {}
	for ls in _lantern_sets(page):
		var plan := {"centres": [], "lanterns": ls, "thoughts": base}
		var world: Dictionary = RULES.initial_world(page, plan)
		var lit := []
		for a in world.characters:
			if a.active:
				lit.append(a.id)
		lit.sort()
		var key := str(lit) + "|" + str(RULES.lit_slots(page, plan, world))
		if not configs.has(key):
			configs[key] = {"lanterns": ls, "lit": lit}
	var parent := {}
	for id in base:
		parent[id] = id
	for key in configs:
		var lit: Array = configs[key].lit
		for k in range(1, lit.size()):
			parent[_find(parent, lit[k])] = _find(parent, lit[0])
	var groups := {}
	for id in base:
		groups.get_or_add(_find(parent, id), []).append(id)
	var arrangements := [base.duplicate()]
	for root in groups:
		var members: Array = groups[root]
		if members.size() < 2:
			continue
		var next := []
		for a in arrangements:
			var values := []
			for m in members:
				values.append(a[m])
			var seen := {}
			for p in _perms(values):
				if seen.has(str(p)):
					continue
				seen[str(p)] = true
				var b: Dictionary = a.duplicate()
				for k in members.size():
					b[members[k]] = p[k]
				next.append(b)
		arrangements = next
	var flicks := [{}]
	if int(page.get("flick", 0)) > 0:
		for beat in range(1, FLICK_BEATS + 1):
			for centre in range(int(page.width)):
				flicks.append({"beat": beat, "centre": centre})
	var plans := 0
	var wins := 0
	var plain_wins := 0
	var win_arrangements := {}
	var endings := {}
	var bonus_hits := {}
	# Ideas per star (master_plan §3.1): thought arrangement + who is lit at
	# ACTION + who the FLICK wakes. Exact positions/beats are not new ideas.
	var star_ideas := {"twist": {}}
	var nothing := 0
	var original_won: bool = GOALS.evaluate(page, SIM.run(page, {"centres": [], "lanterns": page.lanterns.defaults, "thoughts": base})).won
	for key in configs:
		for a in arrangements:
			for flick in flicks:
				var plan := {"centres": [], "lanterns": configs[key].lanterns, "thoughts": a}
				if not flick.is_empty():
					plan.flick = flick
				plans += 1
				var run: Dictionary = SIM.run(page, plan)
				var result: Dictionary = GOALS.evaluate(page, run)
				endings[result.caption] = endings.get(result.caption, 0) + 1
				if result.caption.begins_with("Nobody"):
					nothing += 1
				var woken := []
				for event in run.events:
					if event.type == "DING" and event.get("lamp", "") == "flick":
						woken.append(event.actor)
				woken.sort()
				var idea := str(a) + "|" + str(configs[key].lit) + "|" + str(woken)
				if result.won:
					star_ideas.twist[idea] = true
				if result.won:
					wins += 1
					win_arrangements[str(a)] = true
					if flick.is_empty():
						plain_wins += 1
				for bonus in page.get("bonus", []):
					var challenge: Dictionary = page.duplicate()
					challenge.goal = {"facts": bonus.facts, "twist_caption": bonus.caption}
					if GOALS.evaluate(challenge, run).won:
						bonus_hits[bonus.id] = bonus_hits.get(bonus.id, 0) + 1
						star_ideas.get_or_add(bonus.id, {})[idea] = true
	print("== %s %s: %d lit configs x %d arrangements x %d flick options = %d plans; wins %d (%.1f%%), wins without flick %d, winning arrangements %d; endings %d (endings_total %s); nothing %d; original wins: %s; %d ms" % [
		page.id, page.title, configs.size(), arrangements.size(), flicks.size(), plans, wins, 100.0 * wins / maxf(1, plans), plain_wins, win_arrangements.size(), endings.size(), str(page.get("endings_total", "-")), nothing, str(original_won), Time.get_ticks_msec() - start])
	print("   twist: %d ideas" % star_ideas.twist.size())
	if "dump" in OS.get_cmdline_user_args():
		var captions := endings.keys()
		captions.sort()
		for caption in captions:
			print("   ENDING x%d: %s" % [endings[caption], caption])
	for bonus in page.get("bonus", []):
		print("   bonus %s: %d plans, %d ideas" % [bonus.id, bonus_hits.get(bonus.id, 0), star_ideas.get(bonus.id, {}).size()])
