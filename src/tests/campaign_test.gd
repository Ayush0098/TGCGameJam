extends RefCounted
## The campaign: valid data, full art, failing Originals, and every star reachable.

const MAIN = preload("res://game/main.gd")
const VALIDATOR = preload("res://core/page_validator.gd")
const PLAN = preload("res://core/plan_state.gd")
const SIM = preload("res://core/simulator.gd")
const GOALS = preload("res://core/goal_evaluator.gd")
const AUDIT = preload("res://tools/campaign_audit.gd")


func run(check: Callable) -> bool:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/stage_manifest.json"))
	check.call(MAIN.CAMPAIGN.size() == 3, "Review build has pages 1-3 of the IIIT-H story")
	for script in MAIN.CAMPAIGN:
		var result: Dictionary = VALIDATOR.new().validate(script.definition())
		check.call(result.errors.is_empty(), "%s validates %s" % [script.resource_path.get_file(), str(result.errors)])
		if not result.errors.is_empty():
			continue
		var page: Dictionary = result.page
		var art: bool = page.characters.all(func(c): return manifest.characters.has(c.art)) and page.objects.all(func(o): return manifest.props.has(o.art))
		check.call(art, "%s has art for every cast member and prop" % page.id)
		var original: Dictionary = SIM.run(page, PLAN.from_page(page).to_data())
		check.call(not GOALS.evaluate(page, original).won, "%s Original does not already satisfy its twist" % page.id)
		if page.has("ladder"):
			check.call(_best_level(page) == 1 + page.ladder.size(), "%s: every star on its ladder can be earned" % page.id)
	var lines: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/voice/lines.json"))
	var missing: Array = []
	for key in lines.narrator:
		if key in lines.get("pending_recordings", []):
			continue
		if not ResourceLoader.exists("res://assets/audio/voice/narrator/%s.mp3" % key):
			missing.append(key)
	for art in lines.characters:
		for moment in lines.characters[art]:
			if not ResourceLoader.exists("res://assets/audio/voice/characters/%s_%s.mp3" % [art, moment]):
				missing.append(art + "_" + moment)
		for n in range(1, 5):
			if not ResourceLoader.exists("res://assets/audio/voice/characters/%s_blip_%d.mp3" % [art, n]):
				missing.append("%s_blip_%d" % [art, n])
	check.call(missing.is_empty(), "Every scripted voice line and babble syllable has its audio file %s" % str(missing))
	return true



## Highest star level any plan reaches (twist, then each ladder step on top).
func _best_level(page: Dictionary) -> int:
	var audit = AUDIT.new()
	var base := {}
	for c in page.characters:
		base[c.id] = c.thought
	var ids: Array = base.keys()
	var best := 0
	var seen := {}
	for values in audit._perms(ids.map(func(id): return base[id])):
		var thoughts := {}
		for k in ids.size():
			thoughts[ids[k]] = values[k]
		if seen.has(str(thoughts)):
			continue
		seen[str(thoughts)] = true
		for lanterns in audit._lantern_sets(page):
			var run: Dictionary = SIM.run(page, {"centres": [], "lanterns": lanterns, "thoughts": thoughts})
			if not GOALS.evaluate(page, run).won:
				continue
			var level := 1
			var facts: Array = page.goal.facts.duplicate(true)
			for step in page.ladder:
				facts = facts + step.facts
				var challenge := page.duplicate()
				challenge.goal = {"facts": facts, "twist_caption": ""}
				if not GOALS.evaluate(challenge, run).won:
					break
				level += 1
			best = maxi(best, level)
	return best
