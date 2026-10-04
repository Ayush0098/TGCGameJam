extends RefCounted
## Level 6/15 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_05",
		"number": 6,
		"room": "office",
		"narration_key": "birthday",
		"title": "The Boss's Birthday",
		"voice": "birthday",
		"difficulty": "yellow",
		"width": 11,
		"rail_span": [
			0,
			10
		],
		"spotlights": {
			"count": 1,
			"default_centres": [
				5
			]
		},
		"lanterns": {
			"radius": 1.6,
			"bounds": [
				0.0,
				-1.2,
				5.0,
				-0.6
			],
			"count": 1,
			"defaults": [
				{
					"x": 5.0,
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
				"switch_id": "pedal",
				"initially_on": false
			}
		],
		"characters": [
			{
				"id": "intern",
				"name": "Intern",
				"art": "intern",
				"slot": 1,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": true
			},
			{
				"id": "grandma",
				"name": "Grandma",
				"art": "grandma",
				"slot": 2,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": true
			},
			{
				"id": "boss",
				"name": "Boss",
				"art": "boss",
				"slot": 4,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Dog",
				"art": "dog",
				"slot": 9,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "office_chair",
				"type": "SEAT",
				"art": "office_chair",
				"slot": 0
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"slot": 6
			},
			{
				"id": "pedal",
				"type": "SWITCH",
				"art": "pedal",
				"slot": 7
			}
		],
		"original_caption": "The Boss ate his birthday cake.",
		"endings_total": 12,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "SWEET OLD GRANDMA BONKS THE BIRTHDAY BOY",
				"facts": [
					{
						"type": "BONKED",
						"character": "grandma",
						"target": "boss"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "THE BOSS RUNS OUT OF HIS OWN PARTY",
				"facts": [
					{
						"type": "EXITED",
						"character": "boss"
					}
				]
			}
		],
		"goal": {
			"facts": [
				{
					"type": "ATE",
					"character": "dog",
					"object": "cake"
				}
			],
			"twist_caption": "The DOG ate the birthday cake.",
			"red_pen_words": [
				"DOG"
			]
		},
		"narration": {
			"intro": "It's the Boss's birthday. He planned the party himself, sent himself a card, and signed it 'from everyone'. This year he WILL eat the cake. Boss Cake Count: zero. That changes today.",
			"original": "The Boss ate his birthday cake. Finally. Happy birthday, sir.",
			"twist": "The DOG ate the birthday cake.",
			"win": "Happy birthday, Boss. The Dog says thank you for the cake. Boss Cake Count: zero. Dog Cake Count: I've stopped counting. The Dog has his own accountant now.",
			"fail": "The Boss ate his birthday cake. A beautiful moment. I may cry.",
			"fail_alt": [
				"Happy birthday to the Boss, and to nobody else.",
				"The party went on without the twist."
			]
		},
		"dialogue": [
			{
				"character": "boss",
				"when": "lit",
				"line": "My cake. My party. My cake."
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "Oh, how lovely, a party. I hate parties."
			},
			{
				"character": "intern",
				"when": "lit",
				"line": "I wasn't invited. I'm Brian. Hi. Cake?"
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Somebody said 'cake' in my dream."
			},
			{
				"character": "boss",
				"when": "swap",
				"line": "Why is everyone LOOKING at me?!"
			},
			{
				"character": "dog",
				"when": "win",
				"line": "Best. Party. Ever."
			}
		],
		"tutorial": [],
		"hints": [
			"The Boss will always reach the cake before the Dog wakes up.",
			"Take away the Boss's hunger, but someone still has to step on the pedal.",
			"Swap Grandma's and the Boss's thoughts, and keep both of them in the light."
		],
		"bonus_hints": [
			"Swap Grandma and the Intern, then light Grandma and the Boss.",
			"Give the Boss Grandma's fear, and keep the Boss and Grandma lit."
		]
	}
