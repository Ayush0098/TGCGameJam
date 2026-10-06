extends SceneTree
## Prints page 4's simplest three-star plan (used by the page 15 reveal replay).
const SIM = preload("res://core/simulator.gd")
const GOALS = preload("res://core/goal_evaluator.gd")
const AUDIT = preload("res://tools/campaign_audit.gd")
const VALIDATOR = preload("res://core/page_validator.gd")


func _init() -> void:
	var page: Dictionary = VALIDATOR.new().validate(preload("res://data/campaign/page_04.gd").definition()).page
	var audit = AUDIT.new()
	var base := {}
	for c in page.characters:
		base[c.id] = c.thought
	var ids: Array = base.keys()
	for values in audit._perms(ids.map(func(id): return base[id])):
		var thoughts := {}
		for k in ids.size():
			thoughts[ids[k]] = values[k]
		for lanterns in audit._lantern_sets(page):
			var run: Dictionary = SIM.run(page, {"centres": [], "lanterns": lanterns, "thoughts": thoughts})
			var facts: Array = page.goal.facts.duplicate(true)
			for step in page.ladder:
				facts = facts + step.facts
			var challenge := page.duplicate()
			challenge.goal = {"facts": facts, "twist_caption": ""}
			if GOALS.evaluate(challenge, run).won:
				print(JSON.stringify({"thoughts": thoughts, "lanterns": lanterns}))
				quit()
				return
	print("NONE")
	quit()
