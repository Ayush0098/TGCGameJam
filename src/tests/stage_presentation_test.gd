extends RefCounted

const STAGE = preload("res://presentation/stage_view.gd")
const PAGE = preload("res://data/pages/page_02.gd")
const BIRTHDAY = preload("res://data/pages/page_06.gd")
const PLAN = preload("res://core/plan_state.gd")
const RULES = preload("res://core/rules.gd")
const LIGHTING = preload("res://core/lighting.gd")
const SIM = preload("res://core/simulator.gd")

func run(check: Callable) -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	var stage = STAGE.new()
	var other = STAGE.new()
	tree.root.add_child(stage)
	tree.root.add_child(other)
	stage.size = Vector2(900, 460)
	var page := PAGE.definition()
	stage.configure(page)
	var plan: Dictionary = PLAN.from_page(page).to_data()
	var world := RULES.initial_world(page, plan)
	stage.pose(world, plan, {}, true)
	check.call(stage._rigs.size() == 2 and stage._room.visible, "Nap Time renders both cutout rigs in the playable stage")
	check.call(is_equal_approx(stage._spacing(), 137.5), "Nine-slot fixture retains its original spacing")
	for point in [Vector2(0, -1.2), Vector2(4.5, 0), Vector2(8, 0.6)]:
		check.call(stage.stage_to_world(stage.to_stage(stage.stage_to_local(stage.world_to_stage(point)))).distance_to(point) < 0.00001, "Uniform letterboxing preserves world/input coordinates")
	var image: Image = stage._mask_image
	check.call(image.get_width() == 128 and image.get_height() == 46 and image.get_pixel(64, 0).r == 1, "Mask covers the whole room and retains Nap Time's full-height fixed light")
	var mask = stage._shade
	stage.pose(world, plan, {}, false, [], {"boss": 7.5})
	check.call(stage._shade == mask and stage._world.characters[0].slot == 2, "Visual movement mutates neither authoritative actor position nor mask cache")
	page.fixed_lights = []
	stage.configure(page)
	world = RULES.initial_world(page, plan)
	stage.pose(world, plan, {}, true)
	check.call(stage.revealed_thought_ids().is_empty() and stage._rigs.values().all(func(rig): return rig.expression_name == "neutral"), "Dark PLAN hides every thought and restores neutral expressions")
	plan.lanterns[0] = {"x": 2.0, "y": 0.0, "enabled": true}
	world = RULES.initial_world(page, plan)
	stage.pose(world, plan, {}, true)
	check.call(stage._rigs.boss._lighting_material.get_shader_parameter("lit") == 1.0 and stage._rigs.dog._lighting_material.get_shader_parameter("lit") == 0.0, "Each rig has an independent binary light material")
	for part in stage._rigs.boss._parts.values():
		check.call(part.get_child(0).material == stage._rigs.boss._face.material, "Every rig part and replacement face shares the same light state")
	plan.lanterns[0].x = 4.1
	stage.pose(world, plan, {}, true, [], {"boss": 4.1})
	check.call("boss" not in stage.revealed_thought_ids(), "A visual actor inside light cannot reveal an authoritative actor outside its radius")
	var halo := LIGHTING.intensity(page, plan, world, Vector2(2.3, 0))
	check.call(halo > 0 and not LIGHTING.is_lit(page, plan, world, 2.3), "Decorative halo never supplies binary activation")
	# Darkness still hides: a dark actor looks and sounds identical for every thought.
	var dark_page := PAGE.definition()
	dark_page.fixed_lights = []
	stage.configure(dark_page)
	var dark_plan: Dictionary = PLAN.from_page(dark_page).to_data()
	var signatures := {}
	for thought in ["HUNGRY", "SLEEPY", "ANGRY", "SCARED"]:
		var dark_world := RULES.initial_world(dark_page, dark_plan)
		dark_world.characters[0].thought = thought
		stage.pose(dark_world, dark_plan, {}, true)
		signatures[str([stage._rigs.boss.expression_name, stage.poke("boss"), stage.revealed_thought_ids()])] = true
	check.call(signatures.size() == 1 and signatures.keys()[0].contains("HMPH"), "Dark actors show the same face and poke sound for every thought")
	var revealed: Array = []
	stage.actor_revealed.connect(func(id, thought): revealed.append([id, thought]))
	dark_plan.lanterns[0] = {"x": 2.0, "y": 0.0, "enabled": true}
	stage.pose(RULES.initial_world(dark_page, dark_plan), dark_plan, {}, true)
	check.call(revealed == [["boss", "HUNGRY"]] and stage.poke("boss") == "POKE_HUNGRY", "Lighting an actor reveals it once with its own stinger; lit pokes use the thought")
	stage.set_mood("flinch", 0.2)
	stage._process(0.25)
	check.call(stage._bulb_mood == "idle", "Timed Bulby moods return to the persistent mood")
	page = PAGE.definition()
	stage.configure(page)
	plan = PLAN.from_page(page).to_data()
	world = RULES.initial_world(page, plan)
	world.characters[0].slot = 5
	world.characters[1].slot = 5
	stage.pose(world, plan, {}, true)
	var bubbles: Dictionary = stage._bubble_layout(world, stage._positions(world))
	check.call(bubbles.size() == 2 and not bubbles.boss.intersects(bubbles.dog), "Co-located actors retain nonoverlapping compact bubbles")
	check.call(bubbles.values().all(func(rect): return rect.size == Vector2(96, 64)), "Thought icons and labels fit compact bubbles")
	plan.thoughts.boss = "SLEEPY"
	plan.thoughts.dog = "HUNGRY"
	var run := SIM.run(page, plan, true)
	stage.cancel_presentation()
	stage.pose(run.snapshots.back(), plan, {}, false)
	check.call(stage.revealed_thought_ids().is_empty() and stage._rigs.boss.expression_name == "sleepy", "Finished actors use outcome expressions without stale thoughts")
	check.call(stage._rigs.boss._visual.position.y > -stage._rigs.boss.anchor.y and not stage._rigs.boss.animation_player.is_playing(), "SKIP holds the seated sleeping pose rather than a standing character")
	other.configure(page)
	other.pose(run.snapshots.back(), plan, {}, false)
	check.call(stage._room.material != other._room.material and stage._shade != other._shade, "Comparison stages own independent mask and material resources")
	stage.present_events([{"type": "BONK", "actor": "dog", "target": "boss"}])
	stage._drag_bubble = "boss"
	stage.cancel_presentation()
	check.call(stage._effects.is_empty() and stage._drag_bubble.is_empty() and stage._rigs.values().all(func(rig): return not rig.animation_player.is_playing()), "Cancellation clears effects, gesture and animations")
	page = BIRTHDAY.definition()
	stage.configure(page)
	plan = PLAN.from_page(page).to_data()
	world = RULES.initial_world(page, plan)
	stage.pose(world, plan, {}, false)
	var cached = stage._shade
	world.lamps[0].on = true
	stage.pose(world, plan, {}, false)
	check.call(stage._shade != cached and stage._blend == 0, "Recorded lamp activation invalidates the mask and starts its room transition")
	stage._process(0.15)
	check.call(is_equal_approx(stage._blend, 0.5), "Room glow reaches halfway after 0.15 seconds")
	stage.set_reduced_motion(true)
	check.call(stage._blend == 1 and stage._effects.is_empty(), "Reduced motion immediately resolves lighting and cancels effects")
	stage.free()
	other.free()
	return true
