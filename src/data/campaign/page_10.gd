extends RefCounted
## Page 10 "DASA Workspace, 2 AM", IIIT-H story rev 4 (design/story_proposal.md, design/build_p4_15/spec.md).
## Layout page_13; star ladder verified by the solver (levels_solver/ladder), 0.2 and 0.02 lantern grids: ideas 3/2/1.


static func definition() -> Dictionary:
	return {
		"id": "page_10",
		"number": 10,
		"title": "DASA Workspace, 2 AM",
		"difficulty": "yellow",
		"room": "dasa_workspace",
		"voice": "page_10",
		"source_layout": "page_13",
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
				"switch_id": "switch",
				"initially_on": false
			}
		],
		"characters": [
			{
				"id": "intern",
				"name": "Kassi",
				"art": "intern",
				"slot": 2,
				"facing": "R",
				"thought": "JEALOUS",
				"contradiction": true
			},
			{
				"id": "grandma",
				"name": "Mess Aunty",
				"art": "grandma",
				"slot": 3,
				"facing": "L",
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "prompt",
				"name": "Prompt Bhai",
				"art": "kid",
				"slot": 4,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false,
				"phone_glow": true,
				"tint": "#7FD3FF"
			},
			{
				"id": "dog",
				"name": "Chintu",
				"art": "dog",
				"slot": 5,
				"facing": "L",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "boss",
				"name": "Prof",
				"art": "boss",
				"slot": 7,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "bean_bag",
				"type": "SEAT",
				"art": "cushion",
				"name": "bean bag",
				"slot": 1
			},
			{
				"id": "slice",
				"type": "FOOD",
				"art": "slice",
				"name": "slice of cake ('for you :)')",
				"slot": 6
			},
			{
				"id": "switch",
				"type": "SWITCH",
				"art": "pedal",
				"name": "workspace light switch",
				"slot": 8
			}
		],
		"original_caption": "The Kassi napped on the bean bag, Mess Aunty bonked Chintu, and the Prof ran off.",
		"endings_total": 68,
		"goal": {
			"facts": [
				{
					"type": "ATE",
					"character": "intern",
					"object": "slice"
				}
			],
			"twist_caption": "The KASSI ate the last slice.",
			"red_pen_words": [
				"KASSI"
			]
		},
		"ladder": [
			{
				"id": "star_2",
				"caption": "…and the Prof ran off screaming.",
				"facts": [
					{
						"type": "EXITED",
						"character": "boss"
					}
				]
			},
			{
				"id": "star_3",
				"caption": "…while Mess Aunty and Chintu CLONKED heads.",
				"facts": [
					{
						"type": "CLONK",
						"character": "dog"
					}
				]
			}
		],
		"narration": {
			"intro": "'Re: Re: Re: Re: unsubscribe.' The DASA workspace, 2 AM. Every bench has a couple on it. In the corner, a TA explains recursion to a fresher for the third hour. Recursively. The Kassi bought a slice of cake for a facchi. She brought her boyfriend.",
			"original": "The Kassi napped, Mess Aunty bonked Chintu, and the Prof fled the public display of affection.",
			"twist": "The KASSI ate the last slice.",
			"win": "The Kassi ate the slice. The one he bought for her. The note said 'for you', and he decided it was for him. Attempt four hundred and twelve: ACCEPTED. Phoda machaya!",
			"stars": [
				"And the Prof ran off screaming. He came to book a room. He saw the benches. He's writing a circular.",
				"And Mess Aunty and Chintu CLONKED heads, racing for something neither of them wanted. Kassi Cake Count: ONE."
			],
			"fails": [
				"Somebody else got the slice. Attempt four hundred and twelve: failed.",
				"The slice is claimed. Not by you.",
				"Lite le, Kassi. There's always four hundred and thirteen."
			],
			"hidden": []
		},
		"dialogue": [
			{
				"character": "intern",
				"when": "lit",
				"line": "Every bench. EVERY bench."
			},
			{
				"character": "intern",
				"when": "gets_HUNGRY",
				"line": "Wait… I'm allowed to want things? For myself?"
			},
			{
				"character": "intern",
				"when": "win",
				"line": "Four hundred and twelve attempts. This one was for me."
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "Beta, it's 2 AM. This is a WORKSPACE. Work! Space!"
			},
			{
				"character": "grandma",
				"when": "gets_JEALOUS",
				"line": "Ooh, what's he got? I want what he's got."
			},
			{
				"character": "prompt",
				"when": "lit",
				"line": "'You're absolutely right!' Same code. Again."
			},
			{
				"character": "prompt",
				"when": "gets_ANGRY",
				"line": "Wrong Answer. Eleven times. I'm done being polite."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Nap first. Then cake. Then nap."
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "Is this a WORKSPACE or a PROM? I'm writing a circular."
			}
		],
		"stickers": [
			{
				"text": "Kassi Attempt #412: ✓ (for himself)",
				"when": "result_win"
			},
			{
				"text": "Series 2, attempt #1: get an LoR.",
				"when": "result_win"
			}
		],
		"hints": [
			"The Kassi has to want the slice for himself. He needs a hunger, and Mess Aunty takes his jealousy.",
			"Pass the thoughts round: Kassi to Mess Aunty, Mess Aunty to Prompt Bhai, Prompt Bhai to the Kassi.",
			"Light the Prof and Chintu. The scared Prof runs out over the switch, and the Kassi's corner lights up."
		],
		"star_hints": [
			"Keep the Prof lit, so he runs out of the room.",
			"Pass the thoughts round: the Kassi gets Prompt Bhai's hunger, Mess Aunty gets the Kassi's jealousy, Prompt Bhai gets her anger. Leave Chintu sleepy."
		],
		"new_feeling": "JEALOUS",
		"tutorial": [
			"NEW FEELING: JEALOUS. Wants whatever the nearest busy character is going for, and races them to it. Two arriving at once? CLONK!"
		],
		"manhunt": {
			"subject": "Re: Re: Re: Re: unsubscribe",
			"unread": "5,000",
			"suspect": "#5 PROMPT BHAI.",
			"clue": "It ends: 'Let me know if you'd like it more polite! 😊'"
		},
		"voice_lengths_s": {
			"page_10_intro": [
				15.0,
				20
			],
			"page_10_original": [
				5.0,
				7.5
			],
			"page_10_twist": [
				2.0,
				3.0
			],
			"page_10_win": [
				10.0,
				14
			],
			"page_10_stars_1": [
				6.5,
				9.0
			],
			"page_10_stars_2": [
				6.0,
				8.5
			],
			"page_10_fails_1": [
				3.5,
				5.0
			],
			"page_10_fails_2": [
				2.5,
				3.0
			],
			"page_10_fails_3": [
				3.0,
				4.0
			],
			"page_10_dialogue_intern_lit": [
				1.5,
				2.0
			],
			"page_10_dialogue_intern_gets_HUNGRY": [
				2.5,
				3.5
			],
			"page_10_dialogue_intern_win": [
				3.5,
				4.5
			],
			"page_10_dialogue_grandma_lit": [
				3.5,
				4.5
			],
			"page_10_dialogue_grandma_gets_JEALOUS": [
				3.0,
				4.0
			],
			"page_10_dialogue_prompt_lit": [
				2.0,
				3.0
			],
			"page_10_dialogue_prompt_gets_ANGRY": [
				2.5,
				3.5
			],
			"page_10_dialogue_dog_lit": [
				2.0,
				3.0
			],
			"page_10_dialogue_boss_lit": [
				3.5,
				4.5
			],
			"page_10_card": [
				7.0,
				10.0
			]
		},
		"solver": {
			"ideas": [
				3,
				2,
				1
			],
			"win_percent": [
				0.312,
				0.208,
				0.104
			],
			"grids": [
				0.2,
				0.02
			]
		}
	}
