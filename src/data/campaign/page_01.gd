extends RefCounted
## Campaign page from design thread "Level and puzzle logic design" (design/levels.md).
## New fields: lanterns.count (hard lantern limit), flick, hints, CLONK fact.


static func definition() -> Dictionary:
	return {
		"id": "page_01",
		"room": "kitchen",
		"title": "Dinner Time",
		"width": 9,
		"rail_span": [
			0,
			8
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
				8.0,
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
		"flick": 0,
		"coach": "Drag the glowing lantern. Whoever stands in its light gets an idea, and they only notice what is lit.",
		"fixed_lights": [],
		"lamps": [],
		"characters": [
			{
				"id": "cat",
				"art": "cat",
				"slot": 2,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "dog",
				"art": "dog",
				"slot": 6,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "fish",
				"type": "FOOD",
				"art": "fish",
				"slot": 4
			},
			{
				"id": "cookie",
				"type": "FOOD",
				"art": "cookie",
				"slot": 8
			}
		],
		"original_caption": "The Dog ate the fish.",
		"endings_total": 4,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "The Dog goes for the cookie.",
				"facts": [
					{
						"type": "ATE",
						"character": "dog",
						"object": "cookie"
					}
				]
			}
		],
		"hints": [
			"The Cat can't eat what it can't see.",
			"Light the Cat and the fish together.",
			"ghost: lantern over slot 3"
		],
		"goal": {
			"facts": [
				{
					"type": "ATE",
					"character": "cat",
					"object": "fish"
				}
			],
			"twist_caption": "The CAT ate the fish.",
			"red_pen_words": [
				"CAT"
			]
		}
	}
