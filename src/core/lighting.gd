extends RefCounted
## Shared visibility geometry. Visual falloff never determines gameplay activation.

const EPSILON := 0.00001
const HALO_SCALE := 1.25


static func radius(page: Dictionary) -> float:
	return float(page.get("lanterns", {}).get("radius", 1.6))


static func is_lit(page: Dictionary, plan: Dictionary, world: Dictionary, slot: float) -> bool:
	if _zone_lit(page, world, slot):
		return true
	if not page.has("lanterns") or plan.get("lanterns", []).is_empty():
		for centre in plan.get("centres", []):
			if absf(slot - float(centre)) <= 1.0:
				return true
		return false
	var point := Vector2(slot, 0.0)
	for lantern in plan.get("lanterns", []):
		if not lantern.get("enabled", false):
			continue
		var source := Vector2(lantern.x, lantern.y)
		if source.distance_to(point) <= radius(page) + EPSILON and not _blocked(page, source, point):
			return true
	return false


static func intensity(page: Dictionary, plan: Dictionary, world: Dictionary, point: Vector2) -> float:
	# Authored slot zones occupy their cells visually, including single-slot
	# fixtures. Gameplay still samples their exact inclusive slot endpoints.
	if _zone_lit(page, world, point.x, 0.45):
		return 1.0
	if not page.has("lanterns") or plan.get("lanterns", []).is_empty():
		return 1.0 if is_lit(page, plan, world, point.x) else 0.0
	return lantern_intensity(page, plan, point, radius(page) * HALO_SCALE)


static func lantern_intensity(page: Dictionary, plan: Dictionary, point: Vector2, outer_radius: float) -> float:
	# Presentation may cache zone/radius checks before sampling a mask. This
	# remains the shared radial falloff and occlusion calculation.
	var value := 0.0
	for lantern in plan.get("lanterns", []):
		if not lantern.get("enabled", false):
			continue
		var source := Vector2(lantern.x, lantern.y)
		var distance := source.distance_to(point)
		if distance >= outer_radius or _blocked(page, source, point):
			continue
		# Smooth falloff to an explicitly decorative halo beyond the reveal ring.
		var fraction := clampf(distance / outer_radius, 0.0, 1.0)
		value = maxf(value, 1.0 - smoothstep(0.0, 1.0, fraction))
	return value


static func _zone_lit(page: Dictionary, world: Dictionary, slot: float, margin: float = 0.0) -> bool:
	for zone in page.get("fixed_lights", []):
		if slot >= zone[0] - margin and slot <= zone[1] + margin:
			return true
	for lamp in world.get("lamps", []):
		if lamp.on and slot >= lamp.zone[0] - margin and slot <= lamp.zone[1] + margin:
			return true
	return false


static func _blocked(page: Dictionary, source: Vector2, point: Vector2) -> bool:
	if source.is_equal_approx(point):
		return false
	for obstacle in page.get("obstacles", []):
		var start := Vector2(obstacle.from[0], obstacle.from[1])
		var finish := Vector2(obstacle.to[0], obstacle.to[1])
		var intersection: Variant = Geometry2D.segment_intersects_segment(source, point, start, finish)
		if intersection != null:
			return true
		# Godot treats collinear segments as nonintersecting. A beam grazing
		# along an obstacle must still be blocked, including its endpoints.
		if absf((point - source).cross(start - source)) <= EPSILON and absf((point - source).cross(finish - source)) <= EPSILON:
			var direction := point - source
			var length_squared := direction.length_squared()
			var first := (start - source).dot(direction) / length_squared
			var last := (finish - source).dot(direction) / length_squared
			if maxf(first, last) >= 0.0 and minf(first, last) <= 1.0:
				return true
	return false
