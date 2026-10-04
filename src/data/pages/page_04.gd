extends RefCounted
## Appendix B Midnight Snack geometry; facing resolves no default target tie.


static func definition() -> Dictionary:
	return {
		"id": "page_04", "title": "Midnight Snack", "width": 11,
		"rail_span": [0, 4], "spotlights": {"count": 1, "default_centres": [2]},
		"lanterns": {
			"radius": 1.6, "bounds": [0.0, -1.2, 4.0, 0.6],
			"defaults": [{"x": 2.0, "y": -0.6, "enabled": true}, {"x": 0.0, "y": -0.6, "enabled": false}],
		},
		"fixed_lights": [[6, 6]],
		"lamps": [{"id": "kitchen_lamp", "zone": [6, 10], "switch_id": "pedal", "initially_on": false}],
		"characters": [
			{"id": "grandma", "art": "grandma", "slot": 0, "facing": "R", "thought": "SLEEPY", "contradiction": false},
			{"id": "kid", "art": "kid", "slot": 2, "facing": "R", "thought": "HUNGRY", "contradiction": false},
			{"id": "dog", "art": "dog", "slot": 10, "facing": "L", "thought": "HUNGRY", "contradiction": true},
		],
		"objects": [
			{"id": "pedal", "type": "SWITCH", "art": "pedal", "slot": 3},
			{"id": "armchair", "type": "SEAT", "art": "armchair", "slot": 4},
			{"id": "pie", "type": "FOOD", "art": "pie", "slot": 6},
		],
		"original_caption": "The Kid ate the pie.",
		# Ending count from the solution-space audit (lower bound; display grows if exceeded).
		"endings_total": 6,
		"bonus": [
			{"id": "grandma_pie", "caption": "Grandma gets the pie.", "facts": [{"type": "ATE", "character": "grandma", "object": "pie"}]},
			{"id": "dog_pie_grandma_naps", "caption": "The Dog gets the pie while Grandma naps.", "facts": [{"type": "ATE", "character": "dog", "object": "pie"}, {"type": "ASLEEP", "character": "grandma"}]},
		],
		"goal": {
			"facts": [{"type": "ATE", "character": "dog", "object": "pie"}],
			"twist_caption": "The DOG ate the pie.", "red_pen_words": ["DOG"],
		},
	}
