extends RefCounted
## Level 11/15 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_08",
		"number": 11,
		"room": "office",
		"narration_key": "powercut",
		"title": "Power Cut",
		"voice": "powercut",
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
				3.0,
				-1.2,
				6.0,
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
					"x": 3.0,
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
					0,
					2
				],
				"switch_id": "pedal",
				"initially_on": false
			}
		],
		"characters": [
			{
				"id": "dog",
				"name": "Dog",
				"art": "dog",
				"slot": 2,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "mouse",
				"name": "Mouse",
				"art": "mouse",
				"slot": 3,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": true
			},
			{
				"id": "boss",
				"name": "Boss",
				"art": "boss",
				"slot": 5,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "cat",
				"name": "Cat",
				"art": "cat",
				"slot": 7,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "intern",
				"name": "Intern",
				"art": "intern",
				"slot": 10,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "pie",
				"type": "FOOD",
				"art": "pie",
				"slot": 0
			},
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
				"slot": 8
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"slot": 9
			}
		],
		"original_caption": "The Mouse ran out of the comic.",
		"endings_total": 113,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "THE BOSS NAPS, THE INTERN BONKS THE MOUSE",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "boss",
						"object": "armchair"
					},
					{
						"type": "BONKED",
						"character": "intern",
						"target": "mouse"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "THE BOSS FLEES, THE MOUSE GETS THE CAKE",
				"facts": [
					{
						"type": "EXITED",
						"character": "boss"
					},
					{
						"type": "ATE",
						"character": "mouse",
						"object": "cake"
					}
				]
			}
		],
		"goal": {
			"facts": [
				{
					"type": "ASLEEP",
					"character": "mouse",
					"object": "armchair"
				},
				{
					"type": "ATE",
					"character": "dog",
					"object": "cake"
				}
			],
			"twist_caption": "The MOUSE napped in the armchair. The DOG ate the cake.",
			"red_pen_words": [
				"MOUSE",
				"DOG"
			]
		},
		"narration": {
			"intro": "Right. If you're going to ruin my comic, you can ruin it in the DARK. [click] There. Power's off. Good luck twisting what you can't see, lamp. ...Is that a spare bulb? Where did you get a SPARE BULB?",
			"original": "The Mouse ran out of the comic. Smart Mouse.",
			"twist": "The MOUSE napped in the armchair. The DOG ate the cake.",
			"win": "I cut the power. You brought a spare bulb. Who carries a SPARE BULB? The Mouse is asleep in an armchair like a tiny retired accountant, and the Dog has eaten the cake in total darkness. By SMELL.",
			"fail": "Darkness wins. I love darkness. I should have done this on page one.",
			"fail_alt": [
				"Still dark. Still mine.",
				"The Mouse has left the comic. Sensible."
			]
		},
		"dialogue": [
			{
				"character": "mouse",
				"when": "lit",
				"line": "Who turned off the lights?!"
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "I can smell it. I can't see it. I can SMELL it."
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "Is this a fire drill? I'm not doing a fire drill."
			},
			{
				"character": "mouse",
				"when": "swap",
				"line": "Actually... dark is quite cosy."
			},
			{
				"character": "dog",
				"when": "win",
				"line": "Found it. Ate it. Don't ask."
			}
		],
		"tutorial": [
			"Remember your spare bulb? During ACTION, click the rail once to drop it."
		],
		"hints": [
			"The Mouse panics next to the Dog. What if it was sleepy instead?",
			"Swap the Mouse and the Boss, and light the Dog and the Mouse. The cake corner still needs light.",
			"Light only the Dog and the Mouse. As soon as ACTION starts, drop the spare bulb on the Cat: she panics onto the pedal."
		],
		"bonus_hints": [
			"Swap the Dog and the Mouse. Light the Mouse and the Boss, then drop the spare bulb on the Intern.",
			"Swap the Dog and the Mouse, and the Boss and the Cat. Light the Mouse and the Boss, then drop the spare bulb on the Cat."
		]
	}
