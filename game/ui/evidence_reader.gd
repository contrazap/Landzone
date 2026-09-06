class_name EvidenceReader
extends Control

signal reader_opened
signal reader_closed

@onready var status_label: Label = $Panel/Status
@onready var title_label: Label = $Panel/Title
@onready var glyph_label: Label = $Panel/Glyph
@onready var observation_label: RichTextLabel = $Panel/Observation

var _owns_tree_pause: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visibility_changed.connect(_on_visibility_changed)


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_cancel") and not event.is_echo():
		close_reader()
		get_viewport().set_input_as_handled()


func show_evidence(definition: EvidenceDefinition, newly_observed: bool) -> bool:
	if definition == null:
		return false
	return show_message(
		"NEW EVIDENCE" if newly_observed else "EVIDENCE REVIEW",
		definition.title,
		definition.glyph_line,
		definition.observation
	)


func show_message(status: String, title: String, glyphs: String, observation: String) -> bool:
	if visible or get_tree().paused:
		return false
	status_label.text = status
	title_label.text = title
	glyph_label.text = glyphs
	observation_label.text = observation
	visible = true
	get_tree().paused = true
	_owns_tree_pause = true
	reader_opened.emit()
	return true


func close_reader() -> bool:
	if not visible:
		return false
	visible = false
	if _owns_tree_pause and is_inside_tree():
		get_tree().paused = false
	_owns_tree_pause = false
	reader_closed.emit()
	return true


func is_reader_open() -> bool:
	return visible


func _on_visibility_changed() -> void:
	if not visible and _owns_tree_pause and is_inside_tree():
		get_tree().paused = false
		_owns_tree_pause = false


func _exit_tree() -> void:
	if _owns_tree_pause:
		get_tree().paused = false
		_owns_tree_pause = false
