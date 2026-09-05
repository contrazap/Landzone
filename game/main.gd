extends Node2D

signal retry_started
signal retry_completed

@export_range(0.1, 1.0, 0.05) var retry_delay_seconds: float = 0.65

@onready var player: BasinExplorer = $Player
@onready var shuttle_spawn: Marker2D = $BasinSurface/ShuttleSpawn
@onready var lethal_hazard: Area2D = $BasinSurface/LethalHazard
@onready var retry_timer: Timer = $RetryTimer
@onready var redeploy_feedback: Control = $Interface/RedeployFeedback

var retry_in_progress: bool = false


func _ready() -> void:
	player.global_position = shuttle_spawn.global_position
	player.died.connect(_on_player_died)
	lethal_hazard.body_entered.connect(_on_lethal_hazard_body_entered)
	retry_timer.timeout.connect(_on_retry_timer_timeout)


func request_retry() -> bool:
	if retry_in_progress:
		return false

	retry_in_progress = true
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


func _on_retry_timer_timeout() -> void:
	player.respawn_at(shuttle_spawn.global_position)
	player.visible = true
	redeploy_feedback.visible = false
	retry_in_progress = false
	retry_completed.emit()
