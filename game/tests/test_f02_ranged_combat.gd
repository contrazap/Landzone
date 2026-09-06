extends SceneTree

const MAIN_SCENE_PATH := "res://main.tscn"
const PULSE_SCENE_PATH := "res://base_pulse.tscn"
const EXPECTED_PROJECTILE_LAYER := 8
const EXPECTED_WORLD_LAYER := 2
const EXPECTED_PLAYER_LAYER := 1
const EXPECTED_ENEMY_LAYER := 16
const EXPECTED_ATTACK_LAYER := 32
const EPSILON := 0.01

var shot_count: int = 0
var last_muzzle_position: Vector2 = Vector2.ZERO
var last_shot_direction: Vector2 = Vector2.ZERO


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures: Array[String] = []
	_check_shoot_input(failures)

	var main_scene := load(MAIN_SCENE_PATH) as PackedScene
	if main_scene == null:
		failures.append("Main scene could not be loaded.")
		_finish(failures)
		return

	var app := await _create_basin_app(main_scene, failures)
	if app == null:
		_finish(failures)
		return
	var main_instance := app.active_location as BasinExpedition

	var player := main_instance.get_node_or_null("Player") as BasinExplorer
	var projectiles := main_instance.get_node_or_null("Projectiles") as Node2D
	var stalker := main_instance.get_node_or_null("Stalker") as Stalker
	var stalker_spawn := main_instance.get_node_or_null("BasinSurface/StalkerSpawn") as Marker2D
	_check_composition(player, projectiles, failures)
	_check_stalker_composition(main_instance, stalker, stalker_spawn, failures)
	if player != null and projectiles != null:
		await _check_aim_and_recovery(player, projectiles, failures)

	await _check_pulse_lifecycle(failures)

	if player != null and stalker != null:
		await _check_stalker_state_cycle(player, stalker, failures)
	if stalker != null and projectiles != null:
		await _check_stalker_pulse_defeat(main_instance, stalker, projectiles, failures)

	Input.action_release(&"shoot")
	app.queue_free()
	await process_frame

	var retry_app := await _create_basin_app(main_scene, failures)
	if retry_app == null:
		_finish(failures)
		return
	var retry_instance := retry_app.active_location as BasinExpedition
	await _check_encounter_retry_cycles(retry_instance, failures)
	retry_app.queue_free()
	await process_frame
	_finish(failures)


func _create_basin_app(main_scene: PackedScene, failures: Array[String]) -> LandzoneMain:
	var app := main_scene.instantiate() as LandzoneMain
	root.add_child(app)
	await process_frame
	var mothership := app.active_location as Mothership
	if mothership == null or not app.request_location_change(&"basin", mothership):
		failures.append("Main could not deploy from Kestrel into the Basin regression scene.")
		app.queue_free()
		await process_frame
		return null
	await create_timer(app.transition_delay_seconds + 0.1).timeout
	if app.active_location is not BasinExpedition:
		failures.append("Main did not activate the Basin expedition after deployment.")
		app.queue_free()
		await process_frame
		return null
	return app


func _check_shoot_input(failures: Array[String]) -> void:
	if not InputMap.has_action(&"shoot"):
		failures.append("Missing direct shoot input action.")
		return

	var has_primary_mouse_button := false
	for event: InputEvent in InputMap.action_get_events(&"shoot"):
		var mouse_event := event as InputEventMouseButton
		if mouse_event != null and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			has_primary_mouse_button = true
	if not has_primary_mouse_button:
		failures.append("Shoot is missing its primary mouse-button binding.")


func _check_composition(
	player: BasinExplorer,
	projectiles: Node2D,
	failures: Array[String]
) -> void:
	if player == null:
		failures.append("Main scene is missing its BasinExplorer player.")
		return
	if projectiles == null:
		failures.append("Main scene is missing its Projectiles container.")

	var weapon := player.get_node_or_null("SurveyorWeapon") as Node2D
	var muzzle := player.get_node_or_null("SurveyorWeapon/Muzzle") as Marker2D
	var aim_guide := player.get_node_or_null("SurveyorWeapon/AimGuide") as Line2D
	var recovery_timer := player.get_node_or_null("ShotRecoveryTimer") as Timer
	if weapon == null or muzzle == null or aim_guide == null:
		failures.append("Player is missing the visible Surveyor weapon, aim guide, or muzzle.")
	if recovery_timer == null or not recovery_timer.one_shot:
		failures.append("Player requires one one-shot firing recovery timer.")
	var recovery_seconds := float(player.get("shot_recovery_seconds"))
	if recovery_seconds <= 0.0 or recovery_seconds > 0.5:
		failures.append("Base-pulse recovery must be short, positive, and centralized.")
	if _has_property(player, &"ammo") or _has_property(player, &"ammunition"):
		failures.append("Base pulse must not introduce ammunition state.")

	var pulse_scene := load(PULSE_SCENE_PATH) as PackedScene
	if pulse_scene == null:
		failures.append("Base-pulse scene could not be loaded.")
		return
	var pulse := pulse_scene.instantiate() as BasePulse
	if pulse == null:
		failures.append("Base-pulse scene root is not a BasePulse Area2D.")
		return
	if pulse.collision_layer != EXPECTED_PROJECTILE_LAYER:
		failures.append("Base pulse must occupy projectile collision layer 8.")
	if pulse.collision_mask != (EXPECTED_WORLD_LAYER | EXPECTED_ENEMY_LAYER):
		failures.append("Base pulse must detect world layer 2 and enemy layer 16.")
	if pulse.movement_speed <= 0.0 or pulse.lifetime_seconds <= 0.0:
		failures.append("Base pulse requires positive centralized speed and lifetime values.")
	var shape := pulse.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var core := pulse.get_node_or_null("Core") as Polygon2D
	if shape == null or shape.shape == null or core == null:
		failures.append("Base pulse requires visible geometry and a collision shape.")
	pulse.free()


func _check_stalker_composition(
	main_instance: Node,
	stalker: Stalker,
	spawn: Marker2D,
	failures: Array[String]
) -> void:
	var stalkers := main_instance.get_tree().get_nodes_in_group(&"stalker")
	if stalkers.size() != 1 or stalker == null or stalkers[0] != stalker:
		failures.append("Main scene must contain exactly one authored Stalker.")
		return
	if spawn == null:
		failures.append("Basin is missing its authored Stalker spawn marker.")
	elif not stalker.global_position.is_equal_approx(spawn.global_position):
		failures.append("Stalker does not begin at its authored spawn marker.")

	if stalker.collision_layer != EXPECTED_ENEMY_LAYER:
		failures.append("Stalker must occupy enemy collision layer 16.")
	if stalker.collision_mask != EXPECTED_WORLD_LAYER:
		failures.append("Stalker must collide only with world layer 2.")
	var trigger := stalker.get_node_or_null("TriggerArea") as Area2D
	var attack := stalker.get_node_or_null("AttackArea") as Area2D
	if trigger == null or trigger.collision_layer != 0 or trigger.collision_mask != EXPECTED_PLAYER_LAYER:
		failures.append("Stalker trigger must detect only the player without occupying a layer.")
	if attack == null or attack.collision_layer != EXPECTED_ATTACK_LAYER or attack.collision_mask != EXPECTED_PLAYER_LAYER:
		failures.append("Stalker attack must occupy layer 32 and detect only the player.")
	if attack != null and attack.monitoring:
		failures.append("Stalker lethal attack hitbox must begin inactive.")

	var hint := stalker.get_node_or_null("HintRing") as Line2D
	var telegraph := stalker.get_node_or_null("TelegraphRing") as Line2D
	var hit_flash := stalker.get_node_or_null("HitFlash") as Polygon2D
	if hint == null or telegraph == null or hit_flash == null:
		failures.append("Stalker is missing concealed, telegraph, or hit-feedback presentation.")
	elif not hint.visible or telegraph.visible or hit_flash.visible:
		failures.append("Stalker initial concealed presentation is incorrect.")

	var viewport_width := float(ProjectSettings.get_setting(&"display/window/size/viewport_width"))
	var viewport_height := float(ProjectSettings.get_setting(&"display/window/size/viewport_height"))
	var visible_trigger_limit := minf(viewport_width, viewport_height) * 0.5 - 25.0
	if stalker.trigger_range <= 0.0 or stalker.trigger_range > visible_trigger_limit:
		failures.append("Stalker trigger range is not bounded within the default camera view.")
	if stalker.telegraph_duration < 0.6:
		failures.append("Stalker tell duration is shorter than the configured 0.6-second minimum.")
	if stalker.recovery_duration < 0.2:
		failures.append("Stalker requires a readable recovery before another cycle.")
	if stalker.required_hits != 3 or stalker.hits_remaining != 3:
		failures.append("Stalker must begin with exactly three required Base-pulse hits.")
	if stalker.current_state != Stalker.State.CONCEALED or stalker.attack_active:
		failures.append("Stalker must begin concealed with no lethal attack active.")


func _check_aim_and_recovery(
	player: BasinExplorer,
	projectiles: Node2D,
	failures: Array[String]
) -> void:
	player.set_process(false)
	player.set_physics_process(false)
	shot_count = 0
	player.shot_requested.connect(_on_shot_requested)
	player.shot_recovery_seconds = 0.05

	var expected_direction := Vector2(3.0, 4.0).normalized()
	var target := player.global_position + Vector2(30.0, 40.0)
	if not player.update_aim_direction(target):
		failures.append("Nonzero world-space aim was rejected.")
	if not player.aim_direction.is_equal_approx(expected_direction):
		failures.append("World-space aim direction was not normalized correctly.")
	var weapon := player.get_node("SurveyorWeapon") as Node2D
	if absf(angle_difference(weapon.global_rotation, expected_direction.angle())) > EPSILON:
		failures.append("Surveyor weapon did not visibly follow the aim direction.")

	if not player.try_shoot():
		failures.append("Ready weapon rejected its first valid shot.")
	if shot_count != 1 or projectiles.get_child_count() != 1:
		failures.append("One accepted shot did not create exactly one Base pulse.")
	var muzzle := player.get_node("SurveyorWeapon/Muzzle") as Marker2D
	if not last_muzzle_position.is_equal_approx(muzzle.global_position):
		failures.append("Shot request did not originate at the world-space muzzle.")
	if not last_shot_direction.is_equal_approx(expected_direction):
		failures.append("Shot request did not preserve normalized aim direction.")

	var first_pulse := projectiles.get_child(0) as BasePulse
	var start_position := first_pulse.global_position
	if player.try_shoot() or shot_count != 1 or projectiles.get_child_count() != 1:
		failures.append("Weapon recovery did not reject an immediate repeated shot.")
	await physics_frame
	await physics_frame
	var travel := first_pulse.global_position - start_position
	if travel.dot(expected_direction) <= 0.0:
		failures.append("Base pulse did not move forward along the aimed direction.")
	if absf(travel.cross(expected_direction)) > EPSILON:
		failures.append("Base pulse drifted away from the aimed direction.")

	await create_timer(player.shot_recovery_seconds + 0.02).timeout
	if not player.try_shoot() or shot_count != 2 or projectiles.get_child_count() != 2:
		failures.append("Base pulse was not available again immediately after fixed recovery.")

	player.update_aim_direction(player.global_position)
	await create_timer(player.shot_recovery_seconds + 0.02).timeout
	if player.try_shoot() or shot_count != 2:
		failures.append("Zero-length aim incorrectly accepted a shot.")


func _check_pulse_lifecycle(failures: Array[String]) -> void:
	var pulse_scene := load(PULSE_SCENE_PATH) as PackedScene
	if pulse_scene == null:
		return

	var wall := StaticBody2D.new()
	wall.collision_layer = EXPECTED_WORLD_LAYER
	wall.collision_mask = 0
	wall.position = Vector2(150.0, 100.0)
	var wall_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(20.0, 80.0)
	wall_shape.shape = rectangle
	wall.add_child(wall_shape)
	root.add_child(wall)
	await physics_frame

	var impact_reasons: Array[StringName] = []
	var impact_pulse := pulse_scene.instantiate() as BasePulse
	impact_pulse.lifetime_seconds = 2.0
	impact_pulse.expired.connect(
		func(reason: StringName) -> void: impact_reasons.append(reason)
	)
	root.add_child(impact_pulse)
	impact_pulse.launch(Vector2(100.0, 100.0), Vector2.RIGHT)
	for _frame: int in 12:
		await physics_frame
		if not is_instance_valid(impact_pulse):
			break
	if is_instance_valid(impact_pulse) or impact_reasons != [&"impact"]:
		failures.append(
			"Base pulse did not expire exactly once on first world impact (alive=%s, reasons=%s)."
			% [is_instance_valid(impact_pulse), impact_reasons]
		)

	var lifetime_reasons: Array[StringName] = []
	var lifetime_pulse := pulse_scene.instantiate() as BasePulse
	lifetime_pulse.movement_speed = 1.0
	lifetime_pulse.lifetime_seconds = 0.03
	lifetime_pulse.expired.connect(
		func(reason: StringName) -> void: lifetime_reasons.append(reason)
	)
	root.add_child(lifetime_pulse)
	lifetime_pulse.launch(Vector2(5000.0, 5000.0), Vector2.RIGHT)
	for _frame: int in 5:
		await physics_frame
		if not is_instance_valid(lifetime_pulse):
			break
	if is_instance_valid(lifetime_pulse) or lifetime_reasons != [&"lifetime"]:
		failures.append(
			"Base pulse did not expire exactly once at its lifetime limit (alive=%s, reasons=%s)."
			% [is_instance_valid(lifetime_pulse), lifetime_reasons]
		)

	wall.queue_free()
	await process_frame


func _check_stalker_state_cycle(
	player: BasinExplorer,
	stalker: Stalker,
	failures: Array[String]
) -> void:
	player.set_process(false)
	player.set_physics_process(true)
	player.velocity = Vector2.ZERO

	var observed_states: Array[int] = []
	var committed_directions: Array[Vector2] = []
	stalker.state_changed.connect(
		func(_previous_state: int, new_state: int) -> void: observed_states.append(new_state)
	)
	stalker.attack_committed.connect(
		func(direction: Vector2) -> void: committed_directions.append(direction)
	)

	player.global_position = stalker.global_position + Vector2(-stalker.trigger_range + 10.0, 0.0)
	await physics_frame
	await physics_frame
	stalker.set_physics_process(false)
	if stalker.current_state != Stalker.State.TELEGRAPH:
		var trigger_area := stalker.get_node("TriggerArea") as Area2D
		failures.append(
			"Entering the bounded trigger did not begin the Stalker telegraph (state=%s, overlaps=%s, distance=%.2f, monitoring=%s, shape_disabled=%s, radius=%.2f, player_layer=%d)."
			% [stalker.current_state, trigger_area.get_overlapping_bodies().size(), stalker.global_position.distance_to(player.global_position), trigger_area.monitoring, (trigger_area.get_node("CollisionShape2D") as CollisionShape2D).disabled, ((trigger_area.get_node("CollisionShape2D") as CollisionShape2D).shape as CircleShape2D).radius, player.collision_layer]
		)
		if not stalker.begin_telegraph(player):
			return
	if stalker.attack_active or not player.is_alive:
		failures.append("Stalker became lethal when its telegraph began.")
	var telegraph_ring := stalker.get_node("TelegraphRing") as Line2D
	if not telegraph_ring.visible:
		failures.append("Stalker telegraph lacks its distinct visible ring.")

	stalker.advance_state(stalker.telegraph_duration * 0.5)
	await physics_frame
	var attack_area := stalker.get_node("AttackArea") as Area2D
	if stalker.current_state != Stalker.State.TELEGRAPH or stalker.attack_active or attack_area.monitoring:
		failures.append("Stalker attack activated before the complete tell duration.")
	if not player.is_alive:
		failures.append("Player died before the Stalker tell completed.")

	player.global_position = stalker.global_position + Vector2(-120.0, 0.0)
	stalker.advance_state(stalker.telegraph_duration * 0.5)
	await physics_frame
	if stalker.current_state != Stalker.State.COMMITTED or not stalker.attack_active or not attack_area.monitoring:
		failures.append("Completed tell did not activate one committed lethal approach.")
	var locked_direction := stalker.committed_direction
	if not locked_direction.is_equal_approx(Vector2.LEFT):
		failures.append("Stalker did not lock the player's direction when committing.")
	player.global_position = stalker.global_position + Vector2(120.0, 80.0)
	stalker.advance_state(stalker.committed_duration * 0.5)
	if not stalker.committed_direction.is_equal_approx(locked_direction):
		failures.append("Stalker changed direction after its attack commitment.")
	if committed_directions != [locked_direction]:
		failures.append("Stalker did not emit exactly one committed direction.")

	stalker.advance_state(stalker.committed_duration * 0.5)
	await physics_frame
	if stalker.current_state != Stalker.State.RECOVERY or stalker.attack_active or attack_area.monitoring:
		failures.append("A missed commitment did not enter nonlethal recovery.")
	var recovery_ring := stalker.get_node("RecoveryRing") as Line2D
	if not recovery_ring.visible:
		failures.append("Stalker recovery is missing its readable presentation.")

	player.global_position = stalker.global_position + Vector2(stalker.trigger_range + 100.0, 0.0)
	stalker.advance_state(stalker.recovery_duration)
	await physics_frame
	if stalker.current_state != Stalker.State.CONCEALED or stalker.attack_active:
		failures.append("Stalker did not conceal safely after recovery.")
	var expected_states: Array[int] = [
		Stalker.State.TELEGRAPH,
		Stalker.State.COMMITTED,
		Stalker.State.RECOVERY,
		Stalker.State.CONCEALED,
	]
	if observed_states != expected_states:
		failures.append("Stalker did not follow the authored state sequence: %s." % observed_states)


func _check_stalker_pulse_defeat(
	main_instance: Node,
	stalker: Stalker,
	projectiles: Node2D,
	failures: Array[String]
) -> void:
	main_instance.call(&"clear_active_pulses")
	await process_frame
	var hit_counts: Array[int] = []
	var defeat_events: Array[bool] = []
	stalker.pulse_hit.connect(
		func(remaining_hits: int) -> void: hit_counts.append(remaining_hits)
	)
	stalker.defeated.connect(func() -> void: defeat_events.append(true))

	for hit_index: int in range(3):
		main_instance.call(
			&"_on_player_shot_requested",
			stalker.global_position + Vector2(-70.0, 0.0),
			Vector2.RIGHT
		)
		var expected_hit_count := hit_index + 1
		for _frame: int in 12:
			await physics_frame
			if hit_counts.size() >= expected_hit_count:
				break
		if hit_counts.size() != expected_hit_count:
			failures.append("Base pulse %d did not register exactly one Stalker hit." % expected_hit_count)
			return
		if stalker.hits_remaining != 2 - hit_index:
			failures.append("Stalker hit requirement did not decrement exactly once per pulse.")
		if hit_index < 2:
			var hit_flash := stalker.get_node("HitFlash") as Polygon2D
			if not hit_flash.visible:
				failures.append("Stalker pulse hit lacked visible acknowledgement.")
			if stalker.current_state == Stalker.State.DEFEATED:
				failures.append("Stalker was defeated before exactly three hits.")
		await physics_frame
		if hit_counts.size() != expected_hit_count:
			failures.append("One Base pulse registered more than one Stalker hit.")

	await physics_frame
	if hit_counts != [2, 1, 0] or defeat_events.size() != 1:
		failures.append("Exactly three valid impacts did not emit one Stalker defeat.")
	if stalker.current_state != Stalker.State.DEFEATED or stalker.attack_active:
		failures.append("Defeated Stalker remained active or lethal.")
	var trigger_area := stalker.get_node("TriggerArea") as Area2D
	var attack_area := stalker.get_node("AttackArea") as Area2D
	if trigger_area.monitoring or attack_area.monitoring:
		failures.append("Defeat did not disable Stalker trigger and attack monitoring.")
	if stalker.receive_pulse_hit():
		failures.append("Defeated Stalker accepted another Base-pulse hit.")
	var player := main_instance.get_node("Player") as BasinExplorer
	player.global_position = stalker.global_position
	if stalker.begin_telegraph(player):
		failures.append("Defeated Stalker began another attack action.")


func _check_encounter_retry_cycles(main_instance: Node, failures: Array[String]) -> void:
	var player := main_instance.get_node_or_null("Player") as BasinExplorer
	var stalker := main_instance.get_node_or_null("Stalker") as Stalker
	var projectiles := main_instance.get_node_or_null("Projectiles") as Node2D
	var basin := main_instance.get_node_or_null("BasinSurface") as Node2D
	var shuttle_spawn := main_instance.get_node_or_null("BasinSurface/ShuttleSpawn") as Marker2D
	var stalker_spawn := main_instance.get_node_or_null("BasinSurface/StalkerSpawn") as Marker2D
	var hazard := main_instance.get_node_or_null("BasinSurface/LethalHazard") as Area2D
	if (
		player == null
		or stalker == null
		or projectiles == null
		or basin == null
		or shuttle_spawn == null
		or stalker_spawn == null
		or hazard == null
	):
		failures.append("Retry scene is missing a required player, Basin, Stalker, marker, hazard, or projectile owner.")
		return

	var retry_started_events: Array[bool] = []
	var retry_completed_events: Array[bool] = []
	var reset_events: Array[int] = []
	var player_alive_during_reset: Array[bool] = []
	main_instance.retry_started.connect(func() -> void: retry_started_events.append(true))
	main_instance.retry_completed.connect(func() -> void: retry_completed_events.append(true))
	stalker.encounter_reset.connect(
		func(count: int) -> void:
			reset_events.append(count)
			player_alive_during_reset.append(player.is_alive)
	)
	var player_id := player.get_instance_id()
	var basin_id := basin.get_instance_id()
	var stalker_id := stalker.get_instance_id()
	var retry_delay := float(main_instance.get("retry_delay_seconds"))
	if absf(retry_delay - 0.65) > EPSILON:
		failures.append("F02 changed the existing configured 0.65-second retry delay.")

	for _hit: int in range(stalker.required_hits):
		stalker.receive_pulse_hit()
	await physics_frame
	await physics_frame
	if stalker.current_state != Stalker.State.DEFEATED or stalker.reset_count != 0:
		failures.append("Stalker defeat did not persist during the successful life before a death.")
	if stalker.begin_telegraph(player) or stalker.receive_pulse_hit():
		failures.append("Defeated Stalker became active again without a retry reset.")

	await physics_frame
	await physics_frame
	main_instance.call(
		&"_on_player_shot_requested",
		Vector2(5000.0, 5000.0),
		Vector2.RIGHT
	)
	if projectiles.get_child_count() != 1:
		failures.append("Defeat-persistence retry check could not create one transient Base pulse.")
	player.global_position = hazard.global_position
	player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	await process_frame
	_check_retry_started(main_instance, player, projectiles, 1, retry_started_events, failures)
	await create_timer(retry_delay + 0.15).timeout
	_check_retry_completed(
		main_instance,
		player,
		basin,
		stalker,
		projectiles,
		shuttle_spawn,
		stalker_spawn,
		1,
		player_id,
		basin_id,
		stalker_id,
		retry_completed_events,
		reset_events,
		player_alive_during_reset,
		failures
	)

	var landed_events: Array[bool] = []
	stalker.attack_landed.connect(func() -> void: landed_events.append(true))
	for combat_cycle: int in range(3):
		player.set_process(false)
		player.set_physics_process(false)
		stalker.set_physics_process(false)
		player.global_position = stalker.global_position + Vector2(85.0, 0.0)
		if not stalker.begin_telegraph(player):
			failures.append("Reset Stalker could not begin combat retry cycle %d." % (combat_cycle + 1))
			return
		stalker.advance_state(stalker.telegraph_duration)
		if stalker.current_state != Stalker.State.COMMITTED:
			failures.append("Reset Stalker did not commit in combat retry cycle %d." % (combat_cycle + 1))
			return

		main_instance.call(
			&"_on_player_shot_requested",
			Vector2(5000.0, 5000.0),
			Vector2.RIGHT
		)
		stalker.set_physics_process(true)
		for _frame: int in 45:
			await physics_frame
			if not player.is_alive:
				break
		await process_frame
		var expected_retry_count := combat_cycle + 2
		if player.is_alive or landed_events.size() != combat_cycle + 1:
			failures.append("Committed Stalker contact was not lethal in combat retry cycle %d." % (combat_cycle + 1))
			return
		_check_retry_started(
			main_instance,
			player,
			projectiles,
			expected_retry_count,
			retry_started_events,
			failures
		)
		await create_timer(retry_delay + 0.15).timeout
		_check_retry_completed(
			main_instance,
			player,
			basin,
			stalker,
			projectiles,
			shuttle_spawn,
			stalker_spawn,
			expected_retry_count,
			player_id,
			basin_id,
			stalker_id,
			retry_completed_events,
			reset_events,
			player_alive_during_reset,
			failures
		)

	await physics_frame
	await physics_frame
	main_instance.call(
		&"_on_player_shot_requested",
		Vector2(5000.0, 5000.0),
		Vector2.RIGHT
	)
	player.global_position = hazard.global_position
	player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	await process_frame
	_check_retry_started(main_instance, player, projectiles, 5, retry_started_events, failures)
	await create_timer(retry_delay + 0.15).timeout
	_check_retry_completed(
		main_instance,
		player,
		basin,
		stalker,
		projectiles,
		shuttle_spawn,
		stalker_spawn,
		5,
		player_id,
		basin_id,
		stalker_id,
		retry_completed_events,
		reset_events,
		player_alive_during_reset,
		failures
	)


func _check_retry_started(
	main_instance: Node,
	player: BasinExplorer,
	projectiles: Node2D,
	expected_count: int,
	retry_started_events: Array[bool],
	failures: Array[String]
) -> void:
	if retry_started_events.size() != expected_count or not bool(main_instance.get("retry_in_progress")):
		failures.append("Death did not start exactly one retry in reset cycle %d." % expected_count)
	if player.is_alive or player.is_processing() or player.is_physics_processing():
		failures.append("Player control remained active during reset cycle %d." % expected_count)
	if projectiles.get_child_count() != 0:
		failures.append("Reset cycle %d did not clear every transient Base pulse." % expected_count)
	if player.die() or bool(main_instance.call(&"request_retry")):
		failures.append("Reset cycle %d accepted a duplicate death or retry." % expected_count)
	if retry_started_events.size() != expected_count:
		failures.append("Duplicate contact emitted another retry in reset cycle %d." % expected_count)


func _check_retry_completed(
	main_instance: Node,
	player: BasinExplorer,
	basin: Node2D,
	stalker: Stalker,
	projectiles: Node2D,
	shuttle_spawn: Marker2D,
	stalker_spawn: Marker2D,
	expected_count: int,
	player_id: int,
	basin_id: int,
	stalker_id: int,
	retry_completed_events: Array[bool],
	reset_events: Array[int],
	player_alive_during_reset: Array[bool],
	failures: Array[String]
) -> void:
	if retry_completed_events.size() != expected_count or bool(main_instance.get("retry_in_progress")):
		failures.append("Reset cycle %d did not complete exactly one retry." % expected_count)
	if reset_events.size() != expected_count or stalker.reset_count != expected_count:
		failures.append("Reset cycle %d did not reset the Stalker exactly once." % expected_count)
	if reset_events.is_empty() or reset_events.back() != expected_count:
		failures.append("Stalker reset evidence is not sequential through cycle %d." % expected_count)
	if player_alive_during_reset.is_empty() or player_alive_during_reset.back():
		failures.append("Stalker reset did not occur before player control returned in cycle %d." % expected_count)
	if (
		player.get_instance_id() != player_id
		or basin.get_instance_id() != basin_id
		or stalker.get_instance_id() != stalker_id
	):
		failures.append("Retry replaced the player, Basin, or Stalker in cycle %d." % expected_count)
	if main_instance.get_tree().get_nodes_in_group(&"player").size() != 1:
		failures.append("Retry duplicated the player in cycle %d." % expected_count)
	if main_instance.get_tree().get_nodes_in_group(&"stalker").size() != 1:
		failures.append("Retry duplicated the Stalker in cycle %d." % expected_count)
	if not player.global_position.is_equal_approx(shuttle_spawn.global_position):
		failures.append("Player missed the exact shuttle marker in reset cycle %d." % expected_count)
	if not player.is_alive or not player.is_processing() or not player.is_physics_processing():
		failures.append("Movement, aim, and fire processing did not return in cycle %d." % expected_count)
	if not stalker.global_position.is_equal_approx(stalker_spawn.global_position):
		failures.append("Stalker missed its authored marker in reset cycle %d." % expected_count)
	if (
		stalker.current_state != Stalker.State.CONCEALED
		or stalker.hits_remaining != stalker.required_hits
		or stalker.attack_active
		or not stalker.velocity.is_zero_approx()
		or not stalker.committed_direction.is_zero_approx()
	):
		failures.append("Stalker transient state was not clean in reset cycle %d." % expected_count)
	var trigger_area := stalker.get_node("TriggerArea") as Area2D
	var trigger_shape := stalker.get_node("TriggerArea/CollisionShape2D") as CollisionShape2D
	var attack_area := stalker.get_node("AttackArea") as Area2D
	var attack_shape := stalker.get_node("AttackArea/CollisionShape2D") as CollisionShape2D
	if not trigger_area.monitoring or trigger_shape.disabled or attack_area.monitoring or not attack_shape.disabled:
		failures.append("Stalker collision intent was not restored safely in reset cycle %d." % expected_count)
	if projectiles.get_child_count() != 0:
		failures.append("A stale Base pulse survived reset cycle %d." % expected_count)
	player.update_aim_direction(player.global_position + Vector2.RIGHT * 100.0)
	if not player.try_shoot() or projectiles.get_child_count() != 1:
		failures.append("Aim and fire were not immediately usable after reset cycle %d." % expected_count)


func _on_shot_requested(muzzle_position: Vector2, direction: Vector2) -> void:
	shot_count += 1
	last_muzzle_position = muzzle_position
	last_shot_direction = direction


func _has_property(object: Object, property_name: StringName) -> bool:
	for property: Dictionary in object.get_property_list():
		if StringName(property.get("name", "")) == property_name:
			return true
	return false


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("F02/S03 checks passed: ranged combat, defeat persistence, lethal retries, and exact same-instance encounter reset.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	print("F02/S03 checks failed: %d" % failures.size())
	quit(1)
