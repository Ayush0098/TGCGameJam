extends RefCounted
## Level 4/15 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_04",
		"number": 4,
		"room": "kitchen",
		"narration_key": "snack",
		"title": "Midnight Snack",
		"difficulty": "green",
		"width": 11,
		"rail_span": [
			0,
			10
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
				0.6
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
		"flick": 0,
		"fixed_lights": [
			[
				6,
				6
			]
		],
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
				"id": "grandma",
				"name": "Grandma",
				"art": "grandma",
				"slot": 0,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "kid",
				"name": "Kid",
				"art": "kid",
				"slot": 2,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "cat",
				"name": "Cat",
				"art": "cat",
				"slot": 8,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Dog",
				"art": "dog",
				"slot": 10,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": true
			}
		],
		"objects": [
			{
				"id": "pedal",
				"type": "SWITCH",
				"art": "pedal",
				"slot": 3
			},
			{
				"id": "armchair",
				"type": "SEAT",
				"art": "armchair",
				"slot": 4
			},
			{
				"id": "pie",
				"type": "FOOD",
				"art": "pie",
				"slot": 6
			}
		],
		"original_caption": "The Kid ate the pie. The Cat ran out of the comic.",
		"endings_total": 4,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "GRANDMA'S MIDNIGHT PIE",
				"facts": [
					{
						"type": "ATE",
						"character": "grandma",
						"object": "pie"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "THE KID NAPS, THE CAT FLEES TO A COOKBOOK",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "kid",
						"object": "armchair"
					},
					{
						"type": "EXITED",
						"character": "cat"
					}
				]
			}
		],
		"goal": {
			"facts": [
				{
					"type": "ATE",
					"character": "dog",
					"object": "pie"
				}
			],
			"twist_caption": "The DOG ate the pie.",
			"red_pen_words": [
				"DOG"
			]
		},
		"narration": {
			"intro": "Midnight. The Kid creeps towards the last slice of pie. Grandma is asleep. The Cat is terrified of the Kid, for reasons we do not discuss.",
			"original": "The Kid ate the pie, and the Cat ran clean out of the comic. Crime pays.",
			"twist": "The DOG ate the pie.",
			"win": "The Kid fell asleep in an armchair halfway through a crime, and the Dog ate the evidence. Best-organised heist this house has ever seen.",
			"fail": "The Kid got the pie. Crime does pay, apparently.",
			"fail_alt": [
				"The pie has been... handled.",
				"Midnight snack: successful. Twist: unsuccessful."
			]
		},
		"dialogue": [
			{
				"character": "kid",
				"when": "lit",
				"line": "Shh. Operation Pie is a go."
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "Who's there? ...Zzz."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "I smell pie. And fear."
			},
			{
				"character": "kid",
				"when": "swap",
				"line": "Maybe... a little... sit... down..."
			},
			{
				"character": "dog",
				"when": "win",
				"line": "Delicious. Leave no witnesses."
			}
		],
		"tutorial": [
			"Stepping on a pedal turns on its lamp. Anyone it lights wakes up next beat."
		],
		"hints": [
			"The Kid always reaches the pie first.",
			"Give the Kid Grandma's sleepiness. A sleepy Kid heads for the armchair and steps on the pedal on the way.",
			"Light Grandma and the Kid and swap their thoughts. Then slide the bulb right so only the Kid stays lit."
		],
		"bonus_hints": [
			"Same swap as the twist, but this time keep Grandma in the light.",
			"The twist solution earns this one too: the sleepy Kid steps on the pedal and the lamp scares the Cat away."
		]
	}
