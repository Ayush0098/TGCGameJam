extends RefCounted
## Level 6/10 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_06",
		"number": 6,
		"room": "living_room",
		"narration_key": "revenge",
		"title": "Grandma's Revenge",
		"difficulty": "yellow",
		"width": 11,
		"rail_span": [
			0,
			10
		],
		"spotlights": {
			"count": 2,
			"default_centres": [
				4
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
					"x": 4.0,
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
					3,
					4
				],
				"switch_id": "pedal",
				"initially_on": false
			}
		],
		"characters": [
			{
				"id": "kid",
				"name": "Kid",
				"art": "kid",
				"slot": 1,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Dog",
				"art": "dog",
				"slot": 4,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "grandma",
				"name": "Grandma",
				"art": "grandma",
				"slot": 5,
				"facing": "L",
				"thought": "ANGRY",
				"contradiction": true
			},
			{
				"id": "boss",
				"name": "Boss",
				"art": "boss",
				"slot": 10,
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
				"slot": 7
			},
			{
				"id": "pedal",
				"type": "SWITCH",
				"art": "pedal",
				"slot": 8
			}
		],
		"original_caption": "Grandma bonked the Dog.",
		"endings_total": 58,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "THE BOSS BONKS THE KID",
				"facts": [
					{
						"type": "BONKED",
						"character": "boss",
						"target": "kid"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "THE KID NAPS THROUGH THE BONKING",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "kid",
						"object": "chair"
					},
					{
						"type": "BONKED",
						"character": "grandma",
						"target": "dog"
					}
				]
			}
		],
		"goal": {
			"facts": [
				{
					"type": "BONKED",
					"character": "grandma",
					"target": "boss"
				},
				{
					"type": "ATE",
					"character": "dog",
					"object": "cake"
				}
			],
			"twist_caption": "Grandma bonked the BOSS. The DOG ate the cake.",
			"red_pen_words": [
				"BOSS",
				"DOG"
			]
		},
		"narration": {
			"intro": "Grandma has had enough of everyone. Somebody's getting bonked. Let's choose who.",
			"win": "Grandma got her revenge on the right person, and the Dog got the cake. Justice!",
			"fail": "Wrong target, Grandma."
		},
		"dialogue": [
			{
				"character": "grandma",
				"when": "lit",
				"line": "Somebody is getting it."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Cake? Cake!"
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "Is that cake for me?"
			},
			{
				"character": "grandma",
				"when": "win",
				"line": "That's for the birthday!"
			}
		],
		"tutorial": [],
		"hints": [
			"Grandma bonks whoever comes close. Who could walk past her?",
			"Keep the Dog and the Kid dark. Light Grandma, the cake and the Boss.",
			"Bulbs at x 6 and x 9: the Boss marches to the cake, clicks the pedal and meets Grandma."
		],
		"bonus_hints": [
			"A big shuffle: Boss angry, Kid and Grandma hungry, Dog sleepy. One bulb on each side.",
			"No swaps: light the Kid, the Dog and Grandma on the left."
		]
	}
