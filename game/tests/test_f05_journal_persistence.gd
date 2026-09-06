extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const TEST_DIRECTORY := "user://landzone_f05_test"
const IN_PROCESS_SAVE := TEST_DIRECTORY + "/in_process.json"
const RESTART_SAVE := TEST_DIRECTORY + "/restart.json"
const FIXED_TIME := 1788710400


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures: Array[String] = []
	var phase := _get_argument("--phase")
	match phase:
		"write":
			await _run_restart_write(failures)
		"read":
			await _run_restart_read(failures)
		_:
			await _run_integrated_scenario(failures)
			_check_save_validation(failures)
	_finish(phase, failures)


func _run_integrated_scenario(failures: Array[String]) -> void:
	_cleanup_save(IN_PROCESS_SAVE)
	var app := await _create_basin_app(IN_PROCESS_SAVE, failures)
	if app == null:
		return
	var expedition := app.active_location as BasinExpedition
	var console := expedition.command_console
	console.set_time_provider(Callable(self, &"_fixed_time"))
	expedition.player.global_position = expedition.shuttle_spawn.global_position + Vector2(160.0, -80.0)
	expedition.player.facing_direction = Vector2(1.0, -1.0).normalized()
	var expected_location := "REGION P1-BASIN-01 | LOCAL N01 E02 | FACING NE"

	var add_response := console.submit_command("journal add \"Three-way fork. Ruin path NE.\"")
	if add_response != "ENTRY #1 SAVED\n%s" % expected_location:
		failures.append("Journal add returned an unexpected response: %s" % add_response)
	var first := app.run_state.journal.get_entry(1)
	if first == null:
		failures.append("Journal add did not create entry #1.")
	else:
		if (
			String(first.region_id) != "P1-BASIN-01"
			or first.north_steps != 1
			or first.east_steps != 2
			or first.facing != "NE"
			or first.run_seed != RunState.AUTHORED_RUN_SEED
			or first.discovered_unix_time != FIXED_TIME
		):
			failures.append("Entry #1 did not retain the exact coordinate/seed/time metadata.")

	var tag_response := console.submit_command("journal tag 1 Route cave ROUTE")
	if tag_response != "ENTRY #1 TAGS route, cave | SAVED":
		failures.append("Journal tag did not normalize and deduplicate: %s" % tag_response)
	var append_response := console.submit_command(
		"journal append 1 \"Blue markers identify the return arc.\""
	)
	if append_response != "ENTRY #1 APPENDED | SAVED":
		failures.append("Journal append returned an unexpected response: %s" % append_response)
	var read_response := console.submit_command("journal read 1")
	for expected: String in [
		"#1 | %s" % expected_location,
		"SEED %d | UTC %s" % [
			RunState.AUTHORED_RUN_SEED,
			Time.get_datetime_string_from_unix_time(FIXED_TIME, true),
		],
		"TAGS route, cave",
		"Three-way fork. Ruin path NE.\nBlue markers identify the return arc.",
	]:
		if not read_response.contains(expected):
			failures.append("Journal read omitted expected content: %s" % expected)

	for index: int in range(2, 8):
		var response := console.submit_command("journal add \"Route observation %d\"" % index)
		if not response.begins_with("ENTRY #%d SAVED" % index):
			failures.append("Could not add search fixture #%d: %s" % [index, response])
	var find_response := console.submit_command("journal find RoUtE")
	var result_lines := find_response.split("\n", false)
	if result_lines.size() != 6:
		failures.append("Journal search did not enforce the five-result cap: %s" % find_response)
	else:
		for offset: int in 5:
			var expected_id := 7 - offset
			if not result_lines[offset + 1].begins_with("#%d " % expected_id):
				failures.append("Journal search was not newest-first at result %d." % offset)
	var tag_search := console.submit_command("journal find CaVe")
	if not tag_search.contains("#1 [route, cave]"):
		failures.append("Case-insensitive tag search did not find entry #1.")

	var count_before_invalid := app.run_state.journal.entries.size()
	var next_before_invalid := app.run_state.journal.next_entry_id
	var oversized := "x".repeat(FieldJournal.MAX_NEW_TEXT_LENGTH + 1)
	var invalid_commands := {
		"journal add \"unclosed": "UNCLOSED QUOTE",
		"journal add unquoted": "USAGE: journal add \"<text>\"",
		"journal add \"%s\"" % oversized: "NOTE TOO LONG (MAX 240)",
		"journal find": "USAGE: journal find <query>",
		"journal read nope": "INVALID ENTRY ID: nope",
		"journal read 99": "ENTRY #99 NOT FOUND",
		"journal tag 1 bad!": "INVALID TAG: bad!",
		"journal tag 1 a b c d e f g": "TOO MANY TAGS (MAX 8)",
		"journal append 1 unquoted": "USAGE: journal append <id> \"<text>\"",
		"journal erase 1": "UNKNOWN JOURNAL COMMAND: erase",
	}
	for command: String in invalid_commands:
		var actual := console.submit_command(command)
		if actual != invalid_commands[command]:
			failures.append("`%s` returned `%s`." % [command, actual])
	if (
		app.run_state.journal.entries.size() != count_before_invalid
		or app.run_state.journal.next_entry_id != next_before_invalid
	):
		failures.append("Rejected journal commands mutated entries or next-id state.")

	console.configure_journal(
		app.run_state.journal,
		Callable(expedition, &"get_coordinate_stamp"),
		Callable(expedition, &"format_coordinate_stamp"),
		app.run_state.run_seed,
		Callable(self, &"_always_fail")
	)
	var failed_save_response := console.submit_command("journal add \"Retained after write failure.\"")
	if failed_save_response != "ENTRY #8 ADDED | SAVE FAILED\n%s" % expected_location:
		failures.append("Failed save did not report retained entry #8: %s" % failed_save_response)
	if app.run_state.journal.get_entry(8) == null:
		failures.append("A failed persistence callback discarded the in-memory mutation.")
	console.configure_journal(
		app.run_state.journal,
		Callable(expedition, &"get_coordinate_stamp"),
		Callable(expedition, &"format_coordinate_stamp"),
		app.run_state.run_seed,
		Callable(app, &"persist_run_state")
	)
	if not app.persist_run_state():
		failures.append("Could not persist the retained mutation after restoring the save callback.")

	var preserved_text := app.run_state.journal.get_entry(1).text
	expedition.player.die()
	await expedition.retry_completed
	if expedition.retry_in_progress or app.run_state.journal.get_entry(1).text != preserved_text:
		failures.append("Lethal retry did not preserve journal entry #1.")
	var reset_snapshot := app.run_state.basin_encounter
	if (
		reset_snapshot == null
		or reset_snapshot.behavior_state != Stalker.State.CONCEALED
		or reset_snapshot.hits_remaining != 3
		or reset_snapshot.position.distance_to(expedition.stalker_spawn.global_position) > 0.01
	):
		failures.append("Retry completion did not update the in-memory durable encounter reset.")
	var retry_save := RunSaveStore.new(IN_PROCESS_SAVE).load_state()
	if (
		not retry_save.ok
		or retry_save.state.basin_encounter == null
		or retry_save.state.basin_encounter.behavior_state != Stalker.State.CONCEALED
		or retry_save.state.basin_encounter.hits_remaining != 3
	):
		failures.append("Retry completion did not persist the durable encounter reset.")

	expedition.player.global_position = expedition.return_area.global_position
	if not app.request_location_change(&"mothership", expedition):
		failures.append("Could not return to Kestrel during the journal transition check.")
	else:
		await app.transition_completed
		var mothership := app.active_location as Mothership
		if mothership == null or not app.request_location_change(&"basin", mothership):
			failures.append("Could not redeploy during the journal transition check.")
		else:
			await app.transition_completed
			var restored := app.active_location as BasinExpedition
			var restored_read := restored.command_console.submit_command("journal read 1")
			if not restored_read.contains("Blue markers identify the return arc."):
				failures.append("Location replacement lost the appended journal text.")
			if not restored.command_console.submit_command("journal find cave").contains("#1"):
				failures.append("Location replacement lost searchable journal tags.")

	app.queue_free()
	await process_frame
	_cleanup_save(IN_PROCESS_SAVE)


func _check_save_validation(failures: Array[String]) -> void:
	var absolute_directory := ProjectSettings.globalize_path(TEST_DIRECTORY)
	if DirAccess.make_dir_recursive_absolute(absolute_directory) != OK:
		failures.append("Could not establish the isolated F05 test directory.")
		return
	var missing_path := TEST_DIRECTORY + "/missing.json"
	_cleanup_save(missing_path)
	var missing := RunSaveStore.new(missing_path).load_state()
	if not missing.ok or missing.found or missing.state.journal.entries.size() != 0:
		failures.append("A missing save did not create a clean fresh run.")

	var malformed_path := TEST_DIRECTORY + "/malformed.json"
	_write_fixture(malformed_path, "{ definitely not json", failures)
	var malformed := RunSaveStore.new(malformed_path).load_state()
	if malformed.ok or malformed.state.journal.entries.size() != 0 or malformed.error.is_empty():
		failures.append("Malformed JSON was not rejected with a fresh-state diagnostic.")

	var unsupported_path := TEST_DIRECTORY + "/unsupported.json"
	_write_fixture(
		unsupported_path,
		JSON.stringify({"save_version": 99, "run_state": RunState.new().to_dictionary()}),
		failures
	)
	var unsupported := RunSaveStore.new(unsupported_path).load_state()
	if unsupported.ok or not unsupported.error.contains("unsupported save version"):
		failures.append("An unsupported save version was not rejected.")

	var invalid_entry_path := TEST_DIRECTORY + "/invalid_entry.json"
	var invalid_state := RunState.new().to_dictionary()
	invalid_state["journal"]["entries"] = [{"id": 1}]
	invalid_state["journal"]["next_entry_id"] = 2
	_write_fixture(
		invalid_entry_path,
		JSON.stringify({"save_version": 1, "run_state": invalid_state}),
		failures
	)
	var invalid_entry := RunSaveStore.new(invalid_entry_path).load_state()
	if invalid_entry.ok or invalid_entry.state.journal.entries.size() != 0:
		failures.append("A partially invalid journal was accepted or partially reconstructed.")

	var roundtrip_path := TEST_DIRECTORY + "/roundtrip.json"
	var source := RunState.new()
	var add_result := source.journal.add_entry(
		"Independent reconstruction.",
		{"region": "P1-BASIN-01", "north": -3, "east": 4, "facing": "W"},
		source.run_seed,
		FIXED_TIME
	)
	if not add_result.ok:
		failures.append("Could not establish the valid round-trip fixture.")
	else:
		var snapshot := RunState.BasinEncounterState.new()
		snapshot.position = Vector2(900.5, 412.25)
		snapshot.behavior_state = Stalker.State.RECOVERY
		snapshot.elapsed_seconds = 0.31
		snapshot.hits_remaining = 2
		snapshot.committed_direction = Vector2.LEFT
		source.store_basin_encounter(snapshot)
		var store := RunSaveStore.new(roundtrip_path)
		if not store.save_state(source):
			failures.append("Valid version-1 fixture could not save: %s" % store.last_error)
		else:
			var loaded := store.load_state()
			if not loaded.ok or not loaded.found:
				failures.append("Valid version-1 fixture could not reload: %s" % loaded.error)
			else:
				var loaded_state := loaded.state as RunState
				loaded_state.journal.get_entry(1).text = "Changed loaded copy."
				loaded_state.basin_encounter.position.x = 1.0
				if source.journal.get_entry(1).text != "Independent reconstruction.":
					failures.append("Reloaded journal entry aliases the source entry.")
				if not is_equal_approx(source.basin_encounter.position.x, 900.5):
					failures.append("Reloaded encounter snapshot aliases the source snapshot.")

	for path: String in [
		missing_path, malformed_path, unsupported_path, invalid_entry_path, roundtrip_path
	]:
		_cleanup_save(path)


func _run_restart_write(failures: Array[String]) -> void:
	_cleanup_save(RESTART_SAVE)
	var app := await _create_basin_app(RESTART_SAVE, failures)
	if app == null:
		return
	var expedition := app.active_location as BasinExpedition
	expedition.command_console.set_time_provider(Callable(self, &"_fixed_time"))
	expedition.player.global_position = expedition.shuttle_spawn.global_position + Vector2(240.0, 80.0)
	expedition.player.facing_direction = Vector2.LEFT
	var add_response := expedition.command_console.submit_command(
		"journal add \"Restart boundary observation.\""
	)
	if not add_response.begins_with("ENTRY #1 SAVED"):
		failures.append("Restart writer could not save entry #1: %s" % add_response)
	if expedition.command_console.submit_command("journal tag 1 route restart") != (
		"ENTRY #1 TAGS route, restart | SAVED"
	):
		failures.append("Restart writer could not persist tags.")
	if expedition.command_console.submit_command(
		"journal append 1 \"Reader must recover this line.\""
	) != "ENTRY #1 APPENDED | SAVED":
		failures.append("Restart writer could not persist appended prose.")
	expedition.stalker.global_position = Vector2(1230.0, 470.0)
	expedition.stalker.current_state = Stalker.State.RECOVERY
	expedition.stalker.state_elapsed_seconds = 0.31
	expedition.stalker.hits_remaining = 2
	expedition.stalker.committed_direction = Vector2.LEFT
	expedition.player.global_position = expedition.return_area.global_position
	if not app.request_location_change(&"mothership", expedition):
		failures.append("Restart writer could not capture and save the Basin encounter.")
	else:
		await app.transition_completed
	if not FileAccess.file_exists(RESTART_SAVE):
		failures.append("Restart writer did not leave the isolated save file for the reader process.")
	app.queue_free()
	await process_frame


func _run_restart_read(failures: Array[String]) -> void:
	if not FileAccess.file_exists(RESTART_SAVE):
		failures.append("Restart reader could not find the writer process save.")
		return
	var app := MAIN_SCENE.instantiate() as LandzoneMain
	app.save_path = RESTART_SAVE
	root.add_child(app)
	await process_frame
	if not app.load_warning.is_empty():
		failures.append("Restart reader reported a load warning: %s" % app.load_warning)
	var entry := app.run_state.journal.get_entry(1)
	if entry == null:
		failures.append("Restart reader did not reconstruct entry #1.")
	else:
		if entry.text != "Restart boundary observation.\nReader must recover this line.":
			failures.append("Restart reader lost exact appended prose.")
		if entry.tags != ["route", "restart"]:
			failures.append("Restart reader lost normalized tags.")
		if (
			entry.north_steps != -1
			or entry.east_steps != 3
			or entry.facing != "W"
			or entry.discovered_unix_time != FIXED_TIME
		):
			failures.append("Restart reader lost coordinate/facing/time metadata.")
	if app.run_state.run_seed != RunState.AUTHORED_RUN_SEED:
		failures.append("Restart reader did not restore the authored run seed.")
	if app.run_state.journal.next_entry_id != 2:
		failures.append("Restart reader did not restore monotonic next-id state.")
	var encounter := app.run_state.basin_encounter
	if (
		encounter == null
		or encounter.position.distance_to(Vector2(1230.0, 470.0)) > 0.01
		or encounter.behavior_state != Stalker.State.RECOVERY
		or not is_equal_approx(encounter.elapsed_seconds, 0.31)
		or encounter.hits_remaining != 2
	):
		failures.append("Restart reader did not restore the saved Basin encounter snapshot.")

	var mothership := app.active_location as Mothership
	if mothership == null or not app.request_location_change(&"basin", mothership):
		failures.append("Restart reader could not deploy to use the journal interface.")
	else:
		await app.transition_completed
		var expedition := app.active_location as BasinExpedition
		if (
			expedition.stalker.global_position.distance_to(Vector2(1230.0, 470.0)) > 0.01
			or expedition.stalker.current_state != Stalker.State.RECOVERY
			or expedition.stalker.hits_remaining != 2
		):
			failures.append("Restart deployment did not apply the durable encounter snapshot.")
		var read_response := expedition.command_console.submit_command("journal read 1")
		if not read_response.contains("Reader must recover this line."):
			failures.append("Restart reader could not read durable prose through the real console.")
		if not expedition.command_console.submit_command("journal find RESTART").contains("#1"):
			failures.append("Restart reader could not search durable tags through the real console.")
		expedition.command_console.set_time_provider(Callable(self, &"_fixed_time"))
		var second_response := expedition.command_console.submit_command(
			"journal add \"Second process entry.\""
		)
		if not second_response.begins_with("ENTRY #2 SAVED"):
			failures.append("Restart reader did not continue IDs at #2: %s" % second_response)
	app.queue_free()
	await process_frame
	if failures.is_empty():
		_cleanup_save(RESTART_SAVE)


func _create_basin_app(save_path: String, failures: Array[String]) -> LandzoneMain:
	var app := MAIN_SCENE.instantiate() as LandzoneMain
	app.save_path = save_path
	app.transition_delay_seconds = 0.1
	root.add_child(app)
	await process_frame
	var mothership := app.active_location as Mothership
	if mothership == null or not app.request_location_change(&"basin", mothership):
		failures.append("F05 scenario could not deploy from Kestrel to the Basin.")
		app.queue_free()
		await process_frame
		return null
	await app.transition_completed
	return app


func _fixed_time() -> int:
	return FIXED_TIME


func _always_fail() -> bool:
	return false


func _write_fixture(path: String, contents: String, failures: Array[String]) -> void:
	var absolute_directory := ProjectSettings.globalize_path(path).get_base_dir()
	if DirAccess.make_dir_recursive_absolute(absolute_directory) != OK:
		failures.append("Could not create fixture directory for %s." % path)
		return
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		failures.append("Could not write fixture %s (%s)." % [path, FileAccess.get_open_error()])
		return
	file.store_string(contents)
	file.close()


func _cleanup_save(path: String) -> void:
	for suffix: String in ["", ".tmp", ".bak"]:
		var absolute_path := ProjectSettings.globalize_path(path + suffix)
		if FileAccess.file_exists(absolute_path):
			DirAccess.remove_absolute(absolute_path)


func _get_argument(name: String) -> String:
	var arguments := OS.get_cmdline_user_args()
	for index: int in arguments.size() - 1:
		if arguments[index] == name:
			return arguments[index + 1]
	return ""


func _finish(phase: String, failures: Array[String]) -> void:
	if failures.is_empty():
		match phase:
			"write":
				print("F05 restart writer passed: durable journal and encounter save created.")
			"read":
				print("F05 restart reader passed: separate process restored journal, seed, encounter and next ID.")
			_:
				print("F05/D01 checks passed: journal grammar, lifecycle, validation and isolated save contracts.")
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	print("F05 checks failed (%s): %d" % [phase if not phase.is_empty() else "integrated", failures.size()])
	quit(1)
