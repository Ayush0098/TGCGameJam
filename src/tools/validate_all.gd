extends SceneTree
## Validates every campaign page and prints its errors.
const VALIDATOR = preload("res://core/page_validator.gd")


func _init() -> void:
	for n in range(1, 16):
		var script = load("res://data/campaign/page_%02d.gd" % n)
		var result: Dictionary = VALIDATOR.new().validate(script.definition())
		print("page %02d: %s" % [n, "ok" if result.errors.is_empty() else str(result.errors)])
	quit()
