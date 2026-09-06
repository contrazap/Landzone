class_name BasinExpedition
extends Node2D

signal location_change_requested(destination: StringName)
signal retry_started
signal retry_completed

const BASE_PULSE_SCENE: PackedScene = preload("res://base_pulse.tscn")
const REGION_ID := &"P1-BASIN-01"
const BASIN_CAMERA_BOUNDS := Rect2i(0, 0, 2400, 1080)
const BASIN_ENCOUNTER_BOUNDS := Rect2(40.0, 70.0, 2320.0, 940.0)
const LOCAL_UNIT_PIXELS := 80.0

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
@onready var command_console: CommandConsole = $Interface/CommandConsole
@onready var evidence_reader: EvidenceReader = $Interface/EvidenceReader
@onready var knowledge_prompt: PanelContainer = $Interface/KnowledgePrompt
@onready var knowledge_prompt_label: Label = $Interface/KnowledgePrompt/Label

var retry_in_progress: bool = false
var transition_blocked: bool = false
var player_in_return_range: bool = false
var coordinate_service: CoordinateService
var run_state: RunState = null
var persist_run_state: Callable
var active_knowledge_site: EvidenceSite = null
var knowledge_sites: Array[EvidenceSite] = []


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
	coordinate_service = CoordinateService.new(REGION_ID, shuttle_spawn.global_position, LOCAL_UNIT_PIXELS)
	command_console.configure(
		Callable(self, &"get_where_text"),
		Callable(self, &"_can_open_command_console")
	)
	command_console.console_opened.connect(_on_command_console_opened)
	command_console.console_closed.connect(_on_command_console_closed)
	evidence_reader.reader_closed.connect(_on_evidence_reader_closed)
	for node: Node in get_tree().get_nodes_in_group(&"knowledge_site"):
		var site := node as EvidenceSite
		if site != null and is_ancestor_of(site):
			knowledge_sites.append(site)
			site.availability_changed.connect(_on_knowledge_site_availability_changed)


func _process(_delta: float) -> void:
	_update_return_proximity()
	_update_knowledge_proximity()
	if Input.is_action_just_pressed(&"interact"):
		if active_knowledge_site != null:
			request_knowledge_interaction()
		else:
			request_mothership_return()


func initialize_from_run_state(state: RunState, persist_callback: Callable = Callable()) -> void:
	run_state = state
	persist_run_state = persist_callback
	if state.has_basin_encounter():
		stalker.restore_encounter(state.basin_encounter, BASIN_ENCOUNTER_BOUNDS)
	command_console.configure_journal(
		state.journal,
		Callable(self, &"get_coordinate_stamp"),
		Callable(self, &"format_coordinate_stamp"),
		state.run_seed,
		persist_run_state
	)
	command_console.configure_codex(state.codex, false)
	player.respawn_at(shuttle_spawn.global_position)
	player.configure_for_location(true, BASIN_CAMERA_BOUNDS)
	command_console.set_open_enabled(true)


func get_where_text() -> String:
	return coordinate_service.format_where(player.global_position, player.facing_direction)


func get_coordinate_stamp() -> Dictionary:
	return coordinate_service.capture_stamp(player.global_position, player.facing_direction)


func format_coordinate_stamp(stamp: Dictionary) -> String:
	return coordinate_service.format_stamp(stamp)


func request_mothership_return() -> bool:
	_update_return_proximity()
	if (
		transition_blocked
		or retry_in_progress
		or command_console.is_console_open()
		or evidence_reader.is_reader_open()
		or not player_in_return_range
		or not player.is_alive
	):
		return false
	location_change_requested.emit(&"mothership")
	return true


func prepare_for_mothership_return(state: RunState) -> bool:
	_update_return_proximity()
	if (
		transition_blocked
		or retry_in_progress
		or evidence_reader.is_reader_open()
		or not player_in_return_range
		or not player.is_alive
	):
		return false
	transition_blocked = true
	command_console.set_open_enabled(false)
	knowledge_prompt.visible = false
	state.store_basin_encounter(stalker.capture_encounter())
	clear_active_pulses()
	player.set_transition_locked(true)
	stalker.set_physics_process(false)
	return_prompt.visible = false
	return true


func capture_durable_state(state: RunState) -> void:
	state.store_basin_encounter(stalker.capture_encounter())


func request_retry() -> bool:
	if retry_in_progress or transition_blocked:
		return false

	retry_in_progress = true
	command_console.set_open_enabled(false)
	knowledge_prompt.visible = false
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
	command_console.set_open_enabled(true)
	return_prompt.visible = player_in_return_range
	if run_state != null:
		run_state.store_basin_encounter(stalker.capture_encounter())
		if persist_run_state.is_valid():
			persist_run_state.call()
	retry_completed.emit()


func _can_open_command_console() -> bool:
	return (
		not transition_blocked
		and not retry_in_progress
		and not evidence_reader.is_reader_open()
		and player.is_alive
	)


func _on_command_console_opened() -> void:
	player.clear_transient_state()
	return_prompt.visible = false


func _on_command_console_closed() -> void:
	_update_return_proximity()
	_update_knowledge_prompt()


func request_knowledge_interaction() -> bool:
	if (
		active_knowledge_site == null
		or run_state == null
		or transition_blocked
		or retry_in_progress
		or command_console.is_console_open()
		or evidence_reader.is_reader_open()
		or not player.is_alive
	):
		return false
	var site := active_knowledge_site
	var opened := false
	if site.is_evidence():
		var definition := CodexState.CATALOG.get_evidence(site.evidence_id)
		var result := run_state.codex.observe_evidence(site.evidence_id)
		if not result.ok:
			return false
		if result.changed and persist_run_state.is_valid():
			persist_run_state.call()
		opened = evidence_reader.show_evidence(definition, result.changed)
	elif site.is_destination():
		var result := run_state.codex.attempt_destination(site.destination_id)
		if result.changed and persist_run_state.is_valid():
			persist_run_state.call()
		if result.ok:
			opened = evidence_reader.show_message(
				"PATTERN CONFIRMED",
				"NORTH SHELF SURVEY CAIRN // N04 E23",
				"ACHVNTSAT = NORTH   |   VEL = THREE   |   ORUUN = SILENT STONE",
				"Three matte stones return no visible resonance. Authoritative meanings confirmed."
			)
		else:
			opened = evidence_reader.show_message(
				"PATTERN REJECTED",
				"CAIRN VALIDATION",
				result.error,
				"No confirmed codex fact changed. Compare direction, count, and material response."
			)
	if opened:
		player.clear_transient_state()
		knowledge_prompt.visible = false
		return true
	return false


func _on_knowledge_site_availability_changed(site: EvidenceSite, available: bool) -> void:
	if available:
		active_knowledge_site = site
	elif active_knowledge_site == site:
		active_knowledge_site = null
	_update_knowledge_prompt()


func _on_evidence_reader_closed() -> void:
	_update_return_proximity()
	_update_knowledge_prompt()


func _update_knowledge_prompt() -> void:
	var available := (
		active_knowledge_site != null
		and not transition_blocked
		and not retry_in_progress
		and not command_console.is_console_open()
		and not evidence_reader.is_reader_open()
		and player.is_alive
	)
	knowledge_prompt.visible = available
	if available:
		knowledge_prompt_label.text = (
			"E - OBSERVE EVIDENCE"
			if active_knowledge_site.is_evidence()
			else "E - INSPECT CAIRN PATTERN"
		)


func _update_knowledge_proximity() -> void:
	var closest: EvidenceSite = null
	var closest_distance := INF
	for site: EvidenceSite in knowledge_sites:
		var distance := player.global_position.distance_to(site.global_position)
		if distance <= site.interaction_radius and distance < closest_distance:
			closest = site
			closest_distance = distance
	active_knowledge_site = closest
	_update_knowledge_prompt()


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
		player_in_return_range
		and not retry_in_progress
		and not transition_blocked
		and not command_console.is_console_open()
		and not evidence_reader.is_reader_open()
	)
