extends RefCounted
## Campaign page from design thread "Level and puzzle logic design" (design/levels.md).
## New fields: lanterns.count (hard lantern limit), flick, hints, CLONK fact.


static func definition() -> Dictionary:
	return {
		"id": "page_06",
		"room": "office",
		"narration": "birthday",
		"title": "The Boss's Birthday",
		"width": 11,
		"rail_span": [
			0,
			10
		],
		"spotlights": {
			"count": 1,
			"default_centres": [
				5
			]
		},
		"lanterns": {
			"radius": 1.6,
			"bounds": [
				0.0,
				-1.2,
				5.0,
				0.6
			],
			"count": 1,
			"defaults": [
				{
					"x": 5.0,
					"y": -0.6,
					"enabled": true
				},
				{
					"x": 0.0,
					"y": -0.6,
					"enabled": false
				}
			]
		},
		"flick": 1,
		"fixed_lights": [],
		"lamps": [
			{
				"id": "lamp",
				"zone": [
					6,
					10
				],
				"switch_id": "pedal",
				"initially_on": false
			}
		],
		"characters": [
			{
				"id": "intern",
				"art": "intern",
				"slot": 1,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": true
			},
			{
				"id": "grandma",
				"art": "grandma",
				"slot": 2,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": true
			},
			{
				"id": "boss",
				"art": "boss",
				"slot": 4,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "dog",
				"art": "dog",
				"slot": 9,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "chair",
				"type": "SEAT",
				"art": "chair",
				"slot": 0
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"slot": 6
			},
			{
				"id": "pedal",
				"type": "SWITCH",
				"art": "pedal",
				"slot": 7
			}
		],
		"original_caption": "The Boss ate the birthday cake.",
		"endings_total": 45,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "Grandma bonks the Boss.",
				"facts": [
					{
						"type": "BONKED",
						"character": "grandma",
						"target": "boss"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "The Boss gets his cake and Grandma bonks him.",
				"facts": [
					{
						"type": "ATE",
						"character": "boss",
						"object": "cake"
					},
					{
						"type": "BONKED",
						"character": "grandma",
						"target": "boss"
					}
				]
			}
		],
		"hints": [
			"Sweet Grandma isn't as calm as she looks.",
			"Make someone run past the pedal.",
			"ghost: swap Grandma/Boss + lantern slot 3"
		],
		"goal": {
			"facts": [
				{
					"type": "ATE",
					"character": "dog",
					"object": "cake"
				}
			],
			"twist_caption": "The DOG ate the birthday cake.",
			"red_pen_words": [
				"DOG"
			]
		}
	}
