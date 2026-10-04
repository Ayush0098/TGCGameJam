extends RefCounted
## Level 2/10 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_02",
		"number": 2,
		"room": "living_room",
		"narration_key": "nap",
		"title": "Nap Time",
		"difficulty": "green",
		"width": 11,
		"rail_span": [
			0,
			10
		],
		"spotlights": {
			"count": 1,
			"default_centres": [
				7
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
					"x": 7.0,
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
		"fixed_lights": [
			[
				1,
				2
			],
			[
				9,
				9
			]
		],
		"lamps": [],
		"characters": [
			{
				"id": "intern",
				"name": "Intern",
				"art": "intern",
				"slot": 3,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": true
			},
			{
				"id": "dog",
				"name": "Dog",
				"art": "dog",
				"slot": 5,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "boss",
				"name": "Boss",
				"art": "boss",
				"slot": 7,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "dog_bed",
				"type": "SEAT",
				"art": "dog_bed",
				"slot": 2
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"slot": 9
			}
		],
		"original_caption": "The Boss ate the cake.",
		"endings_total": 17,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "THE BOSS BONKS THE DOG",
				"facts": [
					{
						"type": "BONKED",
						"character": "boss",
						"target": "dog"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "THE DOG BONKS THE INTERN",
				"facts": [
					{
						"type": "BONKED",
						"character": "dog",
						"target": "intern"
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
				},
				{
					"type": "ASLEEP",
					"character": "boss",
					"object": "dog_bed"
				}
			],
			"twist_caption": "The DOG ate the cake. The BOSS napped in the dog bed.",
			"red_pen_words": [
				"DOG",
				"BOSS"
			]
		},
		"narration": {
			"intro": "Sunday afternoon. The fire is warm, the cake is waiting, and the Boss is in charge. As usual.",
			"win": "The Dog got the cake. The Boss got the dog bed. Nobody is telling HR.",
			"fail": "That's one ending. Not the one we wanted."
		},
		"dialogue": [
			{
				"character": "boss",
				"when": "lit",
				"line": "Cake time. Boss privileges."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Five more minutes..."
			},
			{
				"character": "intern",
				"when": "lit",
				"line": "Don't look at me like that."
			},
			{
				"character": "boss",
				"when": "swap",
				"line": "Suddenly... so... sleepy..."
			},
			{
				"character": "dog",
				"when": "win",
				"line": "Best. Nap. Ever. Wait, I ate cake."
			}
		],
		"tutorial": [
			"Drag a thought bubble onto another lit character to swap their thoughts."
		],
		"hints": [
			"Somebody else wants that cake.",
			"Light the Dog and the Boss together and swap their thoughts.",
			"ghost: lantern at x 6, swap Dog and Boss"
		]
	}
