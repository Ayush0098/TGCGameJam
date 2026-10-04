extends RefCounted
## Page 10/15 "The Last Slice", designed by the story thread (design/story.md, design/levels.md).
## Verified by design/levels_solver/audit15.py (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_13",
		"number": 10,
		"title": "The Last Slice",
		"room": "kitchen",
		"difficulty": "yellow",
		"width": 9,
		"rail_span": [
			0,
			8
		],
		"spotlights": {
			"count": 1,
			"default_centres": [
				6
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
					"x": 6.0,
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
		"flick": 0,
		"fixed_lights": [],
		"lamps": [
			{
				"id": "lamp",
				"zone": [
					1,
					3
				],
				"switch_id": "pedal",
				"initially_on": false
			}
		],
		"characters": [
			{
				"id": "intern",
				"name": "Intern",
				"art": "intern",
				"slot": 2,
				"facing": "R",
				"thought": "JEALOUS",
				"contradiction": true
			},
			{
				"id": "grandma",
				"name": "Grandma",
				"art": "grandma",
				"slot": 3,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "kid",
				"name": "Kid",
				"art": "kid",
				"slot": 4,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Dog",
				"art": "dog",
				"slot": 5,
				"facing": "L",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "boss",
				"name": "Boss",
				"art": "boss",
				"slot": 6,
				"facing": "L",
				"thought": "SCARED",
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
				"id": "slice",
				"type": "FOOD",
				"art": "slice",
				"slot": 7
			},
			{
				"id": "pedal",
				"type": "SWITCH",
				"art": "pedal",
				"slot": 8
			}
		],
		"original_caption": "Grandma ate the last slice. The Boss ran off screaming. The Dog slept through it.",
		"endings_total": 24,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "GRANDMA NAPS, THE DOG GETS THE LAST SLICE",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "grandma",
						"object": "armchair"
					},
					{
						"type": "ATE",
						"character": "dog",
						"object": "slice"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "THE KID NAPS, THE DOG RUNS FOR HIS LIFE",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "kid",
						"object": "armchair"
					},
					{
						"type": "EXITED",
						"character": "dog"
					}
				]
			}
		],
		"goal": {
			"facts": [
				{
					"type": "CLONK",
					"character": "grandma"
				},
				{
					"type": "CLONK",
					"character": "dog"
				},
				{
					"type": "ATE",
					"character": "intern",
					"object": "slice"
				}
			],
			"twist_caption": "Grandma and the Dog CLONKED heads over the armchair. The INTERN ate the last slice.",
			"red_pen_words": [
				"CLONKED",
				"INTERN"
			]
		},
		"narration": {
			"intro": "The morning after the Boss's birthday. One slice of cake survived. One. And the Intern, Doug? Dave? Doug, is jealous of everyone. Which is fair. Nobody has ever invited him to anything.",
			"original": "Grandma ate the last slice. The Boss ran off screaming. The Dog slept through it. A quiet morning.",
			"twist": "Grandma and the Dog CLONKED heads over the armchair. The INTERN ate the last slice.",
			"win": "The Intern ate the last slice. The INTERN. He wasn't even invited to this PAGE. Meanwhile Grandma and the Dog knocked each other out over an armchair neither of them owns. Boss Cake Count: zero. Intern Cake Count: ONE. The Boss has asked HR to investigate.",
			"fail": "Grandma got the last slice. Grandma always gets the last slice. Grandma has a system.",
			"fail_alt": [
				"The Intern remains jealous. And slice-less.",
				"The slice has been claimed. Not by you."
			]
		},
		"dialogue": [
			{
				"character": "intern",
				"when": "lit",
				"line": "Why does everyone else get things? I want things."
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "That slice has my name on it. I wrote it there."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Nap first. Then cake. Then nap."
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "Who left a DOG near my cake?!"
			},
			{
				"character": "kid",
				"when": "lit",
				"line": "Is that the last slice? Can I just lick it?"
			},
			{
				"character": "grandma",
				"when": "swap",
				"line": "Ooh, what's HE got? I want what he's got."
			},
			{
				"character": "intern",
				"when": "swap",
				"line": "Wait... I'm allowed to WANT things?"
			},
			{
				"character": "intern",
				"when": "win",
				"line": "I've never been invited to anything. Best day of my life."
			}
		],
		"tutorial": [
			"NEW FEELING: JEALOUS. Wants whatever the nearest busy character is going for, and races them to it. Two arriving at once? CLONK!"
		],
		"hints": [
			"A jealous character wants whatever the nearest busy character is going for. Even an armchair.",
			"Give Grandma the Intern's jealousy. The Dog will be heading for the armchair, and she'll want it too.",
			"Swap the Intern and Grandma. Light only the Dog and the Boss: the Boss bolts over the pedal and wakes everyone."
		],
		"bonus_hints": [
			"Grandma takes the Dog's sleepiness, the Dog takes the Intern's jealousy. Light the Dog and the Boss.",
			"Big shuffle: the Dog scared, the Kid sleepy, the Intern hungry, the Boss jealous. Light the Kid and the Dog, not the Boss."
		],
		"new_feeling": "JEALOUS"
	}
