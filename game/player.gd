class_name BasinExplorer
extends CharacterBody2D

@export_range(1.0, 1000.0, 1.0) var movement_speed: float = 220.0


func _physics_process(_delta: float) -> void:
	update_movement_velocity()
	move_and_slide()


func update_movement_velocity() -> void:
	velocity = get_movement_direction() * movement_speed


func get_movement_direction() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
