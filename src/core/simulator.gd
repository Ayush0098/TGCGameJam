extends RefCounted
## Pure deterministic simulation. Playback consumes the returned owned snapshots.

const RULES = preload("res://core/rules.gd")
const MAX_BEATS := 40


static func run(page: Dictionary, plan: Dictionary, capture_presentation: bool = false) -> Dictionary:
	var saved_plan: Dictionary = plan.duplicate(true)
	var world := RULES.initial_world(page, saved_plan)
	var events: Array[Dictionary] = []
	var snapshots: Array[Dictionary] = []
	var presentation_frames: Array[Dictionary] = []
	var actors: Dictionary = {}
	for actor in world.characters:
		actors[actor.id] = actor
		if actor.active:
			events.append(_event(0, "ACTIVATE", "DING", actor.id, "", "", actor.slot, actor.slot))
	snapshots.append(world.duplicate(true))
	var capped := true
	for beat in range(1, MAX_BEATS + 1):
		world.beat = beat
		var event_count := events.size()
		var decisions := RULES.decisions(world, RULES.lit_slots(page, saved_plan, world))
		# DECIDE reads the complete start-of-beat state before anything moves.
		for decision in decisions:
			var actor: Dictionary = actors[decision.actor]
			if decision.startle:
				actor.flee_direction = decision.flee_direction
				events.append(_event(beat, "DECIDE", "STARTLE", actor.id, decision.target, "", actor.slot, actor.slot))
			if decision.type == "IDLE" and decision.reason != "calm":
				if actor.idle_reason != decision.reason:
					var event := _event(beat, "DECIDE", "IDLE", actor.id, "", "", actor.slot, actor.slot)
					event.reason = decision.reason
					events.append(event)
				actor.idle_reason = decision.reason
			else:
				actor.idle_reason = ""
		_capture_phase(presentation_frames, world, "DECIDE", capture_presentation)
		var entered: Dictionary = {}
		for decision in decisions:
			if decision.step == 0:
				continue
			var actor: Dictionary = actors[decision.actor]
			var from_slot: int = actor.slot
			actor.slot += decision.step
			actor.facing = "R" if decision.step > 0 else "L"
			events.append(_event(beat, "MOVE", "MOVE", actor.id, decision.target, decision.object, from_slot, actor.slot))
			if actor.slot < 0 or actor.slot >= page.width:
				actor.status = "EXITED"
				events.append(_event(beat, "MOVE", "EXIT", actor.id, "", "", from_slot, actor.slot))
			else:
				if not entered.has(actor.slot):
					entered[actor.slot] = []
				entered[actor.slot].append(actor.id)
		_capture_phase(presentation_frames, world, "MOVE", capture_presentation)
		_activate_switches(page, saved_plan, world, entered, events)
		_activate_flick(page, saved_plan, world, events)
		_capture_phase(presentation_frames, world, "SWITCHES", capture_presentation)
		_resolve_bonks(world, actors, decisions, events)
		_resolve_hugs(world, actors, decisions, events)
		_capture_phase(presentation_frames, world, "BONKS", capture_presentation)
		_resolve_claims(world, actors, decisions, events)
		_capture_phase(presentation_frames, world, "CLAIMS", capture_presentation)
		snapshots.append(world.duplicate(true))
		if events.size() == event_count and not _flick_pending(world):
			capped = false
			break
	var result := {"snapshots": snapshots, "events": events, "end_beat": world.beat, "capped": capped, "plan": saved_plan}
	if capture_presentation:
		result.presentation_frames = presentation_frames
	return result


static func _capture_phase(frames: Array[Dictionary], world: Dictionary, phase: String, enabled: bool) -> void:
	# Capture only existing phase boundaries; presentation never resolves rules.
	if enabled:
		frames.append({"beat": world.beat, "phase": phase, "world": world.duplicate(true)})


static func _activate_switches(page: Dictionary, plan: Dictionary, world: Dictionary, entered: Dictionary, events: Array[Dictionary]) -> void:
	for object in world.objects:
		if object.type != "SWITCH" or not entered.has(object.slot):
			continue
		for lamp in world.lamps:
			if lamp.switch_id != object.id or lamp.on:
				continue
			lamp.on = true
			var entrants: Array = entered[object.slot]
			var event := _event(world.beat, "SWITCHES", "STEP_SWITCH", entrants[0], "", object.id, object.slot, object.slot)
			event.actors = entrants.duplicate()
			event.lamp = lamp.id
			events.append(event)
			var lamp_event := _event(world.beat, "SWITCHES", "LAMP_ON", "", "", object.id, object.slot, object.slot)
			lamp_event.lamp = lamp.id
			events.append(lamp_event)
			# Decisions were already captured, so newly active actors wait one beat.
			var lit := RULES.lit_slots(page, plan, world)
			for actor in world.characters:
				if not actor.active and actor.status != "EXITED" and actor.slot in lit:
					actor.active = true
					var ding := _event(world.beat, "SWITCHES", "DING", actor.id, "", "", actor.slot, actor.slot)
					ding.lamp = lamp.id
					events.append(ding)


static func _resolve_bonks(world: Dictionary, actors: Dictionary, decisions: Array[Dictionary], events: Array[Dictionary]) -> void:
	var hits: Array[Dictionary] = []
	var knocked: Dictionary = {}
	var satisfied: Dictionary = {}
	# Collect all hits before changing any status: a struck attacker can still hit.
	for decision in decisions:
		var actor: Dictionary = actors[decision.actor]
		if actor.thought != "ANGRY" or decision.target == "" or actor.status != "READY":
			continue
		var target: Dictionary = actors[decision.target]
		if RULES.standing(target) and absi(target.slot - actor.slot) <= 1:
			hits.append({"actor": actor.id, "target": target.id})
			knocked[target.id] = true
			satisfied[actor.id] = true
			events.append(_event(world.beat, "BONKS", "BONK", actor.id, target.id, "", actor.slot, target.slot))
		else:
			events.append(_event(world.beat, "BONKS", "WHIFF", actor.id, target.id, "", actor.slot, target.slot))
	for hit in hits:
		for other in hits:
			if hit.actor == other.target and hit.target == other.actor and _before(world, hit.actor, hit.target):
				events.append(_event(world.beat, "BONKS", "DOUBLE_KO", hit.actor, hit.target, "", actors[hit.actor].slot, actors[hit.target].slot))
	for actor in world.characters:
		if knocked.has(actor.id):
			actor.status = "KO"
		elif satisfied.has(actor.id):
			actor.status = "SATISFIED"


## IN LOVE: a hug lands on a not-yet-done neighbour. The hugger is SMITTEN
## (done, still standing); the hugged one falls in love and acts next beat,
## and loses this beat's claim. Bonks land first.
static func _resolve_hugs(world: Dictionary, actors: Dictionary, decisions: Array[Dictionary], events: Array[Dictionary]) -> void:
	var hugs: Array[Array] = []
	for decision in decisions:
		var actor: Dictionary = actors[decision.actor]
		if actor.thought != "IN_LOVE" or decision.target == "" or actor.status != "READY":
			continue
		var target: Dictionary = actors[decision.target]
		if target.status == "READY" and absi(target.slot - actor.slot) <= 1:
			hugs.append([actor, target])
	var huggers := {}
	for pair in hugs:
		huggers[pair[0].id] = true
		events.append(_event(world.beat, "BONKS", "HUG", pair[0].id, pair[1].id, "", pair[0].slot, pair[1].slot))
	for pair in hugs:
		pair[0].status = "SMITTEN"
	for pair in hugs:
		var target: Dictionary = pair[1]
		if not huggers.has(target.id) and target.status == "READY":
			target.thought = "IN_LOVE"
			target.flee_direction = 0
			for decision in decisions:
				if decision.actor == target.id:
					decision.object = ""
					decision.target = ""


static func _resolve_claims(world: Dictionary, actors: Dictionary, decisions: Array[Dictionary], events: Array[Dictionary]) -> void:
	for object in world.objects:
		if object.type not in ["FOOD", "SEAT"] or not object.present or object.occupant != "":
			continue
		var claimants: Array[Dictionary] = []
		for decision in decisions:
			var actor: Dictionary = actors[decision.actor]
			if decision.object == object.id and actor.status == "READY" and actor.slot == object.slot:
				claimants.append(actor)
		if claimants.size() > 1:
			var ids: Array[String] = []
			for actor in claimants:
				actor.status = "KO"
				ids.append(actor.id)
			var event := _event(world.beat, "CLAIMS", "CLASH", ids[0], "", object.id, object.slot, object.slot)
			event.actors = ids
			events.append(event)
		elif claimants.size() == 1:
			var actor: Dictionary = claimants[0]
			if object.type == "FOOD":
				object.present = false
				object.eater = actor.id
				actor.status = "FULL"
				events.append(_event(world.beat, "CLAIMS", "EAT", actor.id, "", object.id, actor.slot, actor.slot))
			else:
				object.occupant = actor.id
				actor.status = "ASLEEP"
				events.append(_event(world.beat, "CLAIMS", "SIT", actor.id, "", object.id, actor.slot, actor.slot))


static func _before(world: Dictionary, first: String, second: String) -> bool:
	for actor in world.characters:
		if actor.id == first:
			return true
		if actor.id == second:
			return false
	return false


static func _event(beat: int, phase: String, type: String, actor: String, target: String, object: String, from_slot: int, to_slot: int) -> Dictionary:
	return {"beat": beat, "phase": phase, "type": type, "actor": actor, "target": target, "object": object, "from": from_slot, "to": to_slot}



static func _activate_flick(page: Dictionary, plan: Dictionary, world: Dictionary, events: Array[Dictionary]) -> void:
	# Same code path as a switched lamp, at the beat the player chose.
	for lamp in world.lamps:
		if lamp.id != RULES.FLICK_ID or lamp.on or int(lamp.get("beat", 0)) != int(world.beat):
			continue
		lamp.on = true
		var centre := int((int(lamp.zone[0]) + int(lamp.zone[1])) / 2.0)
		var lamp_event := _event(world.beat, "SWITCHES", "FLICK", "", "", "", centre, centre)
		lamp_event.lamp = lamp.id
		events.append(lamp_event)
		var lit := RULES.lit_slots(page, plan, world)
		for actor in world.characters:
			if not actor.active and actor.status != "EXITED" and actor.slot in lit:
				actor.active = true
				var ding := _event(world.beat, "SWITCHES", "DING", actor.id, "", "", actor.slot, actor.slot)
				ding.lamp = lamp.id
				events.append(ding)



static func _flick_pending(world: Dictionary) -> bool:
	# Quiet beats still pass while the spare bulb waits to switch on.
	for lamp in world.lamps:
		if lamp.id == RULES.FLICK_ID and not lamp.on:
			return true
	return false
