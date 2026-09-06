class_name EvidenceSite
extends Area2D

signal availability_changed(site: EvidenceSite, available: bool)

@export var evidence_id: String = ""
@export var destination_id: String = ""
@export var marker_text: String = "EVIDENCE"
@export var marker_color: Color = Color(0.12, 0.42, 0.42, 1)
@export_range(40.0, 140.0, 2.0) var interaction_radius: float = 82.0

@onready var core: Polygon2D = $Core
@onready var glyph: Label = $Glyph
@onready var interaction_shape: CollisionShape2D = $InteractionShape

var player_inside: bool = false


func _ready() -> void:
	core.color = marker_color
	glyph.text = marker_text
	(interaction_shape.shape as CircleShape2D).radius = interaction_radius
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func is_evidence() -> bool:
	return not evidence_id.is_empty()


func is_destination() -> bool:
	return not destination_id.is_empty()


func _on_body_entered(body: Node2D) -> void:
	if body is not BasinExplorer:
		return
	player_inside = true
	availability_changed.emit(self, true)


func _on_body_exited(body: Node2D) -> void:
	if body is not BasinExplorer:
		return
	player_inside = false
	availability_changed.emit(self, false)
