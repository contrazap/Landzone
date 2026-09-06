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
		failures.append("Could not create F04 capture directory: %s." % directory_error)

	var app := MAIN_SCENE.instantiate() as LandzoneMain
	app.persistence_enabled = false
	root.add_child(app)
	await process_frame
	var mothership := app.active_location as Mothership
	if mothership == null or not app.request_location_change(&"basin", mothership):
		failures.append("F04 capture driver could not deploy to the Basin.")
	else:
		await app.transition_completed

	var expedition := app.active_location as BasinExpedition
	if expedition == null:
		failures.append("F04 capture driver did not activate BasinExpedition.")
	else:
		expedition.player.death_enabled = false
		expedition.stalker.set_physics_process(false)
		expedition.lethal_hazard.set_deferred(&"monitoring", false)
		await physics_frame
		await _capture_at(expedition, Vector2(820.0, 450.0), Vector2(1.0, -1.0), "f04_landing_fork.png", failures)
		await _capture_at(expedition, Vector2(1640.0, 450.0), Vector2.RIGHT, "f04_reunion_fork.png", failures)
		await _capture_at(expedition, Vector2(1980.0, 450.0), Vector2(1.0, -1.0), "f04_far_fork.png", failures)
		await _capture_at(expedition, Vector2(2300.0, 170.0), Vector2.LEFT, "f04_north_shelf_limit.png", failures)
		await _capture_at(expedition, Vector2(2300.0, 730.0), Vector2.LEFT, "f04_south_hollow_limit.png", failures)

		expedition.player.global_position = Vector2(1200.0, 210.0)
		expedition.player.update_aim_direction(expedition.player.global_position + Vector2(100.0, -100.0))
		(expedition.player.get_node("Camera2D") as Camera2D).reset_smoothing()
		await process_frame
		if not expedition.command_console.open_console():
			failures.append("F04 capture driver could not open the command console.")
		else:
			expedition.command_console.submit_command("where")
			await _save_capture("f04_where_console.png", failures)
			expedition.command_console.close_console()

	paused = false
	app.queue_free()
	await process_frame
	if failures.is_empty():
		print("F04 captures passed: six 960x540 route and command-console views saved.")
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	print("F04 captures failed: %d" % failures.size())
	quit(1)


func _capture_at(
	expedition: BasinExpedition,
	position: Vector2,
	facing: Vector2,
	file_name: String,
	failures: Array[String]
) -> void:
	expedition.player.global_position = position
	expedition.player.velocity = Vector2.ZERO
	expedition.player.update_aim_direction(position + facing.normalized() * 100.0)
	(expedition.player.get_node("Camera2D") as Camera2D).reset_smoothing()
	for _frame: int in 4:
		await process_frame
	await _save_capture(file_name, failures)


func _save_capture(file_name: String, failures: Array[String]) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		failures.append("Rendered F04 capture %s was empty." % file_name)
		return
	if image.get_width() != 960 or image.get_height() != 540:
		failures.append(
			"Rendered F04 capture %s was %dx%d instead of 960x540."
			% [file_name, image.get_width(), image.get_height()]
		)
	var save_error := image.save_png("%s/%s" % [ARTIFACT_DIRECTORY, file_name])
	if save_error != OK:
		failures.append("Could not save rendered F04 capture %s: %s." % [file_name, save_error])
