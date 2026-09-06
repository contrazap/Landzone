extends SceneTree

const MAIN_SCENE_PATH := "res://main.tscn"
const EPSILON := 0.01


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures: Array[String] = []
	_check_interact_binding(failures)

	var main_scene := load(MAIN_SCENE_PATH) as PackedScene
	if main_scene == null:
		failures.append("Main scene could not be loaded.")
		_finish(failures)
		return

	var app := main_scene.instantiate() as LandzoneMain
	root.add_child(app)
	await process_frame
	await physics_frame

	if absf(app.transition_delay_seconds - 0.25) > EPSILON:
		failures.append("Static transfer delay is not the planned 0.25 seconds.")
	var mothership := app.active_location as Mothership
	await _check_initial_mothership(app, mothership, failures)
	if mothership == null:
		app.queue_free()
		await process_frame
		_finish(failures)
		return

	var player := mothership.player
	player.global_position = Vector2(360.0, 180.0)
	await physics_frame
	await _press_interact()
	if app.transition_in_progress or app.current_location != &"mothership":
		failures.append("Interact away from the bridge console started a deployment.")

	player.global_position = mothership.deploy_area.global_position
	await physics_frame
	await process_frame
	if not mothership.player_in_deploy_range or not mothership.deploy_prompt.visible:
		failures.append("Bridge proximity did not expose the deployment prompt.")
	var original_mothership_id := mothership.get_instance_id()
	await _press_interact()
	if not app.transition_in_progress or app.pending_location != &"basin":
		failures.append("Physical interact at the bridge did not begin one Basin deployment.")
	if not app.transition_overlay.visible:
		failures.append("Deployment did not show static transfer feedback.")
	if app.request_location_change(&"basin", mothership):
		failures.append("A repeated deployment request was accepted during transition.")
	await _press_interact()
	if app.transition_in_progress:
		await app.transition_completed

	var expedition := app.active_location as BasinExpedition
	await process_frame
	_check_deployed_basin(app, expedition, original_mothership_id, failures)
	if expedition == null:
		app.queue_free()
		await process_frame
		_finish(failures)
		return
	await _check_basin_camera_tracking(expedition, failures)

	# Preserve a damaged Stalker in a committed phase with a nonzero locked direction.
	expedition.stalker.set_physics_process(false)
	expedition.stalker.global_position = expedition.player.global_position + Vector2(100.0, 0.0)
	if not expedition.stalker.begin_telegraph(expedition.player):
		failures.append("Could not establish the Stalker preservation fixture.")
	expedition.stalker.advance_state(expedition.stalker.telegraph_duration)
	expedition.stalker.advance_state(0.21)
	expedition.stalker.global_position = Vector2(1480.0, 472.0)
	expedition.stalker.receive_pulse_hit()
	expedition.player.update_aim_direction(expedition.player.global_position + Vector2.RIGHT * 100.0)
	if not expedition.player.try_shoot():
		failures.append("Could not establish transient weapon/pulse state before return.")
	var first_expedition_id := expedition.get_instance_id()
	var first_player_id := expedition.player.get_instance_id()
	var first_stalker_id := expedition.stalker.get_instance_id()

	await _return_to_mothership(app, expedition, failures)
	if not app.run_state.has_basin_encounter():
		failures.append("Normal return did not store a Basin encounter snapshot.")
		app.queue_free()
		await process_frame
		_finish(failures)
		return
	var saved_committed := app.run_state.basin_encounter.duplicate_state()
	if (
		saved_committed.behavior_state != Stalker.State.COMMITTED
		or saved_committed.hits_remaining != 2
		or saved_committed.committed_direction.is_zero_approx()
	):
		failures.append("Normal return did not preserve Stalker phase and damage.")
	await create_timer(0.2).timeout
	if not _snapshots_equal(saved_committed, app.run_state.basin_encounter):
		failures.append("Stalker encounter advanced while unloaded aboard Kestrel.")

	expedition = await _deploy_current_mothership(app, failures)
	if expedition != null:
		_check_restored_expedition(
			expedition,
			saved_committed,
			first_expedition_id,
			first_player_id,
			first_stalker_id,
			failures
		)
	else:
		app.queue_free()
		await process_frame
		_finish(failures)
		return

	# A defeated enemy remains defeated through a second normal visit.
	while expedition.stalker.current_state != Stalker.State.DEFEATED:
		expedition.stalker.receive_pulse_hit()
	await process_frame
	var defeated_position := Vector2(1540.0, 510.0)
	expedition.stalker.global_position = defeated_position
	var defeated_expedition_id := expedition.get_instance_id()
	await _return_to_mothership(app, expedition, failures)
	var saved_defeated := app.run_state.basin_encounter.duplicate_state()
	expedition = await _deploy_current_mothership(app, failures)
	if expedition == null:
		app.queue_free()
		await process_frame
		_finish(failures)
		return
	if expedition.get_instance_id() == defeated_expedition_id:
		failures.append("Second normal revisit reused the unloaded Basin scene.")
	if (
		expedition.stalker.current_state != Stalker.State.DEFEATED
		or expedition.stalker.hits_remaining != 0
		or not expedition.stalker.global_position.is_equal_approx(defeated_position)
		or expedition.stalker.attack_active
	):
		failures.append("Defeated Stalker state did not survive normal return/redeployment.")
	if not (expedition.stalker.get_node("DefeatedMark") as Line2D).visible:
		failures.append("Restored defeated Stalker lacks its defeated presentation.")
	if not _snapshots_equal(saved_defeated, app.run_state.basin_encounter):
		failures.append("Stored defeated snapshot changed during redeployment.")

	# A third normal visit proves repeatability, then death proves the distinct loaded retry path.
	await _return_to_mothership(app, expedition, failures)
	expedition = await _deploy_current_mothership(app, failures)
	if expedition == null:
		app.queue_free()
		await process_frame
		_finish(failures)
		return
	var retry_expedition_id := expedition.get_instance_id()
	var retry_player_id := expedition.player.get_instance_id()
	var retry_stalker_id := expedition.stalker.get_instance_id()
	var retry_started_events: Array[bool] = []
	var retry_completed_events: Array[bool] = []
	expedition.retry_started.connect(func() -> void: retry_started_events.append(true))
	expedition.retry_completed.connect(func() -> void: retry_completed_events.append(true))
	expedition.player.global_position = expedition.get_node("BasinSurface/SafePassage").global_position
	expedition.player.velocity = Vector2.ZERO
	Input.action_press(&"move_up")
	for _frame: int in 45:
		await physics_frame
		if not expedition.player.is_alive:
			break
	Input.action_release(&"move_up")
	if retry_started_events.size() != 1 or not expedition.retry_in_progress:
		failures.append(
			"Movement into the real hazard after revisiting did not begin one loaded retry: %s"
			% [[
				retry_started_events.size(),
				expedition.player.is_alive,
				expedition.lethal_hazard.get_overlapping_bodies().size(),
				expedition.player.is_physics_processing(),
				expedition.player.global_position,
				expedition.lethal_hazard.global_position,
				expedition.lethal_hazard.monitoring,
				expedition.player.collision_layer,
				expedition.lethal_hazard.collision_mask,
				(expedition.player.get_node("CollisionShape2D") as CollisionShape2D).disabled,
				expedition.player.death_enabled,
			]]
		)
	if expedition.request_mothership_return() or app.transition_in_progress:
		failures.append("Retry in progress allowed a shuttle return.")
	if expedition.player.die() or expedition.request_retry():
		failures.append("Loaded retry accepted a duplicate death or retry request.")
	await create_timer(expedition.retry_delay_seconds + 0.15).timeout
	_check_loaded_retry(
		app,
		expedition,
		retry_expedition_id,
		retry_player_id,
		retry_stalker_id,
		retry_started_events.size(),
		retry_completed_events.size(),
		failures
	)

	# Exercise actual committed-hit contact after the revisit and confirm the same contract again.
	expedition.player.set_process(false)
	expedition.player.set_physics_process(false)
	expedition.stalker.set_physics_process(false)
	expedition.player.global_position = expedition.stalker.global_position + Vector2(85.0, 0.0)
	if not expedition.stalker.begin_telegraph(expedition.player):
		failures.append("Reset Stalker could not begin the post-revisit committed attack.")
	else:
		expedition.stalker.advance_state(expedition.stalker.telegraph_duration)
		expedition.stalker.set_physics_process(true)
		for _frame: int in 45:
			await physics_frame
			if not expedition.player.is_alive:
				break
		await process_frame
		if expedition.player.is_alive or retry_started_events.size() != 2:
			failures.append("Committed Stalker contact after revisiting was not lethal.")
		else:
			await create_timer(expedition.retry_delay_seconds + 0.15).timeout
			_check_loaded_retry(
				app,
				expedition,
				retry_expedition_id,
				retry_player_id,
				retry_stalker_id,
				retry_started_events.size(),
				retry_completed_events.size(),
				failures
			)

	_release_inputs()
	app.queue_free()
	await process_frame
	_finish(failures)


func _check_initial_mothership(
	app: LandzoneMain,
	mothership: Mothership,
	failures: Array[String]
) -> void:
	if app.current_location != &"mothership" or mothership == null:
		failures.append("A new session did not start aboard Kestrel.")
		return
	if app.get_tree().get_nodes_in_group(&"player").size() != 1:
		failures.append("Kestrel did not contain exactly one player.")
	if not mothership.player.global_position.is_equal_approx(mothership.arrival_marker.global_position):
		failures.append("Player did not start at Kestrel's vehicle-bay arrival marker.")
	if mothership.player.weapon_enabled or mothership.player.surveyor_weapon.visible:
		failures.append("Surveyor weapon was not holstered aboard Kestrel.")
	if mothership.player.try_shoot():
		failures.append("Kestrel allowed firing while the Surveyor was holstered.")
	if app.get_tree().get_nodes_in_group(&"mothership_boundary").size() != 4:
		failures.append("Kestrel is missing its four solid outer boundaries.")
	if app.get_tree().get_nodes_in_group(&"sealed_station_boundary").size() != 1:
		failures.append("Later Kestrel stations are not physically sealed.")
	for station_name: String in ["Research", "Galley", "Medical", "Habitat", "Workshop"]:
		var label := mothership.get_node_or_null("StationLabels/%s" % station_name) as Label
		if label == null or "SEALED" not in label.text:
			failures.append("Kestrel is missing the sealed %s station label." % station_name)
	var start_x := mothership.player.global_position.x
	Input.action_press(&"move_right")
	for _frame: int in 8:
		await physics_frame
	Input.action_release(&"move_right")
	if mothership.player.global_position.x <= start_x:
		failures.append("Player could not move through Kestrel's accessible deck.")
	mothership.player.global_position = Vector2(30.0, 220.0)
	Input.action_press(&"move_left")
	for _frame: int in 12:
		await physics_frame
	Input.action_release(&"move_left")
	if mothership.player.global_position.x < 30.0 - EPSILON:
		failures.append("Player passed through Kestrel's solid outer hull.")

	# Follow the accessible aisle from the arrival bay to the bridge using real movement input.
	mothership.player.global_position = mothership.arrival_marker.global_position
	Input.action_press(&"move_right")
	for _frame: int in 66:
		await physics_frame
	Input.action_release(&"move_right")
	Input.action_press(&"move_up")
	for _frame: int in 74:
		await physics_frame
	Input.action_release(&"move_up")
	Input.action_press(&"move_right")
	for _frame: int in 66:
		await physics_frame
	Input.action_release(&"move_right")
	await process_frame
	if not mothership.player_in_deploy_range or not mothership.deploy_prompt.visible:
		failures.append(
			"The accessible Kestrel aisle did not lead from vehicle bay to bridge console "
			+ "(player=%s, console_area=%s)."
			% [mothership.player.global_position, mothership.deploy_area.global_position]
		)


func _check_deployed_basin(
	app: LandzoneMain,
	expedition: BasinExpedition,
	original_mothership_id: int,
	failures: Array[String]
) -> void:
	if app.current_location != &"basin" or expedition == null:
		failures.append("Deployment did not activate the Basin expedition.")
		return
	if is_instance_id_valid(original_mothership_id):
		failures.append("Deployment did not free the previous Kestrel instance.")
	if app.get_tree().get_nodes_in_group(&"player").size() != 1:
		failures.append("Deployment did not retain exactly one player.")
	if not expedition.player.global_position.is_equal_approx(expedition.shuttle_spawn.global_position):
		failures.append("Deployment did not place the player at the exact shuttle marker.")
	if not expedition.player.weapon_enabled or not expedition.player.surveyor_weapon.visible:
		failures.append("Deployment did not restore the Surveyor weapon.")
	var camera := expedition.player.get_node("Camera2D") as Camera2D
	if camera.limit_right != 2160:
		failures.append("Deployment did not restore Basin camera bounds.")
	if expedition.get_viewport().get_camera_2d() != camera:
		failures.append("The deployed player's Camera2D is not the viewport's active camera.")
	var spawn_screen_position := (
		expedition.get_viewport().get_canvas_transform() * expedition.player.global_position
	)
	var viewport_center := Vector2(480.0, 270.0)
	if spawn_screen_position.distance_to(viewport_center) > 2.0:
		failures.append(
			"Basin camera did not snap to the player immediately after deployment "
			+ "(screen=%s, expected=%s)." % [spawn_screen_position, viewport_center]
		)


func _check_basin_camera_tracking(
	expedition: BasinExpedition,
	failures: Array[String]
) -> void:
	var camera := expedition.player.get_node("Camera2D") as Camera2D
	expedition.player.global_position = Vector2(600.0, 535.0)
	expedition.player.velocity = Vector2.ZERO
	await process_frame
	await physics_frame
	var starting_camera_x := camera.get_screen_center_position().x
	Input.action_press(&"move_right")
	for _frame: int in 150:
		await physics_frame
	Input.action_release(&"move_right")
	await process_frame
	var ending_camera_x := camera.get_screen_center_position().x
	var player_screen_position := (
		expedition.get_viewport().get_canvas_transform() * expedition.player.global_position
	)
	if expedition.player.global_position.x < 1000.0:
		failures.append("Basin camera fixture did not move the player far enough across the route.")
	if ending_camera_x <= starting_camera_x + 100.0:
		failures.append(
			"Active Basin camera did not follow horizontal player movement "
			+ "(start=%.2f, end=%.2f)." % [starting_camera_x, ending_camera_x]
		)
	var safe_screen_rect := Rect2(24.0, 24.0, 912.0, 492.0)
	if not safe_screen_rect.has_point(player_screen_position):
		failures.append(
			"Moving Basin player left the viewport safe margin despite the active camera "
			+ "(screen=%s, world=%s)."
			% [player_screen_position, expedition.player.global_position]
		)
	expedition.player.global_position = expedition.shuttle_spawn.global_position
	expedition.player.velocity = Vector2.ZERO


func _return_to_mothership(
	app: LandzoneMain,
	expedition: BasinExpedition,
	failures: Array[String]
) -> void:
	expedition.player.global_position = expedition.shuttle_spawn.global_position
	expedition.player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	if not expedition.player_in_return_range or not expedition.return_prompt.visible:
		failures.append("Shuttle proximity did not expose the Kestrel return prompt.")
	await _press_interact()
	if not app.transition_in_progress or app.pending_location != &"mothership":
		failures.append("Physical interact near the shuttle did not begin return to Kestrel.")
	if expedition.request_retry() or expedition.player.die():
		failures.append("Active return transition accepted death or retry.")
	if app.request_location_change(&"mothership", expedition):
		failures.append("Active return transition accepted a duplicate location request.")
	if app.transition_in_progress:
		await app.transition_completed
	if app.current_location != &"mothership" or app.active_location is not Mothership:
		failures.append("Return transition did not activate a new Kestrel instance.")
	if app.get_tree().get_nodes_in_group(&"player").size() != 1:
		failures.append("Return transition did not retain exactly one player.")


func _deploy_current_mothership(
	app: LandzoneMain,
	failures: Array[String]
) -> BasinExpedition:
	var mothership := app.active_location as Mothership
	if mothership == null:
		failures.append("Expected Kestrel before redeployment.")
		return null
	mothership.player.global_position = mothership.deploy_area.global_position
	await physics_frame
	await physics_frame
	await _press_interact()
	if app.transition_in_progress:
		await app.transition_completed
	var expedition := app.active_location as BasinExpedition
	if expedition == null:
		failures.append("Redeployment did not activate a new Basin expedition.")
	return expedition


func _check_restored_expedition(
	expedition: BasinExpedition,
	snapshot: RunState.BasinEncounterState,
	previous_expedition_id: int,
	previous_player_id: int,
	previous_stalker_id: int,
	failures: Array[String]
) -> void:
	if (
		expedition.get_instance_id() == previous_expedition_id
		or expedition.player.get_instance_id() == previous_player_id
		or expedition.stalker.get_instance_id() == previous_stalker_id
	):
		failures.append("Normal revisit reused an unloaded Basin, player, or Stalker instance.")
	if not expedition.stalker.global_position.is_equal_approx(snapshot.position):
		failures.append("Redeployment did not restore the Stalker position.")
	if (
		expedition.stalker.current_state != snapshot.behavior_state
		or absf(expedition.stalker.state_elapsed_seconds - snapshot.elapsed_seconds) > EPSILON
		or expedition.stalker.hits_remaining != snapshot.hits_remaining
		or not expedition.stalker.committed_direction.is_equal_approx(snapshot.committed_direction)
	):
		failures.append("Redeployment did not restore the complete Stalker encounter snapshot.")
	if not (expedition.stalker.get_node("AttackCore") as Polygon2D).visible:
		failures.append("Restored committed state lacks its matching presentation.")
	var attack_area := expedition.stalker.get_node("AttackArea") as Area2D
	var attack_shape := attack_area.get_node("CollisionShape2D") as CollisionShape2D
	if not expedition.stalker.attack_active or not attack_area.monitoring or attack_shape.disabled:
		failures.append("Restored committed state did not rebuild active lethal collision.")
	if expedition.projectiles.get_child_count() != 0:
		failures.append("A transient projectile survived normal return/redeployment.")
	if not expedition.player.shot_recovery_timer.is_stopped():
		failures.append("Player weapon recovery survived normal return/redeployment.")
	if not expedition.player.global_position.is_equal_approx(expedition.shuttle_spawn.global_position):
		failures.append("Redeployed player did not start cleanly at the shuttle.")


func _check_loaded_retry(
	app: LandzoneMain,
	expedition: BasinExpedition,
	expedition_id: int,
	player_id: int,
	stalker_id: int,
	retry_started_count: int,
	retry_completed_count: int,
	failures: Array[String]
) -> void:
	if app.current_location != &"basin" or app.active_location != expedition:
		failures.append("Death retry incorrectly left the Basin for Kestrel.")
	if (
		expedition.get_instance_id() != expedition_id
		or expedition.player.get_instance_id() != player_id
		or expedition.stalker.get_instance_id() != stalker_id
	):
		failures.append("Death retry replaced the loaded Basin, player, or Stalker instance.")
	if retry_started_count != retry_completed_count or expedition.retry_in_progress:
		failures.append("Death retry did not complete exactly once before control returned.")
	if (
		not expedition.player.is_alive
		or not expedition.player.global_position.is_equal_approx(expedition.shuttle_spawn.global_position)
		or not expedition.player.is_processing()
		or not expedition.player.is_physics_processing()
	):
		failures.append("Death retry did not restore clean player control at the shuttle.")
	if (
		expedition.stalker.current_state != Stalker.State.CONCEALED
		or expedition.stalker.hits_remaining != expedition.stalker.required_hits
		or not expedition.stalker.global_position.is_equal_approx(expedition.stalker_spawn.global_position)
	):
		failures.append("Death retry did not reset the loaded Stalker before control returned.")


func _snapshots_equal(
	a: RunState.BasinEncounterState,
	b: RunState.BasinEncounterState
) -> bool:
	return (
		a.position.is_equal_approx(b.position)
		and a.behavior_state == b.behavior_state
		and absf(a.elapsed_seconds - b.elapsed_seconds) <= EPSILON
		and a.hits_remaining == b.hits_remaining
		and a.committed_direction.is_equal_approx(b.committed_direction)
	)


func _check_interact_binding(failures: Array[String]) -> void:
	if not InputMap.has_action(&"interact"):
		failures.append("Missing contextual interact action.")
		return
	for event: InputEvent in InputMap.action_get_events(&"interact"):
		var key_event := event as InputEventKey
		if key_event != null and key_event.physical_keycode == KEY_E:
			return
	failures.append("Interact is not bound to physical E.")


func _press_interact() -> void:
	Input.action_press(&"interact")
	await process_frame
	Input.action_release(&"interact")
	await process_frame


func _release_inputs() -> void:
	for action: StringName in [&"move_up", &"move_down", &"move_left", &"move_right", &"interact"]:
		Input.action_release(action)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("F03/D01 checks passed: Kestrel, guarded static transfers, preserved revisits, and distinct loaded retries.")
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	print("F03/D01 checks failed: %d" % failures.size())
	quit(1)
