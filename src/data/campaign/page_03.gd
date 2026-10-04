extends RefCounted
## Level 3/10 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_03",
		"number": 3,
		"room": "kitchen",
		"narration_key": "greens",
		"title": "Eat Your Greens",
		"difficulty": "green",
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
		"obstacles": [],
		"flick": 0,
		"fixed_lights": [],
		"lamps": [],
		"characters": [
			{
				"id": "kid",
				"name": "Kid",
				"art": "kid",
				"slot": 4,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Dog",
				"art": "dog",
				"slot": 8,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "grandma",
				"name": "Grandma",
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
				"caption": "THE DOG NAPS IN THE ARMCHAIR",
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
				"caption": "THE KID NAPS INSTEAD",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "kid",
						"object": "armchair"
					}
				]
			}
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
		},
		"narration": {
			"intro": "Dinner rules: greens first. The Kid has other plans, and the Dog has a nose.",
			"win": "The Kid ate the broccoli. Nobody saw the cookie. Nobody will ever know.",
			"fail": "The broccoli survives another day."
		},
		"dialogue": [
			{
				"character": "kid",
				"when": "lit",
				"line": "Cookie! Cookie! Cookie!"
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Is someone not eating that?"
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "Eat your greens, dear."
			},
			{
				"character": "kid",
				"when": "win",
				"line": "...Huh. Not bad."
			}
		],
		"tutorial": [
			"You have a second bulb. Two lights can overlap."
		],
		"hints": [
			"If the Kid can see the cookie, he picks the cookie.",
			"Keep the cookie and the Dog in the dark. You have two bulbs.",
			"ghost: bulbs at x 4 and x 6"
		]
	}
