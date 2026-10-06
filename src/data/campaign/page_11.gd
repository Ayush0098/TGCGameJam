extends RefCounted
## Page 11 "Power Cut", IIIT-H story rev 4 (design/story_proposal.md, design/build_p4_15/spec.md).
## Layout page_08; star ladder verified by the solver (levels_solver/ladder), 0.2 and 0.02 lantern grids: ideas 5/2/1.


static func definition() -> Dictionary:
	return {
		"id": "page_11",
		"number": 11,
		"title": "Power Cut",
		"difficulty": "red",
		"room": "obh_dark",
		"voice": "page_11",
		"source_layout": "page_08",
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
				"switch_id": "switch",
				"initially_on": false
			}
		],
		"characters": [
			{
				"id": "dog",
				"name": "Chintu",
				"art": "dog",
				"slot": 2,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "mouse",
				"name": "Faccha",
				"art": "faccha",
				"slot": 3,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "boss",
				"name": "Prof",
				"art": "prof",
				"slot": 5,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "cat",
				"name": "Dassi",
				"art": "dassi",
				"slot": 7,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "intern",
				"name": "Kassi",
				"art": "kassi",
				"slot": 10,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "maggi",
				"type": "FOOD",
				"art": "pie",
				"name": "Maggi",
				"slot": 0
			},
			{
				"id": "bean_bag",
				"type": "SEAT",
				"art": "cushion",
				"name": "bean bag",
				"slot": 1
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"name": "cake",
				"slot": 8
			},
			{
				"id": "switch",
				"type": "SWITCH",
				"art": "pedal",
				"name": "hostel light switch",
				"slot": 8
			}
		],
		"original_caption": "The Faccha ran out of the comic.",
		"endings_total": 148,
		"goal": {
			"facts": [
				{
					"type": "ATE",
					"character": "dog",
					"object": "cake"
				}
			],
			"twist_caption": "CHINTU ate the cake in the dark.",
			"red_pen_words": [
				"CHINTU"
			]
		},
		"ladder": [
			{
				"id": "star_2",
				"caption": "…and Dassi fled.",
				"facts": [
					{
						"type": "EXITED",
						"character": "cat"
					}
				]
			},
			{
				"id": "star_3",
				"caption": "…and the Faccha fled too.",
				"facts": [
					{
						"type": "EXITED",
						"character": "mouse"
					}
				]
			}
		],
		"narration": {
			"intro": "'Fwd: the Dean talked to the Prof.' Right. If you're going to ruin my comic, ruin it in the DARK. Power's off. Wi-Fi's off. Welcome to OBH. Maintenance says ten days. …Is that a spare bulb? Who carries a SPARE BULB?",
			"original": "The Faccha ran out of the comic. He still thinks there's a curfew. There isn't.",
			"twist": "CHINTU ate the cake in the dark.",
			"win": "I cut the power. You brought a spare bulb. And Chintu found the cake in total darkness. By smell.",
			"stars": [
				"And Dassi fled. Ten-CGPA people simply need proper lighting.",
				"And the Faccha fled too. Last seen in Vindhya. Somehow. From OBH."
			],
			"fails": [
				"Darkness wins. I should have done this on page one.",
				"Still dark. Fixed in ten days.",
				"Power cut. Rubric cut. Marks cut."
			],
			"hidden": []
		},
		"dialogue": [
			{
				"character": "mouse",
				"when": "lit",
				"line": "Who turned off the lights? Is this the MOSS hearing?"
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "I can't see it. I can SMELL it."
			},
			{
				"character": "dog",
				"when": "win",
				"line": "Found it. Ate it. Don't ask."
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "Power cut? Perfect. The TAs can't see me either."
			},
			{
				"character": "cat",
				"when": "lit",
				"line": "I can't study in the dark. My CGPA is photosensitive."
			},
			{
				"character": "intern",
				"when": "lit",
				"line": "WHO cut the power? I had a submission at 11:59!"
			}
		],
		"stickers": [],
		"hints": [
			"No thought swaps needed here. Look at who's already scared and hungry.",
			"Light Chintu and the Faccha together.",
			"During ACTION, drop the spare bulb on Dassi or the Kassi."
		],
		"star_hints": [
			"Drop the spare bulb on Dassi: woken up scared, she runs.",
			"Keep the Faccha lit and scared the whole time; he runs too."
		],
		"tutorial": [
			"Remember your spare bulb? During ACTION, drop it to wake someone up."
		],
		"manhunt": {
			"subject": "Fwd: Re: Re: the Dean talked to the Prof",
			"unread": "7,410",
			"suspect": "#6 The Prof. He knows the Dean personally.",
			"clue": "Prompt Bhai's alibi: a photo of him asleep on the JC bean bag at 1:03 AM. Who took this photo?"
		},
		"act_card_before": {
			"number": 3,
			"title": "ACT THREE: ENDSEMS: RUBRIC ONLY",
			"text": "Dear all. The sender has not been found. The Prof has replied to the TAs: 'Will discuss.' Will. Discuss. The rubric rule now applies to endsems. And to this comic. And to me. Several of you have told me to take it lite. I do not take anything lite. Regards, and I mean that aggressively."
		},
		"voice_lengths_s": {
			"page_11_intro": [
				13.5,
				19.0
			],
			"page_11_original": [
				5.0,
				7.0
			],
			"page_11_twist": [
				2.5,
				3.0
			],
			"page_11_win": [
				6.0,
				9.0
			],
			"page_11_stars_1": [
				3.0,
				4.0
			],
			"page_11_stars_2": [
				4.0,
				5.5
			],
			"page_11_fails_1": [
				3.5,
				4.5
			],
			"page_11_fails_2": [
				2.0,
				3.0
			],
			"page_11_fails_3": [
				2.0,
				3.0
			],
			"page_11_dialogue_mouse_lit": [
				3.5,
				4.5
			],
			"page_11_dialogue_dog_lit": [
				2.5,
				3.5
			],
			"page_11_dialogue_dog_win": [
				2.0,
				3.0
			],
			"page_11_dialogue_boss_lit": [
				3.0,
				4.0
			],
			"page_11_dialogue_cat_lit": [
				3.5,
				4.5
			],
			"page_11_dialogue_intern_lit": [
				3.5,
				4.5
			],
			"page_11_card": [
				4.0,
				5.5
			],
			"act3": [
				18.0,
				25.5
			]
		},
		"solver": {
			"ideas": [
				5,
				2,
				1
			],
			"win_percent": [
				0.351,
				0.211,
				0.023
			],
			"grids": [
				0.2,
				0.02
			]
		}
	}
