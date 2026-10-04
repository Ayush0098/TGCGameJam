extends RefCounted
## Campaign page from design thread "Level and puzzle logic design" (design/levels.md).
## New fields: lanterns.count (hard lantern limit), flick, hints, CLONK fact.


static func definition() -> Dictionary:
	return {
		"id": "page_04",
		"room": "kitchen",
		"title": "Midnight Snack",
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
		"flick": 1,
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
				"switch_id": "pedal",
				"initially_on": false
			}
		],
		"characters": [
			{
				"id": "grandma",
				"art": "grandma",
				"slot": 0,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "kid",
				"art": "kid",
				"slot": 2,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "cat",
				"art": "cat",
				"slot": 8,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "dog",
				"art": "dog",
				"slot": 10,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": true
			}
		],
		"objects": [
			{
				"id": "pedal",
				"type": "SWITCH",
				"art": "pedal",
				"slot": 3
			},
			{
				"id": "armchair",
				"type": "SEAT",
				"art": "armchair",
				"slot": 4
			},
			{
				"id": "pie",
				"type": "FOOD",
				"art": "pie",
				"slot": 6
			}
		],
		"original_caption": "The Kid ate the pie. The Cat ran out of the comic.",
		"endings_total": 9,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "Grandma sleepwalks and the Dog feasts.",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "grandma",
						"object": "armchair"
					},
					{
						"type": "ATE",
						"character": "dog",
						"object": "pie"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "Pie fight! Grandma and the Dog clonk.",
				"facts": [
					{
						"type": "CLONK",
						"character": "grandma"
					},
					{
						"type": "CLONK",
						"character": "dog"
					}
				]
			}
		],
		"hints": [
			"The Kid steps on the pedal on the way.",
			"Give the Kid Grandma's sleepiness, then leave Grandma in the dark.",
			"ghost: lantern slot 1, swap Kid/Grandma, lantern slot 3"
		],
		"goal": {
			"facts": [
				{
					"type": "ATE",
					"character": "dog",
					"object": "pie"
				}
			],
			"twist_caption": "The DOG ate the pie.",
			"red_pen_words": [
				"DOG"
			]
		}
	}
