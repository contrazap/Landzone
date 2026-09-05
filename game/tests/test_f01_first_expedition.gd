extends SceneTree

const MAIN_SCENE_PATH := "res://main.tscn"
const PLAYER_SCENE_PATH := "res://player.tscn"
const EXPECTED_PLAYER_LAYER := 1
const EXPECTED_WORLD_LAYER := 2
const EPSILON := 0.01


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
	_check_composition(main_instance, player, spawn, failures)
	if player != null:
		await _check_movement(player, failures)
		await _check_wall_collision(player, failures)

	_release_movement_inputs()
	main_instance.queue_free()
	await process_frame
	_finish(failures)


func _check_composition(
		main_instance: Node,
		player: CharacterBody2D,
		spawn: Marker2D,
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

	if not main_instance.get_tree().get_nodes_in_group(&"hazard").is_empty():
		failures.append("S01 must not introduce a lethal hazard.")

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


func _release_movement_inputs() -> void:
	Input.action_release(&"move_up")
	Input.action_release(&"move_down")
	Input.action_release(&"move_left")
	Input.action_release(&"move_right")


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("F01/S01 checks passed: Basin composition, player physics, normalized movement, collision intent, and camera.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	print("F01/S01 checks failed: %d" % failures.size())
	quit(1)
