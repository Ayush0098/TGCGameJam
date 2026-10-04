extends RefCounted
## Level 7/10 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_07",
		"number": 7,
		"room": "living_room",
		"narration_key": "shadow",
		"title": "Shadow Play",
		"difficulty": "yellow",
		"width": 11,
		"rail_span": [
			0,
			10
		],
		"spotlights": {
			"count": 1,
			"default_centres": [
				6
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
			"count": 1,
			"defaults": [
				{
					"x": 6.0,
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
		"obstacles": [
			{
				"id": "screen",
				"from": [
					3.5,
					-0.45
				],
				"to": [
					3.5,
					0.8
				]
			}
		],
		"flick": 0,
		"fixed_lights": [],
		"lamps": [],
		"characters": [
			{
				"id": "mouse",
				"name": "Mouse",
				"art": "mouse",
				"slot": 1,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "boss",
				"name": "Boss",
				"art": "boss",
				"slot": 4,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "kid",
				"name": "Kid",
				"art": "kid",
				"slot": 5,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "grandma",
				"name": "Grandma",
				"art": "grandma",
				"slot": 6,
				"facing": "L",
				"thought": "ANGRY",
				"contradiction": true
			},
			{
				"id": "intern",
				"name": "Intern",
				"art": "intern",
				"slot": 7,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
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
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"slot": 3
			},
			{
				"id": "pie",
				"type": "FOOD",
				"art": "pie",
				"slot": 10
			}
		],
		"original_caption": "Grandma bonked the Kid.",
		"endings_total": 28,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "THE INTERN BONKS THE KID",
				"facts": [
					{
						"type": "BONKED",
						"character": "intern",
						"target": "kid"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "THE BOSS BONKS THE KID, GRANDMA FLEES",
				"facts": [
					{
						"type": "BONKED",
						"character": "boss",
						"target": "kid"
					},
					{
						"type": "EXITED",
						"character": "grandma"
					}
				]
			}
		],
		"goal": {
			"facts": [
				{
					"type": "BONKED",
					"character": "boss",
					"target": "grandma"
				}
			],
			"twist_caption": "The BOSS bonked GRANDMA.",
			"red_pen_words": [
				"BOSS",
				"GRANDMA"
			]
		},
		"narration": {
			"intro": "Grandma rules the living room. A tall bookshelf hides the cake, and its shadow hides more.",
			"win": "Grandma met her match. The cake stayed hidden behind the shelf.",
			"fail": "Grandma still rules the room."
		},
		"dialogue": [
			{
				"character": "grandma",
				"when": "lit",
				"line": "Who's making that racket?"
			},
			{
				"character": "kid",
				"when": "lit",
				"line": "Is there cake somewhere?"
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "I don't do conflict."
			},
			{
				"character": "boss",
				"when": "swap",
				"line": "That's IT, Grandma!"
			},
			{
				"character": "grandma",
				"when": "fail",
				"line": "Hmph."
			}
		],
		"tutorial": [
			"Furniture blocks light. Raise the bulb to shine over it, lower it to shine under."
		],
		"hints": [
			"Grandma can't see the cake behind the shelf, so a hungry Grandma just stands there.",
			"Three-way swap: the Boss gets angry, Grandma gets hungry, the Kid gets scared.",
			"Bulb at x 5: swap Boss and Grandma, then Grandma and the Kid."
		],
		"bonus_hints": [
			"Intern angry, Grandma scared, Boss hungry.",
			"Swap only the Boss and Grandma."
		]
	}
