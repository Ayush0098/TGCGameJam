extends RefCounted
## Level 6/10 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_06",
		"number": 6,
		"room": "office",
		"narration_key": "birthday",
		"title": "The Boss's Birthday",
		"difficulty": "yellow",
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
				-0.6
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
		"obstacles": [],
		"flick": 0,
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
				"name": "Intern",
				"art": "intern",
				"slot": 1,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": true
			},
			{
				"id": "grandma",
				"name": "Grandma",
				"art": "grandma",
				"slot": 2,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": true
			},
			{
				"id": "boss",
				"name": "Boss",
				"art": "boss",
				"slot": 4,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Dog",
				"art": "dog",
				"slot": 9,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "office_chair",
				"type": "SEAT",
				"art": "office_chair",
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
		"endings_total": 12,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "GRANDMA BONKS THE BOSS",
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
				"caption": "THE BOSS RUNS OUT OF HIS OWN PARTY",
				"facts": [
					{
						"type": "EXITED",
						"character": "boss"
					}
				]
			}
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
		},
		"narration": {
			"intro": "It's the Boss's birthday. There's cake. There's a desk lamp on a pedal. There's a very hungry Dog in the dark.",
			"win": "Happy birthday, Boss. The Dog says thanks for the cake.",
			"fail": "The party went on without the twist."
		},
		"dialogue": [
			{
				"character": "boss",
				"when": "lit",
				"line": "My cake. My party. My cake."
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "Oh my, so many people!"
			},
			{
				"character": "intern",
				"when": "lit",
				"line": "Nobody invited me."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "I heard cake."
			},
			{
				"character": "boss",
				"when": "swap",
				"line": "Why is everyone looking at me?!"
			},
			{
				"character": "dog",
				"when": "win",
				"line": "Best party ever."
			}
		],
		"tutorial": [],
		"hints": [
			"Sweet Grandma isn't as calm as she looks.",
			"Make someone run right past the pedal.",
			"ghost: swap Grandma and Boss, lantern at x 3"
		]
	}
