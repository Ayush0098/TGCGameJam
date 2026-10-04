extends RefCounted
## Page 3 "Office Hours", IIIT-H story rev 4 (design/story_proposal.md, design/build_p1_3/spec.md).
## Star ladder verified by the solver (design/levels_solver/ladder), 0.2 and 0.02 lantern grids.


static func definition() -> Dictionary:
	return {
		"id": "page_03",
		"number": 3,
		"title": "Office Hours",
		"difficulty": "green",
		"room": "prof_lab",
		"voice": "page_03",
		"width": 11,
		"rail_span": [
			0,
			10
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
				0.0,
				-1.2,
				10.0,
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
				1,
				2
			],
			[
				9,
				9
			]
		],
		"lamps": [],
		"characters": [
			{
				"id": "intern",
				"name": "Kassi",
				"art": "intern",
				"slot": 4,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": true
			},
			{
				"id": "dog",
				"name": "Chintu",
				"art": "dog",
				"slot": 5,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "boss",
				"name": "Prof",
				"art": "boss",
				"slot": 7,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "chintu_bed",
				"type": "SEAT",
				"art": "dog_bed",
				"slot": 2
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"slot": 9
			}
		],
		"original_caption": "The Prof ate the cake.",
		"endings_total": 21,
		"goal": {
			"facts": [
				{
					"type": "ATE",
					"character": "dog",
					"object": "cake"
				}
			],
			"twist_caption": "CHINTU ate the Prof's cake.",
			"red_pen_words": [
				"CHINTU"
			]
		},
		"ladder": [
			{
				"id": "star_2",
				"caption": "…and the Kassi bonked Chintu for it.",
				"facts": [
					{
						"type": "BONKED",
						"character": "intern",
						"target": "dog"
					}
				]
			},
			{
				"id": "star_3",
				"caption": "…and the Prof walked out of the comic.",
				"facts": [
					{
						"type": "EXITED",
						"character": "boss"
					}
				]
			}
		],
		"narration": {
			"intro": "Office hours. Nobody ever comes, so the Prof has bought himself a cake. Prof Cake Count: zero. For now. The Kassi is here with two coffees. One is for a facchi who said she'd 'maybe come to office hours'. Nobody comes to office hours.",
			"original": "The Prof ate the cake. Hard work pays off. So do grants. (Cakes in my version don't count. As per rubric.)",
			"twist": "CHINTU ate the Prof's cake.",
			"win": "Chintu ate the Prof's cake. During office hours. Making Chintu the first person ever to attend them. Prof Cake Count: still zero. Chintu has been promoted.",
			"stars": [
				"And the Kassi bonked Chintu. He says Chintu skipped the queue. There is no queue. There is no facchi. There are two coffees.",
				"And the Prof walked out of the comic. Office hours are now closed. Check Moodle for the new location."
			],
			"fails": [
				"The Prof ate his cake. Check Moodle for office hours.",
				"Order is restored. I love order. I love rubrics.",
				"A tidy ending. Typeset in LaTeX."
			],
			"hidden": []
		},
		"dialogue": [
			{
				"character": "boss",
				"when": "lit",
				"line": "Office hours. Nobody comes. More cake for me."
			},
			{
				"character": "boss",
				"when": "gets_SCARED",
				"line": "Wait. Someone is ATTENDING my office hours?"
			},
			{
				"character": "intern",
				"when": "lit",
				"line": "She said 'maybe'. Maybe is basically yes. It's been two hours."
			},
			{
				"character": "intern",
				"when": "fail",
				"line": "Sir, small doubt, sir. Is 'maybe' a no?"
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "I don't have a doubt. Please don't ask me a doubt."
			},
			{
				"character": "dog",
				"when": "gets_HUNGRY",
				"line": "Doubt: can I eat that? Doubt cleared."
			},
			{
				"character": "dog",
				"when": "win",
				"line": "First office hours I ever attended. Ten on ten."
			}
		],
		"stickers": [
			{
				"text": "Kassi Attempt #407: two coffees, office hours. ✗",
				"when": "result"
			}
		],
		"hints": [
			"Chintu has to want the cake. The Prof is the hungry one.",
			"Swap Chintu's and the Prof's thoughts.",
			"The cake's corner is always lit. Just keep Chintu in your light and press ACTION."
		],
		"star_hints": [
			"After the swap, light the Kassi too. An angry Kassi bonks whoever he can see.",
			"Light all three. A scared Prof walks out of his own office hours."
		]
	}
