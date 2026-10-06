extends RefCounted
## Page 5 "Freshers' Night", IIIT-H story rev 4 (design/story_proposal.md, design/build_p4_15/spec.md).
## Layout page_11; star ladder verified by the solver (levels_solver/ladder), 0.2 and 0.02 lantern grids: ideas 6/2/1.


static func definition() -> Dictionary:
	return {
		"id": "page_05",
		"number": 5,
		"title": "Freshers' Night",
		"difficulty": "green",
		"room": "amphi",
		"voice": "page_05",
		"source_layout": "page_11",
		"width": 11,
		"rail_span": [
			0,
			10
		],
		"spotlights": {
			"count": 1,
			"default_centres": [
				2
			]
		},
		"lanterns": {
			"radius": 1.6,
			"bounds": [
				0.0,
				-1.2,
				6.0,
				0.6
			],
			"count": 1,
			"defaults": [
				{
					"x": 2.0,
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
				"id": "grandma",
				"name": "Mess Aunty",
				"art": "aunty",
				"slot": 0,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "kid",
				"name": "Saap",
				"art": "saap",
				"slot": 2,
				"facing": "L",
				"thought": "SHY",
				"contradiction": true
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
				"slot": 10,
				"facing": "L",
				"thought": "SLEEPY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "front_bench",
				"type": "SEAT",
				"art": "armchair",
				"name": "front bench",
				"slot": 1
			},
			{
				"id": "switch",
				"type": "SWITCH",
				"art": "pedal",
				"name": "spotlight switch",
				"slot": 4
			},
			{
				"id": "prize_cake",
				"type": "FOOD",
				"art": "cake",
				"name": "prize cake",
				"slot": 8
			}
		],
		"original_caption": "The Saap hid from the spotlight.",
		"endings_total": 18,
		"goal": {
			"facts": [
				{
					"type": "HIDING",
					"character": "boss"
				}
			],
			"twist_caption": "The PROF hid from the spotlight.",
			"red_pen_words": [
				"PROF"
			]
		},
		"ladder": [
			{
				"id": "star_2",
				"caption": "…and the Saap fell asleep on the bench.",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "kid",
						"object": "front_bench"
					}
				]
			},
			{
				"id": "star_3",
				"caption": "…and Mess Aunty ate the prize cake.",
				"facts": [
					{
						"type": "ATE",
						"character": "grandma",
						"object": "prize_cake"
					}
				]
			}
		],
		"narration": {
			"intro": "Tuesday. Freshers' Night at the Amphi! Agni, Aakash, Prithvi and Vayu bring music, dance and skits. The Saap has forty jokes and will tell none of them, because he is shy. The Prof is judging. There is a prize cake.",
			"original": "The Saap hid from the spotlight. Vayu won. Agni would like a word.",
			"twist": "The PROF hid from the spotlight.",
			"win": "The Prof, a man who once lectured for three hours on his own h-index, hid from a lightbulb. On Freshers' Night. In front of the freshers.",
			"stars": [
				"And the Saap fell asleep on the bench. Forty jokes prepared. Zero told.",
				"And Mess Aunty ate the prize cake. Official result: Vayu won. Consensus: Agni deserved it. Actual cake: Mess Aunty."
			],
			"fails": [
				"Show's over. Results checked as per rubric.",
				"Vayu won, Agni deserved it, and you deserved neither.",
				"No talent at all. The skits were great, though."
			],
			"hidden": []
		},
		"dialogue": [
			{
				"character": "kid",
				"when": "lit",
				"line": "Don't look at me! I didn't even prepare!"
			},
			{
				"character": "kid",
				"when": "gets_SLEEPY",
				"line": "Reeelaaaax. Mic check… zzz."
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "I'm the judge. I judge the cake first."
			},
			{
				"character": "boss",
				"when": "gets_SHY",
				"line": "Why is everyone LOOKING at me? I'm faculty!"
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "Wake me for the Agni skit, beta."
			},
			{
				"character": "grandma",
				"when": "gets_HUNGRY",
				"line": "Prize cake? I AM the prize."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Wake me for the Vayu skit."
			}
		],
		"stickers": [],
		"hints": [
			"The Prof has to be the shy one. Give him the Saap's shyness.",
			"A shy character in your light runs to the nearest dark spot and hides.",
			"Swap the Saap's and the Prof's thoughts, light only the Prof, and press ACTION."
		],
		"star_hints": [
			"Pass the thoughts round: shyness to the Prof, his hunger to Mess Aunty, her sleepiness to the Saap. Light the Saap and the Prof.",
			"Same thoughts, but light all three."
		],
		"new_feeling": "SHY",
		"tutorial": [
			"NEW FEELING: SHY. A shy character in the light walks to the nearest dark spot and hides. Your light pushes them around!"
		],
		"cliffhanger": {
			"mail_from": "JC Wi-Fi",
			"sent": "Tuesday, 1:04 AM",
			"to": "dean.academics",
			"cc": "all TAs",
			"subject": "The TAs of this comic are INCOMPETENT and do not know basic things.",
			"line": "…1:04 AM. Last night. JC. …Who. Sent. THAT.",
			"note": "After the result card: the page goes quiet, one slow DING, the mail notification slides over the comic."
		},
		"voice_lengths_s": {
			"page_05_intro": [
				13.0,
				18.5
			],
			"page_05_original": [
				4.0,
				6.0
			],
			"page_05_twist": [
				2.0,
				3.0
			],
			"page_05_win": [
				8.5,
				12.0
			],
			"page_05_stars_1": [
				4.0,
				6.0
			],
			"page_05_stars_2": [
				6.0,
				9.0
			],
			"page_05_fails_1": [
				2.5,
				3.0
			],
			"page_05_fails_2": [
				3.0,
				4.0
			],
			"page_05_fails_3": [
				3.0,
				4.0
			],
			"page_05_dialogue_kid_lit": [
				2.5,
				3.5
			],
			"page_05_dialogue_kid_gets_SLEEPY": [
				1.5,
				2.0
			],
			"page_05_dialogue_boss_lit": [
				2.5,
				3.5
			],
			"page_05_dialogue_boss_gets_SHY": [
				2.5,
				3.5
			],
			"page_05_dialogue_grandma_lit": [
				2.5,
				3.0
			],
			"page_05_dialogue_grandma_gets_HUNGRY": [
				2.0,
				3.0
			],
			"page_05_dialogue_dog_lit": [
				2.0,
				3.0
			],
			"page_05_card": [
				7.0,
				10.0
			],
			"page_05_cliffhanger": [
				2.5,
				3.5
			]
		},
		"solver": {
			"ideas": [
				6,
				2,
				1
			],
			"win_percent": [
				16.667,
				2.778,
				0.926
			],
			"grids": [
				0.2,
				0.02
			]
		}
	}
