extends RefCounted
## Level 2/15 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_02",
		"number": 2,
		"room": "kitchen",
		"narration_key": "greens",
		"title": "Eat Your Greens",
		"voice": "greens",
		"difficulty": "green",
		"width": 11,
		"rail_span": [
			0,
			10
		],
		"spotlights": {
			"count": 1,
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
			"count": 1,
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
		"endings_total": 5,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "THE DOG GOES VEGAN",
				"facts": [
					{
						"type": "ATE",
						"character": "dog",
						"object": "broccoli"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "GRANDMA EATS THE BROCCOLI. NOBODY ASKS WHY.",
				"facts": [
					{
						"type": "ATE",
						"character": "grandma",
						"object": "broccoli"
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
			"intro": "Page two. A boy. A cookie. And a head of broccoli that has sat on that table, untouched, since 2009. The broccoli is decorative.",
			"original": "The Kid ate the cookie. Of course he did. He's a child, not a rabbit.",
			"twist": "The Kid ate the BROCCOLI.",
			"win": "A child. Ate broccoli. On purpose. Nobody is going to believe this. I'm not sure I believe this. Somebody check him for a fever.",
			"fail": "The broccoli survives another day. It has survived worse.",
			"fail_alt": [
				"The cookie wins. The cookie always wins.",
				"The broccoli remains decorative."
			]
		},
		"dialogue": [
			{
				"character": "kid",
				"when": "lit",
				"line": "Cookie! Cookie! COOKIE!"
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Is someone... not eating that?"
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "Eat your greens, dear. I'm watching."
			},
			{
				"character": "kid",
				"when": "win",
				"line": "Mum? I think I'm... healthy?"
			},
			{
				"character": "grandma",
				"when": "win",
				"line": "I am so proud I could bonk someone."
			}
		],
		"tutorial": [
			"Pull the bulb down for a wider light."
		],
		"hints": [
			"If the Kid can see the cookie, he picks the cookie.",
			"Light only the Kid and the broccoli. The cookie and the Dog stay dark.",
			"Hang the bulb between the Kid and the broccoli and pull it low, so the light covers just those two."
		],
		"bonus_hints": [
			"Leave the Kid dark. Light the Dog with the broccoli.",
			"Swap Grandma's and the Dog's thoughts so Grandma is hungry, then light Grandma, the Dog and the broccoli."
		]
	}
