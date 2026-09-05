extends SceneTree

const MAIN_SCENE_PATH := "res://main.tscn"
const PLAYER_SCENE_PATH := "res://player.tscn"
const EXPECTED_PLAYER_LAYER := 1
const EXPECTED_WORLD_LAYER := 2
const EXPECTED_HAZARD_LAYER := 4
const EPSILON := 0.01

var retry_started_count: int = 0
var retry_completed_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures: Array[String] = []
	var main_scene := load(MAIN_SCENE_PATH) as PackedScene
	if main_scene == null:
		failures.append("Main scene could not be loaded.")
		_finish(failures)
		return

	var main_instance := main_scene.instantiate()
	root.add_child(main_instance)
	await process_frame

	var player := main_instance.get_node_or_null("Player") as CharacterBody2D
	var spawn := main_instance.get_node_or_null("BasinSurface/ShuttleSpawn") as Marker2D
	var hazard := main_instance.get_node_or_null("BasinSurface/LethalHazard") as Area2D
	var safe_passage := main_instance.get_node_or_null("BasinSurface/SafePassage") as Marker2D
	_check_composition(main_instance, player, spawn, hazard, safe_passage, failures)
	if player != null:
		await _check_movement(player, failures)
		await _check_wall_collision(player, failures)
	if player != null and spawn != null and hazard != null and safe_passage != null:
		await _check_lethal_retry(
			main_instance,
			player,
			spawn,
			hazard,
			safe_passage,
			failures
		)

	_release_movement_inputs()
	main_instance.queue_free()
	await process_frame
	_finish(failures)


func _check_composition(
		main_instance: Node,
		player: CharacterBody2D,
		spawn: Marker2D,
		hazard: Area2D,
		safe_passage: Marker2D,
		failures: Array[String]
) -> void:
	if main_instance.get_node_or_null("BasinSurface") == null:
		failures.append("Main scene is missing the authored Basin surface.")
	if player == null:
		failures.append("Main scene is missing its player CharacterBody2D.")
	if spawn == null:
		failures.append("Basin surface is missing its shuttle spawn marker.")

	var shuttles := main_instance.get_tree().get_nodes_in_group(&"shuttle")
	if shuttles.size() != 1:
		failures.append("Expected one static shuttle, found %d." % shuttles.size())
	elif shuttles[0] is not StaticBody2D:
		failures.append("The shuttle must be a static physics body.")

	var boundaries := main_instance.get_tree().get_nodes_in_group(&"path_boundary")
	if boundaries.size() < 4:
		failures.append("Expected at least four solid route boundaries.")
	for boundary: Node in boundaries:
		var body := boundary as StaticBody2D
		if body == null:
			failures.append("A path boundary is not a StaticBody2D.")
			continue
		if body.collision_layer != EXPECTED_WORLD_LAYER or body.collision_mask != EXPECTED_PLAYER_LAYER:
			failures.append("Path boundary collision layer or mask is incorrect.")

	var hazards := main_instance.get_tree().get_nodes_in_group(&"hazard")
	if hazards.size() != 1 or hazard == null or hazards[0] != hazard:
		failures.append("Expected one authored lethal hazard.")
	elif hazard.collision_layer != EXPECTED_HAZARD_LAYER or hazard.collision_mask != EXPECTED_PLAYER_LAYER:
		failures.append("Hazard collision layer or mask is incorrect.")
	elif not hazard.monitoring:
		failures.append("Lethal hazard must monitor player contact.")
	if safe_passage == null:
		failures.append("Authored route is missing its safe passage beside the hazard.")

	if player == null:
		return
	if spawn != null and not player.global_position.is_equal_approx(spawn.global_position):
		failures.append("Player does not begin at the shuttle spawn marker.")
	if player.collision_layer != EXPECTED_PLAYER_LAYER:
		failures.append("Player must occupy collision layer 1.")
	if player.collision_mask != EXPECTED_WORLD_LAYER:
		failures.append("Player must collide with world layer 2.")

	var collision_shape := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null or collision_shape.shape == null or collision_shape.disabled:
		failures.append("Player requires one enabled physics collision shape.")
	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera == null or not camera.enabled:
		failures.append("Player requires an enabled follow camera.")
	if not player.get("movement_speed") is float or float(player.get("movement_speed")) <= 0.0:
		failures.append("Player movement speed must be a positive centralized value.")

	var player_scene := load(PLAYER_SCENE_PATH) as PackedScene
	if player_scene == null:
		failures.append("Focused player scene could not be loaded.")
	else:
		var player_instance := player_scene.instantiate()
		if player_instance is not CharacterBody2D:
			failures.append("Focused player scene root is not a CharacterBody2D.")
		player_instance.free()


func _check_movement(player: CharacterBody2D, failures: Array[String]) -> void:
	player.set_physics_process(false)
	_release_movement_inputs()
	var movement_speed := float(player.get("movement_speed"))

	Input.action_press(&"move_right")
	player.call(&"update_movement_velocity")
	if not player.velocity.is_equal_approx(Vector2.RIGHT * movement_speed):
		failures.append("Positive horizontal input does not produce expected velocity.")

	Input.action_press(&"move_up")
	player.call(&"update_movement_velocity")
	if absf(player.velocity.length() - movement_speed) > EPSILON:
		failures.append("Diagonal movement is faster or slower than axial movement.")
	if player.velocity.x <= 0.0 or player.velocity.y >= 0.0:
		failures.append("Diagonal input does not preserve both requested directions.")

	Input.action_release(&"move_up")
	Input.action_press(&"move_left")
	player.call(&"update_movement_velocity")
	if not player.velocity.is_zero_approx():
		failures.append("Opposing horizontal inputs must cancel movement.")

	_release_movement_inputs()
	player.call(&"update_movement_velocity")
	var start_position := player.global_position
	Input.action_press(&"move_right")
	player.set_physics_process(true)
	await physics_frame
	await physics_frame
	player.set_physics_process(false)
	if player.global_position.x <= start_position.x:
		failures.append("Player did not move through CharacterBody2D physics.")


func _check_wall_collision(player: CharacterBody2D, failures: Array[String]) -> void:
	_release_movement_inputs()
	player.global_position = Vector2(800, 340)
	player.velocity = Vector2.ZERO
	Input.action_press(&"move_up")
	player.set_physics_process(true)
	for _frame: int in 20:
		await physics_frame
	player.set_physics_process(false)
	if player.global_position.y < 312.0:
		failures.append("Player passed through the solid upper rock boundary.")


func _check_lethal_retry(
		main_instance: Node,
		player: CharacterBody2D,
		spawn: Marker2D,
		hazard: Area2D,
		safe_passage: Marker2D,
		failures: Array[String]
) -> void:
	_release_movement_inputs()
	retry_started_count = 0
	retry_completed_count = 0
	main_instance.connect(&"retry_started", Callable(self, "_on_retry_started"))
	main_instance.connect(&"retry_completed", Callable(self, "_on_retry_completed"))

	var retry_delay := float(main_instance.get("retry_delay_seconds"))
	if retry_delay <= 0.0 or retry_delay > 1.0:
		failures.append("Retry delay must be greater than zero and no more than one second.")

	var retry_timer := main_instance.get_node_or_null("RetryTimer") as Timer
	var feedback := main_instance.get_node_or_null("Interface/RedeployFeedback") as Control
	if retry_timer == null or not retry_timer.one_shot:
		failures.append("Main scene requires one one-shot retry timer.")
	if feedback == null:
		failures.append("Main scene requires visible-state redeploy feedback.")

	player.global_position = safe_passage.global_position
	player.velocity = Vector2.ZERO
	player.set_physics_process(true)
	await physics_frame
	await physics_frame
	if not bool(player.get("is_alive")) or bool(main_instance.get("retry_in_progress")):
		failures.append("The authored safe passage incorrectly triggers lethal contact.")

	var player_id := player.get_instance_id()
	var basin := main_instance.get_node("BasinSurface")
	var basin_id := basin.get_instance_id()
	var hazard_id := hazard.get_instance_id()

	for cycle: int in range(3):
		player.global_position = hazard.global_position
		player.velocity = Vector2(70, 0)
		await physics_frame
		await physics_frame

		var expected_count := cycle + 1
		if retry_started_count != expected_count:
			failures.append("Hazard contact did not start exactly one retry in cycle %d." % expected_count)
		if not bool(main_instance.get("retry_in_progress")):
			failures.append("Retry state was not active after lethal contact in cycle %d." % expected_count)
		if bool(player.get("is_alive")) or player.is_physics_processing():
			failures.append("Death did not disable player control in cycle %d." % expected_count)
		if not player.velocity.is_zero_approx():
			failures.append("Death did not clear player velocity in cycle %d." % expected_count)
		if feedback != null and not feedback.visible:
			failures.append("Redeploy feedback was not visible in cycle %d." % expected_count)
		if retry_timer != null and retry_timer.is_stopped():
			failures.append("Retry timer was not running in cycle %d." % expected_count)

		var duplicate_death_accepted := bool(player.call(&"die"))
		var duplicate_retry_accepted := bool(main_instance.call(&"request_retry"))
		if duplicate_death_accepted or duplicate_retry_accepted:
			failures.append("Duplicate death or retry was accepted in cycle %d." % expected_count)
		if retry_started_count != expected_count:
			failures.append("Duplicate request started another retry in cycle %d." % expected_count)

		await create_timer(retry_delay + 0.15).timeout
		if retry_completed_count != expected_count:
			failures.append("Retry did not complete exactly once in cycle %d." % expected_count)
		if bool(main_instance.get("retry_in_progress")):
			failures.append("Retry state remained active after cycle %d." % expected_count)
		if not bool(player.get("is_alive")) or not player.is_physics_processing():
			failures.append("Player control was not restored after cycle %d." % expected_count)
		if not player.global_position.is_equal_approx(spawn.global_position):
			failures.append("Player did not return to the exact shuttle spawn in cycle %d." % expected_count)
		if not player.velocity.is_zero_approx():
			failures.append("Player velocity was not clean after cycle %d." % expected_count)
		if feedback != null and feedback.visible:
			failures.append("Redeploy feedback remained visible after cycle %d." % expected_count)
		if player.get_instance_id() != player_id or basin.get_instance_id() != basin_id:
			failures.append("Retry replaced the player or Basin scene in cycle %d." % expected_count)
		if hazard.get_instance_id() != hazard_id:
			failures.append("Retry replaced the authored hazard in cycle %d." % expected_count)
		if main_instance.get_tree().get_nodes_in_group(&"player").size() != 1:
			failures.append("Retry created a duplicate player in cycle %d." % expected_count)
		await physics_frame
		await physics_frame


func _on_retry_started() -> void:
	retry_started_count += 1


func _on_retry_completed() -> void:
	retry_completed_count += 1


func _release_movement_inputs() -> void:
	Input.action_release(&"move_up")
	Input.action_release(&"move_down")
	Input.action_release(&"move_left")
	Input.action_release(&"move_right")


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("F01/S02 checks passed: Basin movement, avoidable lethal contact, duplicate-safe retry, and repeated shuttle restoration.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	print("F01/S02 checks failed: %d" % failures.size())
	quit(1)
