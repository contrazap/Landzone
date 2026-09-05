class_name BasinExplorer
extends CharacterBody2D

signal died
signal shot_requested(muzzle_position: Vector2, direction: Vector2)

@export_range(1.0, 1000.0, 1.0) var movement_speed: float = 220.0
@export_range(0.05, 2.0, 0.01) var shot_recovery_seconds: float = 0.24

@onready var surveyor_weapon: Node2D = $SurveyorWeapon
@onready var muzzle: Marker2D = $SurveyorWeapon/Muzzle
@onready var shot_recovery_timer: Timer = $ShotRecoveryTimer

var is_alive: bool = true
var aim_direction: Vector2 = Vector2.RIGHT


func _process(_delta: float) -> void:
	update_aim_direction(get_global_mouse_position())
	if Input.is_action_pressed(&"shoot"):
		try_shoot()


func _physics_process(_delta: float) -> void:
	update_movement_velocity()
	move_and_slide()


func update_movement_velocity() -> void:
	velocity = get_movement_direction() * movement_speed


func get_movement_direction() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")


func update_aim_direction(target_global_position: Vector2) -> bool:
	var target_offset := target_global_position - global_position
	if target_offset.is_zero_approx():
		aim_direction = Vector2.ZERO
		return false

	aim_direction = target_offset.normalized()
	surveyor_weapon.global_rotation = aim_direction.angle()
	return true


func try_shoot() -> bool:
	if not is_alive or aim_direction.is_zero_approx() or not shot_recovery_timer.is_stopped():
		return false

	shot_recovery_timer.start(shot_recovery_seconds)
	shot_requested.emit(muzzle.global_position, aim_direction)
	return true


func die() -> bool:
	if not is_alive:
		return false

	is_alive = false
	velocity = Vector2.ZERO
	shot_recovery_timer.stop()
	set_process(false)
	set_physics_process(false)
	died.emit()
	return true


func respawn_at(checkpoint_position: Vector2) -> void:
	global_position = checkpoint_position
	velocity = Vector2.ZERO
	is_alive = true
	shot_recovery_timer.stop()
	set_process(true)
	set_physics_process(true)
