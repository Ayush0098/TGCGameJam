extends RefCounted
## Player-editable state. Copies are explicit; edits never mutate page defaults.

var centres: Array[int] = []
var lanterns: Array = []
var thoughts: Dictionary = {}


static func from_page(page: Dictionary) -> RefCounted:
	var state = load("res://core/plan_state.gd").new()
	for centre in page.get("spotlights", {}).get("default_centres", []):
		state.centres.append(centre)
	state.lanterns = page.get("lanterns", {}).get("defaults", []).duplicate(true)
	for actor in page.characters:
		state.thoughts[actor.id] = actor.thought
	return state


func to_data() -> Dictionary:
	return {"centres": centres.duplicate(), "lanterns": lanterns.duplicate(true), "thoughts": thoughts.duplicate(true)}


func restore(data: Dictionary) -> void:
	centres.assign(data.get("centres", []))
	lanterns = data.get("lanterns", []).duplicate(true)
	thoughts = data.thoughts.duplicate(true)


func place(page: Dictionary, index: int, centre: int) -> bool:
	if not page.has("spotlights") or not page.has("rail_span"):
		return false
	if index < 0 or index > centres.size():
		return false
	if centre == -1:
		if index >= centres.size():
			return false
		centres.remove_at(index)
		_sync_legacy_lanterns(page)
		return true
	if centre < page.rail_span[0] or centre > page.rail_span[1]:
		return false
	if index == centres.size():
		if centres.size() >= page.spotlights.count:
			return false
		centres.append(centre)
	else:
		centres[index] = centre
	_sync_legacy_lanterns(page)
	return true


func move_lantern(page: Dictionary, index: int, position: Vector2, enabled := true) -> bool:
	if not page.has("lanterns") or index < 0 or index >= lanterns.size() or not position.is_finite():
		return false
	var bounds: Array = page.lanterns.bounds
	if position.x < bounds[0] or position.y < bounds[1] or position.x > bounds[2] or position.y > bounds[3]:
		return false
	lanterns[index] = {"x": position.x, "y": position.y, "enabled": enabled}
	return true


func _sync_legacy_lanterns(page: Dictionary) -> void:
	if not page.has("lanterns"):
		return
	for index in lanterns.size():
		if index < centres.size():
			lanterns[index] = {"x": float(centres[index]), "y": -0.6, "enabled": true}
		else:
			lanterns[index].enabled = false


func swap(first: String, second: String, lit_ids: Array) -> bool:
	if first == second or first not in lit_ids or second not in lit_ids:
		return false
	if not thoughts.has(first) or not thoughts.has(second):
		return false
	var previous: String = thoughts[first]
	thoughts[first] = thoughts[second]
	thoughts[second] = previous
	return true
