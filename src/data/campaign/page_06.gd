extends RefCounted
## Level 7/15 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_06",
		"number": 7,
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
				"caption": "THE BOSS BONKS THE KID. HE WILL BE HEARING FROM GRANDMA.",
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
				"caption": "THE KID NAPS THROUGH ALL THE BONKING",
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
			"intro": "Sweet, gentle Grandma. She knits. She bakes. She has bonked eleven people this week, and it's Tuesday. Tonight she is coming for the Dog.",
			"original": "Grandma bonked the Dog. The Dog had it coming. Probably.",
			"twist": "Grandma bonked the BOSS. The DOG ate the cake.",
			"win": "Grandma bonked the Boss at his own leftover-birthday-cake party, and the Dog ate the leftovers. Boss Cake Count: still zero. I'm starting to think it's personal.",
			"fail": "Wrong target. Then again, Grandma isn't fussy.",
			"fail_alt": [
				"Somebody got bonked. That's the main thing.",
				"Grandma's knitting needles are not involved. Yet."
			]
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
				"line": "Cake? Cake! CAKE!"
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "Is that leftover cake for me?"
			},
			{
				"character": "kid",
				"when": "lit",
				"line": "I'm just here to watch."
			},
			{
				"character": "grandma",
				"when": "win",
				"line": "That's for 1974."
			}
		],
		"tutorial": [],
		"hints": [
			"Grandma bonks whoever comes close. Who could walk past her?",
			"Keep the Dog and the Kid dark. Light Grandma, the cake and the Boss.",
			"Hang one bulb over Grandma and the cake, the other over the Boss. He marches to the cake, steps on the pedal and meets Grandma."
		],
		"bonus_hints": [
			"Swap Grandma and the Boss, and swap the Kid and the Dog. Then light the Boss and the Kid, one bulb on each side.",
			"No swaps needed: light the Kid, the Dog and Grandma, and leave the Boss dark."
		]
	}
