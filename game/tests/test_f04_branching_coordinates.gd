extends SceneTree

const MAIN_SCENE_PATH := "res://main.tscn"
const POSITION_EPSILON := 2.0
const TIMER_EPSILON := 0.02


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures: Array[String] = []
	_check_coordinate_service(failures)
	var app := await _create_basin_app(failures)
	if app == null:
		_finish(failures)
		return

	var expedition := app.active_location as BasinExpedition
	_check_topology(expedition, failures)
	await _check_route_traversal(expedition, failures)
	await _check_command_console(expedition, failures)
	await _check_retry_and_transfer_lifecycle(app, expedition, failures)

	_release_actions()
	paused = false
	app.queue_free()
	await process_frame
	_finish(failures)


func _create_basin_app(failures: Array[String]) -> LandzoneMain:
	var main_scene := load(MAIN_SCENE_PATH) as PackedScene
	if main_scene == null:
		failures.append("F04 could not load the main scene.")
		return null
	var app := main_scene.instantiate() as LandzoneMain
	app.persistence_enabled = false
	root.add_child(app)
	await process_frame
	var mothership := app.active_location as Mothership
	if mothership == null or not app.request_location_change(&"basin", mothership):
		failures.append("F04 could not deploy from Kestrel to the authored Basin.")
		app.queue_free()
		await process_frame
		return null
	await create_timer(app.transition_delay_seconds + 0.1).timeout
	await process_frame
	if app.active_location is not BasinExpedition:
		failures.append("F04 deployment did not activate BasinExpedition.")
		app.queue_free()
		await process_frame
		return null
	return app


func _check_coordinate_service(failures: Array[String]) -> void:
	var service := CoordinateService.new(&"P1-BASIN-01", Vector2(480.0, 450.0), 80.0)
	var cases := {
		"origin": [Vector2(480.0, 450.0), Vector2.RIGHT, "REGION P1-BASIN-01 | LOCAL N00 E00 | FACING E"],
		"north_east": [Vector2(1200.0, 130.0), Vector2(1.0, -1.0), "REGION P1-BASIN-01 | LOCAL N04 E09 | FACING NE"],
		"south_west": [Vector2(320.0, 690.0), Vector2(-1.0, 1.0), "REGION P1-BASIN-01 | LOCAL S03 W02 | FACING SW"],
		"round_down": [Vector2(519.0, 450.0), Vector2.UP, "REGION P1-BASIN-01 | LOCAL N00 E00 | FACING N"],
		"round_up": [Vector2(521.0, 450.0), Vector2.DOWN, "REGION P1-BASIN-01 | LOCAL N00 E01 | FACING S"],
	}
	for case_name: String in cases:
		var values: Array = cases[case_name]
		var actual := service.format_where(values[0], values[1])
		if actual != values[2]:
			failures.append("Coordinate case %s returned '%s'." % [case_name, actual])

	var facing_cases := {
		Vector2.UP: "N",
		Vector2(1.0, -1.0): "NE",
		Vector2.RIGHT: "E",
		Vector2(1.0, 1.0): "SE",
		Vector2.DOWN: "S",
		Vector2(-1.0, 1.0): "SW",
		Vector2.LEFT: "W",
		Vector2(-1.0, -1.0): "NW",
	}
	for direction: Vector2 in facing_cases:
		if service.format_facing(direction) != facing_cases[direction]:
			failures.append("Facing %s did not quantize to %s." % [direction, facing_cases[direction]])


func _check_topology(expedition: BasinExpedition, failures: Array[String]) -> void:
	var route_segments := expedition.get_tree().get_nodes_in_group(&"route_segment")
	var route_junctions := expedition.get_tree().get_nodes_in_group(&"route_junction")
	var route_endpoints := expedition.get_tree().get_nodes_in_group(&"route_endpoint")
	if route_segments.size() != 6:
		failures.append("Expected six authored route segments, found %d." % route_segments.size())
	if route_junctions.size() != 3:
		failures.append("Expected three authored route junctions, found %d." % route_junctions.size())
	if route_endpoints.size() != 2:
		failures.append("Expected two surveyed route limits, found %d." % route_endpoints.size())
	for node_path: String in [
		"BasinSurface/RouteTopology/LandingFork",
		"BasinSurface/RouteTopology/ReunionFork",
		"BasinSurface/RouteTopology/FarFork",
		"BasinSurface/RouteTopology/NorthShelfLimit",
		"BasinSurface/RouteTopology/SouthHollowLimit",
	]:
		if expedition.get_node_or_null(node_path) == null:
			failures.append("Missing authored topology marker %s." % node_path)
	for boundary: Node in expedition.get_tree().get_nodes_in_group(&"path_boundary"):
		var body := boundary as StaticBody2D
		if body == null or body.collision_layer != 2 or body.collision_mask != 1:
			failures.append("Expanded Basin has a non-solid or misconfigured path boundary.")
			break


func _check_route_traversal(expedition: BasinExpedition, failures: Array[String]) -> void:
	var player := expedition.player
	var original_speed := player.movement_speed
	player.movement_speed = 620.0
	player.death_enabled = false
	expedition.lethal_hazard.set_deferred(&"monitoring", false)
	expedition.stalker.set_physics_process(false)
	await physics_frame

	var landing_fork := _marker(expedition, "LandingFork")
	var reunion_fork := _marker(expedition, "ReunionFork")
	var far_fork := _marker(expedition, "FarFork")
	var north_limit := _marker(expedition, "NorthShelfLimit")
	var south_limit := _marker(expedition, "SouthHollowLimit")
	var route_checks := [
		[landing_fork.global_position, "Landing Run"],
		[Vector2(1080.0, 210.0), "North Arc entry"],
		[Vector2(1400.0, 210.0), "North Arc shelf"],
		[reunion_fork.global_position, "North Arc reunion"],
		[Vector2(1400.0, 690.0), "South Arc return"],
		[Vector2(1080.0, 690.0), "South Arc shelf"],
		[landing_fork.global_position, "South Arc landing return"],
		[Vector2(1080.0, 690.0), "South Arc entry"],
		[Vector2(1400.0, 690.0), "South Arc outbound"],
		[reunion_fork.global_position, "South Arc reunion"],
		[far_fork.global_position, "East Approach"],
		[Vector2(2190.0, 210.0), "North Shelf branch"],
		[north_limit.global_position, "North Shelf limit"],
	]
	for check: Array in route_checks:
		if not await _move_player_to(player, check[0]):
			failures.append("Real movement could not traverse %s (player=%s, target=%s)." % [check[1], player.global_position, check[0]])
			break

	var north_limit_start_x := player.global_position.x
	await _hold_action(&"move_right", 80)
	if player.global_position.x > 2390.0 or player.global_position.x <= north_limit_start_x:
		failures.append("North Shelf survey limit did not lead to and stop at the solid world cap.")
	if not await _move_player_to(player, north_limit.global_position):
		failures.append("Player could not return from the North Shelf cap.")
	for check: Array in [
		[Vector2(2190.0, 210.0), "North Shelf return"],
		[far_fork.global_position, "Far Fork return"],
		[Vector2(2190.0, 690.0), "South Hollow branch"],
		[south_limit.global_position, "South Hollow limit"],
	]:
		if not await _move_player_to(player, check[0]):
			failures.append("Real movement could not traverse %s." % check[1])
			break
	await _hold_action(&"move_right", 80)
	if player.global_position.x > 2390.0:
		failures.append("South Hollow survey limit allowed movement outside the Basin bounds.")

	player.global_position = Vector2(1350.0, 620.0)
	player.velocity = Vector2.ZERO
	await _hold_action(&"move_up", 50)
	if player.global_position.y < 580.0:
		failures.append("Player crossed the solid loop island instead of using either loop arc.")

	_release_actions()
	player.movement_speed = original_speed
	player.death_enabled = true
	expedition.lethal_hazard.set_deferred(&"monitoring", true)
	expedition.stalker.reset_encounter(expedition.stalker_spawn.global_position)
	expedition.stalker.set_physics_process(true)
	player.respawn_at(expedition.shuttle_spawn.global_position)
	await physics_frame


func _check_command_console(expedition: BasinExpedition, failures: Array[String]) -> void:
	var player := expedition.player
	var console := expedition.command_console
	player.global_position = Vector2(1200.0, 130.0)
	player.update_aim_direction(player.global_position + Vector2(100.0, -100.0))
	var retained_facing := player.facing_direction
	player.update_aim_direction(player.global_position)
	if not player.facing_direction.is_equal_approx(retained_facing):
		failures.append("Zero-length aim erased the last readable facing.")

	await _send_key(KEY_TAB, 9)
	await process_frame
	if not console.is_console_open() or not paused:
		failures.append("Physical Tab did not open the command console and pause gameplay.")
	if console.command_input.get_viewport().gui_get_focus_owner() != console.command_input:
		failures.append("Opening the command console did not focus its LineEdit.")
	# Fix the visible weapon orientation after pausing so the headless mouse cannot move it again.
	player.update_aim_direction(player.global_position + Vector2(100.0, -100.0))

	for character: String in ["w", "h", "e", "r", "e"]:
		await _send_character(character)
	await _send_key(KEY_ENTER, 13)
	var expected_where := "REGION P1-BASIN-01 | LOCAL N04 E09 | FACING NE"
	if console.response_label.text != expected_where:
		failures.append("Typed `where` returned '%s'." % console.response_label.text)
	if console.submit_command("where extra") != "USAGE: where":
		failures.append("`where` arguments did not return the bounded usage error.")
	if console.submit_command("  WhErE  ") != expected_where:
		failures.append("`where` matching was not trimmed and case-insensitive.")
	if console.submit_command("dance now") != "UNKNOWN COMMAND: dance":
		failures.append("Unknown command did not identify its normalized verb.")
	if console.submit_command("   ") != "ENTER A COMMAND":
		failures.append("Empty command did not return its specific feedback.")
	if console.open_console():
		failures.append("An already open command console accepted a duplicate open.")
	player.global_position = expedition.shuttle_spawn.global_position
	if expedition.request_mothership_return():
		failures.append("Paused command mode allowed an otherwise valid shuttle return.")

	player.global_position = Vector2(600.0, 450.0)
	player.update_aim_direction(player.global_position + Vector2.RIGHT * 100.0)
	player.shot_recovery_seconds = 1.0
	if not player.try_shoot() or expedition.projectiles.get_child_count() != 1:
		failures.append("Pause fixture could not create one live pulse and weapon recovery.")
	var pulse := expedition.projectiles.get_child(0) as BasePulse
	var pulse_position := pulse.global_position
	var pulse_elapsed := pulse.elapsed_seconds
	var recovery_left := player.shot_recovery_timer.time_left
	expedition.stalker.current_state = Stalker.State.TELEGRAPH
	expedition.stalker.state_elapsed_seconds = 0.2
	var stalker_elapsed := expedition.stalker.state_elapsed_seconds
	var player_position := player.global_position
	Input.action_press(&"move_right")
	Input.action_press(&"shoot")
	await create_timer(0.3, true).timeout
	Input.action_release(&"move_right")
	Input.action_release(&"shoot")
	if not player.global_position.is_equal_approx(player_position):
		failures.append("Player moved while the command console paused gameplay.")
	if not pulse.global_position.is_equal_approx(pulse_position) or absf(pulse.elapsed_seconds - pulse_elapsed) > TIMER_EPSILON:
		failures.append("A Base pulse advanced while the command console was open.")
	if absf(player.shot_recovery_timer.time_left - recovery_left) > TIMER_EPSILON:
		failures.append("Weapon recovery advanced during paused planning.")
	if absf(expedition.stalker.state_elapsed_seconds - stalker_elapsed) > TIMER_EPSILON:
		failures.append("Stalker behavior advanced during paused planning.")

	await _send_key(KEY_ESCAPE)
	await process_frame
	if console.is_console_open() or paused:
		failures.append("Escape did not close the console and restore gameplay processing.")
	await physics_frame
	await physics_frame
	if pulse.is_inside_tree() and pulse.elapsed_seconds <= pulse_elapsed:
		failures.append("Base pulse did not resume after command mode closed.")
	if player.shot_recovery_timer.time_left >= recovery_left:
		failures.append("Weapon recovery did not resume after command mode closed.")
	var resumed_position := player.global_position
	await _hold_action(&"move_right", 3)
	if player.global_position.x <= resumed_position.x:
		failures.append("Direct movement did not resume after command mode closed.")
	player.shot_recovery_timer.stop()
	if not player.try_shoot():
		failures.append("Direct firing did not resume after command mode closed.")
	expedition.clear_active_pulses()
	player.shot_recovery_timer.stop()
	expedition.stalker.reset_encounter(expedition.stalker_spawn.global_position)
	player.respawn_at(expedition.shuttle_spawn.global_position)


func _check_retry_and_transfer_lifecycle(
	app: LandzoneMain,
	expedition: BasinExpedition,
	failures: Array[String]
) -> void:
	if not expedition.request_retry():
		failures.append("F04 lifecycle fixture could not begin a loaded retry.")
	else:
		if expedition.command_console.open_console():
			failures.append("Command console opened during a loaded retry.")
		await create_timer(expedition.retry_delay_seconds + 0.1).timeout
		if paused or expedition.retry_in_progress:
			failures.append("Loaded retry completed with a leaked pause or retry guard.")

	expedition.stalker.set_physics_process(false)
	expedition.stalker.global_position = Vector2(1400.0, 690.0)
	var preserved_position := expedition.stalker.global_position
	expedition.player.global_position = expedition.shuttle_spawn.global_position
	expedition.player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	if not app.request_location_change(&"mothership", expedition):
		failures.append("F04 lifecycle fixture could not begin the Basin return transfer.")
		return
	if expedition.command_console.open_console():
		failures.append("Command console opened during a location transfer.")
	await app.transition_completed
	if paused or app.active_location is not Mothership:
		failures.append("Returning to Kestrel leaked pause state or the exterior location.")
		return

	var mothership := app.active_location as Mothership
	mothership.player.global_position = mothership.deploy_area.global_position
	await physics_frame
	await physics_frame
	if not app.request_location_change(&"basin", mothership):
		failures.append("F04 lifecycle fixture could not redeploy after return.")
		return
	await app.transition_completed
	var restored := app.active_location as BasinExpedition
	if restored == null:
		failures.append("F04 lifecycle fixture did not recreate BasinExpedition.")
		return
	if not restored.stalker.global_position.is_equal_approx(preserved_position):
		failures.append("Expanded Basin revisit clamped the Stalker back to the old corridor.")
	if paused or restored.command_console.is_console_open():
		failures.append("Redeployment began with a leaked command pause or open console.")
	if not restored.command_console.open_console():
		failures.append("Fresh redeployment did not restore command-console availability.")
	else:
		await _send_key(KEY_TAB, 9)
		if restored.command_console.is_console_open() or paused:
			failures.append("Physical Tab did not close the command console after redeployment.")


func _marker(expedition: BasinExpedition, marker_name: String) -> Marker2D:
	return expedition.get_node("BasinSurface/RouteTopology/%s" % marker_name) as Marker2D


func _move_player_to(player: BasinExplorer, target: Vector2, max_frames: int = 260) -> bool:
	for _frame: int in max_frames:
		var offset := target - player.global_position
		if offset.length() <= 18.0:
			_release_movement()
			player.velocity = Vector2.ZERO
			return true
		_set_movement(offset)
		await physics_frame
	_release_movement()
	player.velocity = Vector2.ZERO
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


func _hold_action(action: StringName, frame_count: int) -> void:
	_release_movement()
	Input.action_press(action)
	for _frame: int in frame_count:
		await physics_frame
	Input.action_release(action)


func _send_character(character: String) -> void:
	var codepoint := character.unicode_at(0)
	await _send_key(codepoint, codepoint)


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


func _finish(failures: Array[String]) -> void:
	_release_actions()
	paused = false
	if failures.is_empty():
		print("F04/D01 checks passed: branching route, coordinates, paused where console, and lifecycle safety.")
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	print("F04/D01 checks failed: %d" % failures.size())
	quit(1)
