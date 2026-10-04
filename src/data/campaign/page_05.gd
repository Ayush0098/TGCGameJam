extends RefCounted
## Level 5/10 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_05",
		"number": 5,
		"room": "living_room",
		"narration_key": "catmouse",
		"title": "Cat & Mouse",
		"difficulty": "yellow",
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
		"endings_total": 131,
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
			"intro": "Every day the Cat chases the Mouse off the page. Today, you have a spare bulb.",
			"win": "The Mouse bonked the Cat, and the Dog got the cheese. Small, but furious.",
			"fail": "The chase went the usual way."
		},
		"dialogue": [
			{
				"character": "cat",
				"when": "lit",
				"line": "Here, mousey mousey."
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
				"line": "Is it nap time already?"
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Cheese? Cheese."
			},
			{
				"character": "mouse",
				"when": "win",
				"line": "And STAY out!"
			}
		],
		"tutorial": [
			"During ACTION, click the rail once to drop your spare bulb. It lights the spot from that moment on."
		],
		"hints": [
			"What if the Mouse was the angry one? A scared Cat just runs away.",
			"Mouse angry, Cat sleepy: a three-way swap with Grandma. Then wake the Dog with your spare bulb.",
			"ghost: swap Cat-Mouse, then Cat-Grandma, lantern at x 3.5, spare bulb on x 8 at beat 1"
		]
	}
