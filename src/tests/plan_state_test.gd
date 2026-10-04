extends RefCounted

const PLAN = preload("res://core/plan_state.gd")
const PAGE = preload("res://data/pages/page_06.gd")


func run(check: Callable) -> bool:
	var page := PAGE.definition()
	var plan = PLAN.from_page(page)
	var saved: Dictionary = plan.to_data()
	check.call(plan.place(page, 0, 3), "Spotlight can move inside the rail")
	check.call(not plan.place(page, 0, 11) and plan.centres == [3], "Out-of-rail move rejected without mutation")
	check.call(not plan.place(page, 1, 4), "Cannot exceed spotlight budget")
	check.call(plan.swap("grandma", "boss", ["grandma", "boss"]), "Swap between two lit actors succeeds")
	check.call(plan.thoughts.boss == "SCARED" and plan.thoughts.grandma == "HUNGRY", "Swap conserves both thoughts")
	check.call(not plan.swap("intern", "dog", ["intern"]) and plan.thoughts.dog == "HUNGRY", "Unlit drop rejected")
	check.call(not plan.swap("boss", "boss", ["boss"]), "Self-drop rejected")
	check.call(saved.centres == [5] and saved.thoughts.boss == "HUNGRY", "Saved plan remains independent of edits")
	plan.restore(saved)
	saved.centres[0] = 0
	saved.thoughts.boss = "SLEEPY"
	check.call(plan.centres == [5] and plan.thoughts.boss == "HUNGRY", "Restored plan does not alias saved data")
	check.call(page.spotlights.default_centres == [5] and page.characters[2].thought == "HUNGRY", "Editing leaves page defaults intact")
	check.call(plan.place(page, 0, -1) and plan.centres.is_empty(), "Bulb can return to tray")
	check.call(not plan.place(page, 0, -1), "Removing absent bulb rejected")
	check.call(plan.place(page, 0, 10) and plan.centres == [10], "Spare bulb can be placed at rail edge")
	return true
