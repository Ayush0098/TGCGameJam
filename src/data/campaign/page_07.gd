extends RefCounted
## Level 9/15 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_07",
		"number": 9,
		"room": "living_room",
		"narration_key": "shadow",
		"title": "Shadow Play",
		"voice": "shadow",
		"difficulty": "yellow",
		"width": 11,
		"rail_span": [
			0,
			10
		],
		"spotlights": {
			"count": 1,
			"default_centres": [
				6
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
					"x": 6.0,
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
		"obstacles": [
			{
				"id": "screen",
				"from": [
					3.5,
					-0.45
				],
				"to": [
					3.5,
					0.8
				]
			}
		],
		"flick": 0,
		"fixed_lights": [],
		"lamps": [],
		"characters": [
			{
				"id": "mouse",
				"name": "Mouse",
				"art": "mouse",
				"slot": 1,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "boss",
				"name": "Boss",
				"art": "boss",
				"slot": 4,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "kid",
				"name": "Kid",
				"art": "kid",
				"slot": 5,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "grandma",
				"name": "Grandma",
				"art": "grandma",
				"slot": 6,
				"facing": "L",
				"thought": "ANGRY",
				"contradiction": true
			},
			{
				"id": "intern",
				"name": "Intern",
				"art": "intern",
				"slot": 7,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "armchair",
				"type": "SEAT",
				"art": "armchair",
				"slot": 0
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"slot": 3
			},
			{
				"id": "pie",
				"type": "FOOD",
				"art": "pie",
				"slot": 10
			}
		],
		"original_caption": "Grandma bonked the Kid.",
		"endings_total": 28,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "STEVE THE INTERN BONKS THE KID",
				"facts": [
					{
						"type": "BONKED",
						"character": "intern",
						"target": "kid"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "THE BOSS BONKS THE KID, GRANDMA LEAVES THE COMIC",
				"facts": [
					{
						"type": "BONKED",
						"character": "boss",
						"target": "kid"
					},
					{
						"type": "EXITED",
						"character": "grandma"
					}
				]
			}
		],
		"goal": {
			"facts": [
				{
					"type": "BONKED",
					"character": "boss",
					"target": "grandma"
				}
			],
			"twist_caption": "The BOSS bonked GRANDMA.",
			"red_pen_words": [
				"BOSS",
				"GRANDMA"
			]
		},
		"narration": {
			"intro": "Lamp, listen. Let's make a deal. You leave this page alone, and I'll write you a page of your own. You can be the hero. A lamp hero. Grandma bonks the Kid behind a bookshelf. Lovely. Nobody touch it.",
			"original": "Grandma bonked the Kid. He knows what he did.",
			"twist": "The BOSS bonked GRANDMA.",
			"win": "The Boss bonked Grandma. GRANDMA. I'll have to phone Grandma's lawyer. Grandma IS Grandma's lawyer. We had a DEAL, lamp.",
			"fail": "Grandma bonked the Kid. Everything is as it should be.",
			"fail_alt": [
				"Deal's still on the table, lamp.",
				"The bookshelf saw nothing."
			]
		},
		"dialogue": [
			{
				"character": "grandma",
				"when": "lit",
				"line": "Who wants a bonk? Everybody gets a bonk."
			},
			{
				"character": "kid",
				"when": "lit",
				"line": "Is there cake back there?"
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "I don't do conflict. I have people for conflict."
			},
			{
				"character": "intern",
				"when": "lit",
				"line": "Steve. My name is Steve. Hello?"
			},
			{
				"character": "boss",
				"when": "swap",
				"line": "That's IT, Grandma!"
			},
			{
				"character": "boss",
				"when": "win",
				"line": "I'm so sorry, Grandma! It was the lamp!"
			}
		],
		"tutorial": [
			"Furniture blocks light. Raise the bulb to shine over it, lower it to shine under."
		],
		"hints": [
			"Grandma can't see the cake behind the shelf, so a hungry Grandma just stands there.",
			"Three-way swap: the Boss gets angry, Grandma gets hungry, the Kid gets scared.",
			"Light the Boss, the Kid and Grandma. Swap the Boss and Grandma, then swap Grandma and the Kid."
		],
		"bonus_hints": [
			"Give the Intern Grandma's anger, then swap Grandma and the Boss. Light the Kid, Grandma and the Intern.",
			"Swap only the Boss and Grandma, and light the Boss, the Kid and Grandma."
		]
	}
