extends RefCounted
## Campaign page from design thread "Level and puzzle logic design" (design/levels.md).
## New fields: lanterns.count (hard lantern limit), flick, hints, CLONK fact.


static func definition() -> Dictionary:
	return {
		"id": "page_07",
		"title": "Grandma's Revenge",
		"width": 11,
		"rail_span": [
			0,
			10
		],
		"spotlights": {
			"count": 2,
			"default_centres": [
				4
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
			"count": 2,
			"defaults": [
				{
					"x": 4.0,
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
					3,
					4
				],
				"switch_id": "pedal",
				"initially_on": false
			}
		],
		"characters": [
			{
				"id": "kid",
				"art": "kid",
				"slot": 1,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "dog",
				"art": "dog",
				"slot": 4,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "grandma",
				"art": "grandma",
				"slot": 5,
				"facing": "L",
				"thought": "ANGRY",
				"contradiction": true
			},
			{
				"id": "boss",
				"art": "boss",
				"slot": 10,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "chair",
				"type": "SEAT",
				"art": "chair",
				"slot": 0
			},
			{
				"id": "cake",
				"type": "FOOD",
				"art": "cake",
				"slot": 7
			},
			{
				"id": "pedal",
				"type": "SWITCH",
				"art": "pedal",
				"slot": 8
			}
		],
		"original_caption": "Grandma bonked the Dog.",
		"endings_total": 143,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "The Dog bonks the Boss.",
				"facts": [
					{
						"type": "BONKED",
						"character": "dog",
						"target": "boss"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "The Boss naps and the Kid eats the cake.",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "boss",
						"object": "chair"
					},
					{
						"type": "ATE",
						"character": "kid",
						"object": "cake"
					}
				]
			}
		],
		"hints": [
			"Grandma bonks whoever is closest and lit.",
			"Keep the Dog in the dark until the Boss steps on the pedal.",
			"ghost: lanterns over slots 6 and 9"
		],
		"goal": {
			"facts": [
				{
					"type": "BONKED",
					"character": "grandma",
					"target": "boss"
				},
				{
					"type": "ATE",
					"character": "dog",
					"object": "cake"
				}
			],
			"twist_caption": "Grandma bonked the BOSS. The DOG ate the cake.",
			"red_pen_words": [
				"BOSS",
				"DOG"
			]
		}
	}
