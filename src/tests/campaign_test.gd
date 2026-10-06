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
	check.call(MAIN.CAMPAIGN.size() == 15, "The campaign has all fifteen pages of the IIIT-H story")
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
			if not _voice_exists("res://assets/audio/voice/characters/%s_%s" % [art, moment]):
				missing.append(art + "_" + moment)
		for n in range(1, 5):
			if not _voice_exists("res://assets/audio/voice/characters/%s_blip_%d" % [art, n]):
				missing.append("%s_blip_%d" % [art, n])
	check.call(missing.is_empty(), "Every scripted voice line and babble syllable has its audio file %s" % str(missing))
	return true



## Highest star level any plan class reaches (twist, then each ladder step on top).
func _best_level(page: Dictionary) -> int:
	var audit = AUDIT.new()
	var space: Dictionary = audit.plan_space(page)
	var steps: Array = AUDIT.star_steps(page)
	var best := 0
	for key in space.configs:
		for thoughts in space.arrangements:
			for flick in space.flicks:
				var plan := {"centres": [], "lanterns": space.configs[key].lanterns, "thoughts": thoughts}
				if not flick.is_empty():
					plan.flick = flick
				var run: Dictionary = SIM.run(page, plan)
				if not GOALS.evaluate(page, run).won:
					continue
				var level := 1
				for step in steps:
					var challenge := page.duplicate()
					challenge.goal = {"facts": step.facts, "twist_caption": ""}
					if not GOALS.evaluate(challenge, run).won:
						break
					level += 1
				best = maxi(best, level)
				if best == 1 + steps.size():
					audit.free()
					return best
	audit.free()
	return best


func _voice_exists(base: String) -> bool:
	for extension in [".ogg", ".mp3", ".wav"]:
		if ResourceLoader.exists(base + extension):
			return true
	return false
