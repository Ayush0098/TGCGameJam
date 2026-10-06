extends RefCounted
## Page 6 "The Prof's Birthday", IIIT-H story rev 4 (design/story_proposal.md, design/build_p4_15/spec.md).
## Layout page_05; star ladder verified by the solver (levels_solver/ladder), 0.2 and 0.02 lantern grids: ideas 4/2/1.


static func definition() -> Dictionary:
	return {
		"id": "page_06",
		"number": 6,
		"title": "The Prof's Birthday",
		"difficulty": "yellow",
		"room": "prof_lab",
		"voice": "page_06",
		"source_layout": "page_05",
		"width": 11,
		"rail_span": [
			0,
			10
		],
		"spotlights": {
			"count": 1,
			"default_centres": [
				5
			]
		},
		"lanterns": {
			"radius": 1.6,
			"bounds": [
				0.0,
				-1.2,
				5.0,
				-0.6
			],
			"count": 1,
			"defaults": [
				{
					"x": 5.0,
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
				"switch_id": "switch",
				"initially_on": false
			}
		],
		"characters": [
			{
				"id": "intern",
				"name": "Kassi",
				"art": "kassi",
				"slot": 3,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": true
			},
			{
				"id": "grandma",
				"name": "Mess Aunty",
				"art": "aunty",
				"slot": 2,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": true
			},
			{
				"id": "boss",
				"name": "Prof",
				"art": "prof",
				"slot": 4,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Chintu",
				"art": "dog",
				"slot": 9,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "prof_chair",
				"type": "SEAT",
				"art": "office_chair",
				"name": "Prof's chair",
				"slot": 0
			},
			{
				"id": "birthday_cake",
				"type": "FOOD",
				"art": "cake",
				"name": "birthday cake",
				"slot": 6
			},
			{
				"id": "switch",
				"type": "SWITCH",
				"art": "pedal",
				"name": "lab light switch",
				"slot": 7
			}
		],
		"original_caption": "The Prof ate his birthday cake.",
		"endings_total": 17,
		"goal": {
			"facts": [
				{
					"type": "ATE",
					"character": "dog",
					"object": "birthday_cake"
				}
			],
			"twist_caption": "CHINTU ate the birthday cake.",
			"red_pen_words": [
				"CHINTU"
			]
		},
		"ladder": [
			{
				"id": "star_2",
				"caption": "…and the Prof ran out of his own party.",
				"facts": [
					{
						"type": "EXITED",
						"character": "boss"
					}
				]
			},
			{
				"id": "star_3",
				"caption": "…and Mess Aunty bonked the Kassi.",
				"facts": [
					{
						"type": "BONKED",
						"character": "grandma",
						"target": "intern"
					}
				]
			}
		],
		"narration": {
			"intro": "'URGENT: Regarding the mail.' Eight hundred and forty-seven unread. Anyway. It's the Prof's birthday. He sent the invite himself: attendance mandatory, eighty-five percent. Mess Aunty is here. Nobody invited Mess Aunty. Interesting. Not a rumour. Just interesting.",
			"original": "The Prof ate his birthday cake. Happy birthday, sir. Please don't fail us.",
			"twist": "CHINTU ate the birthday cake.",
			"win": "Happy birthday, Prof. Chintu says thank you for the cake. Prof Cake Count: zero. Chintu has a TA now.",
			"stars": [
				"And the Prof ran out of his own party. Attendance: eighty-five percent. Of everyone except him.",
				"And Mess Aunty bonked the Kassi. He asked her where the facchis were sitting. Challenge rejected. Minus three."
			],
			"fails": [
				"The Prof ate his cake. Checked as per rubric.",
				"Happy birthday to the Prof, and to nobody else.",
				"Challenge rejected. Minus three."
			],
			"hidden": []
		},
		"dialogue": [
			{
				"character": "boss",
				"when": "lit",
				"line": "My cake. My party. Mark your attendance."
			},
			{
				"character": "boss",
				"when": "gets_SCARED",
				"line": "Everyone's LOOKING at me! It's my birthday, not my viva!"
			},
			{
				"character": "intern",
				"when": "lit",
				"line": "My plus-one has a quiz. Again."
			},
			{
				"character": "intern",
				"when": "gets_HUNGRY",
				"line": "Can I have cake? Is cake in the rubric?"
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "I brought Pappu. For everyone. Mostly him."
			},
			{
				"character": "grandma",
				"when": "gets_ANGRY",
				"line": "Who asked where the facchis are sitting? Beta. BETA."
			},
			{
				"character": "dog",
				"when": "win",
				"line": "Best. Party. Ever."
			}
		],
		"stickers": [
			{
				"text": "Rumour Meter: UNCONFIRMED",
				"when": "result"
			},
			{
				"text": "Kassi Attempt #408: birthday plus-one. ✗",
				"when": "result"
			}
		],
		"hints": [
			"Chintu can't see the cake while the lab light is off. Someone running out of the lab will step on the switch.",
			"The Prof must not eat his cake. Give him Mess Aunty's fear.",
			"Light the Prof, Mess Aunty and the Kassi together, then press ACTION."
		],
		"star_hints": [
			"Swap the Prof's hunger with Mess Aunty's fear and light all three: the Prof runs out of his own party.",
			"Pass the thoughts round instead: the Prof gets Mess Aunty's fear, Mess Aunty gets the Kassi's anger, the Kassi gets the Prof's hunger. Light all three."
		],
		"manhunt": {
			"subject": "URGENT: Regarding the mail",
			"unread": "847",
			"suspect": "#1 The Kassi. He has challenged every TA since UG-1.",
			"clue": "Sent at 1:04 AM."
		},
		"act_card_before": {
			"number": 2,
			"title": "ACT TWO: QUIZ-1: THE MANHUNT",
			"text": "Dear all. Someone has mailed the Dean that the TAs of this comic 'do not know basic things'. The Dean did not reply. The Dean called the Prof. The Prof called the TAs. The TAs are me. First no salary hike, and now this. Effective immediately: all endings will be checked strictly as per rubric. All submissions will be MOSSed. Yes, again. Regards."
		},
		"voice_lengths_s": {
			"page_06_intro": [
				12.0,
				17.0
			],
			"page_06_original": [
				4.0,
				6.0
			],
			"page_06_twist": [
				1.5,
				2.5
			],
			"page_06_win": [
				6.0,
				9.0
			],
			"page_06_stars_1": [
				5.0,
				7.5
			],
			"page_06_stars_2": [
				6.0,
				8.5
			],
			"page_06_fails_1": [
				3.0,
				4.0
			],
			"page_06_fails_2": [
				3.0,
				4.0
			],
			"page_06_fails_3": [
				1.5,
				2.0
			],
			"page_06_dialogue_boss_lit": [
				2.5,
				3.0
			],
			"page_06_dialogue_boss_gets_SCARED": [
				3.5,
				4.5
			],
			"page_06_dialogue_intern_lit": [
				2.0,
				3.0
			],
			"page_06_dialogue_intern_gets_HUNGRY": [
				3.0,
				4.0
			],
			"page_06_dialogue_grandma_lit": [
				2.5,
				3.0
			],
			"page_06_dialogue_grandma_gets_ANGRY": [
				3.0,
				4.0
			],
			"page_06_dialogue_dog_win": [
				1.0,
				1.5
			],
			"act2": [
				20.5,
				28
			]
		},
		"solver": {
			"ideas": [
				4,
				2,
				1
			],
			"win_percent": [
				7.576,
				3.03,
				1.515
			],
			"grids": [
				0.2,
				0.02
			]
		}
	}
