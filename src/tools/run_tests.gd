extends SceneTree
## Run from the repository root with --headless --path src --script res://tools/run_tests.gd.
## Each suite implements run(check: Callable) -> bool and returns true on completion.

const SUITES = [
	preload("res://tests/project_smoke_test.gd"),
	preload("res://tests/page_validator_test.gd"),
	preload("res://tests/plan_state_test.gd"),
	preload("res://tests/lighting_test.gd"),
	preload("res://tests/simulator_test.gd"),
	preload("res://tests/goal_evaluator_test.gd"),
	preload("res://tests/main_flow_test.gd"),
	preload("res://tests/production_reference_test.gd"),
	preload("res://tests/stage_presentation_test.gd"),
]

var _checks := 0
var _failures := 0


func _initialize() -> void:
	# Defer until the SceneTree is initialized, so suites may instantiate scenes.
	_run.call_deferred()


func _run() -> void:
	for suite_script in SUITES:
		var suite = suite_script.new()
		var checks_before := _checks
		if not suite.has_method("run"):
			_check(false, "%s has no run method" % suite_script.resource_path)
			continue
		var completed = suite.run(_check)
		if completed != true:
			_check(false, "%s did not complete successfully" % suite_script.resource_path)
		if _checks == checks_before:
			_check(false, "%s did not execute any checks" % suite_script.resource_path)

	# Exercises the actual failure/reporting path without keeping a failing suite.
	if "--self-check-failure" in OS.get_cmdline_user_args():
		_check(false, "Intentional runner failure-path check")

	if _checks == 0:
		_check(false, "No checks executed")
	print("TEST RESULT: %d checks, %d failures" % [_checks, _failures])
	quit(0 if _failures == 0 else 1)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if condition:
		print("PASS: %s" % description)
	else:
		_failures += 1
		printerr("FAIL: %s" % description)
