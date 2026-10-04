extends RefCounted
## Level 12/15 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_09",
		"number": 12,
		"room": "living_room",
		"narration_key": "catmouse",
		"title": "Cat & Mouse",
		"voice": "catmouse",
		"difficulty": "red",
		"width": 11,
		"rail_span": [
			0,
			10
		],
		"spotlights": {
			"count": 1,
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
			"count": 1,
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
		"flick": 1,
		"fixed_lights": [],
		"lamps": [],
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
				"id": "cat",
				"name": "Cat",
				"art": "cat",
				"slot": 3,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "mouse",
				"name": "Mouse",
				"art": "mouse",
				"slot": 5,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": true
			},
			{
				"id": "dog",
				"name": "Dog",
				"art": "dog",
				"slot": 7,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "rocker",
				"type": "SEAT",
				"art": "rocker",
				"slot": 1
			},
			{
				"id": "cheese",
				"type": "FOOD",
				"art": "cheese",
				"slot": 9
			}
		],
		"original_caption": "The Cat chased the Mouse out of the comic.",
		"endings_total": 132,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "GRANDMA RUNS OFF, THE MOUSE BONKS THE DOG",
				"facts": [
					{
						"type": "EXITED",
						"character": "grandma"
					},
					{
						"type": "BONKED",
						"character": "mouse",
						"target": "dog"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "GRANDMA NAPS, THE DOG BONKS THE CAT",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "grandma",
						"object": "rocker"
					},
					{
						"type": "BONKED",
						"character": "dog",
						"target": "cat"
					}
				]
			}
		],
		"goal": {
			"facts": [
				{
					"type": "BONKED",
					"character": "mouse",
					"target": "cat"
				},
				{
					"type": "ATE",
					"character": "dog",
					"object": "cheese"
				}
			],
			"twist_caption": "The MOUSE bonked the CAT. The DOG got the cheese.",
			"red_pen_words": [
				"MOUSE",
				"CAT",
				"DOG"
			]
		},
		"narration": {
			"intro": "I've hired a professional. One Cat, paid in advance, in fish. The Cat will chase the Mouse out of this comic, and then the Cat will chase YOU out of this comic. Get him, Cat.",
			"original": "The Cat chased the Mouse out of the comic. Money well spent.",
			"twist": "The MOUSE bonked the CAT. The DOG got the cheese.",
			"win": "The Mouse bonked the Cat. A MOUSE. Bonked. A CAT. I paid that cat in fish. I want my fish back. The Dog ate the cheese. The Dog doesn't even LIKE cheese.",
			"fail": "The Cat chased the Mouse out. Best fish I ever spent.",
			"fail_alt": [
				"The Mouse has left the comic. He's in a cookbook now. Nobody tell the Cat.",
				"Professional work, Cat."
			]
		},
		"dialogue": [
			{
				"character": "cat",
				"when": "lit",
				"line": "I've been paid. Nothing personal, mousey."
			},
			{
				"character": "mouse",
				"when": "lit",
				"line": "Eep!"
			},
			{
				"character": "mouse",
				"when": "swap",
				"line": "Oh, it's ON."
			},
			{
				"character": "cat",
				"when": "swap",
				"line": "Is it... nap time... already?"
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Cheese? I don't even like cheese. CHEESE."
			},
			{
				"character": "mouse",
				"when": "win",
				"line": "And STAY out of my comic!"
			}
		],
		"tutorial": [],
		"hints": [
			"What if the Mouse was the angry one? A scared Cat just runs away.",
			"Mouse angry, Cat sleepy: a three-way swap with Grandma. The Dog still needs waking.",
			"Swap the Cat and the Mouse, then the Cat and Grandma. Light only the Cat and the Mouse, and drop the spare bulb on the Dog as ACTION starts."
		],
		"bonus_hints": [
			"Use the twist's swaps, but light Grandma and the Cat, then drop the spare bulb between the Mouse and the Dog.",
			"Swap the Cat and the Dog. Light Grandma and the Cat, then drop the spare bulb on the Dog."
		]
	}
