class_name Mothership
extends Node2D

signal location_change_requested(destination: StringName)

const KESTREL_CAMERA_BOUNDS := Rect2i(0, 0, 960, 540)

@onready var player: BasinExplorer = $Player
@onready var arrival_marker: Marker2D = $VehicleBayArrival
@onready var deploy_area: Area2D = $DeployArea
@onready var deploy_prompt: PanelContainer = $Interface/DeployPrompt
@onready var research_area: Area2D = $ResearchArea
@onready var research_prompt: PanelContainer = $Interface/ResearchPrompt
@onready var research_console: CommandConsole = $Interface/ResearchConsole
@onready var research_label: Label = $StationLabels/Research

var player_in_deploy_range: bool = false
var transition_blocked: bool = false
var player_in_research_range: bool = false


func _ready() -> void:
	player.global_position = arrival_marker.global_position
	player.configure_for_location(false, KESTREL_CAMERA_BOUNDS)
	deploy_area.body_entered.connect(_on_deploy_area_body_entered)
	deploy_area.body_exited.connect(_on_deploy_area_body_exited)
	research_console.configure(Callable(), Callable(self, &"_can_open_research"))
	research_console.set_open_enabled(false)
	research_label.text = "RESEARCH\nCODEX ONLINE"
	research_label.modulate = Color(0.85, 0.95, 0.7, 1)


func _process(_delta: float) -> void:
	_update_deploy_proximity()
	_update_research_proximity()
	if Input.is_action_just_pressed(&"interact"):
		if player_in_research_range:
			research_console.open_console()
		else:
			request_deployment()


func initialize_from_run_state(state: RunState, persist_callback: Callable) -> void:
	research_console.configure_journal(
		state.journal, Callable(), Callable(), state.run_seed, persist_callback
	)
	research_console.configure_codex(state.codex, true)
	research_console.set_station_text(
		"KESTREL RESEARCH CODEX",
		"AVAILABLE: journal find / read / tag / append | codex search / evidence",
		"journal | codex ...",
		"RESEARCH RESPONSE"
	)
	research_console.set_open_enabled(true)


func request_deployment() -> bool:
	_update_deploy_proximity()
	if transition_blocked or research_console.is_console_open() or not player_in_deploy_range:
		return false
	location_change_requested.emit(&"basin")
	return true


func begin_transition() -> void:
	transition_blocked = true
	research_console.set_open_enabled(false)
	research_prompt.visible = false
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
	deploy_prompt.visible = (
		player_in_deploy_range and not transition_blocked and not research_console.is_console_open()
	)


func _can_open_research() -> bool:
	_update_research_proximity()
	return player_in_research_range and not transition_blocked


func _update_research_proximity() -> void:
	var shape := research_area.get_node("CollisionShape2D") as CollisionShape2D
	var radius := (shape.shape as CircleShape2D).radius
	player_in_research_range = player.global_position.distance_to(research_area.global_position) <= radius
	research_prompt.visible = (
		player_in_research_range and not transition_blocked and not research_console.is_console_open()
	)
