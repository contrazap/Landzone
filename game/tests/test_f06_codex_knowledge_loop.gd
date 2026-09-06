extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const TEST_DIRECTORY := "user://landzone_f06_test"
const MIGRATION_SAVE := TEST_DIRECTORY + "/knowledge_model.json"
const FIELD_SAVE := TEST_DIRECTORY + "/field_loop.json"
const RESTART_SAVE := TEST_DIRECTORY + "/restart.json"
const FIXED_TIME := 1788710400
const ROUTE_SPEED := 620.0

# Authored Basin waypoints. Arc and branch points follow the F04 route topology; the
# southern legs use the authored safe passage so the live hazard stays avoidable.
const LANDING_FORK := Vector2(820.0, 450.0)
const COMPASS_ARRAY := Vector2(820.0, 350.0)
const NORTH_ARC_WEST := Vector2(1080.0, 210.0)
const RESONANCE_CALIBRATION := Vector2(1260.0, 210.0)
const NORTH_ARC_EAST := Vector2(1400.0, 210.0)
const NORTH_TIP := Vector2(1560.0, 330.0)
const ROUTE_SLAB_STAND := Vector2(1580.0, 450.0)
const REUNION_FORK := Vector2(1640.0, 450.0)
const FAR_FORK := Vector2(1980.0, 450.0)
const NORTH_BRANCH := Vector2(2190.0, 210.0)
const NORTH_CAIRN := Vector2(2300.0, 170.0)
const SOUTH_BRANCH := Vector2(2190.0, 690.0)
const SOUTH_CAIRN := Vector2(2300.0, 730.0)
const SOUTH_ARC_WEST := Vector2(1080.0, 690.0)
const SOUTH_PASSAGE_WEST := Vector2(1080.0, 785.0)
const SAFE_PASSAGE := Vector2(1190.0, 785.0)
const SOUTH_PASSAGE_EAST := Vector2(1330.0, 785.0)
const SOUTH_ARC_EAST := Vector2(1400.0, 690.0)
const HAZARD_CONTACT := Vector2(1190.0, 670.0)

# Kestrel aisle stations.
const AISLE_TURN := Vector2(412.0, 420.0)
const AISLE_RESEARCH_ROW := Vector2(412.0, 292.0)
const RESEARCH_STAND := Vector2(470.0, 292.0)
const DEPLOY_STAND := Vector2(630.0, 200.0)
const AWAY_FROM_RESEARCH := Vector2(250.0, 420.0)


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
			_check_catalog_and_state(failures)
			_check_save_migration(failures)
			await _check_field_loop(failures)
			_cleanup_save(MIGRATION_SAVE)
			if failures.is_empty():
				_cleanup_save(FIELD_SAVE)
	_finish(phase, failures)


func _check_field_loop(failures: Array[String]) -> void:
	_cleanup_save(FIELD_SAVE)
	var app := MAIN_SCENE.instantiate() as LandzoneMain
	app.save_path = FIELD_SAVE
	app.transition_delay_seconds = 0.1
	root.add_child(app)
	await process_frame

	var mothership := app.active_location as Mothership
	if mothership == null:
		failures.append("F06 field loop did not start aboard Kestrel.")
		await _teardown(app)
		return
	if not await _walk_route(mothership.player, [[DEPLOY_STAND, "Kestrel vehicle bay"]], failures):
		await _teardown(app)
		return
	await _press_interact()
	if not app.transition_in_progress:
		failures.append("Physical E at the vehicle bay did not begin deployment.")
		await _teardown(app)
		return
	await app.transition_completed

	var expedition := app.active_location as BasinExpedition
	if expedition == null:
		failures.append("Physical deployment did not activate the Basin expedition.")
		await _teardown(app)
		return
	expedition.player.movement_speed = ROUTE_SPEED
	# The Stalker is stilled so the clue route is isolated; F02 and F03 own live combat,
	# committed-attack death and encounter-reset evidence. The lethal hazard stays armed.
	expedition.stalker.set_physics_process(false)
	await physics_frame

	await _check_premature_cairn(app, expedition, failures)
	await _check_evidence_collection(app, expedition, failures)
	await _check_prose_isolation(app, expedition, failures)
	await _check_death_durability(app, expedition, failures)
	await _check_invalid_and_correct_cairns(app, expedition, failures)
	await _check_research_station(app, expedition, failures)

	_check_field_save_file(failures)
	await _teardown(app)


func _check_premature_cairn(
	app: LandzoneMain, expedition: BasinExpedition, failures: Array[String]
) -> void:
	var reached := await _walk_route(expedition.player, [
		[LANDING_FORK, "Landing Fork"],
		[SOUTH_ARC_WEST, "South Arc west"],
		[SOUTH_PASSAGE_WEST, "South Arc hazard descent"],
		[SAFE_PASSAGE, "authored hazard safe passage"],
		[SOUTH_PASSAGE_EAST, "South Arc hazard exit"],
		[SOUTH_ARC_EAST, "South Arc east"],
		[REUNION_FORK, "Reunion Fork"],
		[FAR_FORK, "Far Fork"],
		[NORTH_BRANCH, "North Shelf branch"],
		[NORTH_CAIRN, "North Shelf Survey Cairn"],
	], failures)
	if not reached:
		return
	if not expedition.player.is_alive:
		failures.append("The authored southern safe passage did not avoid the live hazard.")
		return
	if (
		expedition.active_knowledge_site == null
		or not expedition.active_knowledge_site.is_destination()
	):
		failures.append("Walking the route did not activate the North Shelf cairn prompt.")
		return
	if expedition.knowledge_prompt_label.text != "E - INSPECT CAIRN PATTERN":
		failures.append(
			"Cairn proximity prompt read '%s'." % expedition.knowledge_prompt_label.text
		)
	await _press_interact()
	if not expedition.evidence_reader.is_reader_open():
		failures.append("Physical E did not open the cairn reader at the North Shelf.")
		return
	if not paused:
		failures.append("The cairn reader did not own a live pause.")
	if expedition.evidence_reader.status_label.text != "PATTERN REJECTED":
		failures.append("Premature North cairn did not present a rejection.")
	if not expedition.evidence_reader.glyph_label.text.contains("EVIDENCE 0/3"):
		failures.append("Premature North cairn did not report the unresolved evidence count.")
	if (
		not app.run_state.codex.confirmed_meanings.is_empty()
		or not app.run_state.codex.confirmed_destination_id.is_empty()
	):
		failures.append("A premature cairn attempt mutated authoritative codex truth.")
	await _send_key(KEY_ESCAPE)
	if expedition.evidence_reader.is_reader_open() or paused:
		failures.append("Physical Escape did not close the cairn reader and resume gameplay.")


func _check_evidence_collection(
	app: LandzoneMain, expedition: BasinExpedition, failures: Array[String]
) -> void:
	var collection_legs := [
		[
			[
				[NORTH_BRANCH, "North Shelf return"],
				[FAR_FORK, "Far Fork return"],
				[REUNION_FORK, "Reunion Fork return"],
				[ROUTE_SLAB_STAND, "Route Slab"],
			],
			"route_slab",
			"REUNION FORK ROUTE SLAB",
		],
		[
			[
				[NORTH_TIP, "North Arc island tip"],
				[NORTH_ARC_EAST, "North Arc east"],
				[RESONANCE_CALIBRATION, "Resonance Calibration"],
			],
			"resonance_calibration",
			"RESONANCE CALIBRATION",
		],
		[
			[
				[NORTH_ARC_WEST, "North Arc west"],
				[COMPASS_ARRAY, "Compass Array"],
			],
			"compass_array",
			"LANDING FORK COMPASS ARRAY",
		],
	]
	for entry: Array in collection_legs:
		if not await _walk_route(expedition.player, entry[0], failures):
			return
		var site := expedition.active_knowledge_site
		if site == null or site.evidence_id != entry[1]:
			failures.append("Route arrival did not activate the %s evidence site." % entry[1])
			return
		if expedition.knowledge_prompt_label.text != "E - OBSERVE EVIDENCE":
			failures.append(
				"Evidence proximity prompt read '%s'." % expedition.knowledge_prompt_label.text
			)
		await _press_interact()
		if not expedition.evidence_reader.is_reader_open() or not paused:
			failures.append("Physical E did not open a paused reader at %s." % entry[1])
			return
		if expedition.evidence_reader.status_label.text != "NEW EVIDENCE":
			failures.append("First observation of %s was not reported as new evidence." % entry[1])
		if not expedition.evidence_reader.title_label.text.contains(entry[2]):
			failures.append(
				"Reader title for %s read '%s'."
				% [entry[1], expedition.evidence_reader.title_label.text]
			)
		await _send_key(KEY_ESCAPE)
		if paused:
			failures.append("The %s reader leaked its pause." % entry[1])
		if not app.run_state.codex.has_observed(entry[1]):
			failures.append("Observing %s through real input did not store its stable ID." % entry[1])

	# The last site is still in range: a repeated physical observation must not duplicate.
	await _press_interact()
	if expedition.evidence_reader.status_label.text != "EVIDENCE REVIEW":
		failures.append("A repeated observation was not reported as a review.")
	await _send_key(KEY_ESCAPE)
	if app.run_state.codex.observed_evidence_ids.size() != 3:
		failures.append(
			"The walked evidence chain stored %d IDs instead of three."
			% app.run_state.codex.observed_evidence_ids.size()
		)


func _check_prose_isolation(
	app: LandzoneMain, expedition: BasinExpedition, failures: Array[String]
) -> void:
	var console := expedition.command_console
	console.set_time_provider(Callable(self, &"_fixed_time"))
	await _send_key(KEY_TAB, 9)
	if not console.is_console_open() or not paused:
		failures.append("Physical Tab did not open the Basin console after the evidence route.")
		return
	if console.command_input.get_viewport().gui_get_focus_owner() != console.command_input:
		failures.append("The Basin console did not focus its LineEdit for typed commands.")
	var before := app.run_state.codex.to_dictionary()
	var add_response := console.submit_command(
		"journal add \"ACHVNTSAT must mean south and the cairn is already solved.\""
	)
	if not add_response.begins_with("ENTRY #1 SAVED"):
		failures.append("Field journal add failed during prose isolation: %s" % add_response)
	if console.submit_command("codex search ACHVNTSAT") != "CODEX AVAILABLE AT KESTREL RESEARCH":
		failures.append("The Basin console did not direct codex queries to Kestrel Research.")
	if app.run_state.codex.to_dictionary() != before:
		failures.append("Assertive journal prose changed durable codex state.")
	await _send_key(KEY_ESCAPE)
	if console.is_console_open() or paused:
		failures.append("Physical Escape did not close the Basin console.")


func _check_death_durability(
	app: LandzoneMain, expedition: BasinExpedition, failures: Array[String]
) -> void:
	if not await _walk_route(expedition.player, [
		[LANDING_FORK, "Landing Fork before the hazard"],
		[SOUTH_ARC_WEST, "South Arc hazard approach"],
	], failures):
		return
	for _frame: int in 160:
		if expedition.retry_in_progress:
			break
		_set_movement(HAZARD_CONTACT - expedition.player.global_position)
		await physics_frame
	_release_movement()
	if not expedition.retry_in_progress:
		failures.append("Walking into the authored hazard did not start a retry.")
		return
	await expedition.retry_completed
	await process_frame
	if app.run_state.codex.observed_evidence_ids.size() != 3:
		failures.append("Death and redeployment lost collected evidence.")
	if not app.run_state.codex.confirmed_meanings.is_empty():
		failures.append("Death and redeployment fabricated confirmed meanings.")
	if app.run_state.journal.get_entry(1) == null:
		failures.append("Death and redeployment lost the field journal entry.")
	var store := RunSaveStore.new(FIELD_SAVE)
	var loaded := store.load_state()
	if not loaded.ok or loaded.state.codex.observed_evidence_ids.size() != 3:
		failures.append("The retry save did not retain three observed evidence records.")


func _check_invalid_and_correct_cairns(
	app: LandzoneMain, expedition: BasinExpedition, failures: Array[String]
) -> void:
	expedition.player.movement_speed = ROUTE_SPEED
	if not await _walk_route(expedition.player, [
		[LANDING_FORK, "Landing Fork after retry"],
		[NORTH_ARC_WEST, "North Arc west outbound"],
		[NORTH_ARC_EAST, "North Arc east outbound"],
		[REUNION_FORK, "Reunion Fork outbound"],
		[FAR_FORK, "Far Fork outbound"],
		[SOUTH_BRANCH, "South Hollow branch"],
		[SOUTH_CAIRN, "South Hollow Resonant Cairn"],
	], failures):
		return
	await _press_interact()
	if not expedition.evidence_reader.is_reader_open():
		failures.append("Physical E did not inspect the South Hollow decoy cairn.")
		return
	if expedition.evidence_reader.status_label.text != "PATTERN REJECTED":
		failures.append("The fully informed South decoy was not rejected.")
	if not expedition.evidence_reader.glyph_label.text.contains("SOUTH / II / RESONANT"):
		failures.append("The South decoy did not present its grounded physical mismatch.")
	await _send_key(KEY_ESCAPE)
	if not app.run_state.codex.confirmed_meanings.is_empty():
		failures.append("The South decoy mutated confirmed meanings.")

	if not await _walk_route(expedition.player, [
		[SOUTH_BRANCH, "South Hollow return"],
		[FAR_FORK, "Far Fork to the north branch"],
		[NORTH_BRANCH, "North Shelf branch informed"],
		[NORTH_CAIRN, "North Shelf Survey Cairn informed"],
	], failures):
		return
	await _press_interact()
	if not expedition.evidence_reader.is_reader_open():
		failures.append("Physical E did not inspect the informed North Shelf cairn.")
		return
	if expedition.evidence_reader.status_label.text != "PATTERN CONFIRMED":
		failures.append("The informed North Shelf cairn was not confirmed.")
	var glyph_text := expedition.evidence_reader.glyph_label.text
	for meaning: String in ["ACHVNTSAT = NORTH", "VEL = THREE", "ORUUN = SILENT STONE"]:
		if not glyph_text.contains(meaning):
			failures.append("The confirmation view omitted %s." % meaning)
	await _send_key(KEY_ESCAPE)
	if app.run_state.codex.confirmed_destination_id != CodexState.CATALOG.correct_destination_id:
		failures.append("Walking the informed route did not store the authoritative destination.")


func _check_research_station(
	app: LandzoneMain, expedition: BasinExpedition, failures: Array[String]
) -> void:
	if not await _walk_route(expedition.player, [
		[NORTH_BRANCH, "North Shelf homeward"],
		[FAR_FORK, "Far Fork homeward"],
		[REUNION_FORK, "Reunion Fork homeward"],
		[NORTH_ARC_EAST, "North Arc east homeward"],
		[NORTH_ARC_WEST, "North Arc west homeward"],
		[LANDING_FORK, "Landing Fork homeward"],
		[expedition.shuttle_spawn.global_position, "shuttle return area"],
	], failures):
		return
	await _press_interact()
	if not app.transition_in_progress:
		failures.append("Physical E at the shuttle did not begin the return to Kestrel.")
		return
	await app.transition_completed

	var mothership := app.active_location as Mothership
	if mothership == null:
		failures.append("The knowledge loop did not return to Kestrel.")
		return
	if not await _walk_route(mothership.player, [
		[AISLE_TURN, "Kestrel aisle turn"],
		[AISLE_RESEARCH_ROW, "Kestrel research row"],
		[RESEARCH_STAND, "Kestrel Research terminal"],
	], failures):
		return
	if not mothership.research_prompt.visible:
		failures.append("Walking to the Research terminal did not show its prompt.")
	await _press_interact()
	var console := mothership.research_console
	if not console.is_console_open():
		failures.append("Physical E at the Research terminal did not open the console.")
		return
	if not paused:
		failures.append("The Research console did not own a live pause.")
	if console.command_input.get_viewport().gui_get_focus_owner() != console.command_input:
		failures.append("The Research console did not focus its LineEdit.")
	if not console.available_label.text.contains("codex search / evidence"):
		failures.append("The Research console did not advertise its codex commands.")
	if console.title_label.text != "KESTREL RESEARCH CODEX":
		failures.append("The Research console was titled '%s'." % console.title_label.text)
	if console.command_input.placeholder_text.contains("where"):
		failures.append("The Research console advertised the unavailable `where` command.")

	await _type_command(console, "codex search north")
	if not console.response_label.text.contains("ACHVNTSAT = NORTH"):
		failures.append("A typed codex search returned '%s'." % console.response_label.text)
	if not console.submit_command("codex evidence ORUUN").contains("RESONANCE CALIBRATION"):
		failures.append("Research codex evidence omitted a collected ORUUN record.")
	if console.submit_command("codex evidence UNKNOWN") != "UNKNOWN TERM: UNKNOWN":
		failures.append("Research codex evidence did not reject an unknown term.")
	if console.submit_command("where") != "WHERE UNAVAILABLE":
		failures.append("`where` was not reported unavailable aboard Kestrel.")
	if console.submit_command("journal add \"ship note\"") != "LOCATION UNAVAILABLE":
		failures.append("Research allowed a coordinate-stamped journal add aboard ship.")
	if not console.submit_command("journal find ACHVNTSAT").contains("#1"):
		failures.append("Research could not search the field journal.")
	var read_response := console.submit_command("journal read 1")
	if not read_response.contains("REGION P1-BASIN-01 | LOCAL"):
		failures.append(
			"Research journal read lost the entry's recorded coordinates: %s" % read_response
		)
	if console.submit_command("journal tag 1 codex north") != "ENTRY #1 TAGS codex, north | SAVED":
		failures.append("Research could not tag a field entry.")
	if console.submit_command("journal append 1 \"Confirmed at Research.\"") != (
		"ENTRY #1 APPENDED | SAVED"
	):
		failures.append("Research could not append to a field entry.")
	await _send_key(KEY_ESCAPE)
	if console.is_console_open() or paused:
		failures.append("Physical Escape did not close the Research console and resume Kestrel.")

	if not await _walk_route(
		mothership.player, [[AWAY_FROM_RESEARCH, "aisle away from Research"]], failures
	):
		return
	await _press_interact()
	if console.is_console_open():
		failures.append("The Research console opened away from its terminal.")
	if not await _walk_route(
		mothership.player, [[RESEARCH_STAND, "Research terminal again"]], failures
	):
		return
	mothership.begin_transition()
	if console.open_console():
		failures.append("The Research console opened while a static transfer was committed.")


func _check_field_save_file(failures: Array[String]) -> void:
	var store := RunSaveStore.new(FIELD_SAVE)
	var loaded := store.load_state()
	if not loaded.ok or not loaded.found:
		failures.append("The walked knowledge loop did not leave a readable save.")
		return
	if loaded.migrated:
		failures.append("A new F06 run was written as a legacy save version.")
	var state := loaded.state as RunState
	var codex := state.codex
	if codex.observed_evidence_ids.size() != 3:
		failures.append("The saved codex did not retain three observed records.")
	if codex.confirmed_destination_id != CodexState.CATALOG.correct_destination_id:
		failures.append("The saved codex did not retain the confirmed destination.")
	if codex.confirmed_meanings != CodexState.CATALOG.expected_meanings():
		failures.append("The saved codex did not retain the exact confirmed meanings.")
	var entry := state.journal.get_entry(1)
	if (
		entry == null
		or not entry.text.contains("Confirmed at Research.")
		or entry.tags != ["codex", "north"]
	):
		failures.append("The saved journal did not retain Research edits.")


func _run_restart_write(failures: Array[String]) -> void:
	_cleanup_save(RESTART_SAVE)
	var app := MAIN_SCENE.instantiate() as LandzoneMain
	app.save_path = RESTART_SAVE
	app.transition_delay_seconds = 0.1
	root.add_child(app)
	await process_frame
	var mothership := app.active_location as Mothership
	if mothership == null or not app.request_location_change(&"basin", mothership):
		failures.append("F06 restart writer could not deploy to the Basin.")
		await _teardown(app)
		return
	await app.transition_completed
	var expedition := app.active_location as BasinExpedition
	expedition.stalker.set_physics_process(false)
	expedition.command_console.set_time_provider(Callable(self, &"_fixed_time"))

	for site_name: String in ["CompassArray", "ResonanceCalibration", "RouteSlab"]:
		await _observe_site(expedition, site_name, failures)
	if app.run_state.codex.observed_evidence_ids.size() != 3:
		failures.append(
			"F06 restart writer collected %s instead of three evidence records."
			% str(app.run_state.codex.observed_evidence_ids)
		)
	await _observe_site(expedition, "NorthShelfSurveyCairn", failures)
	if app.run_state.codex.confirmed_destination_id != CodexState.CATALOG.correct_destination_id:
		failures.append("F06 restart writer did not confirm the North Shelf destination.")

	expedition.player.global_position = (
		expedition.shuttle_spawn.global_position + Vector2(160.0, -80.0)
	)
	expedition.player.facing_direction = Vector2(1.0, -1.0).normalized()
	var add_response := expedition.command_console.submit_command(
		"journal add \"Silent stone cairn confirmed north of the far fork.\""
	)
	if not add_response.begins_with("ENTRY #1 SAVED"):
		failures.append("F06 restart writer could not save a field entry: %s" % add_response)
	expedition.stalker.global_position = Vector2(1230.0, 470.0)
	expedition.stalker.current_state = Stalker.State.RECOVERY
	expedition.stalker.state_elapsed_seconds = 0.31
	expedition.stalker.hits_remaining = 2
	expedition.player.global_position = expedition.return_area.global_position
	if not app.request_location_change(&"mothership", expedition):
		failures.append("F06 restart writer could not return to Kestrel and save.")
	else:
		await app.transition_completed
	if not FileAccess.file_exists(RESTART_SAVE):
		failures.append("F06 restart writer did not leave the isolated save for the reader process.")
	await _teardown(app)


func _run_restart_read(failures: Array[String]) -> void:
	if not FileAccess.file_exists(RESTART_SAVE):
		failures.append("F06 restart reader could not find the writer process save.")
		return
	var app := MAIN_SCENE.instantiate() as LandzoneMain
	app.save_path = RESTART_SAVE
	app.transition_delay_seconds = 0.1
	root.add_child(app)
	await process_frame
	if not app.load_warning.is_empty():
		failures.append("F06 restart reader reported a load warning: %s" % app.load_warning)
	var codex := app.run_state.codex
	for evidence_id: String in CodexState.CATALOG.required_evidence_ids:
		if not codex.has_observed(evidence_id):
			failures.append("F06 restart reader lost the observed record %s." % evidence_id)
	if codex.observed_evidence_ids.size() != 3:
		failures.append("F06 restart reader did not restore exactly three observed records.")
	if codex.confirmed_meanings != CodexState.CATALOG.expected_meanings():
		failures.append("F06 restart reader did not restore the confirmed meanings.")
	if codex.confirmed_destination_id != CodexState.CATALOG.correct_destination_id:
		failures.append("F06 restart reader did not restore the confirmed destination.")
	if app.run_state.run_seed != RunState.AUTHORED_RUN_SEED:
		failures.append("F06 restart reader did not restore the authored run seed.")
	if app.run_state.journal.next_entry_id != 2:
		failures.append("F06 restart reader did not restore monotonic journal IDs.")
	var encounter := app.run_state.basin_encounter
	if (
		encounter == null
		or encounter.position.distance_to(Vector2(1230.0, 470.0)) > 0.01
		or encounter.behavior_state != Stalker.State.RECOVERY
		or encounter.hits_remaining != 2
	):
		failures.append("F06 restart reader did not restore the durable encounter snapshot.")

	var mothership := app.active_location as Mothership
	if mothership == null or not app.request_location_change(&"basin", mothership):
		failures.append("F06 restart reader could not redeploy to the Basin.")
		await _teardown(app)
		return
	await app.transition_completed
	var expedition := app.active_location as BasinExpedition
	if (
		expedition.stalker.global_position.distance_to(Vector2(1230.0, 470.0)) > 0.01
		or expedition.stalker.current_state != Stalker.State.RECOVERY
		or expedition.stalker.hits_remaining != 2
	):
		failures.append("F06 restart redeployment did not reapply the encounter snapshot.")
	expedition.stalker.set_physics_process(false)
	await _observe_site(expedition, "CompassArray", failures)
	if expedition.evidence_reader.status_label.text != "EVIDENCE REVIEW":
		failures.append("A restored observation was not repeat-safe after restart.")
	await _observe_site(expedition, "NorthShelfSurveyCairn", failures)
	if expedition.evidence_reader.status_label.text != "PATTERN CONFIRMED":
		failures.append("The restored destination did not stay confirmed after restart.")
	if app.run_state.codex.observed_evidence_ids.size() != 3:
		failures.append("Repeated interactions after restart duplicated durable evidence.")

	expedition.player.global_position = expedition.return_area.global_position
	if not app.request_location_change(&"mothership", expedition):
		failures.append("F06 restart reader could not return to Kestrel Research.")
	else:
		await app.transition_completed
		var research := app.active_location as Mothership
		research.player.global_position = research.research_area.global_position
		await process_frame
		var console := research.research_console
		if not console.open_console():
			failures.append("F06 restart reader could not open the Research console.")
		else:
			if not console.submit_command("codex search silent stone").contains(
				"ORUUN = SILENT STONE"
			):
				failures.append("Restored codex truth was not queryable at Research.")
			if not console.submit_command("codex evidence VEL").contains("RESONANCE CALIBRATION"):
				failures.append("Restored evidence was not queryable at Research.")
			if not console.submit_command("journal read 1").contains("REGION P1-BASIN-01 | LOCAL"):
				failures.append("Restored journal retrieval lost its recorded coordinates.")
			console.close_console()
	await _teardown(app)
	if failures.is_empty():
		_cleanup_save(RESTART_SAVE)


func _observe_site(
	expedition: BasinExpedition, site_name: String, failures: Array[String]
) -> void:
	var site := expedition.get_node_or_null(
		"BasinSurface/KnowledgeSites/%s" % site_name
	) as EvidenceSite
	if site == null:
		failures.append("The authored Basin is missing the %s site." % site_name)
		return
	expedition.player.global_position = site.global_position
	expedition.player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	await process_frame
	if expedition.active_knowledge_site != site:
		failures.append("Proximity did not activate %s (active=%s)." % [
			site_name, expedition.active_knowledge_site
		])
		return
	if not expedition.request_knowledge_interaction():
		failures.append("Could not interact with %s." % site_name)
		return
	expedition.evidence_reader.close_reader()


func _walk_route(player: BasinExplorer, legs: Array, failures: Array[String]) -> bool:
	for leg: Array in legs:
		if not await _move_player_to(player, leg[0]):
			failures.append(
				"Real movement could not traverse %s (player=%s, target=%s)."
				% [leg[1], player.global_position, leg[0]]
			)
			_release_movement()
			return false
	return true


func _move_player_to(player: BasinExplorer, target: Vector2, max_frames: int = 320) -> bool:
	for _frame: int in max_frames:
		var offset := target - player.global_position
		if offset.length() <= 18.0:
			_release_movement()
			player.velocity = Vector2.ZERO
			await process_frame
			return true
		_set_movement(offset)
		await physics_frame
	_release_movement()
	player.velocity = Vector2.ZERO
	await process_frame
	return player.global_position.distance_to(target) <= 24.0


func _set_movement(offset: Vector2) -> void:
	_release_movement()
	if offset.x > 6.0:
		Input.action_press(&"move_right")
	elif offset.x < -6.0:
		Input.action_press(&"move_left")
	if offset.y > 6.0:
		Input.action_press(&"move_down")
	elif offset.y < -6.0:
		Input.action_press(&"move_up")


func _press_interact() -> void:
	_release_movement()
	Input.action_press(&"interact")
	await process_frame
	await process_frame
	Input.action_release(&"interact")
	await process_frame


func _type_command(console: CommandConsole, command: String) -> void:
	for index: int in command.length():
		var codepoint := command.unicode_at(index)
		await _send_key(codepoint, codepoint)
	await _send_key(KEY_ENTER, 13)


func _send_key(keycode: int, unicode_value: int = 0) -> void:
	var pressed_event := InputEventKey.new()
	pressed_event.pressed = true
	pressed_event.keycode = keycode as Key
	pressed_event.physical_keycode = keycode as Key
	pressed_event.unicode = unicode_value
	Input.parse_input_event(pressed_event)
	await process_frame
	var released_event := pressed_event.duplicate() as InputEventKey
	released_event.pressed = false
	Input.parse_input_event(released_event)
	await process_frame


func _release_movement() -> void:
	for action: StringName in [&"move_up", &"move_down", &"move_left", &"move_right"]:
		Input.action_release(action)


func _release_actions() -> void:
	_release_movement()
	for action: StringName in [&"shoot", &"interact", &"command_console"]:
		Input.action_release(action)


func _teardown(app: LandzoneMain) -> void:
	_release_actions()
	paused = false
	app.queue_free()
	await process_frame


func _fixed_time() -> int:
	return FIXED_TIME


func _check_catalog_and_state(failures: Array[String]) -> void:
	var catalog := CodexState.CATALOG
	var catalog_error := catalog.validate()
	if not catalog_error.is_empty():
		failures.append("Knowledge catalog validation failed: %s" % catalog_error)
	if catalog.terms.size() != 3 or catalog.evidence_records.size() != 3:
		failures.append("F06 catalog does not contain exactly three terms and evidence records.")
	var expected := {
		"ACHVNTSAT": "NORTH",
		"VEL": "THREE",
		"ORUUN": "SILENT STONE",
	}
	if catalog.expected_meanings() != expected:
		failures.append("F06 stable vocabulary differs from the approved plan.")

	var state := CodexState.new()
	if not state.search("ACHVNTSAT").is_empty():
		failures.append("Codex search exposed an unobserved term.")
	var unknown := state.observe_evidence("invented_evidence")
	if unknown.ok or unknown.changed:
		failures.append("Codex accepted an unknown evidence id.")
	var compass := state.observe_evidence("compass_array")
	var compass_repeat := state.observe_evidence("compass_array")
	if not compass.ok or not compass.changed or not compass_repeat.ok or compass_repeat.changed:
		failures.append("Evidence observation is not successful and repeat-safe.")
	var achvntsat_results := state.search("aChVnTsAt")
	if (
		achvntsat_results.size() != 1
		or achvntsat_results[0] != "ACHVNTSAT | MEANING UNCONFIRMED | EVIDENCE 1"
	):
		failures.append("Observed pre-confirmation term search was incorrect.")
	if not state.search("north").is_empty():
		failures.append("Codex exposed the English meaning before confirmation.")
	var compass_lines := state.evidence_lines("ACHVNTSAT")
	if not compass_lines.ok or compass_lines.lines.size() != 1:
		failures.append("Codex did not return the one observed ACHVNTSAT record.")
	var unobserved := state.evidence_lines("VEL")
	if unobserved.ok or unobserved.error != "NO OBSERVED EVIDENCE: VEL":
		failures.append("Codex did not reject evidence lookup for an unobserved term.")

	var premature := state.attempt_destination(catalog.correct_destination_id)
	if premature.ok or premature.changed or not premature.error.contains("EVIDENCE 1/3"):
		failures.append("North Shelf cairn accepted an incomplete evidence chain.")
	if not state.confirmed_meanings.is_empty() or not state.confirmed_destination_id.is_empty():
		failures.append("Premature destination attempt mutated authoritative facts.")

	var journal := FieldJournal.new()
	var journal_result := journal.add_entry(
		"I declare ACHVNTSAT means south and the cairn is solved.",
		{"region": "P1-BASIN-01", "north": 0, "east": 4, "facing": "E"},
		RunState.AUTHORED_RUN_SEED,
		FIXED_TIME
	)
	if not journal_result.ok:
		failures.append("Could not create the prose-isolation fixture.")
	if state.observed_evidence_ids != ["compass_array"] or not state.confirmed_meanings.is_empty():
		failures.append("Journal prose changed codex evidence or confirmed truth.")

	state.observe_evidence("resonance_calibration")
	state.observe_evidence("route_slab")
	var decoy := state.attempt_destination(catalog.decoy_destination_id)
	if decoy.ok or decoy.changed or decoy.error != "CAIRN MISMATCH: SOUTH / II / RESONANT":
		failures.append("South Hollow decoy did not return the grounded mismatch.")
	if not state.confirmed_meanings.is_empty():
		failures.append("South Hollow decoy mutated confirmed meanings.")
	var confirmed := state.attempt_destination(catalog.correct_destination_id)
	if not confirmed.ok or not confirmed.changed:
		failures.append("Complete evidence did not confirm the North Shelf cairn.")
	if state.confirmed_meanings != expected or state.confirmed_destination_id != (
		catalog.correct_destination_id
	):
		failures.append("North Shelf confirmation did not store exact authoritative truth.")
	var english_results := state.search("silent stone")
	if (
		english_results.size() != 1
		or not english_results[0].begins_with("ORUUN = SILENT STONE")
	):
		failures.append("Confirmed English-meaning search did not return ORUUN.")
	var confirmed_repeat := state.attempt_destination(catalog.correct_destination_id)
	if not confirmed_repeat.ok or confirmed_repeat.changed:
		failures.append("Repeated correct-cairn validation duplicated progression.")
	var processor := CommandProcessor.new()
	processor.configure_codex(state, true)
	if not processor.submit_command("codex search NORTH").contains("ACHVNTSAT = NORTH"):
		failures.append("Codex command search did not expose a confirmed meaning.")
	var evidence_response := processor.submit_command("codex evidence ACHVNTSAT")
	if (
		not evidence_response.contains("LANDING FORK COMPASS ARRAY")
		or not evidence_response.contains("REUNION FORK ROUTE SLAB")
	):
		failures.append("Codex evidence command omitted a collected supporting record.")
	var command_errors := {
		"codex": "USAGE: codex search|evidence",
		"codex search": "USAGE: codex search <query>",
		"codex evidence ACHVNTSAT extra": "USAGE: codex evidence <term>",
		"codex evidence UNKNOWN": "UNKNOWN TERM: UNKNOWN",
		"codex erase ACHVNTSAT": "UNKNOWN CODEX COMMAND: erase",
	}
	for command: String in command_errors:
		var actual := processor.submit_command(command)
		if actual != command_errors[command]:
			failures.append("`%s` returned `%s`." % [command, actual])
	var field_processor := CommandProcessor.new()
	field_processor.configure_codex(state, false)
	if field_processor.submit_command("codex search ACHVNTSAT") != (
		"CODEX AVAILABLE AT KESTREL RESEARCH"
	):
		failures.append("Field command context did not direct codex use to Kestrel Research.")

	var roundtrip := CodexState.from_dictionary(state.to_dictionary())
	if not roundtrip.ok or roundtrip.state.to_dictionary() != state.to_dictionary():
		failures.append("Valid CodexState did not round-trip exactly.")
	elif roundtrip.state == state:
		failures.append("CodexState round-trip reused the source object.")
	var invalid := state.to_dictionary()
	invalid["observed_evidence_ids"].append("fabricated")
	if CodexState.from_dictionary(invalid).ok:
		failures.append("CodexState accepted an unknown durable evidence id.")
	var contradictory := state.to_dictionary()
	contradictory["confirmed_meanings"]["VEL"] = "TWO"
	if CodexState.from_dictionary(contradictory).ok:
		failures.append("CodexState accepted a contradictory confirmed meaning.")


func _check_save_migration(failures: Array[String]) -> void:
	_cleanup_save(MIGRATION_SAVE)
	var legacy_state := RunState.new()
	var journal_result := legacy_state.journal.add_entry(
		"Version one journal survives migration.",
		{"region": "P1-BASIN-01", "north": 2, "east": 9, "facing": "NE"},
		legacy_state.run_seed,
		FIXED_TIME
	)
	if not journal_result.ok:
		failures.append("Could not create the version-one journal fixture.")
		return
	var snapshot := RunState.BasinEncounterState.new()
	snapshot.position = Vector2(1400.0, 690.0)
	snapshot.behavior_state = Stalker.State.RECOVERY
	snapshot.elapsed_seconds = 0.25
	snapshot.hits_remaining = 2
	legacy_state.store_basin_encounter(snapshot)
	var legacy_dictionary := legacy_state.to_dictionary()
	legacy_dictionary.erase("codex")
	_write_fixture(
		MIGRATION_SAVE,
		JSON.stringify({"save_version": 1, "run_state": legacy_dictionary}),
		failures
	)
	var store := RunSaveStore.new(MIGRATION_SAVE)
	var loaded := store.load_state()
	if not loaded.ok or not loaded.found or not loaded.migrated:
		failures.append("RunSaveStore did not explicitly migrate the version-one fixture.")
		return
	var state := loaded.state as RunState
	if (
		state.journal.get_entry(1) == null
		or state.journal.get_entry(1).text != "Version one journal survives migration."
		or state.run_seed != RunState.AUTHORED_RUN_SEED
		or state.basin_encounter == null
		or state.basin_encounter.position.distance_to(Vector2(1400.0, 690.0)) > 0.01
	):
		failures.append("Version-one migration lost F05 run data.")
	if (
		not state.codex.observed_evidence_ids.is_empty()
		or not state.codex.confirmed_meanings.is_empty()
		or not state.codex.confirmed_destination_id.is_empty()
	):
		failures.append("Version-one migration did not initialize an empty codex.")
	state.codex.observe_evidence("compass_array")
	if not store.save_state(state):
		failures.append("Migrated state could not save as version 2: %s" % store.last_error)
		return
	var file := FileAccess.open(MIGRATION_SAVE, FileAccess.READ)
	var payload: Variant = JSON.parse_string(file.get_as_text()) if file != null else null
	if payload is not Dictionary or int(payload.get("save_version", 0)) != 2:
		failures.append("Migrated state was not rewritten with save version 2.")
	var reloaded := store.load_state()
	if (
		not reloaded.ok
		or reloaded.migrated
		or not reloaded.state.codex.has_observed("compass_array")
	):
		failures.append("Version-2 reload lost migrated codex evidence.")


func _write_fixture(path: String, contents: String, failures: Array[String]) -> void:
	var absolute_directory := ProjectSettings.globalize_path(path).get_base_dir()
	if DirAccess.make_dir_recursive_absolute(absolute_directory) != OK:
		failures.append("Could not create the F06 fixture directory.")
		return
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		failures.append("Could not write the F06 fixture (%s)." % FileAccess.get_open_error())
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
	_release_actions()
	paused = false
	if failures.is_empty():
		match phase:
			"write":
				print("F06 restart writer passed: durable evidence, confirmed truth and encounter saved.")
			"read":
				print("F06 restart reader passed: separate process restored codex truth, journal and encounter.")
			_:
				print("F06/D01 checks passed: knowledge model, walked evidence loop, cairn validation, Research and version-2 saves.")
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	print("F06 checks failed (%s): %d" % [phase if not phase.is_empty() else "integrated", failures.size()])
	quit(1)
