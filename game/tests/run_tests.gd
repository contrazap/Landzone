extends SceneTree

const EXPECTED_PROJECT_NAME := "Landzone"
const EXPECTED_MAIN_SCENE := "res://main.tscn"
const EXPECTED_RENDERER := "gl_compatibility"
const EXPECTED_INPUTS := {
	&"move_up": [KEY_W, KEY_UP],
	&"move_down": [KEY_S, KEY_DOWN],
	&"move_left": [KEY_A, KEY_LEFT],
	&"move_right": [KEY_D, KEY_RIGHT],
}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures: Array[String] = []

	_check_setting(&"application/config/name", EXPECTED_PROJECT_NAME, failures)
	_check_setting(&"application/run/main_scene", EXPECTED_MAIN_SCENE, failures)
	_check_setting(&"rendering/renderer/rendering_method", EXPECTED_RENDERER, failures)
	_check_setting(&"rendering/renderer/rendering_method.mobile", EXPECTED_RENDERER, failures)
	_check_compatibility_feature(failures)

	for action_name: StringName in EXPECTED_INPUTS:
		var expected_keys: Array = EXPECTED_INPUTS[action_name]
		_check_action(action_name, expected_keys[0], expected_keys[1], failures)
	_check_physical_key_action(&"interact", KEY_E, failures)

	_check_main_scene(failures)

	if failures.is_empty():
		print("F00 checks passed: project, renderer, movement inputs, and main scene.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	print("F00 checks failed: %d" % failures.size())
	quit(1)


func _check_setting(
		setting_name: StringName,
		expected_value: Variant,
		failures: Array[String]
) -> void:
	var actual_value: Variant = ProjectSettings.get_setting(setting_name)
	if actual_value != expected_value:
		failures.append(
			"Expected %s to be %s, got %s."
			% [setting_name, expected_value, actual_value]
		)


func _check_compatibility_feature(failures: Array[String]) -> void:
	var features: PackedStringArray = ProjectSettings.get_setting(
		&"application/config/features",
		PackedStringArray()
	)
	if not features.has("GL Compatibility"):
		failures.append("Project features do not include GL Compatibility.")


func _check_action(
		action_name: StringName,
		physical_key: int,
		arrow_key: int,
		failures: Array[String]
) -> void:
	if not InputMap.has_action(action_name):
		failures.append("Missing input action: %s." % action_name)
		return

	if not _has_key_binding(action_name, physical_key, true):
		failures.append("%s is missing its physical letter-key binding." % action_name)
	if not _has_key_binding(action_name, arrow_key, false):
		failures.append("%s is missing its arrow-key binding." % action_name)


func _has_key_binding(action_name: StringName, expected_key: int, physical: bool) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		if event is not InputEventKey:
			continue
		var key_event := event as InputEventKey
		var actual_key: int = key_event.physical_keycode if physical else key_event.keycode
		if actual_key == expected_key:
			return true
	return false


func _check_physical_key_action(
	action_name: StringName,
	physical_key: int,
	failures: Array[String]
) -> void:
	if not InputMap.has_action(action_name):
		failures.append("Missing input action: %s." % action_name)
		return
	if not _has_key_binding(action_name, physical_key, true):
		failures.append("%s is missing its physical key binding." % action_name)


func _check_main_scene(failures: Array[String]) -> void:
	var main_scene := load(EXPECTED_MAIN_SCENE) as PackedScene
	if main_scene == null:
		failures.append("Main scene could not be loaded as a PackedScene.")
		return

	var main_instance := main_scene.instantiate()
	if main_instance == null:
		failures.append("Main scene could not be instantiated.")
		return
	main_instance.free()
