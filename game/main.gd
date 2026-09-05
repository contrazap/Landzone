extends Node2D

signal retry_started
signal retry_completed

const BASE_PULSE_SCENE: PackedScene = preload("res://base_pulse.tscn")

@export_range(0.1, 1.0, 0.05) var retry_delay_seconds: float = 0.65

@onready var player: BasinExplorer = $Player
@onready var projectiles: Node2D = $Projectiles
@onready var shuttle_spawn: Marker2D = $BasinSurface/ShuttleSpawn
@onready var stalker_spawn: Marker2D = $BasinSurface/StalkerSpawn
@onready var stalker: Stalker = $Stalker
@onready var lethal_hazard: Area2D = $BasinSurface/LethalHazard
@onready var retry_timer: Timer = $RetryTimer
@onready var redeploy_feedback: Control = $Interface/RedeployFeedback

var retry_in_progress: bool = false


func _ready() -> void:
	player.global_position = shuttle_spawn.global_position
	stalker.global_position = stalker_spawn.global_position
	stalker.set_target_player(player)
	player.died.connect(_on_player_died)
	player.shot_requested.connect(_on_player_shot_requested)
	lethal_hazard.body_entered.connect(_on_lethal_hazard_body_entered)
	retry_timer.timeout.connect(_on_retry_timer_timeout)


func request_retry() -> bool:
	if retry_in_progress:
		return false

	retry_in_progress = true
	clear_active_pulses()
	player.visible = false
	redeploy_feedback.visible = true
	retry_timer.start(retry_delay_seconds)
	retry_started.emit()
	return true


func _on_lethal_hazard_body_entered(body: Node2D) -> void:
	if body == player:
		player.die()


func _on_player_died() -> void:
	request_retry()


func _on_player_shot_requested(muzzle_position: Vector2, direction: Vector2) -> void:
	var pulse := BASE_PULSE_SCENE.instantiate() as BasePulse
	projectiles.add_child(pulse)
	pulse.impacted.connect(_on_base_pulse_impacted)
	pulse.launch(muzzle_position, direction)


func _on_base_pulse_impacted(body: Node2D) -> void:
	if body == stalker:
		stalker.receive_pulse_hit()


func clear_active_pulses() -> void:
	for pulse: Node in projectiles.get_children():
		pulse.queue_free()


func _on_retry_timer_timeout() -> void:
	stalker.reset_encounter(stalker_spawn.global_position)
	player.respawn_at(shuttle_spawn.global_position)
	player.visible = true
	redeploy_feedback.visible = false
	retry_in_progress = false
	retry_completed.emit()
