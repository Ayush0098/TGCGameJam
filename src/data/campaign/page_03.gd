extends RefCounted
## Level 3/15 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_03",
		"number": 3,
		"room": "living_room",
		"narration_key": "nap",
		"title": "Nap Time",
		"difficulty": "green",
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
				"name": "Intern",
				"art": "intern",
				"slot": 3,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": true
			},
			{
				"id": "dog",
				"name": "Dog",
				"art": "dog",
				"slot": 5,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "boss",
				"name": "Boss",
				"art": "boss",
				"slot": 7,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "dog_bed",
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
		"original_caption": "The Boss ate the cake.",
		"endings_total": 17,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "THE BOSS BONKS THE DOG. HR IS TYPING.",
				"facts": [
					{
						"type": "BONKED",
						"character": "boss",
						"target": "dog"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "THE DOG BONKS KEVIN THE INTERN",
				"facts": [
					{
						"type": "BONKED",
						"character": "dog",
						"target": "intern"
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
				},
				{
					"type": "ASLEEP",
					"character": "boss",
					"object": "dog_bed"
				}
			],
			"twist_caption": "The DOG ate the cake. The BOSS napped in the dog bed.",
			"red_pen_words": [
				"DOG",
				"BOSS"
			]
		},
		"narration": {
			"intro": "Sunday. The Boss has invited himself over, which is how the Boss gets invited anywhere. There is cake. Today, the Boss eats his first cake. Boss Cake Count: zero. For now.",
			"original": "The Boss ate the cake. Hard work pays off.",
			"twist": "The DOG ate the cake. The BOSS napped in the dog bed.",
			"win": "The Dog ate the Boss's cake, and the Boss is asleep in a dog bed, drooling on a squeaky bone. Boss Cake Count: still zero. The Dog has been promoted.",
			"fail": "The Boss ate the cake. Capitalism wins again.",
			"fail_alt": [
				"Order is restored. I love order.",
				"Not the ending. But a very tidy ending."
			]
		},
		"dialogue": [
			{
				"character": "boss",
				"when": "lit",
				"line": "Cake time. Boss privileges."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Five more minutes..."
			},
			{
				"character": "intern",
				"when": "lit",
				"line": "Nobody invited me. I came anyway. Hi."
			},
			{
				"character": "boss",
				"when": "swap",
				"line": "Suddenly... so sleepy... is that a chew toy?"
			},
			{
				"character": "dog",
				"when": "win",
				"line": "I've waited my whole life for this. All seven years of it."
			}
		],
		"tutorial": [
			"Drag a thought bubble onto another lit character to swap their thoughts."
		],
		"hints": [
			"The Boss always beats the Dog to the cake. What if the Boss didn't want it?",
			"Light the Dog and the Boss together and swap their thoughts.",
			"Swap the Dog's and the Boss's thoughts, and keep only those two in the light."
		],
		"bonus_hints": [
			"Pass the Intern's anger along: swap the Intern and the Dog, then the Dog and the Boss. End with the Dog and the Boss lit.",
			"Swap the Dog and the Boss first, then the Intern and the Dog. End with the Dog and the Intern lit."
		]
	}
