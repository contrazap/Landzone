class_name BasinExpedition
extends Node2D

signal location_change_requested(destination: StringName)
signal retry_started
signal retry_completed

const BASE_PULSE_SCENE: PackedScene = preload("res://base_pulse.tscn")
const BASIN_CAMERA_BOUNDS := Rect2i(0, 0, 2160, 900)

@export_range(0.1, 1.0, 0.05) var retry_delay_seconds: float = 0.65

@onready var player: BasinExplorer = $Player
@onready var projectiles: Node2D = $Projectiles
@onready var shuttle_spawn: Marker2D = $BasinSurface/ShuttleSpawn
@onready var stalker_spawn: Marker2D = $BasinSurface/StalkerSpawn
@onready var stalker: Stalker = $Stalker
@onready var lethal_hazard: Area2D = $BasinSurface/LethalHazard
@onready var return_area: Area2D = $ReturnArea
@onready var return_prompt: PanelContainer = $Interface/ReturnPrompt
@onready var retry_timer: Timer = $RetryTimer
@onready var redeploy_feedback: Control = $Interface/RedeployFeedback

var retry_in_progress: bool = false
var transition_blocked: bool = false
var player_in_return_range: bool = false


func _ready() -> void:
	player.global_position = shuttle_spawn.global_position
	player.configure_for_location(true, BASIN_CAMERA_BOUNDS)
	stalker.global_position = stalker_spawn.global_position
	stalker.set_target_player(player)
	player.died.connect(_on_player_died)
	player.shot_requested.connect(_on_player_shot_requested)
	lethal_hazard.body_entered.connect(_on_lethal_hazard_body_entered)
	return_area.body_entered.connect(_on_return_area_body_entered)
	return_area.body_exited.connect(_on_return_area_body_exited)
	retry_timer.timeout.connect(_on_retry_timer_timeout)


func _process(_delta: float) -> void:
	_update_return_proximity()
	if Input.is_action_just_pressed(&"interact"):
		request_mothership_return()


func initialize_from_run_state(state: RunState) -> void:
	if state.has_basin_encounter():
		stalker.restore_encounter(state.basin_encounter)
	player.respawn_at(shuttle_spawn.global_position)
	player.configure_for_location(true, BASIN_CAMERA_BOUNDS)


func request_mothership_return() -> bool:
	_update_return_proximity()
	if transition_blocked or retry_in_progress or not player_in_return_range or not player.is_alive:
		return false
	location_change_requested.emit(&"mothership")
	return true


func prepare_for_mothership_return(state: RunState) -> bool:
	_update_return_proximity()
	if transition_blocked or retry_in_progress or not player_in_return_range or not player.is_alive:
		return false
	transition_blocked = true
	state.store_basin_encounter(stalker.capture_encounter())
	clear_active_pulses()
	player.set_transition_locked(true)
	stalker.set_physics_process(false)
	return_prompt.visible = false
	return true


func request_retry() -> bool:
	if retry_in_progress or transition_blocked:
		return false

	retry_in_progress = true
	clear_active_pulses()
	player.visible = false
	return_prompt.visible = false
	redeploy_feedback.visible = true
	retry_timer.start(retry_delay_seconds)
	retry_started.emit()
	return true


func _on_lethal_hazard_body_entered(body: Node2D) -> void:
	if body == player and not transition_blocked:
		player.die()


func _on_player_died() -> void:
	request_retry()


func _on_player_shot_requested(muzzle_position: Vector2, direction: Vector2) -> void:
	if transition_blocked or retry_in_progress:
		return
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
	return_prompt.visible = player_in_return_range
	retry_completed.emit()


func _on_return_area_body_entered(body: Node2D) -> void:
	if body != player:
		return
	player_in_return_range = true
	return_prompt.visible = not retry_in_progress and not transition_blocked


func _on_return_area_body_exited(body: Node2D) -> void:
	if body != player:
		return
	player_in_return_range = false
	return_prompt.visible = false


func _update_return_proximity() -> void:
	var shape := return_area.get_node("CollisionShape2D") as CollisionShape2D
	var radius := (shape.shape as CircleShape2D).radius
	player_in_return_range = player.global_position.distance_to(return_area.global_position) <= radius
	return_prompt.visible = (
		player_in_return_range and not retry_in_progress and not transition_blocked
	)
