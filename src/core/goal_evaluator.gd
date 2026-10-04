extends RefCounted
const LIGHTING = preload("res://core/lighting.gd")
## Goal truth and short event-derived captions only. No simulation or PNR analysis.


static func evaluate(page: Dictionary, run: Dictionary) -> Dictionary:
	var goal: Dictionary = page.get("goal", {})
	var requested: Array = goal.get("facts", [])
	var snapshots: Array = run.get("snapshots", [])
	var world: Dictionary = snapshots.back() if not snapshots.is_empty() else {}
	var events: Array = run.get("events", [])
	var results: Array[Dictionary] = []
	var won := not requested.is_empty()
	run_plan = run.get("plan", {})
	for fact in requested:
		var met := _met(page, world, events, fact)
		results.append({"fact": fact.duplicate(true), "met": met})
		won = won and met
	var caption := _caption(page, events)
	if not world.is_empty():
		for actor in world.get("characters", []):
			if _hiding(page, run_plan, world, actor):
				var hidden := "%s hid in the dark." % _character_name(actor.id, true)
				caption = hidden if caption.begins_with("Nobody") else caption + " " + hidden
	return {"won": won, "facts": results, "caption": caption}


static var run_plan: Dictionary = {}


## SHY, woken, still standing, and in the dark at the end.
static func _hiding(page: Dictionary, plan: Dictionary, world: Dictionary, actor: Dictionary) -> bool:
	if actor.is_empty() or actor.get("thought") != "SHY" or actor.get("active") != true:
		return false
	if actor.get("status") in ["KO", "ASLEEP", "EXITED"]:
		return false
	return not LIGHTING.is_lit(page, plan, world, int(actor.slot))


static func _met(page: Dictionary, world: Dictionary, events: Array, fact: Dictionary) -> bool:
	var actor := _find(page.get("characters", []), fact.get("character"))
	var prop := _find(page.get("objects", []), fact.get("object"))
	var final_actor := _find(world.get("characters", []), fact.get("character"))
	match fact.get("type"):
		"ATE":
			return not actor.is_empty() and prop.get("type") == "FOOD" and _event_matches(
				events, "EAT", fact.character, "object", fact.object
			)
		"ASLEEP":
			if actor.is_empty() or final_actor.get("status") != "ASLEEP":
				return false
			if not fact.has("object"):
				return true
			var final_seat := _find(world.get("objects", []), fact.object)
			return prop.get("type") == "SEAT" and final_seat.get("occupant") == fact.character
		"BONKED":
			var target := _find(page.get("characters", []), fact.get("target"))
			return not actor.is_empty() and not target.is_empty() and _event_matches(
				events, "BONK", fact.character, "target", fact.target
			)
		"CLONK":
			# KO'd in a clash over the same food or seat.
			for event in events:
				if event.get("type") == "CLASH" and str(fact.get("character")) in event.get("actors", []):
					return true
			return false
		"KO", "EXITED":
			return not actor.is_empty() and final_actor.get("status") == fact.type
		"UNEATEN":
			var final_food := _find(world.get("objects", []), fact.get("object"))
			return prop.get("type") == "FOOD" and final_food.get("present") == true
		"HUGGED":
			return not actor.is_empty() and _event_matches(events, "HUG", fact.character, "target", str(fact.get("target", "")))
		"HIDING":
			return not actor.is_empty() and _hiding(page, run_plan, world, final_actor)
		"ALL_ACTIVATED":
			var cast: Array = page.get("characters", [])
			if cast.is_empty():
				return false
			for character in cast:
				var final_character := _find(world.get("characters", []), character.id)
				if final_character.get("active") != true:
					return false
			return true
	return false


static func _event_matches(events: Array, type: String, actor: String, key: String, value: String) -> bool:
	for event in events:
		if event.get("type") == type and event.get("actor") == actor and event.get(key) == value:
			return true
	return false


static func _find(records: Array, id: Variant) -> Dictionary:
	if not id is String or id.is_empty():
		return {}
	for record in records:
		if record.get("id") == id:
			return record
	return {}


static func _caption(page: Dictionary, events: Array) -> String:
	var sentences: Array[String] = []
	for event in events:
		var sentence := _event_caption(page, event)
		if not sentence.is_empty() and sentence not in sentences:
			sentences.append(sentence)
			if sentences.size() > 2:
				sentences.pop_front()
	return " ".join(sentences) if not sentences.is_empty() else "Nobody did anything. Riveting."


static func _event_caption(page: Dictionary, event: Dictionary) -> String:
	var actor := _find(page.get("characters", []), event.get("actor"))
	var prop := _find(page.get("objects", []), event.get("object"))
	if event.get("type") == "CLASH":
		if prop.get("type") in ["FOOD", "SEAT"]:
			return "They fought over the %s. CLONK!" % _object_name(prop.id)
		return ""
	if actor.is_empty():
		return ""
	var name := _character_name(actor.id, true)
	match event.get("type"):
		"EAT":
			if prop.get("type") == "FOOD":
				return "%s ate the %s." % [name, _object_name(prop.id)]
		"SIT":
			if prop.get("type") == "SEAT":
				return "%s fell asleep." % name
		"BONK":
			var target := _find(page.get("characters", []), event.get("target"))
			if not target.is_empty():
				return "%s bonked %s." % [name, _character_name(target.id)]
		"EXIT":
			return "%s ran out of the comic." % name
		"HUG":
			var hugged := _find(page.get("characters", []), event.get("target"))
			if not hugged.is_empty():
				return "%s hugged %s." % [name, _character_name(hugged.id)]
	return ""


## Display names for the current page (set by the game on page load).
static var names: Dictionary = {}
static var object_names: Dictionary = {}
## Names that read with "the" in front: the Saap, the Prof, the Cat.
const WITH_ARTICLE := ["Saap", "Kassi", "Prof", "Faccha", "Cat", "Dog", "Kid", "Boss", "Intern", "Mouse"]


static func set_page(page: Dictionary) -> void:
	names.clear()
	object_names.clear()
	for character in page.get("characters", []):
		if character.has("name"):
			names[str(character.id)] = str(character.name)
	for object in page.get("objects", []):
		if object.has("name"):
			object_names[str(object.id)] = str(object.name)


static func _character_name(id: String, subject := false) -> String:
	if names.has(id):
		var name: String = names[id]
		if name in WITH_ARTICLE:
			return ("The " if subject else "the ") + name
		return name
	if id == "grandma":
		return "Grandma"
	return ("The " if subject else "the ") + id.capitalize()


static func _object_name(id: String) -> String:
	if object_names.has(id):
		return str(object_names[id])
	return id.replace("_", " ").to_lower()


## Player-facing wording for one goal fact (goal card and result checklist).
static func fact_text(fact: Dictionary) -> String:
	var who := _character_name(str(fact.get("character", "")), true)
	var what := _object_name(str(fact.get("object", "")))
	match fact.get("type"):
		"ATE":
			return "%s eats the %s" % [who, what]
		"ASLEEP":
			return ("%s naps in the %s" % [who, what]) if fact.has("object") else "%s falls asleep" % who
		"BONKED":
			return "%s bonks %s" % [who, _character_name(str(fact.get("target", "")))]
		"KO":
			return "%s gets knocked out" % who
		"EXITED":
			return "%s runs out of the comic" % who
		"UNEATEN":
			return "Nobody eats the %s" % what
		"ALL_ACTIVATED":
			return "Everyone gets a bright idea"
		"CLONK":
			return "%s gets clonked in a food fight" % who
		"HUGGED":
			return "%s hugs %s" % [who, _character_name(str(fact.get("target", "")))]
		"HIDING":
			return "%s hides in the dark" % who
	return str(fact.get("type", ""))
