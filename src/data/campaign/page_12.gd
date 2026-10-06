extends RefCounted
## Page 12 "Kalakshetra", IIIT-H story rev 4 (design/story_proposal.md, design/build_p4_15/spec.md).
## Layout page_09; star ladder verified by the solver (levels_solver/ladder), 0.2 and 0.02 lantern grids: ideas 40/2/1.


static func definition() -> Dictionary:
	return {
		"id": "page_12",
		"number": 12,
		"title": "Kalakshetra",
		"difficulty": "red",
		"room": "kalakshetra",
		"voice": "page_12",
		"source_layout": "page_09",
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
				0.0,
				-1.2,
				10.0,
				0.6
			],
			"count": 1,
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
		"flick": 1,
		"fixed_lights": [],
		"lamps": [],
		"characters": [
			{
				"id": "grandma",
				"name": "Mess Aunty",
				"art": "aunty",
				"slot": 0,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "cat",
				"name": "Dassi",
				"art": "dassi",
				"slot": 3,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": true
			},
			{
				"id": "mouse",
				"name": "Faccha",
				"art": "faccha",
				"slot": 5,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Chintu",
				"art": "dog",
				"slot": 7,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "rocking_chair",
				"type": "SEAT",
				"art": "rocker",
				"name": "rocking chair",
				"slot": 1
			},
			{
				"id": "cheese",
				"type": "FOOD",
				"art": "cheese",
				"name": "cheese",
				"slot": 9
			}
		],
		"original_caption": "Dassi chased the Faccha out of the comic.",
		"endings_total": 132,
		"goal": {
			"facts": [
				{
					"type": "BONKED",
					"character": "mouse",
					"target": "cat"
				}
			],
			"twist_caption": "The FACCHA bonked DASSI.",
			"red_pen_words": [
				"FACCHA",
				"DASSI"
			]
		},
		"ladder": [
			{
				"id": "star_2",
				"caption": "…and Chintu dozed off in the rocking chair.",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "dog",
						"object": "rocking_chair"
					}
				]
			},
			{
				"id": "star_3",
				"caption": "…and Mess Aunty walked out.",
				"facts": [
					{
						"type": "EXITED",
						"character": "grandma"
					}
				]
			}
		],
		"narration": {
			"intro": "'Re: lite le guys.' Kalakshetra. Theme: Retro Disco. Forty disco balls, unpainted. Dassi is the Faccha's mentor, the only healthy senior-junior relationship on campus: she just makes him work. Get him painting, Dassi.",
			"original": "Dassi chased the Faccha out of the comic. He's hiding at JC. Mentors know where JC is.",
			"twist": "The FACCHA bonked DASSI.",
			"win": "The Faccha bonked Dassi. His own mentor. With a disco ball. She says she's proud of him. She also says forty disco balls by morning.",
			"stars": [
				"And Chintu dozed off in the rocking chair. He was guarding the cheese. He doesn't even like cheese.",
				"And Mess Aunty walked out. To Goa, with the fourth years. She has 'some invites to post'."
			],
			"fails": [
				"Best mentor I ever hired.",
				"Forty disco balls remain unpainted.",
				"Come on. It's Kalakshetra time. Again."
			],
			"hidden": []
		},
		"dialogue": [
			{
				"character": "cat",
				"when": "lit",
				"line": "Come on, Faccha. Disco balls. It builds character."
			},
			{
				"character": "cat",
				"when": "gets_HUNGRY",
				"line": "Is there food at Kalakshetra? There is NEVER food at Kalakshetra."
			},
			{
				"character": "mouse",
				"when": "lit",
				"line": "I can't paint! I can barely C! Ask MOSS!"
			},
			{
				"character": "mouse",
				"when": "gets_ANGRY",
				"line": "Oh, it's ON. Mentor or no mentor."
			},
			{
				"character": "mouse",
				"when": "win",
				"line": "Sorry, ma'am! Mentor ma'am! …Was that good?"
			},
			{
				"character": "dog",
				"when": "gets_SLEEPY",
				"line": "Disco… ball… so… shiny… zzz."
			},
			{
				"character": "grandma",
				"when": "gets_SCARED",
				"line": "Forty disco balls? I'm going to Goa. With… a friend."
			}
		],
		"stickers": [],
		"hints": [
			"The Faccha has to be the angry one. Give him Dassi's anger.",
			"An angry character bonks whoever they can see. Make sure the Faccha can see Dassi.",
			"Light Dassi, or wake the Faccha with the spare bulb near her."
		],
		"star_hints": [
			"Pass all four thoughts round: the Faccha gets Dassi's anger, Dassi gets Chintu's hunger, Chintu gets Mess Aunty's sleepiness, Mess Aunty gets the Faccha's fear. Light Dassi, and drop the spare bulb between Chintu and the Faccha.",
			"Same plan, but light Mess Aunty too."
		],
		"manhunt": {
			"subject": "Re: Fwd: Re: lite le guys",
			"unread": "8,888",
			"suspect": "#7 The lamp. It was on every page. It was on page 4.",
			"clue": "A greasy smudge on the Send key. The lamp has no fingers. …Or DOES it."
		},
		"postcard_after": {
			"art": "postcard_goa",
			"text": "Postcard from Goa. The fourth years went to Goa, as is tradition. Some uncles were being uncles. Senior Udhav sir stood up for his friends, and the other students calmed everyone down. Nobody got hurt. Wish you were here. P.S. Mess Aunty says hi. She posted a wedding invite. To whom? We'll see."
		},
		"voice_lengths_s": {
			"page_12_intro": [
				11.0,
				15.0
			],
			"page_12_original": [
				5.5,
				8.0
			],
			"page_12_twist": [
				1.5,
				2.0
			],
			"page_12_win": [
				8.0,
				11.5
			],
			"page_12_stars_1": [
				6.0,
				8.5
			],
			"page_12_stars_2": [
				5.5,
				8.0
			],
			"page_12_fails_1": [
				1.5,
				2.5
			],
			"page_12_fails_2": [
				1.5,
				2.5
			],
			"page_12_fails_3": [
				2.0,
				3.0
			],
			"page_12_dialogue_cat_lit": [
				2.5,
				3.5
			],
			"page_12_dialogue_cat_gets_HUNGRY": [
				3.5,
				4.5
			],
			"page_12_dialogue_mouse_lit": [
				3.0,
				4.0
			],
			"page_12_dialogue_mouse_gets_ANGRY": [
				2.5,
				3.0
			],
			"page_12_dialogue_mouse_win": [
				2.5,
				3.0
			],
			"page_12_dialogue_dog_gets_SLEEPY": [
				1.5,
				2.5
			],
			"page_12_dialogue_grandma_gets_SCARED": [
				3.5,
				4.5
			],
			"postcard_goa": [
				17.5,
				22
			]
		},
		"solver": {
			"ideas": [
				40,
				2,
				1
			],
			"win_percent": [
				3.725,
				0.04,
				0.013
			],
			"grids": [
				0.2,
				0.02
			]
		}
	}
