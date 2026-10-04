extends RefCounted
## Campaign page from design thread "Level and puzzle logic design" (design/levels.md).
## New fields: lanterns.count (hard lantern limit), flick, hints, CLONK fact.


static func definition() -> Dictionary:
	return {
		"id": "page_08",
		"room": "office",
		"title": "Lightbulb Moment",
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
		"flick": 1,
		"fixed_lights": [],
		"lamps": [
			{
				"id": "lamp",
				"zone": [
					5,
					8
				],
				"switch_id": "pedal",
				"initially_on": false
			},
			{
				"id": "lamp_2",
				"zone": [
					9,
					11
				],
				"switch_id": "pedal_2",
				"initially_on": false
			}
		],
		"characters": [
			{
				"id": "boss",
				"art": "boss",
				"slot": 2,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "intern",
				"art": "intern",
				"slot": 3,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "dog",
				"art": "dog",
				"slot": 5,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "grandma",
				"art": "grandma",
				"slot": 8,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": true
			},
			{
				"id": "cat",
				"art": "cat",
				"slot": 11,
				"facing": "L",
				"thought": "SLEEPY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "pedal",
				"type": "SWITCH",
				"art": "pedal",
				"slot": 4
			},
			{
				"id": "chair",
				"type": "SEAT",
				"art": "chair",
				"slot": 6
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"slot": 8
			},
			{
				"id": "pedal_2",
				"type": "SWITCH",
				"art": "pedal",
				"slot": 9
			}
		],
		"original_caption": "The Boss and the Intern had the same bad idea.",
		"endings_total": 20,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "The Intern and the Dog bonk each other.",
				"facts": [
					{
						"type": "BONKED",
						"character": "intern",
						"target": "dog"
					},
					{
						"type": "BONKED",
						"character": "dog",
						"target": "intern"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "The Boss bonks the Dog.",
				"facts": [
					{
						"type": "BONKED",
						"character": "boss",
						"target": "dog"
					}
				]
			}
		],
		"hints": [
			"Each lamp needs someone to walk over its pedal.",
			"Somebody has to cross the whole room, and your spare bulb can give them a reason.",
			"ghost: lantern slot 4 + flick on the Boss at beat 1"
		],
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
		}
	}
