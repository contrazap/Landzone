class_name CommandConsole
extends Control

signal console_opened
signal console_closed

@onready var command_input: LineEdit = $Panel/CommandInput
@onready var response_label: RichTextLabel = $Panel/Response
@onready var available_label: Label = $Panel/Available
@onready var title_label: Label = $Panel/Title
@onready var response_caption_label: Label = $Panel/ResponseCaption

var _open_allowed: Callable
var _open_enabled: bool = true
var _owns_tree_pause: bool = false
var _processor := CommandProcessor.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	command_input.text_submitted.connect(_on_text_submitted)
	visibility_changed.connect(_on_visibility_changed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"command_console") and not event.is_echo():
		if visible:
			close_console()
		else:
			open_console()
		get_viewport().set_input_as_handled()
		return
	if visible and event.is_action_pressed(&"ui_cancel") and not event.is_echo():
		close_console()
		get_viewport().set_input_as_handled()


func configure(where_provider: Callable, open_allowed: Callable) -> void:
	_processor.configure_where(where_provider)
	_open_allowed = open_allowed


func configure_journal(
	journal: FieldJournal,
	coordinate_provider: Callable,
	coordinate_formatter: Callable,
	run_seed: int,
	persist_callback: Callable
) -> void:
	_processor.configure_journal(
		journal, coordinate_provider, coordinate_formatter, run_seed, persist_callback
	)


func set_time_provider(provider: Callable) -> void:
	_processor.set_time_provider(provider)


func configure_codex(codex: CodexState, enabled: bool) -> void:
	_processor.configure_codex(codex, enabled)


# Locations own their console wording: the same commands read differently in the field
# and at a ship station, where the surveyed-region commands are unavailable.
func set_station_text(
	title: String, available: String, placeholder: String, response_caption: String
) -> void:
	title_label.text = title
	available_label.text = available
	command_input.placeholder_text = placeholder
	response_caption_label.text = response_caption


func is_console_open() -> bool:
	return visible


func set_open_enabled(enabled: bool) -> void:
	_open_enabled = enabled
	if not enabled and visible:
		close_console()


func open_console() -> bool:
	if visible or not _open_enabled or get_tree().paused:
		return false
	if _open_allowed.is_valid() and not bool(_open_allowed.call()):
		return false
	command_input.clear()
	response_label.text = "ENTER A COMMAND"
	visible = true
	get_tree().paused = true
	_owns_tree_pause = true
	command_input.call_deferred(&"grab_focus")
	console_opened.emit()
	return true


func close_console() -> bool:
	if not visible:
		return false
	command_input.release_focus()
	visible = false
	if _owns_tree_pause and is_inside_tree():
		get_tree().paused = false
	_owns_tree_pause = false
	console_closed.emit()
	return true


func submit_command(raw_command: String) -> String:
	var response := _processor.submit_command(raw_command)
	response_label.text = response
	command_input.clear()
	command_input.call_deferred(&"grab_focus")
	return response


func _on_text_submitted(command: String) -> void:
	submit_command(command)


func _on_visibility_changed() -> void:
	if not visible and _owns_tree_pause and is_inside_tree():
		get_tree().paused = false
		_owns_tree_pause = false


func _exit_tree() -> void:
	if _owns_tree_pause:
		get_tree().paused = false
		_owns_tree_pause = false
