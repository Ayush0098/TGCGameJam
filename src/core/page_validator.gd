extends RefCounted
## Content validation only; no simulation or gameplay knowledge is evaluated here.
## Successful results own a deep copy. Invalid results expose no playable page.

const THOUGHTS = ["HUNGRY", "SLEEPY", "ANGRY", "SCARED"]
const OBJECT_TYPES = ["FOOD", "SEAT", "SWITCH"]
const FACT_TYPES = ["ATE", "ASLEEP", "BONKED", "KO", "EXITED", "UNEATEN", "ALL_ACTIVATED", "CLONK"]

var _errors := PackedStringArray()
var _page_id := "<unknown>"
var _finale := false
var _width := 0
var _ids: Dictionary = {}


func validate(content: Variant) -> Dictionary:
	_errors = PackedStringArray()
	_ids = {}
	_page_id = "<unknown>"
	_width = 0
	if not content is Dictionary:
		_error("page", content, "expected a dictionary")
		return _result({})
	var page: Dictionary = content
	_finale = page.get("finale", false) == true
	if _field(page, "id", TYPE_STRING, "id"):
		_page_id = page.id
	for field in ["title", "original_caption"]:
		_field(page, field, TYPE_STRING, field)
	if _field(page, "width", TYPE_INT, "width"):
		_width = page.width
		if _width < 7 or _width > 12:
			_error("width", _width, "expected 7 to 12 slots")
	if page.has("lanterns"):
		_validate_lanterns(page.lanterns)
	# Dual-format content keeps its legacy data validated for old reference traces.
	if not page.has("lanterns") or page.has("spotlights") or page.has("rail_span"):
		var rail_valid := _zone(page.get("rail_span"), "rail_span")
		_validate_spotlights(page.get("spotlights"), page.get("rail_span"), rail_valid)
	if page.has("obstacles"):
		_validate_obstacles(page)
	if _field(page, "fixed_lights", TYPE_ARRAY, "fixed_lights"):
		for i in page.fixed_lights.size():
			_zone(page.fixed_lights[i], "fixed_lights[%d]" % i)

	var characters := _records(page, "characters")
	var objects := _records(page, "objects")
	var lamps := _records(page, "lamps")
	var cast: Dictionary = {}
	var props: Dictionary = {}
	var object_slots: Dictionary = {}
	if characters.is_empty():
		_error("characters", characters, "expected at least one character")
	for i in characters.size():
		var actor: Dictionary = characters[i]
		var path := "characters[%d]" % i
		_register(actor, path, cast)
		_slot(actor, path)
		_field(actor, "art", TYPE_STRING, path + ".art")
		_field(actor, "contradiction", TYPE_BOOL, path + ".contradiction")
		_choice(actor, "facing", ["L", "R"], path)
		_choice(actor, "thought", THOUGHTS, path)
	for i in objects.size():
		var object: Dictionary = objects[i]
		var path := "objects[%d]" % i
		_register(object, path, props)
		_slot(object, path)
		_field(object, "art", TYPE_STRING, path + ".art")
		_choice(object, "type", OBJECT_TYPES, path)
		if typeof(object.get("slot")) == TYPE_INT:
			if object_slots.has(object.slot):
				_error(path + ".slot", object.slot, "at most one object per slot")
			object_slots[object.slot] = true

	var switches: Dictionary = {}
	var lamp_ids: Dictionary = {}
	for i in lamps.size():
		var lamp: Dictionary = lamps[i]
		var path := "lamps[%d]" % i
		_register(lamp, path, lamp_ids)
		_zone(lamp.get("zone"), path + ".zone")
		if _field(lamp, "initially_on", TYPE_BOOL, path + ".initially_on") and lamp.initially_on:
			_error(path + ".initially_on", true, "switch lamps must start off")
		if _field(lamp, "switch_id", TYPE_STRING, path + ".switch_id"):
			_reference(props, lamp.switch_id, "SWITCH", path + ".switch_id")
			if switches.has(lamp.switch_id):
				_error(path + ".switch_id", lamp.switch_id, "switch already wired to another lamp")
			switches[lamp.switch_id] = true
	for id in props:
		if props[id].get("type") == "SWITCH" and not switches.has(id):
			_error("objects." + id, id, "switch has no lamp")
	_validate_goal(page.get("goal"), cast, props)
	# Optional bonus challenges reuse the goal-fact vocabulary (stars).
	if page.has("bonus"):
		if not page.bonus is Array or page.bonus.size() > 2:
			_error("bonus", page.bonus, "expected up to 2 bonus challenges")
		else:
			for bonus in page.bonus:
				if not bonus is Dictionary or not bonus.get("id") is String or not bonus.get("caption") is String:
					_error("bonus", bonus, "expected {id, caption, facts}")
					continue
				_validate_goal({"twist_caption": bonus.caption, "red_pen_words": ["BONUS"], "facts": bonus.get("facts")}, cast, props)
	if page.has("hints") and (not page.hints is Array or page.hints.size() > 3 or not page.hints.all(func(hint): return hint is String)):
		_error("hints", page.hints, "expected up to 3 hint strings")
	if page.has("flick") and (not page.flick is int or page.flick < 0 or page.flick > 1):
		_error("flick", page.flick, "expected 0 or 1 spare bulbs")
	if page.has("endings_total") and (not page.endings_total is int or page.endings_total < 1):
		_error("endings_total", page.endings_total, "expected a positive count")
	return _result(page)


func _validate_spotlights(value: Variant, rail: Variant, rail_valid: bool) -> void:
	if not value is Dictionary:
		_error("spotlights", value, "expected a dictionary")
		return
	var count_valid := _field(value, "count", TYPE_INT, "spotlights.count")
	if count_valid and (value.count < 0 or value.count > 3):
		_error("spotlights.count", value.count, "expected 0 to 3")
	if not _field(value, "default_centres", TYPE_ARRAY, "spotlights.default_centres"):
		return
	if count_valid and value.default_centres.size() > value.count:
		_error("spotlights.default_centres", value.default_centres, "placed bulbs exceed spotlight budget")
	for centre in value.default_centres:
		if typeof(centre) != TYPE_INT:
			_error("spotlights.default_centres", centre, "expected integer centre")
		elif rail_valid and (centre < rail[0] or centre > rail[1]):
			_error("spotlights.default_centres", centre, "centre outside rail span")


func _validate_lanterns(value: Variant) -> void:
	if not value is Dictionary:
		_error("lanterns", value, "expected a dictionary")
		return
	if not _finite_number(value.get("radius")) or value.get("radius", 0.0) <= 0.0 or value.get("radius", 0.0) > 20.0:
		_error("lanterns.radius", value.get("radius"), "expected finite radius greater than 0 and at most 20")
	var bounds: Variant = value.get("bounds")
	var bounds_valid: bool = bounds is Array and bounds.size() == 4
	if bounds_valid:
		for coordinate in bounds:
			bounds_valid = bounds_valid and _finite_number(coordinate)
	if bounds_valid:
		bounds_valid = Vector2(bounds[0], bounds[1]).is_finite() and Vector2(bounds[2], bounds[3]).is_finite()
	if bounds_valid:
		bounds_valid = bounds[0] >= 0.0 and bounds[2] <= _width - 1 and bounds[0] < bounds[2] and bounds[1] < bounds[3]
	if not bounds_valid:
		_error("lanterns.bounds", bounds, "expected finite nonempty [min_x,min_y,max_x,max_y] bounds inside stage x")
	if value.has("count") and (not value.count is int or value.count < 1 or value.count > 2):
		_error("lanterns.count", value.count, "expected 1 or 2 usable lanterns")
	var defaults: Variant = value.get("defaults")
	if not defaults is Array or defaults.size() != 2:
		_error("lanterns.defaults", defaults, "expected exactly two lantern records")
		return
	for index in defaults.size():
		var lantern: Variant = defaults[index]
		var path := "lanterns.defaults[%d]" % index
		if not lantern is Dictionary:
			_error(path, lantern, "expected a dictionary")
			continue
		_field(lantern, "enabled", TYPE_BOOL, path + ".enabled")
		var position_valid := _finite_number(lantern.get("x")) and _finite_number(lantern.get("y"))
		if position_valid:
			position_valid = Vector2(lantern.x, lantern.y).is_finite()
		if not position_valid:
			_error(path, lantern, "expected finite numeric x and y")
		elif bounds_valid and (lantern.x < bounds[0] or lantern.x > bounds[2] or lantern.y < bounds[1] or lantern.y > bounds[3]):
			_error(path, lantern, "position outside lantern bounds")


func _validate_obstacles(page: Dictionary) -> void:
	if not _field(page, "obstacles", TYPE_ARRAY, "obstacles"):
		return
	var ids := {}
	for index in page.obstacles.size():
		var path := "obstacles[%d]" % index
		if not page.obstacles[index] is Dictionary:
			_error(path, page.obstacles[index], "expected a dictionary")
			continue
		var obstacle: Dictionary = page.obstacles[index]
		_register(obstacle, path, ids)
		var endpoints_valid := true
		for endpoint in ["from", "to"]:
			var value: Variant = obstacle.get(endpoint)
			var valid: bool = value is Array and value.size() == 2
			if valid:
				valid = _finite_number(value[0]) and _finite_number(value[1])
			if valid:
				valid = Vector2(value[0], value[1]).is_finite()
			if valid:
				valid = value[0] >= 0.0 and value[0] <= _width - 1
			if not valid:
				_error(path + "." + endpoint, value, "expected finite [x,y] endpoint inside stage x")
			endpoints_valid = endpoints_valid and valid
		if endpoints_valid and Vector2(obstacle.from[0], obstacle.from[1]).is_equal_approx(Vector2(obstacle.to[0], obstacle.to[1])):
			_error(path, obstacle, "obstacle segment must have nonzero length")


func _finite_number(value: Variant) -> bool:
	return (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT) and is_finite(float(value))


func _validate_goal(value: Variant, cast: Dictionary, props: Dictionary) -> void:
	if not value is Dictionary:
		_error("goal", value, "expected a dictionary")
		return
	_field(value, "twist_caption", TYPE_STRING, "goal.twist_caption")
	if _field(value, "red_pen_words", TYPE_ARRAY, "goal.red_pen_words"):
		if value.red_pen_words.is_empty():
			_error("goal.red_pen_words", value.red_pen_words, "expected red-pen markup")
		for word in value.red_pen_words:
			if not word is String or word.strip_edges().is_empty():
				_error("goal.red_pen_words", word, "expected nonempty text")
	var facts := _records(value, "facts", "goal.")
	if facts.size() < 1 or facts.size() > 2:
		_error("goal.facts", facts, "expected 1 or 2 facts")
	for i in facts.size():
		var fact: Dictionary = facts[i]
		var path := "goal.facts[%d]" % i
		if not _choice(fact, "type", FACT_TYPES, path):
			continue
		var type: String = fact.type
		var allowed_keys := ["type"]
		if type in ["ATE", "ASLEEP", "BONKED", "KO", "EXITED", "CLONK"]:
			allowed_keys.append("character")
		if type == "BONKED":
			allowed_keys.append("target")
		if type in ["ATE", "UNEATEN", "ASLEEP"]:
			allowed_keys.append("object")
		for key in fact:
			if key not in allowed_keys:
				_error(path + "." + str(key), fact[key], "unknown argument for %s" % type)
		if type in ["ATE", "ASLEEP", "BONKED", "KO", "EXITED", "CLONK"]:
			if _field(fact, "character", TYPE_STRING, path + ".character"):
				_reference(cast, fact.character, "", path + ".character")
		if type == "BONKED":
			if _field(fact, "target", TYPE_STRING, path + ".target"):
				_reference(cast, fact.target, "", path + ".target")
				if fact.target == fact.get("character"):
					_error(path + ".target", fact.target, "cannot bonk self")
		if type in ["ATE", "UNEATEN"] or (type == "ASLEEP" and fact.has("object")):
			if _field(fact, "object", TYPE_STRING, path + ".object"):
				_reference(props, fact.object, "SEAT" if type == "ASLEEP" else "FOOD", path + ".object")
		if type == "ALL_ACTIVATED" and _page_id != "page_08" and not _finale:
			_error(path + ".type", type, "finale-only fact")


func _records(parent: Dictionary, key: String, prefix := "") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not _field(parent, key, TYPE_ARRAY, prefix + key):
		return result
	for i in parent[key].size():
		var record: Variant = parent[key][i]
		if record is Dictionary:
			result.append(record)
		else:
			_error("%s%s[%d]" % [prefix, key, i], record, "expected a dictionary")
	return result


func _field(record: Dictionary, key: String, expected: int, path: String) -> bool:
	var value: Variant = record.get(key)
	if typeof(value) != expected:
		_error(path, value, "expected %s" % type_string(expected))
		return false
	if expected == TYPE_STRING and value.strip_edges().is_empty():
		_error(path, value, "expected nonempty text")
		return false
	return true


func _choice(record: Dictionary, key: String, choices: Array, path: String) -> bool:
	if not _field(record, key, TYPE_STRING, path + "." + key):
		return false
	if record[key] not in choices:
		_error(path + "." + key, record[key], "expected one of %s" % [choices])
		return false
	return true


func _zone(value: Variant, path: String) -> bool:
	if not value is Array or value.size() != 2:
		_error(path, value, "expected inclusive [first, last] slots")
		return false
	if typeof(value[0]) != TYPE_INT or typeof(value[1]) != TYPE_INT:
		_error(path, value, "zone endpoints must be integers")
		return false
	if value[0] < 0 or value[1] >= _width or value[0] > value[1]:
		_error(path, value, "zone outside stage or reversed")
		return false
	return true


func _slot(record: Dictionary, path: String) -> void:
	if _field(record, "slot", TYPE_INT, path + ".slot"):
		if record.slot < 0 or record.slot >= _width:
			_error(path + ".slot", record.slot, "slot outside stage")


func _register(record: Dictionary, path: String, group: Dictionary) -> void:
	if _field(record, "id", TYPE_STRING, path + ".id"):
		if _ids.has(record.id):
			_error(path + ".id", record.id, "duplicate entity ID")
		_ids[record.id] = true
		group[record.id] = record


func _reference(group: Dictionary, id: String, type: String, path: String) -> void:
	if not group.has(id):
		_error(path, id, "unknown reference")
	elif not type.is_empty() and group[id].get("type") != type:
		_error(path, id, "expected %s reference" % type)


func _error(path: String, value: Variant, reason: String) -> void:
	_errors.append("%s.%s: %s (value=%s)" % [_page_id, path, reason, str(value)])


func _result(page: Dictionary) -> Dictionary:
	return {"page": page.duplicate(true) if _errors.is_empty() else {}, "errors": _errors.duplicate()}
