extends RefCounted
## Page 5/15 "Stage Fright", designed by the story thread (design/story.md, design/levels.md).
## Verified by design/levels_solver/audit15.py (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_11",
		"number": 5,
		"title": "Stage Fright",
		"room": "living_room",
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
				6.0,
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
		"fixed_lights": [],
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
				"facing": "L",
				"thought": "SHY",
				"contradiction": true
			},
			{
				"id": "boss",
				"name": "Boss",
				"art": "boss",
				"slot": 5,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Dog",
				"art": "dog",
				"slot": 10,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "armchair",
				"type": "SEAT",
				"art": "armchair",
				"slot": 1
			},
			{
				"id": "pedal",
				"type": "SWITCH",
				"art": "pedal",
				"slot": 4
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"slot": 8
			}
		],
		"original_caption": "The Kid hid from the spotlight. The talent show was cancelled.",
		"endings_total": 11,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "GRANDMA SLEEPS THROUGH THE SHOW, THE KID HIDES",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "grandma",
						"object": "armchair"
					},
					{
						"type": "HIDING",
						"character": "kid"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "THE KID NAPS, GRANDMA STORMS OFF STAGE",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "kid",
						"object": "armchair"
					},
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
					"type": "HIDING",
					"character": "boss"
				},
				{
					"type": "ATE",
					"character": "dog",
					"object": "cake"
				}
			],
			"twist_caption": "The BOSS hid from the spotlight. The DOG ate the prize cake.",
			"red_pen_words": [
				"BOSS",
				"DOG"
			]
		},
		"narration": {
			"intro": "The Bulb Family Talent Show! The Kid will sing. The Kid is shy, so the Kid will not sing. The Boss will do impressions of himself. There is a prize cake.",
			"original": "The Kid hid from the spotlight. The talent show was cancelled due to a lack of talent.",
			"twist": "The BOSS hid from the spotlight. The DOG ate the prize cake.",
			"win": "The Boss, a man who once gave a ninety-minute speech about his own parking space, hid from a lightbulb. The Dog won the talent show. His talent was cake. Boss Cake Count: still zero.",
			"fail": "The show must go on. It didn't.",
			"fail_alt": [
				"Talent show cancelled. Refunds will not be given.",
				"A stunning display of no talent at all."
			]
		},
		"dialogue": [
			{
				"character": "kid",
				"when": "lit",
				"line": "Don't look at me don't look at me don't look at—"
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "Stand back. I do impressions. Of me."
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "I'll be judging. Harshly."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "The prize is cake? I'm entering."
			},
			{
				"character": "boss",
				"when": "swap",
				"line": "Why is everyone LOOKING at me?!"
			},
			{
				"character": "dog",
				"when": "win",
				"line": "Thank you, thank you. No autographs."
			}
		],
		"tutorial": [
			"NEW FEELING: SHY. A shy character in the light walks to the nearest dark spot and hides. Your light pushes them around!"
		],
		"hints": [
			"A shy character runs to the nearest dark spot. Your light decides which way they run.",
			"Give the Boss the Kid's shyness. Someone has to step on the pedal to light up the Dog's corner.",
			"Swap the Kid and the Boss. Light only the Boss, shining from his right, so he runs left onto the pedal."
		],
		"bonus_hints": [
			"No swaps. Just light Grandma and the Kid together.",
			"Swap Grandma and the Kid, and light them both. Guess who leaves the comic."
		],
		"new_feeling": "SHY"
	}
