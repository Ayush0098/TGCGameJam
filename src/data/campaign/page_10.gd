extends RefCounted
## Level 15/15 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_10",
		"number": 15,
		"room": "office",
		"narration_key": "finale",
		"title": "Lightbulb Moment",
		"difficulty": "red",
		"width": 12,
		"rail_span": [
			0,
			11
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
				-0.6
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
		"flick": 1,
		"fixed_lights": [],
		"lamps": [
			{
				"id": "lamp",
				"zone": [
					5,
					8
				],
				"switch_id": "pedal",
				"initially_on": false
			},
			{
				"id": "lamp_2",
				"zone": [
					9,
					11
				],
				"switch_id": "pedal_2",
				"initially_on": false
			}
		],
		"characters": [
			{
				"id": "kid",
				"name": "Kid",
				"art": "kid",
				"slot": 0,
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
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "intern",
				"name": "Intern",
				"art": "intern",
				"slot": 3,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Dog",
				"art": "dog",
				"slot": 5,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "grandma",
				"name": "Grandma",
				"art": "grandma",
				"slot": 8,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": true
			},
			{
				"id": "cat",
				"name": "Cat",
				"art": "cat",
				"slot": 11,
				"facing": "L",
				"thought": "SLEEPY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "pedal",
				"type": "SWITCH",
				"art": "pedal",
				"slot": 4
			},
			{
				"id": "chair",
				"type": "SEAT",
				"art": "chair",
				"slot": 6
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"slot": 8
			},
			{
				"id": "pedal_2",
				"type": "SWITCH",
				"art": "pedal",
				"slot": 9
			}
		],
		"original_caption": "The Boss and the Intern had the same bad idea.",
		"endings_total": 45,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "THE KID GETS THE CAKE. OF COURSE HE DOES.",
				"facts": [
					{
						"type": "ATE",
						"character": "kid",
						"object": "cake"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "THE BOSS BONKS GRANDMA. BRAVE.",
				"facts": [
					{
						"type": "BONKED",
						"character": "boss",
						"target": "grandma"
					}
				]
			}
		],
		"goal": {
			"facts": [
				{
					"type": "ALL_ACTIVATED"
				}
			],
			"twist_caption": "EVERYONE had a lightbulb moment!",
			"red_pen_words": [
				"EVERYONE"
			]
		},
		"narration": {
			"intro": "The last page. I have no tricks left. No power cuts, no cats, no ghosts. Just a nice, quiet ending where nothing happens. Please. I'm begging you. Let nothing happen.",
			"original": "The Boss and the Intern had the same bad idea. Nobody else had any idea at all. The End. Quietly.",
			"twist": "EVERYONE had a lightbulb moment!",
			"win": "Everyone... everyone had a... [snort] The Dog has the cake AGAIN. Boss Cake Count: ZERO. [wheeze] Fifteen pages! ZERO! [laughing helplessly] Fine. FINE. It's funnier. Your version is funnier. You win, lamp. ...That was my lightbulb moment. THE END.",
			"fail": "Somebody's still in the dark. Good. Stay there.",
			"fail_alt": [
				"Nothing happened. Perfect. Beautiful. Don't touch it.",
				"So close, lamp. So close to ruining everything."
			]
		},
		"dialogue": [
			{
				"character": "boss",
				"when": "lit",
				"line": "My idea!"
			},
			{
				"character": "intern",
				"when": "lit",
				"line": "No, MY idea! I'm Nigel, by the way."
			},
			{
				"character": "kid",
				"when": "lit",
				"line": "I have an idea too! It's loud!"
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "Oh dear, a crowd. I'll get my slipper."
			},
			{
				"character": "cat",
				"when": "lit",
				"line": "Wake me when it's over."
			},
			{
				"character": "boss",
				"when": "swap",
				"line": "Is there... cake? For ME?"
			},
			{
				"character": "cat",
				"when": "win",
				"line": "Fine. That was a good one."
			}
		],
		"tutorial": [],
		"hints": [
			"Every lamp needs someone to cross its pedal, and two people are out of your reach.",
			"Make the Boss hungry: swap Intern and Dog, then Boss and Intern.",
			"Light the Intern and the Dog. As ACTION starts, drop the spare bulb between the Kid and the Boss so it wakes them both."
		],
		"bonus_hints": [
			"Pass the Dog's hunger down the line to the Kid: Dog to Intern, Intern to Boss, Boss to Kid.",
			"No swaps needed: light only the Boss, then drop the spare bulb on the Cat."
		],
		"finale": true
	}
