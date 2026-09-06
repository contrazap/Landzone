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
		failures.append("Could not create the F06 capture directory: %s." % directory_error)

	var app := MAIN_SCENE.instantiate() as LandzoneMain
	app.persistence_enabled = false
	app.transition_delay_seconds = 0.1
	root.add_child(app)
	await process_frame
	var mothership := app.active_location as Mothership
	if mothership == null or not app.request_location_change(&"basin", mothership):
		failures.append("The F06 capture driver could not deploy to the Basin.")
		await _finish(app, failures)
		return
	await app.transition_completed

	var expedition := app.active_location as BasinExpedition
	expedition.stalker.set_physics_process(false)
	expedition.command_console.set_time_provider(Callable(self, &"_fixed_time"))

	for view: Array in [
		["CompassArray", "f06_evidence_compass.png"],
		["ResonanceCalibration", "f06_evidence_resonance.png"],
		["RouteSlab", "f06_evidence_route_slab.png"],
	]:
		await _observe_site(expedition, view[0], failures)
		await _save_capture(view[1], failures)
		expedition.evidence_reader.close_reader()

	await _observe_site(expedition, "SouthHollowResonantCairn", failures)
	await _save_capture("f06_cairn_south_mismatch.png", failures)
	expedition.evidence_reader.close_reader()

	await _observe_site(expedition, "NorthShelfSurveyCairn", failures)
	await _save_capture("f06_cairn_north_confirmed.png", failures)
	expedition.evidence_reader.close_reader()

	# Record a field note so Research retrieval has coordinate-stamped prose to render.
	expedition.player.global_position = (
		expedition.shuttle_spawn.global_position + Vector2(1760.0, -280.0)
	)
	expedition.player.facing_direction = Vector2(1.0, -1.0).normalized()
	expedition.command_console.submit_command(
		"journal add \"Three matte stones on the north shelf answer the directive.\""
	)
	expedition.command_console.submit_command("journal tag 1 cairn silent-stone")

	expedition.player.global_position = expedition.return_area.global_position
	if not app.request_location_change(&"mothership", expedition):
		failures.append("The F06 capture driver could not return to Kestrel.")
		await _finish(app, failures)
		return
	await app.transition_completed

	var research := app.active_location as Mothership
	research.player.global_position = research.research_area.global_position
	await process_frame
	if not research.research_console.open_console():
		failures.append("The F06 capture driver could not open the Research console.")
	else:
		await process_frame
		research.research_console.submit_command("codex search north")
		await _save_capture("f06_research_codex.png", failures)
		research.research_console.submit_command("codex evidence ORUUN")
		await _save_capture("f06_research_evidence.png", failures)
		research.research_console.submit_command("journal read 1")
		await _save_capture("f06_research_journal.png", failures)
		research.research_console.close_console()

	await _finish(app, failures)


func _observe_site(
	expedition: BasinExpedition, site_name: String, failures: Array[String]
) -> void:
	var site := expedition.get_node_or_null(
		"BasinSurface/KnowledgeSites/%s" % site_name
	) as EvidenceSite
	if site == null:
		failures.append("The capture driver could not find the %s site." % site_name)
		return
	# Use the proximity-validated public interaction: the capture window's synthetic
	# action state is focus-sensitive, so headless scenarios own physical-key evidence.
	expedition.player.global_position = site.global_position
	expedition.player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	await process_frame
	if not expedition.request_knowledge_interaction():
		failures.append("The capture driver could not interact with %s." % site_name)


func _fixed_time() -> int:
	return FIXED_TIME


func _save_capture(file_name: String, failures: Array[String]) -> void:
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	if image == null:
		failures.append("Could not read the F06 viewport for %s." % file_name)
		return
	if image.get_width() != 960 or image.get_height() != 540:
		failures.append(
			"F06 capture %s was %dx%d instead of 960x540."
			% [file_name, image.get_width(), image.get_height()]
		)
	var save_error := image.save_png("%s/%s" % [ARTIFACT_DIRECTORY, file_name])
	if save_error != OK:
		failures.append("Could not save the F06 capture %s: %s." % [file_name, save_error])


func _finish(app: LandzoneMain, failures: Array[String]) -> void:
	paused = false
	app.queue_free()
	await process_frame
	if failures.is_empty():
		print("F06 captures passed: evidence, cairn validation and Research views saved at 960x540.")
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	print("F06 captures failed: %d" % failures.size())
	quit(1)
