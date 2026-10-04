extends SceneTree
## Prints every no-flick plan class of one campaign page with its caption and
## event log, for diffing against the level thread's Python solver.
##   Godot --headless --path src --script res://tools/dump_plans.gd -- page_09

const MAIN = preload("res://game/main.gd")
const VALIDATOR = preload("res://core/page_validator.gd")
const RULES = preload("res://core/rules.gd")
const SIM = preload("res://core/simulator.gd")
const GOALS = preload("res://core/goal_evaluator.gd")
const AUDIT = preload("res://tools/campaign_audit.gd")


func _initialize() -> void:
	var wanted := Array(OS.get_cmdline_user_args())
	for script in MAIN.CAMPAIGN:
		var page: Dictionary = VALIDATOR.new().validate(script.definition()).page
		if page.is_empty() or page.id not in wanted:
			continue
		var audit = AUDIT.new()
		var base := {}
		for c in page.characters:
			base[c.id] = c.thought
		var configs := {}
		for ls in audit._lantern_sets(page):
			var plan := {"centres": [], "lanterns": ls, "thoughts": base}
			var world: Dictionary = RULES.initial_world(page, plan)
			var key := str(RULES.lit_slots(page, plan, world))
			if not configs.has(key):
				configs[key] = ls
		var ids: Array = base.keys()
		ids.sort()
		var arrangements := audit._perms(ids.map(func(id): return base[id]))
		var seen := {}
		for values in arrangements:
			var thoughts := {}
			for k in ids.size():
				thoughts[ids[k]] = values[k]
			if seen.has(str(thoughts)):
				continue
			seen[str(thoughts)] = true
			for key in configs:
				var plan := {"centres": [], "lanterns": configs[key], "thoughts": thoughts}
				var run: Dictionary = SIM.run(page, plan)
				var events: Array[String] = []
				for event in run.events:
					if event.type in ["MOVE", "IDLE", "STEP_SWITCH"]:
						continue
					events.append("%d %s %s %s" % [event.beat, event.type, event.actor, event.get("object", event.get("target", ""))])
				var lantern: Dictionary = configs[key][0]
				print("thoughts=%s lit_slots=%s lantern=%s" % [str(thoughts), key, "(%.2f, %.2f)" % [lantern.x, lantern.y] if lantern.enabled else "(None,)"])
				print("  caption: " + GOALS.evaluate(page, run).caption)
				print("  events: " + " | ".join(events))
	quit()
