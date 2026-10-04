extends RefCounted
## Canonical Appendix B layout. Art keys are placeholders for labelled greyboxes.


static func definition() -> Dictionary:
	return {
		"id": "page_06",
		"title": "The Boss's Birthday",
		"width": 11,
		"rail_span": [0, 10],
		"spotlights": {"count": 1, "default_centres": [5]},
		"lanterns": {
			"radius": 1.6, "bounds": [0.0, -1.2, 5.0, 0.6],
			"defaults": [{"x": 5.0, "y": -0.6, "enabled": true}, {"x": 0.0, "y": -0.6, "enabled": false}],
		},
		"fixed_lights": [],
		"lamps": [
			{"id": "desk_lamp", "zone": [6, 10], "switch_id": "pedal", "initially_on": false},
		],
		"characters": [
			{"id": "intern", "art": "intern", "slot": 1, "facing": "R", "thought": "ANGRY", "contradiction": true},
			{"id": "grandma", "art": "grandma", "slot": 2, "facing": "R", "thought": "SCARED", "contradiction": true},
			{"id": "boss", "art": "boss", "slot": 4, "facing": "R", "thought": "HUNGRY", "contradiction": false},
			{"id": "dog", "art": "dog", "slot": 9, "facing": "L", "thought": "HUNGRY", "contradiction": false},
		],
		"objects": [
			{"id": "office_chair", "type": "SEAT", "art": "office_chair", "slot": 0},
			{"id": "cake", "type": "FOOD", "art": "cake", "slot": 6},
			{"id": "pedal", "type": "SWITCH", "art": "pedal", "slot": 7},
		],
		"original_caption": "The Boss ate the birthday cake.",
		"endings_total": 25,
		"bonus": [
			{"id": "grandma_bonks_boss", "caption": "Grandma bonks the Boss.", "facts": [{"type": "BONKED", "character": "grandma", "target": "boss"}]},
			{"id": "cake_then_bonk", "caption": "The Boss gets his cake and Grandma bonks him.", "facts": [{"type": "ATE", "character": "boss", "object": "cake"}, {"type": "BONKED", "character": "grandma", "target": "boss"}]},
		],
		"goal": {
			"facts": [{"type": "ATE", "character": "dog", "object": "cake"}],
			"twist_caption": "The DOG ate the birthday cake.",
			"red_pen_words": ["DOG"],
		},
	}
