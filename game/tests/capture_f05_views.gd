extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const ARTIFACT_DIRECTORY := "res://tests/artifacts"
const FIXED_TIME := 1788710400


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures: Array[String] = []
	var artifact_path := ProjectSettings.globalize_path(ARTIFACT_DIRECTORY)
	var directory_error := DirAccess.make_dir_recursive_absolute(artifact_path)
	if directory_error != OK:
		failures.append("Could not create F05 capture directory: %s." % directory_error)

	var app := MAIN_SCENE.instantiate() as LandzoneMain
	app.persistence_enabled = false
	app.transition_delay_seconds = 0.1
	root.add_child(app)
	await process_frame
	var mothership := app.active_location as Mothership
	if mothership == null or not app.request_location_change(&"basin", mothership):
		failures.append("F05 capture driver could not deploy to the Basin.")
	else:
		await app.transition_completed
		var expedition := app.active_location as BasinExpedition
		expedition.player.global_position = (
			expedition.shuttle_spawn.global_position + Vector2(480.0, -160.0)
		)
		expedition.player.facing_direction = Vector2(1.0, -1.0).normalized()
		expedition.command_console.set_time_provider(Callable(self, &"_fixed_time"))
		if not expedition.command_console.open_console():
			failures.append("F05 capture driver could not open the command console.")
		else:
			await process_frame
			expedition.command_console.submit_command(
				"journal add \"Three-way fork. Ruin path northeast; blue markers return to the shuttle.\""
			)
			await _save_capture("f05_journal_add.png", failures)
			expedition.command_console.submit_command("journal tag 1 route ruin safe-return")
			for index: int in range(2, 6):
				expedition.command_console.submit_command(
					"journal add \"Ruin route observation %d near the eastern fork.\"" % index
				)
			expedition.command_console.submit_command("journal find ruin")
			await _save_capture("f05_journal_find.png", failures)
			expedition.command_console.submit_command(
				"journal append 1 \"Stalker tell remains readable from the southern approach.\""
			)
			expedition.command_console.submit_command("journal read 1")
			await _save_capture("f05_journal_read.png", failures)
			expedition.command_console.close_console()

	paused = false
	app.queue_free()
	await process_frame
	if failures.is_empty():
		print("F05 captures passed: add, bounded search and metadata-rich read views saved at 960x540.")
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	print("F05 captures failed: %d" % failures.size())
	quit(1)


func _fixed_time() -> int:
	return FIXED_TIME


func _save_capture(file_name: String, failures: Array[String]) -> void:
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	if image == null:
		failures.append("Could not read the F05 viewport for %s." % file_name)
		return
	if image.get_width() != 960 or image.get_height() != 540:
		failures.append(
			"F05 capture %s was %dx%d instead of 960x540."
			% [file_name, image.get_width(), image.get_height()]
		)
	var save_error := image.save_png("%s/%s" % [ARTIFACT_DIRECTORY, file_name])
	if save_error != OK:
		failures.append("Could not save F05 capture %s: %s." % [file_name, save_error])
