extends RefCounted
## Page 8/15 "First Date", designed by the story thread (design/story.md, design/levels.md).
## Verified by design/levels_solver/audit15.py (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_12",
		"number": 8,
		"title": "First Date",
		"voice": "date",
		"room": "office",
		"difficulty": "yellow",
		"width": 10,
		"rail_span": [
			0,
			9
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
				6.0,
				-1.2,
				8.0,
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
					"x": 6.0,
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
				"id": "intern",
				"name": "Intern",
				"art": "intern",
				"slot": 6,
				"facing": "L",
				"thought": "IN_LOVE",
				"contradiction": false
			},
			{
				"id": "boss",
				"name": "Boss",
				"art": "boss",
				"slot": 7,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": true
			},
			{
				"id": "cat",
				"name": "Cat",
				"art": "cat",
				"slot": 8,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "grandma",
				"name": "Grandma",
				"art": "grandma",
				"slot": 9,
				"facing": "L",
				"thought": "ANGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "chair",
				"type": "SEAT",
				"art": "chair",
				"slot": 3
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"slot": 5
			}
		],
		"original_caption": "The Intern hugged the Boss. HR has been notified.",
		"endings_total": 61,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "THE BOSS BONKS GRANDMA. GRANDMA WILL REMEMBER THIS.",
				"facts": [
					{
						"type": "BONKED",
						"character": "boss",
						"target": "grandma"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "GRANDMA MAKES THE FIRST MOVE",
				"facts": [
					{
						"type": "HUGGED",
						"character": "grandma",
						"target": "boss"
					}
				]
			}
		],
		"goal": {
			"facts": [
				{
					"type": "HUGGED",
					"character": "intern",
					"target": "boss"
				},
				{
					"type": "HUGGED",
					"character": "boss",
					"target": "grandma"
				}
			],
			"twist_caption": "The Intern hugged the Boss. The Boss hugged GRANDMA.",
			"red_pen_words": [
				"GRANDMA"
			]
		},
		"narration": {
			"intro": "The office party. The Intern, Gary, is in love with the Boss. The Boss is furious about everything. The Cat is here for the free buffet. Nobody knows why Grandma is here.",
			"original": "The Intern hugged the Boss. HR has been notified. HR has notified HR.",
			"twist": "The Intern hugged the Boss. The Boss hugged GRANDMA.",
			"win": "The Intern hugged the Boss. The Boss hugged Grandma. Grandma has booked a church. I wrote a workplace drama, and you have turned it into a romance. A horrible, beautiful romance.",
			"fail": "HR has been notified. Again.",
			"fail_alt": [
				"Love is in the air. So is HR.",
				"Romance is dead. Long live the office."
			]
		},
		"dialogue": [
			{
				"character": "intern",
				"when": "lit",
				"line": "He looked at me. Twice. That's basically a date."
			},
			{
				"character": "boss",
				"when": "lit",
				"line": "Everyone is fired. Even the cat."
			},
			{
				"character": "grandma",
				"when": "lit",
				"line": "I'm only here for the buffet, dear."
			},
			{
				"character": "cat",
				"when": "lit",
				"line": "I'm not part of this."
			},
			{
				"character": "boss",
				"when": "swap",
				"line": "WHO DID THIS? I'm FURIOUS. At... feelings?"
			},
			{
				"character": "grandma",
				"when": "swap",
				"line": "Is the buffet open?"
			},
			{
				"character": "boss",
				"when": "win",
				"line": "Grandma... you smell like soup and danger."
			},
			{
				"character": "grandma",
				"when": "win",
				"line": "First hug since the war. Which war? Yes."
			}
		],
		"tutorial": [
			"NEW FEELING: IN LOVE. Walks to the nearest lit character and hugs them. Whoever gets hugged falls in love too and goes looking for someone else to hug!"
		],
		"hints": [
			"A hug turns anger into love. Even the Boss's.",
			"Make the Boss angry, and give Grandma his hunger so she stays put.",
			"Swap the Boss and Grandma, then light the Intern, the Boss, the Cat and Grandma all at once."
		],
		"bonus_hints": [
			"Same swap as the twist, but keep the Intern in the dark. Nobody calms the Boss down.",
			"Pass the love round: the Intern's love to the Cat, the Cat's fear to the Boss, the Boss's hunger to Grandma, Grandma's anger to the Intern. Light all four."
		],
		"new_feeling": "IN_LOVE"
	}
