extends RefCounted
## Small fully lit swap tutorial, preserving the approved Nap Time outcomes.


static func definition() -> Dictionary:
	return {
		"id": "page_02", "title": "Nap Time", "width": 9,
		"rail_span": [0, 8], "spotlights": {"count": 0, "default_centres": []},
		"lanterns": {
			"radius": 1.6, "bounds": [0.0, -1.2, 8.0, 0.6],
			"defaults": [{"x": 0.0, "y": -0.6, "enabled": false}, {"x": 0.0, "y": -0.6, "enabled": false}],
		},
		"fixed_lights": [[0, 8]], "lamps": [],
		"characters": [
			{"id": "boss", "art": "boss", "slot": 2, "facing": "R", "thought": "HUNGRY", "contradiction": false},
			{"id": "dog", "art": "dog", "slot": 6, "facing": "L", "thought": "SLEEPY", "contradiction": true},
		],
		"objects": [
			{"id": "cake", "type": "FOOD", "art": "cake", "slot": 4},
			{"id": "dog_bed", "type": "SEAT", "art": "dog_bed", "slot": 8},
		],
		"original_caption": "The Boss ate the cake. The Dog napped.",
		"endings_total": 2,
		"goal": {
			"facts": [
				{"type": "ATE", "character": "dog", "object": "cake"},
				{"type": "ASLEEP", "character": "boss", "object": "dog_bed"},
			],
			"twist_caption": "The DOG ate the cake. The BOSS napped in the dog bed.",
			"red_pen_words": ["DOG", "BOSS"],
		},
	}
