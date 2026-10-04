extends RefCounted
## Shared integer-slot rules for simulation and PLAN previews.
## Worlds are owned copies; decisions never mutate them.

const LIGHTING = preload("res://core/lighting.gd")
const FLICK_ID := "flick"


static func initial_world(page: Dictionary, plan: Dictionary) -> Dictionary:
	var world := {"beat": 0, "width": int(page.width), "characters": [], "objects": [], "lamps": []}
	# Sorting by initial slot preserves authored order for co-located actors.
	for slot in range(page.width):
		for authored in page.characters:
			if authored.slot != slot:
				continue
			var actor: Dictionary = authored.duplicate(true)
			actor.thought = plan.thoughts.get(actor.id, actor.thought)
			actor.active = false
			actor.status = "READY"
			actor.flee_direction = 0
			actor.idle_reason = ""
			world.characters.append(actor)
		for authored in page.objects:
			if authored.slot != slot:
				continue
			var object: Dictionary = authored.duplicate(true)
			object.present = true
			object.occupant = ""
			object.eater = ""
			world.objects.append(object)
	for authored in page.lamps:
		var lamp: Dictionary = authored.duplicate(true)
		lamp.on = false
		world.lamps.append(lamp)
	var flick := flick_of(page, plan)
	if not flick.is_empty():
		# FLICK: the spare bulb is a lamp whose zone and switch-on beat the player
		# chooses. It is off until the SWITCHES phase of its beat.
		world.lamps.append({"id": FLICK_ID, "zone": [maxi(0, flick.centre - 1), mini(page.width - 1, flick.centre + 1)], "switch_id": "", "on": false, "beat": flick.beat})
	var lit := lit_slots(page, plan, world)
	for actor in world.characters:
		actor.active = actor.slot in lit
	return world


static func lit_slots(page: Dictionary, plan: Dictionary, world: Dictionary) -> Array[int]:
	var result: Array[int] = []
	for slot in range(page.width):
		if LIGHTING.is_lit(page, plan, world, slot):
			result.append(slot)
	return result


static func is_lit(page: Dictionary, plan: Dictionary, world: Dictionary, slot: int) -> bool:
	return LIGHTING.is_lit(page, plan, world, slot)


static func decisions(world: Dictionary, lit: Array[int]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for actor in world.characters:
		if not actor.active or actor.status != "READY":
			continue
		var decision := {
			"actor": actor.id, "target": "", "object": "", "type": "IDLE",
			"step": 0, "startle": false, "flee_direction": actor.flee_direction,
			"reason": "",
		}
		match actor.thought:
			"HUNGRY", "SLEEPY":
				var candidates: Array[Dictionary] = []
				var object_type := "FOOD" if actor.thought == "HUNGRY" else "SEAT"
				for object in world.objects:
					if object.type == object_type and object.present and object.occupant == "" and object.slot in lit:
						candidates.append(object)
				var target := _nearest(actor, candidates)
				if target.is_empty():
					decision.reason = "no_food" if object_type == "FOOD" else "no_seat"
				else:
					decision.object = target.id
					decision.step = _direction(target.slot - actor.slot)
					decision.type = "MOVE" if decision.step != 0 else ("EAT" if object_type == "FOOD" else "SIT")
			"ANGRY":
				var target := _nearest(actor, _standing_targets(actor, world, lit))
				if target.is_empty():
					decision.reason = "no_character"
				else:
					decision.target = target.id
					if absi(target.slot - actor.slot) > 1:
						decision.type = "MOVE"
						decision.step = _direction(target.slot - actor.slot)
					else:
						decision.type = "BONK"
			"SCARED":
				if actor.flee_direction != 0:
					decision.type = "FLEE"
					decision.step = actor.flee_direction
				else:
					var threats: Array[Dictionary] = []
					for target in _standing_targets(actor, world, lit):
						if absi(target.slot - actor.slot) <= 2:
							threats.append(target)
					var target := _nearest(actor, threats)
					if target.is_empty():
						decision.reason = "calm"
					else:
						var facing := 1 if actor.facing == "R" else -1
						var distance: int = absi(target.slot - actor.slot)
						var left := false
						var right := false
						for threat in threats:
							if absi(threat.slot - actor.slot) == distance:
								left = left or threat.slot < actor.slot
								right = right or threat.slot > actor.slot
						var direction := facing if distance == 0 or (left and right) else _direction(actor.slot - target.slot)
						decision.type = "FLEE"
						decision.target = target.id
						decision.step = direction
						decision.startle = true
						decision.flee_direction = direction
			"SHY":
				# Hates being seen: from a lit slot, walk to the nearest dark one
				# (the panel border counts as dark). In the dark it hides, never done.
				if actor.slot in lit:
					var facing := 1 if actor.facing == "R" else -1
					var best_distance := 2147483647
					var best_step := 0
					var best_preferred := false
					for spot in range(-1, int(world.get("width", 0)) + 1):
						if spot >= 0 and spot < int(world.get("width", 0)) and spot in lit:
							continue
						var step := _direction(spot - actor.slot)
						var distance: int = absi(spot - actor.slot)
						var preferred := step == facing
						if distance < best_distance or (distance == best_distance and preferred and not best_preferred):
							best_distance = distance
							best_step = step
							best_preferred = preferred
					decision.type = "HIDE"
					decision.step = best_step
				else:
					decision.reason = "calm"
			"IN_LOVE":
				# Walks to the nearest visible character who is not done yet and hugs them.
				var candidates: Array[Dictionary] = []
				for other in _standing_targets(actor, world, lit):
					if other.status == "READY":
						candidates.append(other)
				var target := _nearest(actor, candidates)
				if target.is_empty():
					decision.reason = "no_character"
				else:
					decision.target = target.id
					if absi(target.slot - actor.slot) > 1:
						decision.type = "MOVE"
						decision.step = _direction(target.slot - actor.slot)
					else:
						decision.type = "HUG"
		result.append(decision)
	# JEALOUS decides last: it copies the food or seat the nearest visible
	# character is going for this beat, and races them to it.
	for decision in result:
		var actor := _actor(world, decision.actor)
		if actor.thought != "JEALOUS":
			continue
		var busy: Array[Dictionary] = []
		for other in _standing_targets(actor, world, lit):
			for other_decision in result:
				if other_decision.actor == other.id and other_decision.object != "":
					busy.append(other)
		var rival := _nearest(actor, busy)
		if rival.is_empty():
			decision.reason = "nobody_to_envy"
			continue
		var wanted := ""
		for other_decision in result:
			if other_decision.actor == rival.id:
				wanted = other_decision.object
		for object in world.objects:
			if object.id == wanted:
				decision.object = wanted
				decision.target = rival.id
				decision.step = _direction(object.slot - actor.slot)
				decision.type = "MOVE" if decision.step != 0 else ("EAT" if object.type == "FOOD" else "SIT")
				decision.reason = ""
	return result


static func _actor(world: Dictionary, id: String) -> Dictionary:
	for actor in world.characters:
		if actor.id == id:
			return actor
	return {}


static func standing(actor: Dictionary) -> bool:
	return actor.status not in ["KO", "ASLEEP", "EXITED"]


static func _standing_targets(actor: Dictionary, world: Dictionary, lit: Array[int] = []) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	for other in world.characters:
		# A SHY character standing in the dark hides its glow: nobody can see it.
		if other.id != actor.id and other.active and standing(other) and not (other.thought == "SHY" and other.slot not in lit):
			candidates.append(other)
	return candidates


static func _nearest(actor: Dictionary, candidates: Array[Dictionary]) -> Dictionary:
	var nearest: Dictionary = {}
	var distance := 2147483647
	var facing := 1 if actor.facing == "R" else -1
	var preferred := false
	for candidate in candidates:
		var candidate_distance: int = absi(candidate.slot - actor.slot)
		var candidate_preferred: bool = _direction(candidate.slot - actor.slot) == facing
		if candidate_distance < distance or (candidate_distance == distance and candidate_preferred and not preferred):
			nearest = candidate
			distance = candidate_distance
			preferred = candidate_preferred
	return nearest


static func _direction(delta: int) -> int:
	return 0 if delta == 0 else (1 if delta > 0 else -1)



## The plan's FLICK if the page grants one and it is well formed, else {}.
static func flick_of(page: Dictionary, plan: Dictionary) -> Dictionary:
	var flick: Variant = plan.get("flick", {})
	if int(page.get("flick", 0)) < 1 or not flick is Dictionary or flick.is_empty():
		return {}
	var beat := int(flick.get("beat", 0))
	var centre := int(flick.get("centre", -1))
	if beat < 1 or centre < 0 or centre >= int(page.width):
		return {}
	return {"beat": beat, "centre": centre}
