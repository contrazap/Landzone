extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const ARTIFACT_DIRECTORY := "res://tests/artifacts"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures: Array[String] = []
	var artifact_path := ProjectSettings.globalize_path(ARTIFACT_DIRECTORY)
	var directory_error := DirAccess.make_dir_recursive_absolute(artifact_path)
	if directory_error != OK:
		failures.append("Could not create capture artifact directory: %s." % directory_error)

	var app := MAIN_SCENE.instantiate() as LandzoneMain
	root.add_child(app)
	await process_frame
	await physics_frame
	await _save_capture("f03_mothership.png", failures)

	var mothership := app.active_location as Mothership
	mothership.player.global_position = mothership.deploy_area.global_position
	await process_frame
	await physics_frame
	await _save_capture("f03_bridge_prompt.png", failures)

	if not mothership.request_deployment():
		failures.append("Capture driver could not request bridge deployment.")
	await process_frame
	await _save_capture("f03_static_transfer.png", failures)
	if app.transition_in_progress:
		await app.transition_completed
	await process_frame
	await physics_frame
	await _save_capture("f03_shuttle_return.png", failures)

	var expedition := app.active_location as BasinExpedition
	Input.action_press(&"move_down")
	for _frame: int in 24:
		await physics_frame
	Input.action_release(&"move_down")
	Input.action_press(&"move_right")
	for _frame: int in 150:
		await physics_frame
	Input.action_release(&"move_right")
	for _frame: int in 45:
		await process_frame
	await _save_capture("f03_basin_camera_follow.png", failures)
	expedition.stalker.set_physics_process(false)
	expedition.stalker.global_position = Vector2(1480.0, 472.0)
	expedition.stalker.receive_pulse_hit()
	expedition.player.global_position = expedition.shuttle_spawn.global_position
	await process_frame
	await physics_frame
	if not expedition.request_mothership_return():
		failures.append("Capture driver could not request shuttle return.")
	if app.transition_in_progress:
		await app.transition_completed

	mothership = app.active_location as Mothership
	mothership.player.global_position = mothership.deploy_area.global_position
	await process_frame
	await physics_frame
	if not mothership.request_deployment():
		failures.append("Capture driver could not request redeployment.")
	if app.transition_in_progress:
		await app.transition_completed
	await process_frame
	await physics_frame
	await _save_capture("f03_basin_redeployed.png", failures)

	app.queue_free()
	await process_frame
	if failures.is_empty():
		print("F03 captures passed: six 960x540 rendered location/transition views saved.")
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	print("F03 captures failed: %d" % failures.size())
	quit(1)


func _save_capture(file_name: String, failures: Array[String]) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		failures.append("Rendered capture %s was empty." % file_name)
		return
	if image.get_width() != 960 or image.get_height() != 540:
		failures.append(
			"Rendered capture %s was %dx%d instead of 960x540."
			% [file_name, image.get_width(), image.get_height()]
		)
	var save_error := image.save_png("%s/%s" % [ARTIFACT_DIRECTORY, file_name])
	if save_error != OK:
		failures.append("Could not save rendered capture %s: %s." % [file_name, save_error])
