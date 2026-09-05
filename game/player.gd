class_name BasinExplorer
extends CharacterBody2D

signal died

@export_range(1.0, 1000.0, 1.0) var movement_speed: float = 220.0

var is_alive: bool = true


func _physics_process(_delta: float) -> void:
	update_movement_velocity()
	move_and_slide()


func update_movement_velocity() -> void:
	velocity = get_movement_direction() * movement_speed


func get_movement_direction() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")


func die() -> bool:
	if not is_alive:
		return false

	is_alive = false
	velocity = Vector2.ZERO
	set_physics_process(false)
	died.emit()
	return true


func respawn_at(checkpoint_position: Vector2) -> void:
	global_position = checkpoint_position
	velocity = Vector2.ZERO
	is_alive = true
	set_physics_process(true)
