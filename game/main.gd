class_name LandzoneMain
extends Node2D

signal transition_started(from_location: StringName, to_location: StringName)
signal transition_completed(location: StringName)
signal location_changed(location: StringName)

const MOTHERSHIP_SCENE: PackedScene = preload("res://mothership.tscn")
const BASIN_EXPEDITION_SCENE: PackedScene = preload("res://basin_expedition.tscn")

@export_range(0.1, 1.0, 0.05) var transition_delay_seconds: float = 0.25

@onready var location_container: Node2D = $ActiveLocation
@onready var transition_timer: Timer = $TransitionTimer
@onready var transition_overlay: Control = $Interface/TransitionOverlay
@onready var transition_message: Label = $Interface/TransitionOverlay/Message

var run_state: RunState = RunState.new()
var active_location: Node2D = null
var current_location: StringName = &""
var transition_in_progress: bool = false
var pending_location: StringName = &""


func _ready() -> void:
	transition_timer.timeout.connect(_on_transition_timer_timeout)
	_activate_location(&"mothership")


func request_location_change(destination: StringName, source: Node) -> bool:
	if transition_in_progress or source != active_location:
		return false
	if not _is_valid_route(current_location, destination):
		return false

	if current_location == &"basin":
		var expedition := active_location as BasinExpedition
		if expedition == null or not expedition.prepare_for_mothership_return(run_state):
			return false
	else:
		active_location.call(&"begin_transition")

	transition_in_progress = true
	pending_location = destination
	transition_message.text = (
		"STATIC TRANSFER\nDEPLOYING TO P1-BASIN-01"
		if destination == &"basin"
		else "STATIC TRANSFER\nRETURNING TO KESTREL"
	)
	transition_overlay.visible = true
	transition_timer.start(transition_delay_seconds)
	transition_started.emit(current_location, destination)
	return true


func _is_valid_route(from_location: StringName, destination: StringName) -> bool:
	return (
		(from_location == &"mothership" and destination == &"basin")
		or (from_location == &"basin" and destination == &"mothership")
	)


func _activate_location(location_name: StringName) -> void:
	if active_location != null:
		location_container.remove_child(active_location)
		active_location.free()
		active_location = null

	var scene: PackedScene = MOTHERSHIP_SCENE if location_name == &"mothership" else BASIN_EXPEDITION_SCENE
	active_location = scene.instantiate() as Node2D
	location_container.add_child(active_location)
	current_location = location_name
	var location_source := active_location
	active_location.location_change_requested.connect(
		func(destination: StringName) -> void:
			request_location_change(destination, location_source)
	)
	if active_location is BasinExpedition:
		(active_location as BasinExpedition).initialize_from_run_state(run_state)
	location_changed.emit(current_location)


func _on_transition_timer_timeout() -> void:
	var destination := pending_location
	pending_location = &""
	_activate_location(destination)
	transition_overlay.visible = false
	transition_in_progress = false
	transition_completed.emit(current_location)
