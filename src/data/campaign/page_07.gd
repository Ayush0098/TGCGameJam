extends RefCounted
## Page 7 "Mess Aunty vs the Prof", IIIT-H story rev 4 (design/story_proposal.md, design/build_p4_15/spec.md).
## Layout page_06; star ladder verified by the solver (levels_solver/ladder), 0.2 and 0.02 lantern grids: ideas 6/2/1.


static func definition() -> Dictionary:
	return {
		"id": "page_07",
		"number": 7,
		"title": "Mess Aunty vs the Prof",
		"difficulty": "yellow",
		"room": "kadamba",
		"voice": "page_07",
		"source_layout": "page_06",
		"width": 11,
		"rail_span": [
			0,
			10
		],
		"spotlights": {
			"count": 2,
			"default_centres": [
				4
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
			"count": 2,
			"defaults": [
				{
					"x": 4.0,
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
					3,
					4
				],
				"switch_id": "switch",
				"initially_on": false
			}
		],
		"characters": [
			{
				"id": "prompt",
				"name": "Prompt Bhai",
				"art": "kid",
				"slot": 1,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false,
				"phone_glow": true,
				"tint": "#7FD3FF"
			},
			{
				"id": "dog",
				"name": "Chintu",
				"art": "dog",
				"slot": 4,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "grandma",
				"name": "Mess Aunty",
				"art": "grandma",
				"slot": 5,
				"facing": "L",
				"thought": "ANGRY",
				"contradiction": true
			},
			{
				"id": "boss",
				"name": "Prof",
				"art": "boss",
				"slot": 10,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "stolen_chair",
				"type": "SEAT",
				"art": "chair",
				"name": "stolen auditorium chair",
				"slot": 0
			},
			{
				"id": "leftover_cake",
				"type": "FOOD",
				"art": "cake",
				"name": "leftover cake",
				"slot": 7
			},
			{
				"id": "switch",
				"type": "SWITCH",
				"art": "pedal",
				"name": "mess light switch",
				"slot": 8
			}
		],
		"original_caption": "Mess Aunty and Chintu bonked each other.",
		"endings_total": 69,
		"goal": {
			"facts": [
				{
					"type": "BONKED",
					"character": "grandma",
					"target": "boss"
				}
			],
			"twist_caption": "Mess Aunty bonked the PROF.",
			"red_pen_words": [
				"PROF"
			]
		},
		"ladder": [
			{
				"id": "star_2",
				"caption": "…and the Prof bonked her right back.",
				"facts": [
					{
						"type": "BONKED",
						"character": "boss",
						"target": "grandma"
					}
				]
			},
			{
				"id": "star_3",
				"caption": "…and Chintu ate the cake while they were busy.",
				"facts": [
					{
						"type": "ATE",
						"character": "dog",
						"object": "leftover_cake"
					}
				]
			}
		],
		"narration": {
			"intro": "'Re: URGENT: Regarding the mail.' Moving on. The Prof eats at Kadamba every day, 'for research'. Yesterday he wrote on the feedback form: 'Pappu: bland.' Sweet, gentle Mess Aunty has read the feedback form. Sweet, gentle Mess Aunty has a ladle.",
			"original": "Mess Aunty and Chintu bonked each other. Nobody registered. Nobody won.",
			"twist": "Mess Aunty bonked the PROF.",
			"win": "Mess Aunty ladled the Prof. Faculty and students eat the same food here, so they get the same ladle. The socialism of IIIT.",
			"stars": [
				"And the Prof bonked her right back. They're arguing about Pappu like they've been married thirty years. They have not. Officially.",
				"And Chintu ate the leftover cake while they were busy. Prof Cake Count: still zero. I'm starting to think it's personal."
			],
			"fails": [
				"Wrong target. Mess Aunty isn't fussy.",
				"Somebody got ladled. Checked as per rubric.",
				"The ladle has been washed. Probably."
			],
			"hidden": []
		},
		"dialogue": [
			{
				"character": "grandma",
				"when": "lit",
				"line": "BLAND? My Pappu? I know that handwriting."
			},
			{
				"character": "grandma",
				"when": "win",
				"line": "That's for Felicity 2012. And for 'bland'."
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "I stand by my feedback. Your rasam is perfect, though."
			},
			{
				"character": "boss",
				"when": "gets_ANGRY",
				"line": "Nobody ladles a professor!"
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Registration? I AM the registration."
			},
			{
				"character": "dog",
				"when": "gets_HUNGRY",
				"line": "Forget the fight. Is that cake?"
			},
			{
				"character": "prompt",
				"when": "lit",
				"line": "Lite le. The AI wouldn't hack the CTF. Sleeping."
			}
		],
		"stickers": [
			{
				"text": "Rumour Meter: STILL UNCONFIRMED",
				"when": "result"
			}
		],
		"hints": [
			"Mess Aunty bonks whoever she can see. Bring the Prof into her sight.",
			"You have two lanterns this time. Put one on Mess Aunty and the other on the Prof at the far end.",
			"Keep Chintu out of the light, so the Prof is the one she goes for."
		],
		"star_hints": [
			"Give the Prof Chintu's anger, so an angry Prof hits back.",
			"After that swap Chintu is hungry. When the Prof walks past the switch, Chintu's corner lights up and he finds the cake."
		],
		"manhunt": {
			"subject": "Re: URGENT: Regarding the mail",
			"unread": "1,203",
			"suspect": "#2 Mess Aunty. She was at JC that night. With whom?",
			"clue": "Sent from JC Wi-Fi."
		},
		"voice_lengths_s": {
			"page_07_intro": [
				13.5,
				19.0
			],
			"page_07_original": [
				3.5,
				5.0
			],
			"page_07_twist": [
				1.5,
				2.5
			],
			"page_07_win": [
				7.5,
				10.5
			],
			"page_07_stars_1": [
				7.0,
				9
			],
			"page_07_stars_2": [
				7.0,
				9
			],
			"page_07_fails_1": [
				2.0,
				3.0
			],
			"page_07_fails_2": [
				2.5,
				3.0
			],
			"page_07_fails_3": [
				2.0,
				3.0
			],
			"page_07_dialogue_grandma_lit": [
				2.5,
				3.0
			],
			"page_07_dialogue_grandma_win": [
				2.5,
				3.0
			],
			"page_07_dialogue_boss_lit": [
				3.5,
				4.5
			],
			"page_07_dialogue_boss_gets_ANGRY": [
				1.5,
				2.0
			],
			"page_07_dialogue_dog_lit": [
				1.5,
				2.5
			],
			"page_07_dialogue_dog_gets_HUNGRY": [
				2.0,
				3.0
			],
			"page_07_dialogue_prompt_lit": [
				3.0,
				4.0
			]
		},
		"solver": {
			"ideas": [
				6,
				2,
				1
			],
			"win_percent": [
				1.047,
				0.349,
				0.087
			],
			"grids": [
				0.2,
				0.02
			]
		}
	}
