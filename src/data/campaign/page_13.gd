extends RefCounted
## Page 13 "Haunted OBH", IIIT-H story rev 4 (design/story_proposal.md, design/build_p4_15/spec.md).
## Layout page_15; star ladder verified by the solver (levels_solver/ladder), 0.2 and 0.02 lantern grids: ideas 4/2/1.


static func definition() -> Dictionary:
	return {
		"id": "page_13",
		"number": 13,
		"title": "Haunted OBH",
		"difficulty": "red",
		"room": "obh_washroom",
		"voice": "page_13",
		"source_layout": "page_15",
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
				4.0,
				-1.2,
				8.0,
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
					"x": 4.0,
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
				"id": "intern",
				"name": "Kassi",
				"art": "kassi",
				"slot": 2,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "boss",
				"name": "Prof",
				"art": "prof",
				"slot": 3,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "mouse",
				"name": "Faccha",
				"art": "faccha",
				"slot": 4,
				"facing": "L",
				"thought": "SHY",
				"contradiction": true
			},
			{
				"id": "kid",
				"name": "Saap",
				"art": "saap",
				"slot": 5,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "grandma",
				"name": "Mess Aunty",
				"art": "aunty",
				"slot": 10,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "coffin",
				"type": "SEAT",
				"art": "coffin",
				"name": "coffin",
				"slot": 0
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"name": "cake",
				"slot": 6
			}
		],
		"original_caption": "The Saap ran screaming, and the Faccha hid in the dark.",
		"endings_total": 71,
		"goal": {
			"facts": [
				{
					"type": "ASLEEP",
					"character": "boss",
					"object": "coffin"
				}
			],
			"twist_caption": "The PROF took a nap in the COFFIN.",
			"red_pen_words": [
				"PROF",
				"COFFIN"
			]
		},
		"ladder": [
			{
				"id": "star_2",
				"caption": "…and the Kassi bonked the Faccha in the dark.",
				"facts": [
					{
						"type": "BONKED",
						"character": "intern",
						"target": "mouse"
					}
				]
			},
			{
				"id": "star_3",
				"caption": "…and the Saap hid.",
				"facts": [
					{
						"type": "HIDING",
						"character": "kid"
					}
				]
			}
		],
		"narration": {
			"intro": "'Ok who's typing.' New genre: HORROR. The old OBH washrooms, 3 AM. Jagruti the banyan reaches in with her roots. There is a coffin. There is a cake. There is a wedding invite on the door, and it's still not the scariest thing here.",
			"original": "The Saap ran screaming, and the Faccha hid in the dark. Terrifying. I scared myself.",
			"twist": "The PROF took a nap in the COFFIN.",
			"win": "The Prof climbed into the coffin for a nap. Best sleep since his PhD. He's nervous about something next week. He won't say what.",
			"stars": [
				"And the Kassi bonked the Faccha in the dark. He thought it was Cthulhu.",
				"And the Saap hid. He says he wasn't scared. He says he didn't even come. He's in the cupboard."
			],
			"fails": [
				"BOO! …Did that work?",
				"The washrooms remain haunted. Mostly by you.",
				"Jagruti sends her regards."
			],
			"hidden": []
		},
		"dialogue": [
			{
				"character": "kid",
				"when": "lit",
				"line": "Haunted? Bro, I'm not scared. I'm leaving. Calmly. Screaming."
			},
			{
				"character": "kid",
				"when": "gets_SHY",
				"line": "Nobody look at me. Not even ghosts."
			},
			{
				"character": "mouse",
				"when": "lit",
				"line": "Nobody look at me. Especially seniors. Especially MOSS."
			},
			{
				"character": "mouse",
				"when": "gets_SCARED",
				"line": "Is something behind me? EVERYTHING is behind me!"
			},
			{
				"character": "intern",
				"when": "lit",
				"line": "Who's there? Is it the TA? I want a re-evaluation!"
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "Is that a coffin? Is it… ergonomic?"
			},
			{
				"character": "boss",
				"when": "win",
				"line": "Comfy. Roomy. Wake me after the wedding. I mean, after nothing."
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "Beta, I only came to pin this. Don't read it."
			}
		],
		"stickers": [
			{
				"text": "Rumour Meter: WEDDING INVITE RECEIVED",
				"when": "result"
			}
		],
		"hints": [
			"The Prof is already sleepy. He just needs your light.",
			"Light the Prof, the Faccha and the Saap together.",
			"Press ACTION and let the Prof find the coffin."
		],
		"star_hints": [
			"During ACTION, wake the Kassi with the spare bulb. Angry in the dark, he bonks the Faccha.",
			"Swap the Faccha's shyness onto the Saap. A shy Saap hides instead of running."
		],
		"decor": [
			{
				"art": "wedding_invite",
				"slot": 9,
				"note": "A wedding invite pinned to the door. Small; a recoloured paper card is fine."
			}
		],
		"manhunt": {
			"subject": "Re: Re: Re: Re: Re: Re: ok who's typing",
			"unread": "9,999+",
			"suspect": "#8 The frog 👌",
			"clue": "The TAs MOSSed the mail: 100% match with a draft on Prompt Bhai's laptop, 'testing AI for hackathon, DO NOT SEND'. He wrote it. Who sent it?"
		},
		"voice_lengths_s": {
			"page_13_intro": [
				14.5,
				20
			],
			"page_13_original": [
				5.0,
				7.0
			],
			"page_13_twist": [
				2.5,
				3.5
			],
			"page_13_win": [
				8.0,
				11.0
			],
			"page_13_stars_1": [
				4.5,
				6.5
			],
			"page_13_stars_2": [
				6.0,
				9.0
			],
			"page_13_fails_1": [
				1.5,
				2.0
			],
			"page_13_fails_2": [
				2.5,
				3.0
			],
			"page_13_fails_3": [
				1.5,
				2.0
			],
			"page_13_dialogue_kid_lit": [
				3.0,
				4.0
			],
			"page_13_dialogue_kid_gets_SHY": [
				2.5,
				3.0
			],
			"page_13_dialogue_mouse_lit": [
				2.5,
				3.5
			],
			"page_13_dialogue_mouse_gets_SCARED": [
				2.5,
				3.5
			],
			"page_13_dialogue_intern_lit": [
				3.5,
				4.5
			],
			"page_13_dialogue_boss_lit": [
				2.5,
				3.0
			],
			"page_13_dialogue_boss_win": [
				3.5,
				4.5
			],
			"page_13_dialogue_grandma_lit": [
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
				0.356,
				0.15,
				0.019
			],
			"grids": [
				0.2,
				0.02
			]
		}
	}
