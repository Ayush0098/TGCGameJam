extends RefCounted
## Page 8 "Prom Night", IIIT-H story rev 4 (design/story_proposal.md, design/build_p4_15/spec.md).
## Layout page_12; star ladder verified by the solver (levels_solver/ladder), 0.2 and 0.02 lantern grids: ideas 3/2/1.


static func definition() -> Dictionary:
	return {
		"id": "page_08",
		"number": 8,
		"title": "Prom Night",
		"difficulty": "yellow",
		"room": "amphi",
		"voice": "page_08",
		"source_layout": "page_12",
		"width": 10,
		"rail_span": [
			0,
			9
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
				6.0,
				-1.2,
				8.0,
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
					"x": 6.0,
					"y": -0.6,
					"enabled": false
				}
			]
		},
		"obstacles": [],
		"flick": 0,
		"fixed_lights": [],
		"lamps": [],
		"characters": [
			{
				"id": "intern",
				"name": "Kassi",
				"art": "intern",
				"slot": 6,
				"facing": "L",
				"thought": "IN_LOVE",
				"contradiction": false
			},
			{
				"id": "boss",
				"name": "Prof",
				"art": "boss",
				"slot": 7,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": true
			},
			{
				"id": "cat",
				"name": "Dassi",
				"art": "dassi",
				"slot": 8,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "grandma",
				"name": "Mess Aunty",
				"art": "grandma",
				"slot": 9,
				"facing": "L",
				"thought": "IN_LOVE",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "chair",
				"type": "SEAT",
				"art": "chair",
				"name": "chair",
				"slot": 3
			},
			{
				"id": "buffet_cake",
				"type": "FOOD",
				"art": "cake",
				"name": "buffet cake",
				"slot": 5
			}
		],
		"original_caption": "The Kassi hugged the Prof.",
		"endings_total": 46,
		"goal": {
			"facts": [
				{
					"type": "HUGGED",
					"character": "boss",
					"target": "grandma"
				}
			],
			"twist_caption": "The PROF hugged MESS AUNTY.",
			"red_pen_words": [
				"PROF",
				"MESS AUNTY"
			]
		},
		"ladder": [
			{
				"id": "star_2",
				"caption": "…and Dassi hugged Mess Aunty too.",
				"facts": [
					{
						"type": "HUGGED",
						"character": "cat",
						"target": "grandma"
					}
				]
			},
			{
				"id": "star_3",
				"caption": "…right after the Kassi hugged the Prof.",
				"facts": [
					{
						"type": "HUGGED",
						"character": "intern",
						"target": "boss"
					}
				]
			}
		],
		"narration": {
			"intro": "'Re: Re: who sent this.' Prom Night at the Amphi. Apex is famous for its facchi orientation. It is very well attended. By Apex. The Kassi has rehearsed asking a facchi to dance four hundred and nine times. Tonight, he goes for it.",
			"original": "The Kassi closed his eyes and hugged… the Prof. The facchi was behind the Prof. She has left.",
			"twist": "The PROF hugged MESS AUNTY.",
			"win": "The Prof hugged Mess Aunty. In public. He says it's 'conservation of heat; we are an engineering college.' The Rumour Meter just moved. I didn't move it.",
			"stars": [
				"And Dassi hugged Mess Aunty too. Trip at Prom, land in someone else's relationship.",
				"And it all started because the Kassi hugged the Prof. Attempt four hundred and nine: wrong person. Right plot."
			],
			"fails": [
				"Love is in the air. So is Apex.",
				"Nobody hugged. Somebody liked a story instead.",
				"Maybe the real love was the assignments."
			],
			"hidden": []
		},
		"dialogue": [
			{
				"character": "intern",
				"when": "lit",
				"line": "She looked at me. Twice. Or at the clock behind me."
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "I'm only here for the buffet. And for no other reason."
			},
			{
				"character": "boss",
				"when": "gets_SCARED",
				"line": "Why is everyone walking TOWARDS me?!"
			},
			{
				"character": "boss",
				"when": "win",
				"line": "Aunty… you smell like rasam and danger."
			},
			{
				"character": "cat",
				"when": "lit",
				"line": "I'm only here so my faccha doesn't get facchi-maxxed."
			},
			{
				"character": "cat",
				"when": "gets_IN_LOVE",
				"line": "Ten on ten. For her. Not me. HER."
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "I've loved someone since Felicity 2012. He called my Pappu bland."
			},
			{
				"character": "grandma",
				"when": "gets_HUNGRY",
				"line": "Is the buffet open, beta?"
			}
		],
		"stickers": [
			{
				"text": "Rumour Meter: STRONGLY UNCONFIRMED (they hugged)",
				"when": "result"
			},
			{
				"text": "Kassi Attempt #409: Prom. Hugged the Prof. ✗",
				"when": "result"
			}
		],
		"hints": [
			"Love spreads by hugs. Whoever gets hugged falls in love and goes looking for the next hug.",
			"Mess Aunty has to stay put and be hugged. Take her love away: give her the Prof's hunger.",
			"Light the Prof, Dassi and Mess Aunty, and keep the Kassi in the dark."
		],
		"star_hints": [
			"Dassi needs love too. Pass the thoughts round so Dassi gets Mess Aunty's love, and light all four.",
			"The Prof takes Dassi's fear, so it's the Kassi's hug that sets him off. Light all four."
		],
		"new_feeling": "IN_LOVE",
		"tutorial": [
			"NEW FEELING: IN LOVE. Walks to the nearest lit character and hugs them. Whoever gets hugged falls in love too and goes looking for someone to hug!"
		],
		"manhunt": {
			"subject": "Re: Re: who sent this 💀",
			"unread": "2,048",
			"suspect": "#3 Dassi. Also at JC that night, 'for the Wi-Fi'.",
			"clue": "Perfect grammar. The word 'delve', four times."
		},
		"voice_lengths_s": {
			"page_08_intro": [
				14.0,
				20.0
			],
			"page_08_original": [
				6.0,
				8
			],
			"page_08_twist": [
				1.5,
				2.5
			],
			"page_08_win": [
				9.0,
				12.5
			],
			"page_08_stars_1": [
				4.5,
				6.5
			],
			"page_08_stars_2": [
				6.0,
				9.0
			],
			"page_08_fails_1": [
				2.5,
				3.5
			],
			"page_08_fails_2": [
				2.5,
				3.0
			],
			"page_08_fails_3": [
				2.5,
				3.0
			],
			"page_08_dialogue_intern_lit": [
				3.5,
				4.5
			],
			"page_08_dialogue_boss_lit": [
				3.5,
				4.5
			],
			"page_08_dialogue_boss_gets_SCARED": [
				2.0,
				3.0
			],
			"page_08_dialogue_boss_win": [
				2.5,
				3.0
			],
			"page_08_dialogue_cat_lit": [
				3.0,
				4.0
			],
			"page_08_dialogue_cat_gets_IN_LOVE": [
				2.5,
				3.5
			],
			"page_08_dialogue_grandma_lit": [
				3.5,
				4.5
			],
			"page_08_dialogue_grandma_gets_HUNGRY": [
				1.5,
				2.5
			],
			"page_08_card": [
				9.0,
				12
			]
		},
		"solver": {
			"ideas": [
				3,
				2,
				1
			],
			"win_percent": [
				3.125,
				2.083,
				1.042
			],
			"grids": [
				0.2,
				0.02
			]
		}
	}
