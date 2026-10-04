extends RefCounted
## Campaign page from design thread "Level and puzzle logic design" (design/levels.md).
## New fields: lanterns.count (hard lantern limit), flick, hints, CLONK fact.


static func definition() -> Dictionary:
	return {
		"id": "page_05",
		"room": "living_room",
		"title": "Cat & Mouse",
		"width": 11,
		"rail_span": [
			0,
			10
		],
		"spotlights": {
			"count": 1,
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
			"count": 1,
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
		"lamps": [],
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
				"id": "cat",
				"art": "cat",
				"slot": 3,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": false
			},
			{
				"id": "mouse",
				"art": "mouse",
				"slot": 5,
				"facing": "L",
				"thought": "SCARED",
				"contradiction": true
			},
			{
				"id": "dog",
				"art": "dog",
				"slot": 7,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "rocker",
				"type": "SEAT",
				"art": "rocker",
				"slot": 1
			},
			{
				"id": "cheese",
				"type": "FOOD",
				"art": "cheese",
				"slot": 9
			}
		],
		"original_caption": "The Cat chased the Mouse out of the comic.",
		"endings_total": 132,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "The Mouse bonks the Cat.",
				"facts": [
					{
						"type": "BONKED",
						"character": "mouse",
						"target": "cat"
					}
				]
			},
			{
				"id": "headline_2",
				"caption": "The Cat eats the cheese.",
				"facts": [
					{
						"type": "ATE",
						"character": "cat",
						"object": "cheese"
					}
				]
			}
		],
		"hints": [
			"What if the Mouse was the angry one?",
			"Swap the Cat and the Mouse, then wake the Dog with your spare bulb.",
			"ghost: swap Cat/Mouse + flick slot 8 at beat 2"
		],
		"goal": {
			"facts": [
				{
					"type": "EXITED",
					"character": "cat"
				},
				{
					"type": "ATE",
					"character": "dog",
					"object": "cheese"
				}
			],
			"twist_caption": "The MOUSE chased the CAT out of the comic. The DOG got the cheese.",
			"red_pen_words": [
				"MOUSE",
				"CAT",
				"DOG"
			]
		}
	}
