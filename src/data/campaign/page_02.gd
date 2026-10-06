extends RefCounted
## Page 2 "Eat Your Pappu", IIIT-H story rev 4 (design/story_proposal.md, design/build_p1_3/spec.md).
## Star ladder verified by the solver (design/levels_solver/ladder), 0.2 and 0.02 lantern grids.


static func definition() -> Dictionary:
	return {
		"id": "page_02",
		"number": 2,
		"title": "Eat Your Pappu",
		"difficulty": "green",
		"room": "kadamba",
		"voice": "page_02",
		"width": 11,
		"rail_span": [
			0,
			10
		],
		"spotlights": {
			"count": 1,
			"default_centres": [
				3
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
					"x": 3.0,
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
		"lamps": [],
		"characters": [
			{
				"id": "kid",
				"name": "Saap",
				"art": "saap",
				"slot": 6,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Chintu",
				"art": "dog",
				"slot": 8,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "grandma",
				"name": "Mess Aunty",
				"art": "aunty",
				"slot": 9,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": true
			},
			{
				"id": "prompt",
				"name": "Prompt Bhai",
				"art": "prompt",
				"slot": 4,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": false,
				"phone_glow": true
			}
		],
		"objects": [
			{
				"id": "mess_bench",
				"type": "SEAT",
				"art": "armchair",
				"slot": 0
			},
			{
				"id": "bonda",
				"type": "FOOD",
				"art": "bonda",
				"slot": 2
			},
			{
				"id": "pappu",
				"type": "FOOD",
				"art": "prop_tomato_pappu",
				"slot": 7
			}
		],
		"original_caption": "Nobody ate anything.",
		"endings_total": 21,
		"goal": {
			"facts": [
				{
					"type": "ATE",
					"character": "kid",
					"object": "pappu"
				}
			],
			"twist_caption": "The SAAP ate the PAPPU.",
			"red_pen_words": [
				"SAAP",
				"PAPPU"
			]
		},
		"ladder": [
			{
				"id": "star_2",
				"caption": "…and Chintu fled the mess.",
				"facts": [
					{
						"type": "EXITED",
						"character": "dog"
					}
				]
			},
			{
				"id": "star_3",
				"caption": "…and so did Mess Aunty.",
				"facts": [
					{
						"type": "EXITED",
						"character": "grandma"
					}
				]
			}
		],
		"narration": {
			"intro": "Monday. Today's Kadamba menu: Tomato Pappu. Also Dal Pappu, Palak Pappu, Pappu Rice, and for dessert, a sweet Pappu. One bowl of Tomato Pappu has sat on that counter since 2009. Everyone is scared of the Pappu. The Pappu is scared of nobody. Also new this week: Prompt Bhai, registered for all fourteen Infinium events. ChatGPT filled in the form. The quiz and the hackathon start at the same time. He's in both.",
			"original": "Nobody ate anything. Everyone stared at the Pappu. The Pappu stared back. I call this suspense.",
			"twist": "The Saap ate the PAPPU.",
			"win": "The Saap ate the Pappu. Voluntarily. And now he says he 'didn't even eat that much'. Somebody check him for a fever. Somebody check the PAPPU for a fever.",
			"stars": [
				"And Chintu fled the mess. The one dog who eats everything has drawn a line. The line is Pappu.",
				"And Mess Aunty fled her own mess. She made it. She knows."
			],
			"fails": [
				"The Pappu survives another semester.",
				"The Pappu remains uneaten. As it has since 2009.",
				"Wrong Answer on test 2. The Pappu thanks you."
			],
			"hidden": [
				{
					"facts": [
						{
							"type": "EXITED",
							"character": "prompt"
						}
					],
					"line": "Prompt Bhai fled too. He asked Claude what was in the Pappu. Claude asked for more context. There is no more context. It's Pappu."
				}
			]
		},
		"dialogue": [
			{
				"character": "kid",
				"when": "lit",
				"line": "Bro, I'm not scared of Pappu. I just didn't study the Pappu."
			},
			{
				"character": "kid",
				"when": "gets_HUNGRY",
				"line": "Fine. I'll eat it. I won't even like it. I'll top it."
			},
			{
				"character": "kid",
				"when": "win",
				"line": "Bro, it was mid. Ten on ten. Mid."
			},
			{
				"character": "prompt",
				"when": "lit",
				"line": "Let me ask ChatGPT what's in this. …It says 'Pappu'. Thanks, ChatGPT."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Bonda? Bonda! BONDA!"
			},
			{
				"character": "dog",
				"when": "gets_SCARED",
				"line": "The Pappu just gave me a 👌. I'm out."
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "Beta, even I don't eat my Pappu. And I put it in everything."
			}
		],
		"stickers": [],
		"hints": [
			"The Saap is scared of the Pappu. Chintu is the hungry one.",
			"Light the Saap and Chintu together and swap their thoughts.",
			"After the swap, light the Saap and the Pappu, and press ACTION."
		],
		"star_hints": [
			"Keep Chintu lit after the swap. Scared characters run out of the comic.",
			"Stretch the light from the Saap to Mess Aunty, so Chintu and Mess Aunty are both lit. Keep Prompt Bhai in the dark."
		]
	}
