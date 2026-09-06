class_name RunState
extends RefCounted

const AUTHORED_RUN_SEED := 51005


class BasinEncounterState extends RefCounted:
	var position: Vector2 = Vector2.ZERO
	var behavior_state: int = 0
	var elapsed_seconds: float = 0.0
	var hits_remaining: int = 3
	var committed_direction: Vector2 = Vector2.ZERO

	func duplicate_state() -> BasinEncounterState:
		var copy := BasinEncounterState.new()
		copy.position = position
		copy.behavior_state = behavior_state
		copy.elapsed_seconds = elapsed_seconds
		copy.hits_remaining = hits_remaining
		copy.committed_direction = committed_direction
		return copy

	func to_dictionary() -> Dictionary:
		return {
			"position": {"x": position.x, "y": position.y},
			"behavior_state": behavior_state,
			"elapsed_seconds": elapsed_seconds,
			"hits_remaining": hits_remaining,
			"committed_direction": {
				"x": committed_direction.x,
				"y": committed_direction.y,
			},
		}

	static func from_dictionary(value: Variant) -> Dictionary:
		if value is not Dictionary:
			return {"ok": false, "snapshot": null, "error": "encounter is not an object"}
		var data := value as Dictionary
		for key: String in [
			"position", "behavior_state", "elapsed_seconds", "hits_remaining",
			"committed_direction"
		]:
			if not data.has(key):
				return {"ok": false, "snapshot": null, "error": "encounter is missing %s" % key}
		var position_result := _parse_vector(data["position"])
		var direction_result := _parse_vector(data["committed_direction"])
		var state_result := JournalEntry._parse_integer(data["behavior_state"])
		var hits_result := JournalEntry._parse_integer(data["hits_remaining"])
		if not position_result.ok or not direction_result.ok:
			return {"ok": false, "snapshot": null, "error": "encounter vector is invalid"}
		if not state_result.ok or state_result.value < 0 or state_result.value > 4:
			return {"ok": false, "snapshot": null, "error": "encounter state is invalid"}
		if not hits_result.ok or hits_result.value < 0 or hits_result.value > 3:
			return {"ok": false, "snapshot": null, "error": "encounter hits are invalid"}
		if data["elapsed_seconds"] is not float and data["elapsed_seconds"] is not int:
			return {"ok": false, "snapshot": null, "error": "encounter time is invalid"}
		var elapsed := float(data["elapsed_seconds"])
		if not is_finite(elapsed) or elapsed < 0.0 or elapsed > 60.0:
			return {"ok": false, "snapshot": null, "error": "encounter time is invalid"}
		var snapshot := BasinEncounterState.new()
		snapshot.position = position_result.value
		snapshot.behavior_state = state_result.value
		snapshot.elapsed_seconds = elapsed
		snapshot.hits_remaining = hits_result.value
		snapshot.committed_direction = direction_result.value
		return {"ok": true, "snapshot": snapshot, "error": ""}

	static func _parse_vector(value: Variant) -> Dictionary:
		if value is not Dictionary:
			return {"ok": false, "value": Vector2.ZERO}
		var data := value as Dictionary
		if not data.has("x") or not data.has("y"):
			return {"ok": false, "value": Vector2.ZERO}
		if (data["x"] is not float and data["x"] is not int) or (
			data["y"] is not float and data["y"] is not int
		):
			return {"ok": false, "value": Vector2.ZERO}
		var vector := Vector2(float(data["x"]), float(data["y"]))
		if not is_finite(vector.x) or not is_finite(vector.y):
			return {"ok": false, "value": Vector2.ZERO}
		if absf(vector.x) > 100000.0 or absf(vector.y) > 100000.0:
			return {"ok": false, "value": Vector2.ZERO}
		return {"ok": true, "value": vector}


var basin_encounter: BasinEncounterState = null
var run_seed: int = AUTHORED_RUN_SEED
var journal: FieldJournal = FieldJournal.new()
var codex: CodexState = CodexState.new()


func store_basin_encounter(snapshot: BasinEncounterState) -> void:
	basin_encounter = snapshot.duplicate_state()


func has_basin_encounter() -> bool:
	return basin_encounter != null


func to_dictionary() -> Dictionary:
	return {
		"run_seed": run_seed,
		"journal": journal.to_dictionary(),
		"codex": codex.to_dictionary(),
		"basin_encounter": basin_encounter.to_dictionary() if basin_encounter != null else null,
	}


static func from_dictionary(value: Variant, migrate_version_1: bool = false) -> Dictionary:
	if value is not Dictionary:
		return _load_failure("run state is not an object")
	var data := value as Dictionary
	for key: String in ["run_seed", "journal", "basin_encounter"]:
		if not data.has(key):
			return _load_failure("run state is missing %s" % key)
	if not migrate_version_1 and not data.has("codex"):
		return _load_failure("run state is missing codex")
	var seed_result := JournalEntry._parse_integer(data["run_seed"])
	if not seed_result.ok or seed_result.value <= 0:
		return _load_failure("run seed is invalid")
	var journal_result := FieldJournal.from_dictionary(data["journal"])
	if not journal_result.ok:
		return _load_failure(journal_result.error)

	var state := RunState.new()
	state.run_seed = seed_result.value
	state.journal = journal_result.journal
	if not migrate_version_1:
		var codex_result := CodexState.from_dictionary(data["codex"])
		if not codex_result.ok:
			return _load_failure(codex_result.error)
		state.codex = codex_result.state
	if data["basin_encounter"] != null:
		var encounter_result := BasinEncounterState.from_dictionary(data["basin_encounter"])
		if not encounter_result.ok:
			return _load_failure(encounter_result.error)
		state.basin_encounter = encounter_result.snapshot
	return {"ok": true, "state": state, "error": ""}


static func _load_failure(message: String) -> Dictionary:
	return {"ok": false, "state": null, "error": message}
