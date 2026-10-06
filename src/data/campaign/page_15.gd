extends RefCounted
## Page 15 "Lightbulb Moment", IIIT-H story rev 4 (design/story_proposal.md, design/build_p4_15/spec.md).
## Layout page_10; star ladder verified by the solver (levels_solver/ladder), 0.2 and 0.02 lantern grids: ideas 6/2/1.


static func definition() -> Dictionary:
	return {
		"id": "page_15",
		"number": 15,
		"title": "Lightbulb Moment",
		"finale": true,
		"difficulty": "red",
		"room": "workspaces",
		"voice": "page_15",
		"source_layout": "page_10",
		"width": 12,
		"rail_span": [
			0,
			11
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
				-0.6
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
		"flick": 1,
		"fixed_lights": [],
		"lamps": [
			{
				"id": "lamp",
				"zone": [
					5,
					8
				],
				"switch_id": "switch",
				"initially_on": false
			},
			{
				"id": "lamp_2",
				"zone": [
					9,
					11
				],
				"switch_id": "switch_2",
				"initially_on": false
			}
		],
		"characters": [
			{
				"id": "kid",
				"name": "Saap",
				"art": "kid",
				"slot": 0,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "boss",
				"name": "Prof",
				"art": "boss",
				"slot": 2,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "intern",
				"name": "Kassi",
				"art": "intern",
				"slot": 4,
				"facing": "L",
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Chintu",
				"art": "dog",
				"slot": 5,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": true
			},
			{
				"id": "grandma",
				"name": "Mess Aunty",
				"art": "grandma",
				"slot": 9,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "cat",
				"name": "Dassi",
				"art": "dassi",
				"slot": 11,
				"facing": "L",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "prompt",
				"name": "Prompt Bhai",
				"art": "kid",
				"slot": 10,
				"facing": "L",
				"thought": "ANGRY",
				"contradiction": false,
				"phone_glow": true,
				"tint": "#7FD3FF"
			}
		],
		"objects": [
			{
				"id": "switch",
				"type": "SWITCH",
				"art": "pedal",
				"name": "light switch",
				"slot": 4
			},
			{
				"id": "chair",
				"type": "SEAT",
				"art": "chair",
				"name": "chair",
				"slot": 6
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"name": "cake",
				"slot": 8
			},
			{
				"id": "switch_2",
				"type": "SWITCH",
				"art": "pedal",
				"name": "light switch",
				"slot": 9
			}
		],
		"original_caption": "Nothing happened.",
		"endings_total": 107,
		"goal": {
			"facts": [
				{
					"type": "ALL_ACTIVATED"
				}
			],
			"twist_caption": "EVERYONE had a lightbulb moment!",
			"red_pen_words": [
				"EVERYONE"
			]
		},
		"ladder": [
			{
				"id": "star_2",
				"caption": "…and the Saap bonked Mess Aunty.",
				"facts": [
					{
						"type": "BONKED",
						"character": "kid",
						"target": "grandma"
					}
				]
			},
			{
				"id": "star_3",
				"caption": "…and the Prof and the Kassi bonked each other.",
				"facts": [
					{
						"type": "BONKED",
						"character": "boss",
						"target": "intern"
					}
				]
			}
		],
		"narration": {
			"intro": "Endsem eve. The last page. I see the Prof tomorrow. Prompt Bhai is at the TGC Game Jam, typing 'make a game about a lightbulb'. I have no tricks left. Just a quiet ending where nothing happens. Pls sar. Let nothing happen.",
			"original": "Nothing happened. Everyone studied. Nobody had a single idea. Perfect.",
			"twist": "EVERYONE had a lightbulb moment!",
			"win": "Everyone… everyone had a… [snort] Fifteen pages! Prof Cake Count: ZERO! Fine. FINE. I'll take it lite. …Lite. Light. LIGHT. Oh no. That's the joke, isn't it. That was my lightbulb moment.",
			"stars": [
				"And the Saap bonked Mess Aunty. He says he didn't even swing. He swung.",
				"And the Prof and the Kassi bonked each other. Minus three. Worth it. And Prompt Bhai bonked Chintu. Nobody prompted him. Remember that."
			],
			"fails": [
				"Somebody's still in the dark. Good. Stay there.",
				"Nothing happened. Perfect. Don't touch it.",
				"So close to ruining everything."
			],
			"hidden": []
		},
		"dialogue": [
			{
				"character": "boss",
				"when": "lit",
				"line": "My idea! Put it in the paper! Co-author: my wife."
			},
			{
				"character": "intern",
				"when": "lit",
				"line": "No, MY idea! Sir, can I be second author? Acknowledgements?"
			},
			{
				"character": "kid",
				"when": "lit",
				"line": "Bro, I have an idea. It just came."
			},
			{
				"character": "prompt",
				"when": "lit",
				"line": "Wait. Nobody prompted me. Is this thinking?"
			},
			{
				"character": "prompt",
				"when": "win",
				"line": "The light helps. The idea has to be yours."
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "Oh dear, a crowd. I'll get my ladle. And Pappu."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Too many ideas. I'm out."
			},
			{
				"character": "cat",
				"when": "lit",
				"line": "Wake me when it's over. I've already submitted."
			},
			{
				"character": "cat",
				"when": "win",
				"line": "Fine. Nine point nine out of ten."
			}
		],
		"stickers": [],
		"hints": [
			"Everyone has to end up active. Two switches light the far side of the room.",
			"No swaps needed. Light the Kassi and Chintu: whoever runs or charges will hit the switches.",
			"During ACTION, drop the spare bulb on the Saap and the Prof."
		],
		"star_hints": [
			"Leave every thought as it is. Angry characters do the bonking for you.",
			"Light exactly the Kassi and Chintu, and drop the spare bulb between the Saap and the Prof."
		],
		"manhunt": {
			"subject": "Re: The sender",
			"unread": "0 (everyone is reading)",
			"suspect": "Revealed.",
			"clue": "Turn back to page 4."
		},
		"reveal": {
			"steps": [
				{
					"say": "Dear all. The sender has been found. Turn back to page 4.",
					"voice": "page_15_reveal_1"
				},
				{
					"action": "Replay page 4 (1:03 AM, JC) in full light with the Narrator's winning plan. Camera follows Chintu across the table. His paw lands on the laptop. The screen, now lit, reads: Drafts (1): 'write the angriest possible mail to a dean (testing AI for hackathon, DO NOT SEND)'. Paw on Send. Whoosh. Clock ticks to 1:04. Prompt Bhai snores on the bean bag. Chintu eats the Maggi."
				},
				{
					"say": "Chintu pressed Send. Chintu doesn't refuse literally anything. Including Send. …But Chintu wasn't hungry on page 4. Not until somebody lit him.",
					"voice": "page_15_reveal_2"
				},
				{
					"say": "You. YOU did this. Page 4. Suspect number seven was right. I met the Prof. He said, 'Lite le.' The rubric stays, though. So does my salary. Regards.",
					"voice": "page_15_reveal_3"
				}
			],
			"final_panel": "Chintu wearing a tiny lanyard 'Infinium: Best Prompt (accidental)', a bump on his head, and the frog giving a 👌.",
			"achievement": {
				"id": "it_was_me",
				"name": "It Was Me All Along"
			},
			"credits_additions": [
				"In memory of Oreo, Queen of IIITH.",
				"The Faccha: still in Vindhya. If found, please return to Bakul.",
				"The Prof and Mess Aunty: this comic does not spread rumours.",
				"The Kassi: series two, attempt #2 in progress.",
				"Pineapple status: still reserved for Ishaan sir.",
				"No code in this game was MOSSed. We checked. Twice.",
				"Made at Infinium with a little help from AI. We learnt the basics first. Prompt Bhai is learning too."
			]
		},
		"voice_lengths_s": {
			"page_15_intro": [
				13.5,
				19.5
			],
			"page_15_original": [
				3.5,
				4.5
			],
			"page_15_twist": [
				1.5,
				2.5
			],
			"page_15_win": [
				10.0,
				14
			],
			"page_15_stars_1": [
				4.5,
				6.5
			],
			"page_15_stars_2": [
				7.5,
				9
			],
			"page_15_fails_1": [
				2.5,
				3.5
			],
			"page_15_fails_2": [
				2.0,
				3.0
			],
			"page_15_fails_3": [
				1.5,
				2.5
			],
			"page_15_dialogue_boss_lit": [
				3.5,
				4.5
			],
			"page_15_dialogue_intern_lit": [
				3.5,
				4.5
			],
			"page_15_dialogue_kid_lit": [
				2.5,
				3.5
			],
			"page_15_dialogue_prompt_lit": [
				2.5,
				3.0
			],
			"page_15_dialogue_prompt_win": [
				3.0,
				4.0
			],
			"page_15_dialogue_grandma_lit": [
				3.5,
				4.5
			],
			"page_15_dialogue_dog_lit": [
				1.5,
				2.5
			],
			"page_15_dialogue_cat_lit": [
				2.5,
				3.5
			],
			"page_15_dialogue_cat_win": [
				2.5,
				3.0
			],
			"page_15_reveal_1": [
				4.0,
				5.5
			],
			"page_15_reveal_2": [
				7.0,
				10.0
			],
			"page_15_reveal_3": [
				9.0,
				12
			]
		},
		"solver": {
			"ideas": [
				6,
				2,
				1
			],
			"win_percent": [
				1.833,
				0.258,
				0.029
			],
			"grids": [
				0.2,
				0.02
			]
		}
	}
