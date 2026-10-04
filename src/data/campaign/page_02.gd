extends RefCounted
## Campaign page from design thread "Level and puzzle logic design" (design/levels.md).
## New fields: lanterns.count (hard lantern limit), flick, hints, CLONK fact.


static func definition() -> Dictionary:
	return {
		"id": "page_02",
		"title": "Nap Time",
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
				"art": "intern",
				"slot": 3,
				"facing": "R",
				"thought": "ANGRY",
				"contradiction": true
			},
			{
				"id": "dog",
				"art": "dog",
				"slot": 5,
				"facing": "R",
				"thought": "SLEEPY",
				"contradiction": false
			},
			{
				"id": "boss",
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
				"caption": "The Intern naps in the dog bed.",
				"facts": [
					{
						"type": "ASLEEP",
						"character": "intern",
						"object": "dog_bed"
					}
				]
			}
		],
		"hints": [
			"Somebody in the dark is sleepy.",
			"Swap the Dog's thought with the Boss's.",
			"ghost: lantern over slot 6 + swap Dog/Boss"
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
		}
	}
