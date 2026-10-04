extends RefCounted

const LIGHTING = preload("res://core/lighting.gd")
const PLAN = preload("res://core/plan_state.gd")
const RULES = preload("res://core/rules.gd")
const VALIDATOR = preload("res://core/page_validator.gd")
const PAGE = preload("res://data/pages/page_06.gd")
const SIMULATOR = preload("res://core/simulator.gd")


func run(check: Callable) -> bool:
	var page := _page()
	var state = PLAN.from_page(page)
	var plan: Dictionary = state.to_data()
	var world := {"lamps": []}
	check.call(LIGHTING.radius(page) == 1.6, "Lantern gameplay radius comes from authored data")
	check.call(LIGHTING.is_lit(page, plan, world, 3.0), "Enabled lantern reveals its own sample")
	check.call(LIGHTING.is_lit(page, plan, world, 4.6), "Exact reveal radius boundary is inclusive")
	check.call(not LIGHTING.is_lit(page, plan, world, 4.6001), "Outside reveal boundary remains dark")
	check.call(LIGHTING.intensity(page, plan, world, Vector2(4.8, 0)) > 0.0 and not LIGHTING.is_lit(page, plan, world, 4.8), "Decorative dim halo never activates characters")
	check.call(is_zero_approx(LIGHTING.intensity(page, plan, world, Vector2(5.0, 0))), "Visual light fades completely at outer halo")
	check.call(LIGHTING.intensity(page, plan, world, Vector2(3.5, 0)) > LIGHTING.intensity(page, plan, world, Vector2(4, 0)), "Brightness decreases with radial distance")
	check.call(not LIGHTING.is_lit(page, plan, world, 9.0), "Disabled second lantern has no coverage")
	plan.lanterns[0].y = 1.0
	check.call(LIGHTING.is_lit(page, plan, world, 4.0) and not LIGHTING.is_lit(page, plan, world, 4.5), "Vertical displacement affects true radial coverage")
	plan.lanterns[0].y = 0.0
	plan.lanterns[1] = plan.lanterns[0].duplicate(true)
	var overlapping := LIGHTING.intensity(page, plan, world, Vector2(4, 0))
	plan.lanterns[1].enabled = false
	check.call(is_equal_approx(overlapping, LIGHTING.intensity(page, plan, world, Vector2(4, 0))), "Overlapping lanterns use max brightness without expanding reveal radius")
	page.obstacles = [{"id": "screen", "from": [3.5, -1.0], "to": [3.5, 1.0]}]
	check.call(not LIGHTING.is_lit(page, plan, world, 4.0) and is_zero_approx(LIGHTING.intensity(page, plan, world, Vector2(4, 0))), "Obstacle blocks reveal and visual intensity behind it")
	check.call(LIGHTING.is_lit(page, plan, world, 3.0), "Source and sample coincidence is safe")
	check.call(LIGHTING.is_lit(page, plan, world, 2.0), "Obstacle does not shadow its source side")
	page.obstacles[0].from = [3.5, 0.0]
	check.call(not LIGHTING.is_lit(page, plan, world, 4.0), "Beam tangent to obstacle endpoint is blocked")
	page.obstacles[0].to = [4.2, 0.0]
	check.call(not LIGHTING.is_lit(page, plan, world, 4.0), "Collinear obstacle overlap is blocked")
	page.obstacles[0] = {"id": "screen", "from": [5.5, 0.0], "to": [6.0, 0.0]}
	check.call(LIGHTING.is_lit(page, plan, world, 4.0), "Collinear obstacle beyond sample does not block")
	page.fixed_lights = [[8, 8]]
	check.call(LIGHTING.intensity(page, plan, world, Vector2(8.2, 0)) == 1.0, "Single-slot fixed light renders its cell even between raster samples")
	check.call(not LIGHTING.is_lit(page, plan, world, 9), "Visual fixture cell width does not illuminate the neighbouring gameplay slot")
	world.lamps = [{"on": true, "zone": [6, 7]}]
	check.call(LIGHTING.is_lit(page, plan, world, 8) and LIGHTING.is_lit(page, plan, world, 6), "Fixed and activated lamps retain inclusive authored zones")
	world.lamps[0].on = false
	check.call(not LIGHTING.is_lit(page, plan, world, 6), "Untriggered lamp contributes no coverage")
	page.fixed_lights = []
	check.call(RULES.lit_slots(page, plan, world) == [2, 3, 4], "Rules use shared lantern coverage for deterministic integer samples")
	var original := _page()
	var initial := RULES.initial_world(original, PLAN.from_page(original).to_data())
	check.call(initial.characters[1].active and initial.characters[2].active and not initial.characters[0].active, "Initial activation uses radius geometry while preserving cast order")
	_state_checks(check)
	_validation_checks(check)
	_activation_checks(check)
	return true


func _activation_checks(check: Callable) -> void:
	var page := _page()
	page.characters = [
		{"id": "traveller", "art": "intern", "slot": 2, "facing": "R", "thought": "HUNGRY", "contradiction": false},
		{"id": "halo_actor", "art": "boss", "slot": 0, "facing": "R", "thought": "HUNGRY", "contradiction": false},
	]
	page.objects = [{"id": "snack", "art": "cake", "slot": 6, "type": "FOOD"}]
	page.lamps = []
	page.lanterns.defaults = [{"x": 1.7, "y": 0.0, "enabled": true}, {"x": 6.0, "y": 0.0, "enabled": true}]
	page.erase("bonus")
	page.goal.facts = [{"type": "ATE", "character": "traveller", "object": "snack"}]
	var plan: Dictionary = PLAN.from_page(page).to_data()
	var run: Dictionary = SIMULATOR.run(page, plan)
	check.call(VALIDATOR.new().validate(page).errors.is_empty(), "Persistent-activation fixture uses valid new lantern-only content")
	check.call(LIGHTING.intensity(page, plan, run.snapshots[0], Vector2.ZERO) > 0.0 and not run.snapshots[0].characters[0].active, "Actual run does not awaken an actor inside the decorative halo")
	check.call(run.snapshots[2].characters[1].slot == 4 and run.snapshots[2].characters[1].active and not LIGHTING.is_lit(page, plan, run.snapshots[2], 4), "Actor stays activated while moving through an unlit gap between lanterns")
	var ate := false
	var halo_awakened := false
	for event in run.events:
		ate = ate or (event.type == "EAT" and event.get("actor") == "traveller" and event.get("object") == "snack")
		if event.type == "DING" and event.get("actor") == "halo_actor":
			halo_awakened = true
	check.call(ate and not halo_awakened and not run.snapshots[-1].characters[0].active, "Persistent idea reaches illuminated food without the halo actor awakening")


func _state_checks(check: Callable) -> void:
	var page := _page()
	var state = PLAN.from_page(page)
	var saved: Dictionary = state.to_data()
	check.call(state.move_lantern(page, 0, Vector2(4.25, -0.7)), "Lantern accepts fractional in-bounds placement")
	check.call(page.lanterns.defaults[0].x == 3.0 and saved.lanterns[0].x == 3.0, "Lantern edits alias neither page defaults nor saved plans")
	var before: Dictionary = state.to_data()
	for position in [Vector2(-0.01, 0), Vector2(10.01, 0), Vector2(0, -2.01), Vector2(0, 1.01), Vector2(INF, 0), Vector2(NAN, 0)]:
		check.call(not state.move_lantern(page, 0, position) and state.to_data() == before, "Reject out-of-bounds/nonfinite lantern without mutation: %s" % position)
	check.call(not state.move_lantern(page, -1, Vector2.ZERO) and not state.move_lantern(page, 2, Vector2.ZERO), "Lantern indices cannot remove/add or exceed two-light budget")
	check.call(state.move_lantern(page, 1, Vector2(10, 1), false), "Disabled lantern accepts exact placement bounds")
	state.restore(saved)
	saved.lanterns[0].x = 0.0
	check.call(state.lanterns[0].x == 3.0, "Restored lanterns do not alias saved nested records")
	state.restore({"centres": [3], "thoughts": state.thoughts})
	check.call(state.lanterns.is_empty(), "Legacy saved plans restore without requiring lantern data")
	var dual := _page()
	dual.rail_span = [0, 10]
	dual.spotlights = {"count": 1, "default_centres": [3]}
	state = PLAN.from_page(dual)
	check.call(state.place(dual, 0, 4) and state.lanterns[0] == {"x": 4.0, "y": -0.6, "enabled": true}, "Legacy centre movement synchronizes dual-format lantern position")
	check.call(state.place(dual, 0, -1) and not state.lanterns[0].enabled and not state.lanterns[1].enabled, "Legacy tray removal disables matching dual-format lanterns")
	var legacy := _page()
	legacy.erase("lanterns")
	legacy.rail_span = [0, 10]
	legacy.spotlights = {"count": 1, "default_centres": [3]}
	var legacy_state = PLAN.from_page(legacy)
	check.call(RULES.lit_slots(legacy, legacy_state.to_data(), {"lamps": []}) == [2, 3, 4], "Legacy pages retain their three-slot spotlight rules")


func _validation_checks(check: Callable) -> void:
	var validator = VALIDATOR.new()
	var page := _page()
	check.call(validator.validate(page).errors.is_empty(), "Lantern-only page validates without legacy rail/spotlight fields")
	var cases := [
		[{"radius": 0.0}, "radius"], [{"radius": INF}, "radius"], [{"radius": NAN}, "radius"], [{"radius": "wide"}, "radius"], [{"radius": 21.0}, "radius"],
		[{"bounds": [0, 0, 0, 1]}, "bounds"], [{"bounds": [0, 0, 10, 0]}, "bounds"], [{"bounds": [-1, -2, 10, 1]}, "bounds"], [{"bounds": [0, -2, 11, 1]}, "bounds"], [{"bounds": [0, -2, INF, 1]}, "bounds"], [{"bounds": [0, 1]}, "bounds"],
		[{"bounds": [0, -1e100, 10, 1e100]}, "bounds"],
		[{"defaults": []}, "defaults"], [{"defaults": [null, null]}, "defaults"], [{"defaults": [{"x": 3, "y": 0, "enabled": true}]}, "defaults"],
		[{"defaults": [{"x": INF, "y": 0, "enabled": true}, {"x": 9, "y": 0, "enabled": false}]}, "defaults"],
		[{"defaults": [{"x": 3, "y": 0, "enabled": "yes"}, {"x": 9, "y": 0, "enabled": false}]}, "defaults"],
		[{"defaults": [{"x": 3, "y": -3, "enabled": true}, {"x": 9, "y": 0, "enabled": false}]}, "defaults"],
	]
	for case in cases:
		var broken := _page()
		broken.lanterns.merge(case[0], true)
		var rejected: Dictionary = validator.validate(broken)
		check.call(not rejected.errors.is_empty() and rejected.page.is_empty(), "Reject malformed lantern %s without playable page" % case[1])
	for obstacle in [null, {}, {"id": "screen", "from": [2, 0], "to": [2, 0]}, {"id": "screen", "from": [2, NAN], "to": [3, 1]}, {"id": "screen", "from": [2, 0], "to": [11, 1]}, {"id": "screen", "from": [2, 0], "to": [3, 1e100]}]:
		var broken := _page()
		broken.obstacles = [obstacle]
		check.call(not validator.validate(broken).errors.is_empty(), "Reject malformed obstacle: %s" % str(obstacle))
	page.obstacles = [{"id": "screen", "from": [2, -1], "to": [2, 1]}]
	check.call(validator.validate(page).errors.is_empty(), "Finite nondegenerate obstacle within stage validates")
	page.obstacles.append(page.obstacles[0].duplicate(true))
	check.call(not validator.validate(page).errors.is_empty(), "Duplicate obstacle IDs rejected")
	page.obstacles = [{"id": "boss", "from": [2, -1], "to": [2, 1]}]
	check.call(not validator.validate(page).errors.is_empty(), "Obstacle IDs cannot collide with character IDs")
	page = _page()
	var validated: Dictionary = validator.validate(page)
	validated.page.lanterns.defaults[0].x = 0.0
	check.call(page.lanterns.defaults[0].x == 3.0, "Validated lantern records are independent deep copies")


func _page() -> Dictionary:
	var page := PAGE.definition()
	page.erase("spotlights")
	page.erase("rail_span")
	page.fixed_lights = []
	page.lanterns = {
		"radius": 1.6, "bounds": [0.0, -2.0, 10.0, 1.0],
		"defaults": [{"x": 3.0, "y": 0.0, "enabled": true}, {"x": 9.0, "y": 0.0, "enabled": false}],
	}
	return page
