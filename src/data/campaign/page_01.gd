extends RefCounted
## Page 1 "Biryani Sunday", IIIT-H story rev 4 (design/story_proposal.md, design/build_p1_3/spec.md).
## Star ladder verified by the solver (design/levels_solver/ladder), 0.2 and 0.02 lantern grids.


static func definition() -> Dictionary:
	return {
		"id": "page_01",
		"number": 1,
		"title": "Biryani Sunday",
		"difficulty": "green",
		"room": "kadamba",
		"voice": "page_01",
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
				"name": "Dassi",
				"art": "dassi",
				"slot": 3,
				"facing": "R",
				"thought": "SCARED",
				"contradiction": false
			},
			{
				"id": "dog",
				"name": "Chintu",
				"art": "dog",
				"slot": 6,
				"facing": "L",
				"thought": "HUNGRY",
				"contradiction": false
			}
		],
		"objects": [
			{
				"id": "biryani",
				"type": "FOOD",
				"art": "biryani",
				"slot": 4
			},
			{
				"id": "bonda",
				"type": "FOOD",
				"art": "bonda",
				"slot": 8
			}
		],
		"original_caption": "Chintu ate the biryani.",
		"endings_total": 6,
		"goal": {
			"facts": [
				{
					"type": "ATE",
					"character": "cat",
					"object": "biryani"
				}
			],
			"twist_caption": "DASSI ate the biryani.",
			"red_pen_words": [
				"DASSI"
			]
		},
		"ladder": [
			{
				"id": "star_2",
				"caption": "…and Chintu ran out of the comic.",
				"facts": [
					{
						"type": "EXITED",
						"character": "dog"
					}
				]
			}
		],
		"narration": {
			"intro": "Sunday. Biryani Day at Kadamba, the one day there's no Pappu in it. Every Sunday for eleven years, Chintu the campus dog has eaten the biryani. Chintu does not refuse literally anything. Dassi does not eat biryani. Dassi has seen what is IN the biryani.",
			"original": "Chintu ate the biryani. Frog and all. A classic.",
			"twist": "DASSI ate the biryani.",
			"win": "Dassi ate the biryani. Ten CGPA, never touches mess food. Who moved my lamp? Somebody MOVED my LAMP.",
			"stars": [
				"And Chintu ran out of the comic. The dog who eats everything has refused something. Write it down. History."
			],
			"fails": [
				"Chintu ate the biryani. As per policy.",
				"Ah, the classics. Like the mess menu.",
				"Wrong Answer on test 1. Lovely."
			],
			"hidden": []
		},
		"dialogue": [
			{
				"character": "cat",
				"when": "lit",
				"line": "I have a ten CGPA. I KNOW what's in that biryani."
			},
			{
				"character": "cat",
				"when": "gets_HUNGRY",
				"line": "Actually… a ten CGPA needs protein."
			},
			{
				"character": "cat",
				"when": "win",
				"line": "Write it down, Narrator. Dassi. Ate. The. Biryani."
			},
			{
				"character": "dog",
				"when": "lit",
				"line": "Biryani? Biryani! BIRYANI!!"
			},
			{
				"character": "dog",
				"when": "gets_SCARED",
				"line": "Something in there just did a 👌 at me."
			},
			{
				"character": "dog",
				"when": "fail",
				"line": "Biryani."
			}
		],
		"stickers": [],
		"hints": [
			"Dassi has to WANT the biryani. Who in this room is the hungry one?",
			"Light Dassi and Chintu together, then drag Chintu's hunger onto Dassi to swap their thoughts.",
			"After the swap, keep the light on Dassi and the biryani, and press ACTION."
		],
		"star_hints": [
			"Keep Chintu in the light too. After the swap he's scared, and scared characters run."
		],
		"tutorial": {
			"intro": [
				"Welcome to the Official Campus Comic (Approved). Every page has already been printed. That's the ORIGINAL story.",
				"You're Bulby, the only working bulb in OBH. Characters only act when they're in your light, and each one does what its thought bubble says.",
				"Your goal: change who's lit and what they think, so the page ends with the TWIST written in red pen. The grey pencil lines are fine-tunes for extra stars.",
				"One star for the twist, more for the fine-tunes, and collect every ending. Let's start with Biryani Sunday…"
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
							"name": "Dassi",
							"art": "dassi",
							"slot": 1,
							"facing": "R",
							"thought": "HUNGRY",
							"contradiction": false
						},
						{
							"id": "dog",
							"name": "Chintu",
							"art": "dog",
							"slot": 6,
							"facing": "L",
							"thought": "HUNGRY",
							"contradiction": false
						}
					],
					"objects": [
						{
							"id": "biryani",
							"type": "FOOD",
							"art": "biryani",
							"slot": 4
						}
					],
					"original_caption": "Chintu ate the biryani.",
					"goal": {
						"facts": [
							{
								"type": "ATE",
								"character": "cat",
								"object": "biryani"
							}
						],
						"twist_caption": "DASSI ate the biryani.",
						"red_pen_words": [
							"DASSI"
						]
					},
					"bonus": [],
					"steps": [
						{
							"caption": "I'm Bulby, the light. Only characters in my light act, see and get named. Slide me onto Dassi.",
							"gate": "lit",
							"target": "cat"
						},
						{
							"caption": "A lit character shows their name and what they're thinking. Now slide me off Dassi.",
							"gate": "unlit",
							"target": "cat"
						},
						{
							"caption": "In the dark their thoughts hide and they do nothing at all. That's the power of the light.",
							"gate": "click"
						},
						{
							"caption": "This is today's comic, the Original. Watch what was printed.",
							"gate": "clipping_opened"
						},
						{
							"caption": "Our twist: DASSI eats the biryani. A lower light is wider. Lower me until Dassi AND the biryani are lit.",
							"gate": "lit_set",
							"target": [
								"cat",
								"biryani"
							]
						},
						{
							"caption": "Things get name tags when they're lit too: that's the biryani.",
							"gate": "click"
						},
						{
							"caption": "Keep Chintu in the dark. A dark Chintu can't smell a thing.",
							"gate": "unlit",
							"target": "dog"
						},
						{
							"caption": "Light set. ACTION plays the scene so you can watch it play out.",
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
						"Hang the bulb between Dassi and the biryani, at their level, so the light stops before Chintu."
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
					],
					"room": "kadamba"
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
							"name": "Dassi",
							"art": "dassi",
							"slot": 2,
							"facing": "L",
							"thought": "SLEEPY",
							"contradiction": false
						},
						{
							"id": "dog",
							"name": "Chintu",
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
							"slot": 1,
							"name": "bean bag"
						},
						{
							"id": "biryani",
							"type": "FOOD",
							"art": "biryani",
							"slot": 4
						}
					],
					"original_caption": "Chintu ate the biryani. Dassi napped.",
					"goal": {
						"facts": [
							{
								"type": "ATE",
								"character": "cat",
								"object": "biryani"
							}
						],
						"twist_caption": "DASSI ate the biryani.",
						"red_pen_words": [
							"DASSI"
						]
					},
					"bonus": [
						{
							"id": "headline_1",
							"caption": "THE CHINTU NAPS ON THE CUSHION",
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
							"caption": "Every character is thinking something. The row at the bottom says what each thought makes them do.",
							"gate": "legend_opened"
						},
						{
							"caption": "Dassi is sleepy, Chintu is hungry. Characters in the light can be chosen. Choose one.",
							"gate": "choose"
						},
						{
							"caption": "Now pick up the chosen character's thought. Esc puts it back.",
							"gate": "picked"
						},
						{
							"caption": "Move to the other lit character and drop the thought on them: the two swap.",
							"gate": "swap",
							"target": [
								"cat",
								"dog"
							]
						},
						{
							"caption": "Thoughts swapped. Both had to be lit for that. Time for ACTION.",
							"gate": "action"
						},
						{
							"caption": "See the extra headline? Bonus headlines earn extra stars on every page.",
							"gate": "click"
						},
						{
							"caption": "NEW ENDING! Every different result goes in your Endings book. Peek inside.",
							"gate": "endings_opened"
						},
						{
							"caption": "Close the book and carry on.",
							"gate": "result_closed"
						}
					],
					"hints": [
						"Swap Dassi's and Chintu's thoughts."
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
					],
					"room": "kadamba"
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
							"name": "Chintu",
							"art": "dog",
							"slot": 2,
							"facing": "L",
							"thought": "HUNGRY",
							"contradiction": false
						},
						{
							"id": "cat",
							"name": "Dassi",
							"art": "dassi",
							"slot": 4,
							"facing": "L",
							"thought": "ANGRY",
							"contradiction": false
						},
						{
							"id": "mouse",
							"name": "Faccha",
							"art": "faccha",
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
					"original_caption": "Chintu ate the cheese.",
					"goal": {
						"facts": [
							{
								"type": "BONKED",
								"character": "cat",
								"target": "dog"
							}
						],
						"twist_caption": "DASSI bonked CHINTU.",
						"red_pen_words": [
							"DASSI",
							"CHINTU"
						]
					},
					"bonus": [
						{
							"id": "headline_1",
							"caption": "THE FACCHA RUNS OFF",
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
							"caption": "A projector screen casts a shadow. Slide me right of it and the cheese goes dark.",
							"gate": "unlit",
							"target": "cheese"
						},
						{
							"caption": "An angry Dassi bonks whoever she can see. Chintu hides behind the screen: raise me to shine over it and light both.",
							"gate": "lit_set",
							"target": [
								"cat",
								"dog"
							]
						},
						{
							"caption": "No cheese in sight, so Chintu stays put. ACTION!",
							"gate": "action"
						},
						{
							"caption": "Bonus: scared characters run out of the comic. Light the Faccha too and see.",
							"gate": "result_closed"
						}
					],
					"hints": [
						"Keep the cheese in the projector screen's shadow.",
						"Raise the bulb high, just right of the projector screen, to light Chintu and Dassi."
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
					],
					"room": "kadamba"
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
							"name": "Mess Aunty",
							"art": "aunty",
							"slot": 0,
							"facing": "R",
							"thought": "SLEEPY",
							"contradiction": false
						},
						{
							"id": "kid",
							"name": "Saap",
							"art": "saap",
							"slot": 2,
							"facing": "R",
							"thought": "HUNGRY",
							"contradiction": false
						},
						{
							"id": "dog",
							"name": "Chintu",
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
							"slot": 6,
							"name": "Maggi"
						}
					],
					"original_caption": "The Saap ate the Maggi.",
					"goal": {
						"facts": [
							{
								"type": "ATE",
								"character": "dog",
								"object": "pie"
							}
						],
						"twist_caption": "CHINTU ate the Maggi.",
						"red_pen_words": [
							"CHINTU"
						]
					},
					"bonus": [],
					"steps": [
						{
							"caption": "See the pedal? The dashed wire runs to that lamp. It's OFF.",
							"gate": "click"
						},
						{
							"caption": "Anyone who walks over the pedal switches the lamp ON. Chintu is under it.",
							"gate": "click"
						},
						{
							"caption": "The Saap always beats Chintu to the Maggi. Make the Saap sleepy: swap with Mess Aunty.",
							"gate": "swap",
							"target": [
								"kid",
								"grandma"
							]
						},
						{
							"caption": "Stuck? A hint shows one more step each time you ask.",
							"gate": "hint_opened"
						},
						{
							"caption": "Keep Mess Aunty in the dark, then ACTION.",
							"gate": "action"
						}
					],
					"hints": [
						"Give the Saap Mess Aunty's sleepiness.",
						"The armchair is past the pedal. Leave Mess Aunty dark."
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
					],
					"room": "kadamba"
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
							"name": "Dassi",
							"art": "dassi",
							"slot": 1,
							"facing": "R",
							"thought": "HUNGRY",
							"contradiction": false
						},
						{
							"id": "dog",
							"name": "Chintu",
							"art": "dog",
							"slot": 6,
							"facing": "L",
							"thought": "HUNGRY",
							"contradiction": false
						}
					],
					"objects": [
						{
							"id": "biryani",
							"type": "FOOD",
							"art": "biryani",
							"slot": 3
						},
						{
							"id": "bonda",
							"type": "FOOD",
							"art": "bonda",
							"slot": 8
						}
					],
					"original_caption": "Chintu ate the biryani.",
					"goal": {
						"facts": [
							{
								"type": "ATE",
								"character": "cat",
								"object": "biryani"
							},
							{
								"type": "ATE",
								"character": "dog",
								"object": "bonda"
							}
						],
						"twist_caption": "Dassi ate the biryani. Chintu ate the BONDA.",
						"red_pen_words": [
							"BONDA"
						]
					},
					"bonus": [],
					"steps": [
						{
							"caption": "Some pages give you a second bulb. Take the 2nd one off its hook.",
							"gate": "lantern_deployed"
						},
						{
							"caption": "A bulb you don't need goes back on its hook. Park it.",
							"gate": "lantern_parked"
						},
						{
							"caption": "Light Dassi with the biryani and Chintu with the bonda. Leave the gap dark, then ACTION.",
							"gate": "action"
						}
					],
					"hints": [
						"One bulb on Dassi and the biryani, one on Chintu and the bonda.",
						"If Chintu sees the biryani, he wants it more."
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
					],
					"room": "kadamba"
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
							"name": "Dassi",
							"art": "dassi",
							"slot": 2,
							"facing": "R",
							"thought": "HUNGRY",
							"contradiction": false
						},
						{
							"id": "dog",
							"name": "Chintu",
							"art": "dog",
							"slot": 6,
							"facing": "L",
							"thought": "HUNGRY",
							"contradiction": false
						}
					],
					"objects": [
						{
							"id": "biryani",
							"type": "FOOD",
							"art": "biryani",
							"slot": 4
						}
					],
					"original_caption": "Dassi ate the biryani.",
					"goal": {
						"facts": [
							{
								"type": "ATE",
								"character": "dog",
								"object": "biryani"
							}
						],
						"twist_caption": "CHINTU ate the biryani.",
						"red_pen_words": [
							"CHINTU"
						]
					},
					"bonus": [],
					"steps": [
						{
							"caption": "Chintu is out of my reach. Light the biryani, keep Dassi dark, then ACTION.",
							"gate": "action"
						},
						{
							"caption": "Quick! Aim with A / D and press F (or click the rail over Chintu) to drop the spare bulb. You get one per run.",
							"gate": "flick"
						}
					],
					"hints": [
						"Drop the spare bulb right at the start of the run.",
						"Light only the biryani, then flick on Chintu on the first beat."
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
					"pause_for_flick_at_beat": 1,
					"room": "kadamba"
				}
			],
			"final": {
				"steps": [
					{
						"caption": "Your turn. No arrows this time.",
						"when": "start"
					},
					{
						"caption": "Stuck? Press H for a HINT. Each hint shows a bit more.",
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
		}
	}
