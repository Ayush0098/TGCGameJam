extends RefCounted
## Level 10/10 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_10",
		"number": 10,
		"room": "office",
		"narration_key": "finale",
		"finale": true,
		"title": "Lightbulb Moment",
		"difficulty": "red",
		"width": 12,
		"rail_span": [
			0,
			11
		],
		"spotlights": {
			"count": 1,
			"default_centres": [
				2
			]
		},
		"lanterns": {
			"radius": 1.6,
			"bounds": [
				0.0,
				-1.2,
				4.0,
				-0.6
			],
			"count": 1,
			"defaults": [
				{
					"x": 2.0,
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
		"flick": 1,
		"fixed_lights": [],
		"lamps": [
			{
				"id": "lamp",
				"zone": [
					5,
					8
				],
				"switch_id": "pedal",
				"initially_on": false
			},
			{
				"id": "lamp_2",
				"zone": [
					9,
					11
				],
				"switch_id": "pedal_2",
				"initially_on": false
			}
		],
		"characters": [
			{
				"id": "boss",
				"name": "Boss",
				"art": "boss",
				"slot": 2,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "intern",
				"name": "Intern",
				"art": "intern",
				"slot": 3,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Dog",
				"art": "dog",
				"slot": 5,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "grandma",
				"name": "Grandma",
				"art": "grandma",
				"slot": 8,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": true
			},
			{
				"id": "cat",
				"name": "Cat",
				"art": "cat",
				"slot": 11,
				"facing": "L",
				"thought": "SLEEPY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "pedal",
				"type": "SWITCH",
				"art": "pedal",
				"slot": 4
			},
			{
				"id": "chair",
				"type": "SEAT",
				"art": "chair",
				"slot": 6
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"slot": 8
			},
			{
				"id": "pedal_2",
				"type": "SWITCH",
				"art": "pedal",
				"slot": 9
			}
		],
		"original_caption": "The Boss and the Intern had the same bad idea.",
		"endings_total": 24,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "THE DOG GETS THE CAKE",
				"facts": [
					{
						"type": "ATE",
						"character": "dog",
						"object": "cake"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "THE BOSS BONKS GRANDMA",
				"facts": [
					{
						"type": "BONKED",
						"character": "boss",
						"target": "grandma"
					}
				]
			}
		],
		"goal": {
			"facts": [
				{
					"type": "ALL_ACTIVATED"
				}
			],
			"twist_caption": "EVERYONE had a lightbulb moment!",
			"red_pen_words": [
				"EVERYONE"
			]
		},
		"narration": {
			"intro": "The last page of the paper. The Boss and the Intern never agree. Tonight, everyone gets an idea.",
			"win": "Everyone had a lightbulb moment, including you. THE END.",
			"fail": "Somebody's still in the dark."
		},
		"dialogue": [
			{
				"character": "boss",
				"when": "lit",
				"line": "My idea!"
			},
			{
				"character": "intern",
				"when": "lit",
				"line": "No, MY idea!"
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "Oh dear, a crowd."
			},
			{
				"character": "cat",
				"when": "lit",
				"line": "Wake me when it's over."
			},
			{
				"character": "boss",
				"when": "swap",
				"line": "Is there... cake?"
			},
			{
				"character": "cat",
				"when": "win",
				"line": "Fine. That was a good one."
			}
		],
		"tutorial": [],
		"hints": [
			"Each lamp needs someone to walk over its pedal.",
			"Somebody has to cross the room, and your spare bulb can give them a reason.",
			"ghost: swaps Intern-Dog then Boss-Intern, lantern at x 4, spare bulb on the Boss at beat 1"
		]
	}
