class_name RunSaveStore
extends RefCounted

const SAVE_VERSION := 2
const LEGACY_SAVE_VERSION := 1
const DEFAULT_SAVE_PATH := "user://landzone_save.json"

var save_path: String
var last_error: String = ""


func _init(configured_save_path: String = DEFAULT_SAVE_PATH) -> void:
	save_path = configured_save_path


func load_state() -> Dictionary:
	last_error = ""
	if not FileAccess.file_exists(save_path):
		return {"ok": true, "found": false, "state": RunState.new(), "error": ""}
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return _load_failure("could not open save (%s)" % FileAccess.get_open_error())
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK:
		return _load_failure(
			"invalid JSON at line %d: %s" % [json.get_error_line(), json.get_error_message()]
		)
	var payload: Variant = json.data
	if payload is not Dictionary:
		return _load_failure("save root is not an object")
	var data := payload as Dictionary
	if not data.has("save_version") or not data.has("run_state"):
		return _load_failure("save is missing required fields")
	var version_result := JournalEntry._parse_integer(data["save_version"])
	if not version_result.ok or (
		version_result.value != SAVE_VERSION and version_result.value != LEGACY_SAVE_VERSION
	):
		return _load_failure("unsupported save version")
	var migrated: bool = version_result.value == LEGACY_SAVE_VERSION
	var state_result := RunState.from_dictionary(data["run_state"], migrated)
	if not state_result.ok:
		return _load_failure(state_result.error)
	return {
		"ok": true,
		"found": true,
		"state": state_result.state,
		"migrated": migrated,
		"error": "",
	}


func save_state(state: RunState) -> bool:
	last_error = ""
	if save_path.strip_edges().is_empty():
		last_error = "save path is empty"
		return false
	var absolute_path := ProjectSettings.globalize_path(save_path)
	var directory_path := absolute_path.get_base_dir()
	var directory_error := DirAccess.make_dir_recursive_absolute(directory_path)
	if directory_error != OK:
		last_error = "could not create save directory (%s)" % directory_error
		return false

	var temp_path := "%s.tmp" % absolute_path
	var backup_path := "%s.bak" % absolute_path
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		last_error = "could not open temporary save (%s)" % FileAccess.get_open_error()
		return false
	var payload := {"save_version": SAVE_VERSION, "run_state": state.to_dictionary()}
	file.store_string(JSON.stringify(payload, "  "))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		last_error = "could not write temporary save (%s)" % write_error
		DirAccess.remove_absolute(temp_path)
		return false

	if FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(backup_path)
	var had_existing_save := FileAccess.file_exists(absolute_path)
	if had_existing_save:
		var backup_error := DirAccess.rename_absolute(absolute_path, backup_path)
		if backup_error != OK:
			last_error = "could not stage existing save (%s)" % backup_error
			DirAccess.remove_absolute(temp_path)
			return false
	var install_error := DirAccess.rename_absolute(temp_path, absolute_path)
	if install_error != OK:
		last_error = "could not install new save (%s)" % install_error
		if had_existing_save:
			DirAccess.rename_absolute(backup_path, absolute_path)
		DirAccess.remove_absolute(temp_path)
		return false
	if had_existing_save and FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(backup_path)
	return true


func _load_failure(message: String) -> Dictionary:
	last_error = message
	return {"ok": false, "found": true, "state": RunState.new(), "error": message}
