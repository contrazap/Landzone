class_name Mothership
extends Node2D

signal location_change_requested(destination: StringName)

const KESTREL_CAMERA_BOUNDS := Rect2i(0, 0, 960, 540)

@onready var player: BasinExplorer = $Player
@onready var arrival_marker: Marker2D = $VehicleBayArrival
@onready var deploy_area: Area2D = $DeployArea
@onready var deploy_prompt: PanelContainer = $Interface/DeployPrompt

var player_in_deploy_range: bool = false
var transition_blocked: bool = false


func _ready() -> void:
	player.global_position = arrival_marker.global_position
	player.configure_for_location(false, KESTREL_CAMERA_BOUNDS)
	deploy_area.body_entered.connect(_on_deploy_area_body_entered)
	deploy_area.body_exited.connect(_on_deploy_area_body_exited)


func _process(_delta: float) -> void:
	_update_deploy_proximity()
	if Input.is_action_just_pressed(&"interact"):
		request_deployment()


func request_deployment() -> bool:
	_update_deploy_proximity()
	if transition_blocked or not player_in_deploy_range:
		return false
	location_change_requested.emit(&"basin")
	return true


func begin_transition() -> void:
	transition_blocked = true
	deploy_prompt.visible = false
	player.set_transition_locked(true)


func _on_deploy_area_body_entered(body: Node2D) -> void:
	if body != player:
		return
	player_in_deploy_range = true
	deploy_prompt.visible = not transition_blocked


func _on_deploy_area_body_exited(body: Node2D) -> void:
	if body != player:
		return
	player_in_deploy_range = false
	deploy_prompt.visible = false


func _update_deploy_proximity() -> void:
	var shape := deploy_area.get_node("CollisionShape2D") as CollisionShape2D
	var radius := (shape.shape as CircleShape2D).radius
	player_in_deploy_range = player.global_position.distance_to(deploy_area.global_position) <= radius
	deploy_prompt.visible = player_in_deploy_range and not transition_blocked
