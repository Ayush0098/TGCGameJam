extends RefCounted
## Page 14 "The Great Coupling", IIIT-H story rev 4 (design/story_proposal.md, design/build_p4_15/spec.md).
## Layout page_14; star ladder verified by the solver (levels_solver/ladder), 0.2 and 0.02 lantern grids: ideas 4/2/1.


static func definition() -> Dictionary:
	return {
		"id": "page_14",
		"number": 14,
		"title": "The Great Coupling",
		"difficulty": "red",
		"room": "amphi_wedding",
		"voice": "page_14",
		"source_layout": "page_14",
		"width": 9,
		"rail_span": [
			0,
			8
		],
		"spotlights": {
			"count": 1,
			"default_centres": [
				7
			]
		},
		"lanterns": {
			"radius": 1.6,
			"bounds": [
				5.0,
				-1.2,
				7.0,
				0.6
			],
			"count": 1,
			"defaults": [
				{
					"x": 7.0,
					"y": -0.6,
					"enabled": true
				},
				{
					"x": 5.0,
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
				"id": "mouse",
				"name": "Faccha",
				"art": "faccha",
				"slot": 2,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "boss",
				"name": "Prof",
				"art": "prof",
				"slot": 3,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Chintu",
				"art": "dog",
				"slot": 5,
				"facing": "R",
				"thought": "JEALOUS",
				"contradiction": false
			},
			{
				"id": "grandma",
				"name": "Mess Aunty",
				"art": "aunty",
				"slot": 6,
				"facing": "R",
				"thought": "IN_LOVE",
				"contradiction": false
			},
			{
				"id": "cat",
				"name": "Dassi",
				"art": "dassi",
				"slot": 7,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": true
			}
		],
		"objects": [
			{
				"id": "wedding_cake",
				"type": "FOOD",
				"art": "cake",
				"name": "wedding cake",
				"slot": 1
			},
			{
				"id": "chair",
				"type": "SEAT",
				"art": "chair",
				"name": "chair",
				"slot": 8
			}
		],
		"original_caption": "Dassi objected. By bonking the bride.",
		"endings_total": 60,
		"goal": {
			"facts": [
				{
					"type": "HUGGED",
					"character": "cat",
					"target": "mouse"
				}
			],
			"twist_caption": "DASSI hugged the FACCHA.",
			"red_pen_words": [
				"DASSI",
				"FACCHA"
			]
		},
		"ladder": [
			{
				"id": "star_2",
				"caption": "…right after Mess Aunty hugged Dassi.",
				"facts": [
					{
						"type": "HUGGED",
						"character": "grandma",
						"target": "cat"
					}
				]
			},
			{
				"id": "star_3",
				"caption": "…and the Faccha hugged the Prof.",
				"facts": [
					{
						"type": "HUGGED",
						"character": "mouse",
						"target": "boss"
					}
				]
			}
		],
		"narration": {
			"intro": "One new mail. From the Prof. Sent from his own wedding. 'TAs, please see me.' …I'm fine. Mess Aunty and the Prof are getting married. The Rumour was true. The buffet is entirely Pappu. Dassi has been asked not to object.",
			"original": "Dassi objected. By bonking the bride. Lovely ceremony. Very moving.",
			"twist": "DASSI hugged the FACCHA.",
			"win": "Dassi hugged the Faccha. Her mentee. A fight was about to start, and the comic calmed itself down. Udhav sir would be proud.",
			"stars": [
				"And the bride hugged Dassi first. She hugged the objector. Objection withdrawn.",
				"And the Faccha hugged the Prof. I now pronounce this… whatever this is. Prof Cake Count: still zero."
			],
			"fails": [
				"Somebody objected. Somebody always objects.",
				"Dearly beloved, we are gathered here to watch you fail.",
				"The wedding is off. The cake is not."
			],
			"hidden": [
				{
					"facts": [
						{
							"type": "ATE",
							"character": "boss",
							"object": "wedding_cake"
						}
					],
					"line": "Prof Cake Count: ONE. At his own wedding. He's crying. Happy tears. Cake tears."
				}
			]
		},
		"dialogue": [
			{
				"character": "grandma",
				"when": "lit",
				"line": "I do! He called my Pappu bland, and I do!"
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "My wedding. My cake. TAs, see me after."
			},
			{
				"character": "cat",
				"when": "lit",
				"line": "I object. To everything. Generally."
			},
			{
				"character": "cat",
				"when": "gets_JEALOUS",
				"line": "Why does EVERYONE get to want things?"
			},
			{
				"character": "cat",
				"when": "win",
				"line": "I'm not crying. My CGPA is crying."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "I'm not jealous. Who's the cake for? I'm jealous."
			},
			{
				"character": "dog",
				"when": "gets_ANGRY",
				"line": "That's MY cake! Nobody registered it!"
			},
			{
				"character": "mouse",
				"when": "win",
				"line": "Weirdest day of my life, and I live in Vindhya now."
			}
		],
		"stickers": [
			{
				"text": "Rumour Meter: CONFIRMED 💍",
				"when": "result"
			}
		],
		"hints": [
			"Mess Aunty is in love, and love spreads by hugs. Dassi needs to end up hugging the Faccha.",
			"Give Dassi Chintu's jealousy, and light Dassi and Mess Aunty.",
			"During ACTION, wake the Faccha with the spare bulb."
		],
		"star_hints": [
			"Keep Mess Aunty in love, so she hugs Dassi first.",
			"Drop the spare bulb so it wakes the Prof as well as the Faccha."
		],
		"manhunt": {
			"subject": "From the Prof: TAs, please see me.",
			"unread": "the app crashed",
			"suspect": "#9 Me. My sent folder is empty. Which is exactly what a sender would do.",
			"clue": "The smudge on the Send key smells of cheese Maggi."
		},
		"voice_lengths_s": {
			"page_14_intro": [
				13.5,
				19.0
			],
			"page_14_original": [
				3.5,
				4.5
			],
			"page_14_twist": [
				1.5,
				2.0
			],
			"page_14_win": [
				7.5,
				10.5
			],
			"page_14_stars_1": [
				4.0,
				5.5
			],
			"page_14_stars_2": [
				6.0,
				8.5
			],
			"page_14_fails_1": [
				1.5,
				2.5
			],
			"page_14_fails_2": [
				3.5,
				4.5
			],
			"page_14_fails_3": [
				2.5,
				3.5
			],
			"page_14_hidden_1": [
				4.5,
				6.5
			],
			"page_14_dialogue_grandma_lit": [
				3.5,
				4.5
			],
			"page_14_dialogue_boss_lit": [
				2.5,
				3.5
			],
			"page_14_dialogue_cat_lit": [
				1.5,
				2.5
			],
			"page_14_dialogue_cat_gets_JEALOUS": [
				2.5,
				3.0
			],
			"page_14_dialogue_cat_win": [
				2.5,
				3.0
			],
			"page_14_dialogue_dog_lit": [
				3.0,
				4.0
			],
			"page_14_dialogue_dog_gets_ANGRY": [
				2.0,
				3.0
			],
			"page_14_dialogue_mouse_win": [
				3.5,
				4.5
			]
		},
		"solver": {
			"ideas": [
				4,
				2,
				1
			],
			"win_percent": [
				2.74,
				1.142,
				0.228
			],
			"grids": [
				0.2,
				0.02
			]
		}
	}
