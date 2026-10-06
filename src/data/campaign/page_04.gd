extends RefCounted
## Page 4 "1:03 AM, JC", IIIT-H story rev 4 (design/story_proposal.md, design/build_p4_15/spec.md).
## Layout page_04; star ladder verified by the solver (levels_solver/ladder), 0.2 and 0.02 lantern grids: ideas 3/2/1.


static func definition() -> Dictionary:
	return {
		"id": "page_04",
		"number": 4,
		"title": "1:03 AM, JC",
		"difficulty": "green",
		"room": "jc_night",
		"voice": "page_04",
		"source_layout": "page_04",
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
				4.0,
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
		"fixed_lights": [
			[
				6,
				6
			]
		],
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
				"art": "grandma",
				"slot": 0,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "prompt",
				"name": "Prompt Bhai",
				"art": "kid",
				"slot": 2,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": true,
				"phone_glow": true,
				"tint": "#7FD3FF"
			},
			{
				"id": "cat",
				"name": "Dassi",
				"art": "cat",
				"slot": 8,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Chintu",
				"art": "dog",
				"slot": 10,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "bean_bag",
				"type": "SEAT",
				"art": "cushion",
				"name": "bean bag",
				"slot": 3
			},
			{
				"id": "switch",
				"type": "SWITCH",
				"art": "pedal",
				"name": "JC light switch",
				"slot": 3
			},
			{
				"id": "maggi",
				"type": "FOOD",
				"art": "pie",
				"name": "cheese Maggi",
				"slot": 6
			}
		],
		"original_caption": "Nothing happened.",
		"endings_total": 6,
		"goal": {
			"facts": [
				{
					"type": "ATE",
					"character": "dog",
					"object": "maggi"
				}
			],
			"twist_caption": "CHINTU ate the Maggi.",
			"red_pen_words": [
				"CHINTU"
			]
		},
		"ladder": [
			{
				"id": "star_2",
				"caption": "…while Prompt Bhai fell asleep on the bean bag.",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "prompt",
						"object": "bean_bag"
					}
				]
			},
			{
				"id": "star_3",
				"caption": "…and Mess Aunty left the comic.",
				"facts": [
					{
						"type": "EXITED",
						"character": "grandma"
					}
				]
			}
		],
		"narration": {
			"intro": "Monday night. 1:03 AM. JC. One plate of cheese Maggi left. Prompt Bhai is 'testing the AI' for the hackathon. Dassi is here 'for the Wi-Fi'. Mess Aunty is here for reasons. Nothing will happen on this page. Nothing ever happens at 1:03.",
			"original": "Nobody moved. The Maggi went cold. This is called character development.",
			"twist": "CHINTU ate the Maggi.",
			"win": "Chintu ate the cheese Maggi. Straight across the table. Over the laptop, paws and all. Dassi left; she says the Wi-Fi dropped. Nothing else happened. I checked.",
			"stars": [
				"And Prompt Bhai fell asleep while the AI was 'thinking'. Someone took a photo. Why did I mention that?",
				"And Mess Aunty left the comic. At 1 AM. From JC. This comic does not spread rumours."
			],
			"fails": [
				"The Maggi went cold. So did my heart.",
				"1:03 AM. Nothing happens. Accurate.",
				"Midnight snack: accepted. Twist: wrong answer."
			],
			"hidden": []
		},
		"dialogue": [
			{
				"character": "prompt",
				"when": "lit",
				"line": "Bro, Quiz-1 is tomorrow and Claude can't sit it for me."
			},
			{
				"character": "prompt",
				"when": "gets_SLEEPY",
				"line": "Reeelaaaax… it's still thinking… five minutes…"
			},
			{
				"character": "cat",
				"when": "lit",
				"line": "He just said 'urgent' to a laptop. I'm not okay."
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "Mess opens at seven. Zzz."
			},
			{
				"character": "grandma",
				"when": "gets_SCARED",
				"line": "One AM? Beta, I have to go… somewhere."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Cheese. Maggi."
			},
			{
				"character": "dog",
				"when": "win",
				"line": "Shortcut across the table. Didn't touch anything. Probably."
			}
		],
		"stickers": [],
		"hints": [
			"Chintu is hungry, but the Maggi end of JC is dark. Someone has to walk over the light switch by the bean bag.",
			"Give Prompt Bhai Mess Aunty's sleepiness.",
			"Light Prompt Bhai. He walks to the bean bag, hits the switch on the way, and Chintu sees the Maggi."
		],
		"star_hints": [
			"Prompt Bhai should be the one asleep on the bean bag: swap his fear with Mess Aunty's sleepiness and light him.",
			"After that swap, light Mess Aunty too. Now she's the scared one, and she leaves."
		],
		"decor": [
			{
				"art": "laptop",
				"slot": 7,
				"note": "Prompt Bhai's open laptop on the table, between Chintu and the Maggi. Screen text 'Drafts (1)' readable only when lit."
			},
			{
				"art": "wall_clock",
				"slot": 5,
				"at": [
					1102,
					176
				],
				"note": "Wall clock showing 1:03. It ticks to 1:04 when the page ends, every time, win or fail. Nobody comments."
			}
		],
		"finale_replay_source": true,
		"voice_lengths_s": {
			"page_04_intro": [
				14.0,
				20.0
			],
			"page_04_original": [
				3.5,
				5.0
			],
			"page_04_twist": [
				1.5,
				2.0
			],
			"page_04_win": [
				9.0,
				12.5
			],
			"page_04_stars_1": [
				6.0,
				9.0
			],
			"page_04_stars_2": [
				5.5,
				8.0
			],
			"page_04_fails_1": [
				2.5,
				3.5
			],
			"page_04_fails_2": [
				1.5,
				2.5
			],
			"page_04_fails_3": [
				2.0,
				3.0
			],
			"page_04_dialogue_prompt_lit": [
				3.5,
				4.5
			],
			"page_04_dialogue_prompt_gets_SLEEPY": [
				2.0,
				3.0
			],
			"page_04_dialogue_cat_lit": [
				3.5,
				4.5
			],
			"page_04_dialogue_grandma_lit": [
				1.5,
				2.5
			],
			"page_04_dialogue_grandma_gets_SCARED": [
				2.5,
				3.5
			],
			"page_04_dialogue_dog_lit": [
				0.8,
				1.0
			],
			"page_04_dialogue_dog_win": [
				2.5,
				3.5
			]
		},
		"solver": {
			"ideas": [
				3,
				2,
				1
			],
			"win_percent": [
				33.333,
				25.0,
				4.167
			],
			"grids": [
				0.2,
				0.02
			]
		}
	}
