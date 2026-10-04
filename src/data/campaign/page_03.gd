extends RefCounted
## Campaign page from design thread "Level and puzzle logic design" (design/levels.md).
## New fields: lanterns.count (hard lantern limit), flick, hints, CLONK fact.


static func definition() -> Dictionary:
	return {
		"id": "page_03",
		"room": "kitchen",
		"title": "Eat Your Greens",
		"width": 11,
		"rail_span": [
			0,
			10
		],
		"spotlights": {
			"count": 2,
			"default_centres": [
				3
			]
		},
		"lanterns": {
			"radius": 1.6,
			"bounds": [
				0.0,
				-1.2,
				10.0,
				0.6
			],
			"count": 2,
			"defaults": [
				{
					"x": 3.0,
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
		"fixed_lights": [],
		"lamps": [],
		"characters": [
			{
				"id": "kid",
				"art": "kid",
				"slot": 4,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "dog",
				"art": "dog",
				"slot": 8,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "grandma",
				"art": "grandma",
				"slot": 10,
				"facing": "L",
				"thought": "SLEEPY",
				"contradiction": true
			}
		],
		"objects": [
			{
				"id": "armchair",
				"type": "SEAT",
				"art": "armchair",
				"slot": 0
			},
			{
				"id": "cookie",
				"type": "FOOD",
				"art": "cookie",
				"slot": 2
			},
			{
				"id": "broccoli",
				"type": "FOOD",
				"art": "broccoli",
				"slot": 7
			}
		],
		"original_caption": "The Kid ate the cookie.",
		"endings_total": 18,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "The Dog steals the armchair.",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "dog",
						"object": "armchair"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "Grandma swipes the cookie.",
				"facts": [
					{
						"type": "ATE",
						"character": "grandma",
						"object": "cookie"
					}
				]
			}
		],
		"hints": [
			"If the Kid can see the cookie, he'll pick it.",
			"Keep the cookie and the Dog in the dark.",
			"ghost: lanterns over slots 4 and 6"
		],
		"goal": {
			"facts": [
				{
					"type": "ATE",
					"character": "kid",
					"object": "broccoli"
				}
			],
			"twist_caption": "The Kid ate the BROCCOLI.",
			"red_pen_words": [
				"BROCCOLI"
			]
		}
	}
