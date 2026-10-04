extends RefCounted
## Page 13/15 "The Haunted House", designed by the story thread (design/story.md, design/levels.md).
## Verified by design/levels_solver/audit15.py (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_15",
		"number": 13,
		"title": "The Haunted House",
		"voice": "haunted",
		"room": "living_room",
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
				4.0,
				-1.2,
				8.0,
				-0.6
			],
			"count": 1,
			"defaults": [
				{
					"x": 4.0,
					"y": -0.6,
					"enabled": true
				},
				{
					"x": 4.0,
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
				"id": "intern",
				"name": "Intern",
				"art": "intern",
				"slot": 1,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "boss",
				"name": "Boss",
				"art": "boss",
				"slot": 2,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "mouse",
				"name": "Mouse",
				"art": "mouse",
				"slot": 4,
				"facing": "R",
				"thought": "SHY",
				"contradiction": true
			},
			{
				"id": "kid",
				"name": "Kid",
				"art": "kid",
				"slot": 5,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": true
			},
			{
				"id": "grandma",
				"name": "Grandma",
				"art": "grandma",
				"slot": 10,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "coffin",
				"type": "SEAT",
				"art": "coffin",
				"slot": 0
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"slot": 6
			}
		],
		"original_caption": "The Kid ran screaming from the haunted house. The Mouse hid in the dark.",
		"endings_total": 17,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "THE INTERN BONKS THE BOSS, THE MOUSE RUNS FOR IT",
				"facts": [
					{
						"type": "BONKED",
						"character": "intern",
						"target": "boss"
					},
					{
						"type": "EXITED",
						"character": "mouse"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "GRANDMA RUNS SCREAMING. IT WAS ONLY THE KID.",
				"facts": [
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
					"type": "ASLEEP",
					"character": "boss",
					"object": "coffin"
				}
			],
			"twist_caption": "The BOSS took a nap in the COFFIN.",
			"red_pen_words": [
				"BOSS",
				"COFFIN"
			]
		},
		"narration": {
			"intro": "New genre. HORROR. It was a dark and stormy night. The Bulb family entered the haunted house. There is a coffin. There is a cake, for some reason. Be afraid, lamp. BE VERY AFRAID.",
			"original": "The Kid ran screaming from the haunted house, and the Mouse hid in the dark. Terrifying. I scared myself.",
			"twist": "The BOSS took a nap in the COFFIN.",
			"win": "The Intern bonked the Mouse in the dark, and the Boss climbed into a coffin for a nap. He says it's the best sleep he's had in years. He's ordered one for the office. This was a horror story. The scariest thing left in it is the Boss's snoring.",
			"fail": "BOO! ...Did that work? Please tell me that worked.",
			"fail_alt": [
				"The house remains haunted. Mostly by you.",
				"Spooky. Very spooky. For you, specifically."
			]
		},
		"dialogue": [
			{
				"character": "kid",
				"when": "lit",
				"line": "Is it haunted? I'm not scared. I'm leaving."
			},
			{
				"character": "mouse",
				"when": "lit",
				"line": "Nobody look at me. Especially ghosts."
			},
			{
				"character": "kid",
				"when": "swap",
				"line": "Don't look at me. Not even ghosts can look at me."
			},
			{
				"character": "mouse",
				"when": "swap",
				"line": "Is something behind me? EVERYTHING is behind me!"
			},
			{
				"character": "boss",
				"when": "win",
				"line": "Comfy. Roomy. Do they do these in executive?"
			},
			{
				"character": "intern",
				"when": "win",
				"line": "Sorry, Mouse! It was dark! It's always dark!"
			},
			{
				"character": "mouse",
				"when": "fail",
				"line": "I'm moving to a cookbook."
			}
		],
		"tutorial": [
			"Timing matters: the spare bulb wakes people the moment you drop it."
		],
		"hints": [
			"The Boss is sleepy and the coffin is right next to him, but he's in the dark, and so is the angry Intern.",
			"Swap the Kid and the Mouse, and light them both. The panicking Mouse runs straight at the Intern.",
			"Drop your spare bulb on the Intern and the Boss just as the Mouse arrives. The Intern bonks the Mouse, not the Boss."
		],
		"bonus_hints": [
			"Same plan as the twist, but drop the spare bulb too early. The Intern finds the Boss first.",
			"No swaps. Drop your spare bulb on Grandma, far in the corner, while the Kid is running her way."
		]
	}
