extends RefCounted
## The eight-page campaign: valid data, full art, failing Originals.

const MAIN = preload("res://game/main.gd")
const VALIDATOR = preload("res://core/page_validator.gd")
const PLAN = preload("res://core/plan_state.gd")
const SIM = preload("res://core/simulator.gd")
const GOALS = preload("res://core/goal_evaluator.gd")


func run(check: Callable) -> bool:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/stage_manifest.json"))
	check.call(MAIN.CAMPAIGN.size() == 8, "Campaign has eight pages")
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
	return true
