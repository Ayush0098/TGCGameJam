extends RefCounted
## Title screen, Sunday Edition page select and contextual help (Claude batch 1).

const MAIN = preload("res://scenes/main.tscn")


func run(check: Callable) -> bool:
	var game = MAIN.instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(game)
	check.call(game._front.visible and game._story_waiting, "Launch shows the title over the waiting first page")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	game._input(click)
	check.call(game.mode == "INTRO", "Clicks on the title never skip the hidden Original")
	game._on_front_start()
	check.call(not game._front.visible and not game._story_waiting, "START leaves the title and starts the story")
	check.call("MVP" not in game._status.text and "pending" not in game._status.text, "Player HUD shows no development status text")
	game._stop_voice()
	game._finish_run()
	game._process(0.7)
	check.call(game.mode == "PLAN" and not game._hooks[0].visible, "Lantern hooks hide on a page that is fully lit by fixed lights")
	check.call("Everyone is lit" in game._instructions.text, "Fully lit page explains the swap directly")
	var pages: Array = game._progress()
	check.call(pages[0].unlocked and not pages[1].unlocked and not pages[2].unlocked, "Only the first page is open at the start")
	game._start_action()
	game._finish_run()
	check.call(game._stamp.visible and game._stamp.text == "THE END...?" and game._missing.visible and "The Dog eats the cake" in game._missing.text, "A failed run stamps THE END...? and names what is still needed")
	check.call(game._rewind.get_theme_stylebox("normal") is StyleBoxFlat and (game._rewind.get_theme_stylebox("normal") as StyleBoxFlat).bg_color == Color("c0392b"), "REWIND is the primary button after a failure")
	game._return_to_plan()
	check.call(not game._stamp.visible and not game._missing.visible, "Returning to PLAN clears the result stamp")
	game._swap("boss", "dog")
	game._start_action()
	game._finish_run()
	check.call(game._stamp.visible and game._stamp.text == "TWIST!" and not game._missing.visible, "A win slams the TWIST! stamp")
	pages = game._progress()
	check.call(pages[0].solved and pages[1].unlocked and not pages[2].unlocked, "Solving a page inks it and unlocks the next")
	game._open_edition()
	check.call(game._front.visible and game._front._edition_panel.visible, "PAGES opens the Sunday Edition")
	game._on_front_page(1)
	game._finish_run()
	game._process(0.7)
	check.call(game.page.id == "page_04" and not game._front.visible and game._hooks[0].visible, "Choosing a page loads it with lantern hooks")
	game._move_lantern(0, Vector2(0.0, -0.6), false)
	check.call(game._lit_ids().is_empty() and "Nobody is lit" in game._instructions.text and "nobody lit" in game._action.text, "Unlit plans warn before ACTION")
	game.free()
	return true
