extends RefCounted
## Page 9 "Lost in Vindhya", IIIT-H story rev 4 (design/story_proposal.md, design/build_p4_15/spec.md).
## Layout page_07; star ladder verified by the solver (levels_solver/ladder), 0.2 and 0.02 lantern grids: ideas 4/2/1.


static func definition() -> Dictionary:
	return {
		"id": "page_09",
		"number": 9,
		"title": "Lost in Vindhya",
		"difficulty": "yellow",
		"room": "vindhya",
		"voice": "page_09",
		"source_layout": "page_07",
		"width": 11,
		"rail_span": [
			0,
			10
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
				0.0,
				-1.2,
				10.0,
				0.6
			],
			"count": 1,
			"defaults": [
				{
					"x": 6.0,
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
		"obstacles": [
			{
				"id": "screen",
				"name": "projector screen",
				"from": [
					3.5,
					-0.45
				],
				"to": [
					3.5,
					0.8
				]
			}
		],
		"flick": 0,
		"fixed_lights": [],
		"lamps": [],
		"characters": [
			{
				"id": "mouse",
				"name": "Faccha",
				"art": "mouse",
				"slot": 1,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "boss",
				"name": "Prof",
				"art": "boss",
				"slot": 4,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "kid",
				"name": "Saap",
				"art": "kid",
				"slot": 5,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "grandma",
				"name": "Mess Aunty",
				"art": "grandma",
				"slot": 6,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": true
			},
			{
				"id": "intern",
				"name": "Kassi",
				"art": "intern",
				"slot": 7,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "prompt",
				"name": "Prompt Bhai",
				"art": "kid",
				"slot": 8,
				"facing": "L",
				"thought": "ANGRY",
				"contradiction": false,
				"phone_glow": true,
				"tint": "#7FD3FF"
			}
		],
		"objects": [
			{
				"id": "bean_bag",
				"type": "SEAT",
				"art": "cushion",
				"name": "bean bag",
				"slot": 0
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"name": "cake",
				"slot": 3
			},
			{
				"id": "pineapple",
				"type": "FOOD",
				"art": "pineapple_reserved",
				"name": "pineapple (RESERVED: ISHAAN SIR)",
				"slot": 10
			}
		],
		"original_caption": "Mess Aunty bonked the Kassi, and the Saap bonked Mess Aunty.",
		"endings_total": 82,
		"goal": {
			"facts": [
				{
					"type": "BONKED",
					"character": "boss",
					"target": "grandma"
				}
			],
			"twist_caption": "The PROF bonked MESS AUNTY.",
			"red_pen_words": [
				"PROF",
				"MESS AUNTY"
			]
		},
		"ladder": [
			{
				"id": "star_2",
				"caption": "…and the Saap found the EXIT.",
				"facts": [
					{
						"type": "EXITED",
						"character": "kid"
					}
				]
			},
			{
				"id": "star_3",
				"caption": "…and Mess Aunty bonked the Kassi anyway.",
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
			"intro": "'Re: Re: Re: PLEASE STOP REPLYING ALL.' Vindhya. Four staircases, three go somewhere. You entered on floor two. You are now on floor two and a half. It does not exist. Also, a pineapple, reserved for Ishaan Romil sir. That's all we know.",
			"original": "Mess Aunty bonked the Kassi, and the Saap bonked Mess Aunty. Behind the projector screen. Classic Vindhya.",
			"twist": "The PROF bonked MESS AUNTY.",
			"win": "The Prof bonked Mess Aunty. They were not lost together. They were lost separately, in the same corridor, for forty minutes.",
			"stars": [
				"And the Saap found the EXIT. The actual exit. Nobody has found it since 2014. He says he didn't even look.",
				"And Mess Aunty bonked the Kassi anyway. Some traditions survive Vindhya. Ishaan sir, the pineapple is still yours."
			],
			"fails": [
				"Still lost. Floor two and three quarters.",
				"The shadow people saw nothing. Checked as per rubric.",
				"The pineapple remains reserved. So does my dignity."
			],
			"hidden": []
		},
		"dialogue": [
			{
				"character": "boss",
				"when": "lit",
				"line": "I came in for a faculty meeting in 2019."
			},
			{
				"character": "boss",
				"when": "gets_ANGRY",
				"line": "Aunty, I KNOW where I'm going! …Where are we?"
			},
			{
				"character": "kid",
				"when": "lit",
				"line": "Bro, I'm not lost. I just didn't study the map."
			},
			{
				"character": "kid",
				"when": "gets_SCARED",
				"line": "Okay, I'm leaving. Left, left, up, the weird door. Bye."
			},
			{
				"character": "prompt",
				"when": "lit",
				"line": "ChatGPT said 'turn left at the Vindhya'. Thanks."
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "I came to deliver Pappu. Who wants a bonk?"
			},
			{
				"character": "intern",
				"when": "lit",
				"line": "I was giving a tour. The tour has left."
			},
			{
				"character": "mouse",
				"when": "lit",
				"line": "We shared LOGIC, not code! Where's the MOSS hearing?"
			}
		],
		"stickers": [
			{
				"text": "Rumour Meter: LOST IN VINDHYA, TOGETHER",
				"when": "result"
			},
			{
				"text": "Kassi Attempt #410: Vindhya tour guide. ✗",
				"when": "result"
			}
		],
		"hints": [
			"The Prof has to be the angry one. The Saap has the anger.",
			"Swap the Prof's and the Saap's thoughts.",
			"Light the Prof, the Saap and Mess Aunty together, and keep Prompt Bhai in the dark."
		],
		"star_hints": [
			"Stretch your light to the Kassi as well. The scared Saap then runs for the exit.",
			"Swap only the Prof and the Saap, and light all four from the Prof to the Kassi."
		],
		"manhunt": {
			"subject": "Re: Re: Re: PLEASE STOP REPLYING ALL",
			"unread": "3,333",
			"suspect": "#4 The Faccha. A known MOSS case.",
			"clue": "It begins: 'Certainly! Here's a strongly worded email to the Dean:'"
		},
		"achievement": {
			"id": "escaped_vindhya",
			"name": "Escaped Vindhya",
			"when": "star_2 on this page"
		},
		"voice_lengths_s": {
			"page_09_intro": [
				14.0,
				20.0
			],
			"page_09_original": [
				5.5,
				8.0
			],
			"page_09_twist": [
				1.5,
				2.5
			],
			"page_09_win": [
				7.0,
				9.5
			],
			"page_09_stars_1": [
				7.0,
				9
			],
			"page_09_stars_2": [
				6.0,
				8.5
			],
			"page_09_fails_1": [
				2.5,
				3.0
			],
			"page_09_fails_2": [
				3.0,
				4.0
			],
			"page_09_fails_3": [
				2.5,
				3.5
			],
			"page_09_dialogue_boss_lit": [
				3.0,
				4.0
			],
			"page_09_dialogue_boss_gets_ANGRY": [
				3.0,
				4.0
			],
			"page_09_dialogue_kid_lit": [
				3.5,
				4.5
			],
			"page_09_dialogue_kid_gets_SCARED": [
				3.5,
				4.5
			],
			"page_09_dialogue_prompt_lit": [
				2.5,
				3.5
			],
			"page_09_dialogue_grandma_lit": [
				3.0,
				4.0
			],
			"page_09_dialogue_intern_lit": [
				3.0,
				4.0
			],
			"page_09_dialogue_mouse_lit": [
				3.0,
				4.0
			]
		},
		"solver": {
			"ideas": [
				4,
				2,
				1
			],
			"win_percent": [
				0.8,
				0.4,
				0.2
			],
			"grids": [
				0.2,
				0.02
			]
		}
	}
