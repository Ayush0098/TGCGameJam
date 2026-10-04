extends RefCounted
## Page 14/15 "Wedding Crashers", designed by the story thread (design/story.md, design/levels.md).
## Verified by design/levels_solver/audit15.py (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_14",
		"number": 14,
		"title": "Wedding Crashers",
		"room": "living_room",
		"difficulty": "red",
		"width": 9,
		"rail_span": [
			0,
			8
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
				5.0,
				-1.2,
				7.0,
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
					"x": 5.0,
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
				"id": "mouse",
				"name": "Mouse",
				"art": "mouse",
				"slot": 2,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
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
				"slot": 5,
				"facing": "R",
				"thought": "JEALOUS",
				"contradiction": false
			},
			{
				"id": "grandma",
				"name": "Grandma",
				"art": "grandma",
				"slot": 6,
				"facing": "R",
				"thought": "IN_LOVE",
				"contradiction": false
			},
			{
				"id": "cat",
				"name": "Cat",
				"art": "cat",
				"slot": 7,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": true
			}
		],
		"objects": [
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"slot": 1
			},
			{
				"id": "chair",
				"type": "SEAT",
				"art": "chair",
				"slot": 8
			}
		],
		"original_caption": "The Cat objected. Grandma was bonked at her own wedding.",
		"endings_total": 108,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "THE BOSS OBJECTS: HE BONKS THE CAT",
				"facts": [
					{
						"type": "BONKED",
						"character": "boss",
						"target": "cat"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "CAT AND MOUSE HUG, THE BOSS FINALLY EATS A CAKE. NOT HIS.",
				"facts": [
					{
						"type": "HUGGED",
						"character": "cat",
						"target": "mouse"
					},
					{
						"type": "ATE",
						"character": "boss",
						"object": "cake"
					}
				]
			}
		],
		"goal": {
			"facts": [
				{
					"type": "HUGGED",
					"character": "cat",
					"target": "mouse"
				},
				{
					"type": "ATE",
					"character": "dog",
					"object": "cake"
				}
			],
			"twist_caption": "The CAT hugged the MOUSE. The DOG ate the wedding cake.",
			"red_pen_words": [
				"CAT",
				"MOUSE",
				"DOG"
			]
		},
		"narration": {
			"intro": "Grandma and the Boss are getting married. Yes. Because of one hug on page eight. I take no responsibility. The Cat has been asked not to object. The Cat has objected to everything since 2016.",
			"original": "The Cat objected. Grandma was bonked at her own wedding. Lovely ceremony. Very moving.",
			"twist": "The CAT hugged the MOUSE. The DOG ate the wedding cake.",
			"win": "The bride hugged the Cat. The Cat hugged the Mouse. The groom is still looking for the cake, which the Dog ate. By the power vested in me by absolutely nobody, I now pronounce this... whatever this is. You may hug the Mouse.",
			"fail": "Somebody objected. Somebody always objects.",
			"fail_alt": [
				"The wedding is off. The cake is not.",
				"Dearly beloved, we are gathered here today to watch you fail."
			]
		},
		"dialogue": [
			{
				"character": "grandma",
				"when": "lit",
				"line": "I do! I do! Do I? I do!"
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "Is there cake at this thing? I'm only here for the cake."
			},
			{
				"character": "cat",
				"when": "lit",
				"line": "I object. To everything. Generally."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "I'm not jealous. Who's the cake for? I'm jealous."
			},
			{
				"character": "mouse",
				"when": "lit",
				"line": "Am I invited? I'm never invited."
			},
			{
				"character": "cat",
				"when": "swap",
				"line": "Why does the DOG get to want things?"
			},
			{
				"character": "boss",
				"when": "swap",
				"line": "I OBJECT!"
			},
			{
				"character": "dog",
				"when": "swap",
				"line": "Forget jealousy. CAKE."
			},
			{
				"character": "cat",
				"when": "win",
				"line": "I don't know what happened. I love him. He's delicious. DELIGHTFUL. I meant delightful."
			},
			{
				"character": "mouse",
				"when": "win",
				"line": "Weirdest day of my life, and I live in a comic."
			}
		],
		"tutorial": [],
		"hints": [
			"The bride hugs whoever is closest, and love spreads. The Mouse and the cake are asleep in the dark.",
			"Shuffle three thoughts: the Boss gets angry, the Cat gets jealous, the Dog gets hungry. Light the Dog, Grandma and the Cat.",
			"When ACTION starts, drop your spare bulb on the Mouse and the cake together."
		],
		"bonus_hints": [
			"Make the Boss angry, and wake him with your spare bulb right when ACTION starts.",
			"Give the Cat Grandma's love, Grandma the Dog's jealousy, and the Dog the Cat's anger. Light the Boss as well, then wake the Mouse."
		]
	}
