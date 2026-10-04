extends RefCounted
## Level 1/15 proposed by design thread "Level and puzzle logic design" (design/levels.md).
## Verified by design/levels_solver (twist and each headline reachable by 1-2 distinct solutions).


static func definition() -> Dictionary:
	return {
		"id": "page_01",
		"number": 1,
		"title": "Dinner Time",
		"room": "kitchen",
		"narration_key": "dinner",
		"difficulty": "green",
		"width": 9,
		"rail_span": [
			0,
			8
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
				8.0,
				0.6
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
		"lamps": [],
		"characters": [
			{
				"id": "cat",
				"name": "Cat",
				"art": "cat",
				"slot": 2,
				"facing": "R",
				"thought": "HUNGRY",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Dog",
				"art": "dog",
				"slot": 6,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "fish",
				"type": "FOOD",
				"art": "fish",
				"slot": 4
			},
			{
				"id": "cookie",
				"type": "FOOD",
				"art": "cookie",
				"slot": 8
			}
		],
		"original_caption": "The Dog ate the fish.",
		"endings_total": 4,
		"bonus": [
			{
				"id": "headline_1",
				"caption": "THE DOG SETTLES FOR A COOKIE",
				"facts": [
					{
						"type": "ATE",
						"character": "dog",
						"object": "cookie"
					}
				]
			}
		],
		"goal": {
			"facts": [
				{
					"type": "ATE",
					"character": "cat",
					"object": "fish"
				}
			],
			"twist_caption": "The CAT ate the fish.",
			"red_pen_words": [
				"CAT"
			]
		},
		"narration": {
			"intro": "Dinner at the Bulb house. Every night for eleven years, the Dog has eaten the fish. It is a classic. It is tradition. It is, frankly, the only joke I have.",
			"original": "The Dog ate the fish. Ha. Ha ha. Classic.",
			"twist": "The CAT ate the fish.",
			"win": "The CAT ate the... Who moved my lamp? Somebody MOVED my LAMP.",
			"fail": "The Dog ate the fish. As is tradition. As God and the Narrator intended.",
			"fail_alt": [
				"Ah, the classics.",
				"The fish has spoken."
			]
		},
		"dialogue": [
			{
				"character": "cat",
				"when": "lit",
				"line": "Eleven years. ELEVEN YEARS he gets the fish."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Fish fish fish fish fish."
			},
			{
				"character": "cat",
				"when": "win",
				"line": "Tell them, Narrator. Tell them who ate the fish."
			},
			{
				"character": "dog",
				"when": "fail",
				"line": "Fish."
			}
		],
		"tutorial": {
			"intro": [
				"Welcome to the Daily Bulb! Every page is a comic strip that has already been printed. That's the ORIGINAL story.",
				"You're Bulby, the lightbulb. Characters only act when they're in your light, and each one does what its thought bubble says.",
				"Your goal: change who's lit and what they think, so the strip ends with the TWIST written in red pen.",
				"Win the twist for a star, find bonus headlines for more stars, and collect every ending. Let's start with dinner..."
			],
			"panels": [
				{
					"id": "p1_light",
					"title": "Lights, please",
					"teaches": [
						"light reveals names and thoughts",
						"move the bulb",
						"raise/lower the bulb",
						"goal clipping: Original vs Twist",
						"ACTION and the result popup"
					],
					"width": 8,
					"rail_span": [
						0,
						7
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
							7.0,
							0.6
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
					"lamps": [],
					"characters": [
						{
							"id": "cat",
							"name": "Cat",
							"art": "cat",
							"slot": 1,
							"facing": "R",
							"thought": "HUNGRY",
							"contradiction": false
						},
						{
							"id": "dog",
							"name": "Dog",
							"art": "dog",
							"slot": 6,
							"facing": "L",
							"thought": "HUNGRY",
							"contradiction": false
						}
					],
					"objects": [
						{
							"id": "fish",
							"type": "FOOD",
							"art": "fish",
							"slot": 4
						}
					],
					"original_caption": "The Dog ate the fish.",
					"goal": {
						"facts": [
							{
								"type": "ATE",
								"character": "cat",
								"object": "fish"
							}
						],
						"twist_caption": "The CAT ate the fish.",
						"red_pen_words": [
							"CAT"
						]
					},
					"bonus": [],
					"steps": [
						{
							"caption": "It's dark in here. Drag me over to see who's home.",
							"gate": "lit",
							"target": "cat"
						},
						{
							"caption": "Lit characters show their name and what they're thinking. Slide me away...",
							"gate": "unlit",
							"target": "cat"
						},
						{
							"caption": "...and their thoughts hide again. Only lit characters act or see anything.",
							"gate": "click"
						},
						{
							"caption": "This is today's comic. Tap the crossed-out line to watch what was printed.",
							"gate": "clipping_opened"
						},
						{
							"caption": "Our version: the CAT eats the fish. Pull my cord down so my light reaches the Cat AND the fish.",
							"gate": "lit_set",
							"target": [
								"cat",
								"fish"
							]
						},
						{
							"caption": "Things get name tags too when they're lit: that's the fish.",
							"gate": "click"
						},
						{
							"caption": "Keep the Dog in the dark. A dark Dog can't smell a thing.",
							"gate": "unlit",
							"target": "dog"
						},
						{
							"caption": "Now press ACTION and watch the beats play out.",
							"gate": "action"
						},
						{
							"caption": "Twist printed! Flip between the ORIGINAL and YOUR TWIST tabs to compare.",
							"gate": "tabs_viewed"
						},
						{
							"caption": "RETRY replays, NEXT moves on.",
							"gate": "result_closed"
						}
					],
					"hints": [
						"Lower the bulb: its light gets wider.",
						"Bulb between the Cat and the fish, pulled all the way down."
					],
					"solution": [
						{
							"thoughts": {
								"Cat": "HUNGRY",
								"Dog": "HUNGRY"
							},
							"lit": [
								"cat"
							],
							"flick_wakes": []
						}
					]
				},
				{
					"id": "p2_swap",
					"title": "Change of heart",
					"teaches": [
						"thought icons and the legend",
						"swap two lit thoughts",
						"bonus headlines (stars)"
					],
					"width": 8,
					"rail_span": [
						0,
						7
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
							7.0,
							0.6
						],
						"count": 1,
						"defaults": [
							{
								"x": 2.5,
								"y": -0.3,
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
					"lamps": [],
					"characters": [
						{
							"id": "cat",
							"name": "Cat",
							"art": "cat",
							"slot": 2,
							"facing": "L",
							"thought": "SLEEPY",
							"contradiction": false
						},
						{
							"id": "dog",
							"name": "Dog",
							"art": "dog",
							"slot": 3,
							"facing": "R",
							"thought": "HUNGRY",
							"contradiction": false
						}
					],
					"objects": [
						{
							"id": "cushion",
							"type": "SEAT",
							"art": "cushion",
							"slot": 1
						},
						{
							"id": "fish",
							"type": "FOOD",
							"art": "fish",
							"slot": 4
						}
					],
					"original_caption": "The Dog ate the fish. The Cat napped.",
					"goal": {
						"facts": [
							{
								"type": "ATE",
								"character": "cat",
								"object": "fish"
							}
						],
						"twist_caption": "The CAT ate the fish.",
						"red_pen_words": [
							"CAT"
						]
					},
					"bonus": [
						{
							"id": "headline_1",
							"caption": "THE DOG NAPS ON THE CUSHION",
							"facts": [
								{
									"type": "ASLEEP",
									"character": "dog",
									"object": "cushion"
								}
							]
						}
					],
					"steps": [
						{
							"caption": "Everyone wants something. Tap ? to see what each thought does.",
							"gate": "legend_opened"
						},
						{
							"caption": "The Cat is sleepy, the Dog is hungry. Drag the Dog's thought onto the Cat.",
							"gate": "swap",
							"target": [
								"cat",
								"dog"
							]
						},
						{
							"caption": "Both must be lit to swap. Now press ACTION.",
							"gate": "action"
						},
						{
							"caption": "See the extra headline? Bonus headlines earn extra stars on every page.",
							"gate": "click"
						},
						{
							"caption": "NEW ENDING! Every different result goes in your Endings book. Tap the counter to peek.",
							"gate": "endings_opened"
						},
						{
							"caption": "Close the book and carry on.",
							"gate": "result_closed"
						}
					],
					"hints": [
						"Swap the Cat's and the Dog's thoughts."
					],
					"solution": [
						{
							"thoughts": {
								"Cat": "HUNGRY",
								"Dog": "SLEEPY"
							},
							"lit": [
								"cat",
								"dog"
							],
							"flick_wakes": []
						}
					]
				},
				{
					"id": "p3_shelf",
					"title": "Lights and shadows",
					"teaches": [
						"furniture blocks light",
						"raise the bulb to shine over it",
						"ANGRY characters bonk",
						"SCARED characters run off"
					],
					"width": 8,
					"rail_span": [
						0,
						7
					],
					"spotlights": {
						"count": 1,
						"default_centres": [
							1
						]
					},
					"lanterns": {
						"radius": 1.6,
						"bounds": [
							0.0,
							-1.2,
							7.0,
							0.6
						],
						"count": 1,
						"defaults": [
							{
								"x": 1.0,
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
							"id": "shelf",
							"from": [
								2.5,
								-0.45
							],
							"to": [
								2.5,
								0.8
							]
						}
					],
					"flick": 0,
					"fixed_lights": [],
					"lamps": [],
					"characters": [
						{
							"id": "dog",
							"name": "Dog",
							"art": "dog",
							"slot": 2,
							"facing": "L",
							"thought": "HUNGRY",
							"contradiction": false
						},
						{
							"id": "cat",
							"name": "Cat",
							"art": "cat",
							"slot": 4,
							"facing": "L",
							"thought": "ANGRY",
							"contradiction": false
						},
						{
							"id": "mouse",
							"name": "Mouse",
							"art": "mouse",
							"slot": 5,
							"facing": "L",
							"thought": "SCARED",
							"contradiction": false
						}
					],
					"objects": [
						{
							"id": "cheese",
							"type": "FOOD",
							"art": "cheese",
							"slot": 0
						}
					],
					"original_caption": "The Dog ate the cheese.",
					"goal": {
						"facts": [
							{
								"type": "BONKED",
								"character": "cat",
								"target": "dog"
							}
						],
						"twist_caption": "The CAT bonked the DOG.",
						"red_pen_words": [
							"CAT",
							"DOG"
						]
					},
					"bonus": [
						{
							"id": "headline_1",
							"caption": "THE MOUSE RUNS OFF",
							"facts": [
								{
									"type": "EXITED",
									"character": "mouse"
								}
							]
						}
					],
					"steps": [
						{
							"caption": "A shelf! Slide me to the right of it. See how its shadow keeps the cheese dark?",
							"gate": "unlit",
							"target": "cheese"
						},
						{
							"caption": "An angry Cat bonks whoever it can see. The Dog is behind the shelf: pull my cord UP to shine over it and light both.",
							"gate": "lit_set",
							"target": [
								"cat",
								"dog"
							]
						},
						{
							"caption": "No cheese in sight, so the Dog stays put. Press ACTION.",
							"gate": "action"
						},
						{
							"caption": "Bonus: scared characters run out of the comic. Light the Mouse too and see.",
							"gate": "result_closed"
						}
					],
					"hints": [
						"Keep the cheese in the shelf's shadow.",
						"Raise the bulb high, just right of the shelf, to light the Dog and the Cat."
					],
					"solution": [
						{
							"thoughts": {
								"Cat": "ANGRY",
								"Dog": "HUNGRY",
								"Mouse": "SCARED"
							},
							"lit": [
								"cat",
								"dog"
							],
							"flick_wakes": []
						}
					]
				},
				{
					"id": "p4_pedal",
					"title": "Step on it",
					"teaches": [
						"pedals switch on lamps",
						"lamp light wakes characters on the next beat"
					],
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
							3.0,
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
					"obstacles": [],
					"flick": 0,
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
								8,
								10
							],
							"switch_id": "pedal",
							"initially_on": false
						}
					],
					"characters": [
						{
							"id": "grandma",
							"name": "Grandma",
							"art": "grandma",
							"slot": 0,
							"facing": "R",
							"thought": "SLEEPY",
							"contradiction": false
						},
						{
							"id": "kid",
							"name": "Kid",
							"art": "kid",
							"slot": 2,
							"facing": "R",
							"thought": "HUNGRY",
							"contradiction": false
						},
						{
							"id": "dog",
							"name": "Dog",
							"art": "dog",
							"slot": 10,
							"facing": "L",
							"thought": "HUNGRY",
							"contradiction": false
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
					"original_caption": "The Kid ate the pie.",
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
					},
					"bonus": [],
					"steps": [
						{
							"caption": "See the pedal? The dashed wire runs to that lamp. It's OFF.",
							"gate": "click"
						},
						{
							"caption": "Anyone who walks over the pedal switches the lamp ON. The Dog is under it.",
							"gate": "click"
						},
						{
							"caption": "The Kid always beats the Dog to the pie. Make the Kid sleepy instead. Swap with Grandma.",
							"gate": "swap",
							"target": [
								"kid",
								"grandma"
							]
						},
						{
							"caption": "Stuck? Tap HINT. Each tap shows one more step.",
							"gate": "hint_opened"
						},
						{
							"caption": "Keep Grandma in the dark, then press ACTION.",
							"gate": "action"
						}
					],
					"hints": [
						"Give the Kid Grandma's sleepiness.",
						"The armchair is past the pedal. Leave Grandma dark."
					],
					"solution": [
						{
							"thoughts": {
								"Dog": "HUNGRY",
								"Grandma": "HUNGRY",
								"Kid": "SLEEPY"
							},
							"lit": [
								"kid"
							],
							"flick_wakes": []
						}
					]
				},
				{
					"id": "p5_two_bulbs",
					"title": "Double feature",
					"teaches": [
						"the second bulb: deploy and park"
					],
					"width": 10,
					"rail_span": [
						0,
						9
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
							9.0,
							0.6
						],
						"count": 2,
						"defaults": [
							{
								"x": 4.5,
								"y": -0.3,
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
					"lamps": [],
					"characters": [
						{
							"id": "cat",
							"name": "Cat",
							"art": "cat",
							"slot": 1,
							"facing": "R",
							"thought": "HUNGRY",
							"contradiction": false
						},
						{
							"id": "dog",
							"name": "Dog",
							"art": "dog",
							"slot": 6,
							"facing": "L",
							"thought": "HUNGRY",
							"contradiction": false
						}
					],
					"objects": [
						{
							"id": "fish",
							"type": "FOOD",
							"art": "fish",
							"slot": 3
						},
						{
							"id": "bone",
							"type": "FOOD",
							"art": "bone",
							"slot": 8
						}
					],
					"original_caption": "The Dog ate the fish.",
					"goal": {
						"facts": [
							{
								"type": "ATE",
								"character": "cat",
								"object": "fish"
							},
							{
								"type": "ATE",
								"character": "dog",
								"object": "bone"
							}
						],
						"twist_caption": "The Cat ate the fish. The Dog ate the BONE.",
						"red_pen_words": [
							"BONE"
						]
					},
					"bonus": [],
					"steps": [
						{
							"caption": "Some pages give you a second bulb. The hooks show how many bulbs you have. Drag one off its hook.",
							"gate": "lantern_deployed"
						},
						{
							"caption": "Drag it back to the hook to park it. Try it.",
							"gate": "lantern_parked"
						},
						{
							"caption": "Light the Cat with the fish and the Dog with the bone. Leave the gap dark, then press ACTION.",
							"gate": "action"
						}
					],
					"hints": [
						"One bulb on the Cat and the fish, one on the Dog and the bone.",
						"If the Dog sees the fish, he wants it more."
					],
					"solution": [
						{
							"thoughts": {
								"Cat": "HUNGRY",
								"Dog": "HUNGRY"
							},
							"lit": [
								"cat",
								"dog"
							],
							"flick_wakes": []
						}
					]
				},
				{
					"id": "p6_flick",
					"title": "Spare bulb",
					"teaches": [
						"the spare bulb (FLICK) during ACTION",
						"timing"
					],
					"width": 9,
					"rail_span": [
						0,
						8
					],
					"spotlights": {
						"count": 1,
						"default_centres": [
							3
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
								"x": 3.0,
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
					"flick": 1,
					"fixed_lights": [],
					"lamps": [],
					"characters": [
						{
							"id": "cat",
							"name": "Cat",
							"art": "cat",
							"slot": 2,
							"facing": "R",
							"thought": "HUNGRY",
							"contradiction": false
						},
						{
							"id": "dog",
							"name": "Dog",
							"art": "dog",
							"slot": 6,
							"facing": "L",
							"thought": "HUNGRY",
							"contradiction": false
						}
					],
					"objects": [
						{
							"id": "fish",
							"type": "FOOD",
							"art": "fish",
							"slot": 4
						}
					],
					"original_caption": "The Cat ate the fish.",
					"goal": {
						"facts": [
							{
								"type": "ATE",
								"character": "dog",
								"object": "fish"
							}
						],
						"twist_caption": "The DOG ate the fish.",
						"red_pen_words": [
							"DOG"
						]
					},
					"bonus": [],
					"steps": [
						{
							"caption": "The Dog is out of my reach. Light the fish, keep the Cat dark, press ACTION.",
							"gate": "action"
						},
						{
							"caption": "Quick! Click the rail over the Dog to drop the spare bulb. You get one per run.",
							"gate": "flick"
						}
					],
					"hints": [
						"Drop the spare bulb right at the start of the run.",
						"Light only the fish, then flick on the Dog on the first beat."
					],
					"solution": [
						{
							"thoughts": {
								"Cat": "HUNGRY",
								"Dog": "HUNGRY"
							},
							"lit": [],
							"flick_wakes": [
								"dog"
							]
						}
					],
					"pause_for_flick_at_beat": 1
				}
			],
			"final": {
				"steps": [
					{
						"caption": "Your turn. No arrows this time.",
						"when": "start"
					},
					{
						"caption": "Stuck? Tap HINT. Each hint shows a bit more.",
						"when": "first_fail"
					},
					{
						"caption": "Every different result goes in your Endings book.",
						"when": "first_new_ending"
					}
				]
			},
			"stars_from": "final",
			"skip": {
				"where": [
					"intro_card",
					"hud_tab",
					"pause_sheet"
				],
				"confirm": "tap_again_3s",
				"goes_to": "final",
				"unlocks_next_only_on_win": true,
				"sets_save": "tutorial_done"
			},
			"replay": [
				"settings_replay_tutorial",
				"level_card_badge"
			],
			"resume_panel_on_reopen": true
		},
		"hints": [
			"The Cat only goes for fish it can see.",
			"Light the Cat and the fish, and keep the Dog in the dark.",
			"Hang the bulb between the Cat and the fish. Its light should reach both of them but stop before the Dog."
		],
		"bonus_hints": [
			"Light the Dog and the cookie, not the fish."
		]
	}
