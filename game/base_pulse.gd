class_name BasePulse
extends Area2D

signal expired(reason: StringName)
signal impacted(body: Node2D)

@export_range(1.0, 2000.0, 1.0) var movement_speed: float = 620.0
@export_range(0.05, 10.0, 0.05) var lifetime_seconds: float = 1.4

var direction: Vector2 = Vector2.RIGHT
var elapsed_seconds: float = 0.0
var has_expired: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position += direction * movement_speed * delta
	elapsed_seconds += delta
	if elapsed_seconds >= lifetime_seconds:
		expire(&"lifetime")


func launch(origin: Vector2, travel_direction: Vector2) -> bool:
	if travel_direction.is_zero_approx():
		return false

	global_position = origin
	direction = travel_direction.normalized()
	rotation = direction.angle()
	return true


func expire(reason: StringName) -> bool:
	if has_expired:
		return false

	has_expired = true
	set_physics_process(false)
	set_deferred(&"monitoring", false)
	expired.emit(reason)
	queue_free()
	return true


func _on_body_entered(body: Node2D) -> void:
	if has_expired:
		return

	impacted.emit(body)
	expire(&"impact")
