extends RefCounted

const PAGE = preload("res://data/pages/page_06.gd")
const VALIDATOR = preload("res://core/page_validator.gd")


func run(check: Callable) -> bool:
	var validator = VALIDATOR.new()
	var page := PAGE.definition()
	var result: Dictionary = validator.validate(page)
	check.call(result.errors.is_empty(), "Canonical page 6 passes content validation: %s" % result.errors)
	check.call(page.width == 11 and page.rail_span == [0, 10], "Page 6 uses slots 0-10 and full-width rail")
	check.call(page.spotlights == {"count": 1, "default_centres": [5]}, "Page 6 default spotlight is centre 5")
	var cast := []
	for actor in page.characters:
		cast.append([actor.id, actor.slot, actor.facing, actor.thought])
	check.call(cast == [
		["intern", 1, "R", "ANGRY"], ["grandma", 2, "R", "SCARED"],
		["boss", 4, "R", "HUNGRY"], ["dog", 9, "L", "HUNGRY"],
	], "Page 6 cast matches the hand-traced Appendix B layout")
	check.call(page.lamps[0].zone == [6, 10] and page.lamps[0].switch_id == "pedal", "Page 6 pedal lights slots 6-10")
	check.call(page.objects[0].slot == 0 and page.objects[1].slot == 6 and page.objects[2].slot == 7, "Page 6 chair/cake/pedal occupy reference slots")
	check.call(page.goal.facts == [{"type": "ATE", "character": "dog", "object": "cake"}], "Page 6 asks Dog to eat Cake")
	check.call(page.characters[0].contradiction and page.characters[1].contradiction, "Intern and Grandma carry the approved contradiction reveals")

	result.page.characters[0].thought = "SLEEPY"
	result.page.lamps[0].zone[0] = 0
	check.call(page.characters[0].thought == "ANGRY" and page.lamps[0].zone == [6, 10], "Validated nested data does not alias input")
	page.characters[1].slot = 3
	check.call(PAGE.definition().characters[1].slot == 2, "Page factory returns independent definitions")

	# Each mutation must fail with a useful field path and no playable output.
	var cases := [
		[["width"], 0, "width"],
		[["width"], 11.0, "width"],
		[["rail_span"], [4, 2], "rail_span"],
		[["rail_span"], [0, 11], "rail_span"],
		[["rail_span"], "all", "rail_span"],
		[["spotlights", "count"], 4, "spotlights.count"],
		[["spotlights", "default_centres"], [5, 6], "spotlights.default_centres"],
		[["spotlights", "default_centres"], [11], "spotlights.default_centres"],
		[["spotlights", "default_centres"], [5.0], "spotlights.default_centres"],
		[["characters", 0, "id"], "dog", "characters[3].id"],
		[["objects", 0, "id"], "intern", "objects[0].id"],
		[["characters", 0, "thought"], "HAPPY", "characters[0].thought"],
		[["characters", 0, "facing"], "UP", "characters[0].facing"],
		[["characters", 0, "slot"], -1, "characters[0].slot"],
		[["characters", 0, "contradiction"], "false", "characters[0].contradiction"],
		[["characters"], [], "characters"],
		[["characters"], [null], "characters[0]"],
		[["objects", 0, "slot"], 6, "objects[1].slot"],
		[["objects", 1, "type"], "GIFT", "objects[1].type"],
		[["lamps", 0, "switch_id"], "missing", "lamps[0].switch_id"],
		[["lamps", 0, "switch_id"], "cake", "lamps[0].switch_id"],
		[["lamps", 0, "zone"], [6, 99], "lamps[0].zone"],
		[["lamps", 0, "initially_on"], true, "lamps[0].initially_on"],
		[["lamps"], [], "objects.pedal"],
		[["goal", "facts", 0, "character"], "missing", "goal.facts[0].character"],
		[["goal", "facts", 0, "object"], "office_chair", "goal.facts[0].object"],
		[["goal", "facts", 0, "type"], "WIN", "goal.facts[0].type"],
		[["goal", "facts"], [], "goal.facts"],
		[["goal", "facts"], [{"type": "ALL_ACTIVATED"}], "goal.facts[0].type"],
		[["goal", "red_pen_words"], [], "goal.red_pen_words"],
		[["goal"], null, "goal"],
		[["fixed_lights"], [[2, 1]], "fixed_lights[0]"],
	]
	for case in cases:
		var broken := PAGE.definition()
		_set_path(broken, case[0], case[1])
		var rejected: Dictionary = validator.validate(broken)
		check.call(
			not rejected.errors.is_empty() and rejected.page.is_empty() and _mentions(rejected.errors, "page_06." + case[2]),
			"Reject %s=%s with field diagnostic and no playable page" % [case[0], str(case[1])]
		)
	for malformed in [null, [], "page", {}, {"id": "broken"}]:
		var rejected: Dictionary = validator.validate(malformed)
		check.call(not rejected.errors.is_empty() and rejected.page.is_empty(), "Malformed top-level content rejected: %s" % str(malformed))

	# Exercise the whole closed goal vocabulary, including ASLEEP without a seat.
	for fact in [
		{"type": "ASLEEP", "character": "boss"},
		{"type": "ASLEEP", "character": "boss", "object": "office_chair"},
		{"type": "BONKED", "character": "intern", "target": "dog"},
		{"type": "KO", "character": "dog"},
		{"type": "EXITED", "character": "boss"},
		{"type": "UNEATEN", "object": "cake"},
	]:
		var variant := PAGE.definition()
		variant.goal.facts = [fact]
		check.call(validator.validate(variant).errors.is_empty(), "Accept structurally valid %s fact (not a claim of solvability)" % fact.type)
	var finale := PAGE.definition()
	finale.id = "page_08"
	finale.goal.facts = [{"type": "ALL_ACTIVATED"}]
	check.call(validator.validate(finale).errors.is_empty(), "ALL_ACTIVATED accepted for finale ID")
	var boundaries := PAGE.definition()
	boundaries.spotlights = {"count": 3, "default_centres": [0, 10, 10]}
	boundaries.fixed_lights = [[0, 0], [0, 10]]
	boundaries.characters[0].slot = 0
	boundaries.characters[1].slot = 0
	check.call(validator.validate(boundaries).errors.is_empty(), "Allow edge/overlapping bulbs, overlapping zones and shared character/object slots")
	boundaries.spotlights = {"count": 1, "default_centres": []}
	check.call(validator.validate(boundaries).errors.is_empty(), "Allow unused spotlight budget")
	boundaries.spotlights.count = 0
	check.call(validator.validate(boundaries).errors.is_empty(), "Allow zero-spotlight pages")
	var missing := PAGE.definition()
	missing.characters[0].erase("thought")
	missing.lamps[0].erase("initially_on")
	var missing_result: Dictionary = validator.validate(missing)
	check.call(_mentions(missing_result.errors, "characters[0].thought") and _mentions(missing_result.errors, "lamps[0].initially_on"), "Missing required rule fields produce diagnostics")
	var bad_bonk := PAGE.definition()
	bad_bonk.goal.facts = [{"type": "BONKED", "character": "intern", "target": "intern"}]
	check.call(not validator.validate(bad_bonk).errors.is_empty(), "Reject goal requiring self-bonk")
	var bad_seat := PAGE.definition()
	bad_seat.goal.facts = [{"type": "ASLEEP", "character": "boss", "object": "cake"}]
	check.call(not validator.validate(bad_seat).errors.is_empty(), "Reject ASLEEP goal pointing to food")
	var typo_seat := PAGE.definition()
	typo_seat.goal.facts = [{"type": "ASLEEP", "character": "boss", "seat": "office_chair"}]
	var typo_result: Dictionary = validator.validate(typo_seat)
	check.call(typo_result.page.is_empty() and _mentions(typo_result.errors, "goal.facts[0].seat"), "Reject misspelled optional goal argument rather than weakening the goal")
	var duplicate_switch := PAGE.definition()
	duplicate_switch.lamps.append({"id": "second_lamp", "zone": [0, 1], "switch_id": "pedal", "initially_on": false})
	check.call(not validator.validate(duplicate_switch).errors.is_empty(), "Reject one switch wired to two lamps")
	check.call(validator.validate(PAGE.definition()).errors.is_empty(), "Reusing validator clears prior errors")
	return true


func _set_path(page: Dictionary, path: Array, value: Variant) -> void:
	var current: Variant = page
	for i in range(path.size() - 1):
		current = current[path[i]]
	current[path[-1]] = value


func _mentions(errors: PackedStringArray, fragment: String) -> bool:
	for error in errors:
		if fragment in error:
			return true
	return false
