class_name CodexState
extends RefCounted

const CATALOG: KnowledgeCatalog = preload("res://knowledge/knowledge_catalog.tres")
const MAX_SEARCH_RESULTS := 5

var observed_evidence_ids: Array[String] = []
var confirmed_meanings: Dictionary = {}
var confirmed_destination_id: String = ""


func observe_evidence(evidence_id: String) -> Dictionary:
	if CATALOG.get_evidence(evidence_id) == null:
		return {"ok": false, "changed": false, "error": "UNKNOWN EVIDENCE: %s" % evidence_id}
	if observed_evidence_ids.has(evidence_id):
		return {"ok": true, "changed": false, "error": ""}
	observed_evidence_ids.append(evidence_id)
	return {"ok": true, "changed": true, "error": ""}


func has_observed(evidence_id: String) -> bool:
	return observed_evidence_ids.has(evidence_id)


func has_all_required_evidence() -> bool:
	for evidence_id: String in CATALOG.required_evidence_ids:
		if not observed_evidence_ids.has(evidence_id):
			return false
	return true


func attempt_destination(destination_id: String) -> Dictionary:
	if destination_id == CATALOG.decoy_destination_id:
		return {
			"ok": false,
			"changed": false,
			"error": "CAIRN MISMATCH: SOUTH / II / RESONANT",
		}
	if destination_id != CATALOG.correct_destination_id:
		return {"ok": false, "changed": false, "error": "UNKNOWN CAIRN PATTERN"}
	if not has_all_required_evidence():
		return {
			"ok": false,
			"changed": false,
			"error": "PATTERN UNRESOLVED: EVIDENCE %d/%d" % [
				observed_evidence_ids.size(), CATALOG.required_evidence_ids.size()
			],
		}
	if confirmed_destination_id == CATALOG.correct_destination_id:
		return {"ok": true, "changed": false, "error": ""}
	confirmed_meanings = CATALOG.expected_meanings()
	confirmed_destination_id = CATALOG.correct_destination_id
	return {"ok": true, "changed": true, "error": ""}


func evidence_count_for_term(token: String) -> int:
	var count := 0
	for definition: EvidenceDefinition in CATALOG.evidence_for_term(token):
		if observed_evidence_ids.has(definition.evidence_id):
			count += 1
	return count


func search(query: String) -> Array[String]:
	var normalized := query.strip_edges().to_lower()
	var results: Array[String] = []
	if normalized.is_empty():
		return results
	for term: AlienTermDefinition in CATALOG.terms:
		var observed_count := evidence_count_for_term(term.token)
		if observed_count == 0:
			continue
		var searchable := term.token.to_lower()
		for evidence: EvidenceDefinition in CATALOG.evidence_for_term(term.token):
			if observed_evidence_ids.has(evidence.evidence_id):
				searchable += " %s %s" % [evidence.title.to_lower(), evidence.observation.to_lower()]
		if confirmed_meanings.has(term.token):
			searchable += " %s" % String(confirmed_meanings[term.token]).to_lower()
		if not searchable.contains(normalized):
			continue
		if confirmed_meanings.has(term.token):
			results.append("%s = %s | CONFIRMED: NORTH SHELF SURVEY CAIRN" % [
				term.token, confirmed_meanings[term.token]
			])
		else:
			results.append("%s | MEANING UNCONFIRMED | EVIDENCE %d" % [
				term.token, observed_count
			])
		if results.size() == MAX_SEARCH_RESULTS:
			break
	return results


func evidence_lines(token: String) -> Dictionary:
	var term := CATALOG.get_term(token)
	if term == null:
		return {"ok": false, "lines": [], "error": "UNKNOWN TERM: %s" % token.to_upper()}
	var lines: Array[String] = []
	for evidence: EvidenceDefinition in CATALOG.evidence_for_term(term.token):
		if observed_evidence_ids.has(evidence.evidence_id):
			lines.append("%s: %s" % [evidence.title, evidence.observation])
	if lines.is_empty():
		return {
			"ok": false,
			"lines": [],
			"error": "NO OBSERVED EVIDENCE: %s" % term.token,
		}
	return {"ok": true, "lines": lines, "error": ""}


func to_dictionary() -> Dictionary:
	return {
		"observed_evidence_ids": observed_evidence_ids.duplicate(),
		"confirmed_meanings": confirmed_meanings.duplicate(true),
		"confirmed_destination_id": confirmed_destination_id,
	}


static func from_dictionary(value: Variant) -> Dictionary:
	if value is not Dictionary:
		return _failure("codex state is not an object")
	var data := value as Dictionary
	for key: String in [
		"observed_evidence_ids", "confirmed_meanings", "confirmed_destination_id"
	]:
		if not data.has(key):
			return _failure("codex state is missing %s" % key)
	if data["observed_evidence_ids"] is not Array:
		return _failure("codex evidence ids are not an array")
	if data["confirmed_meanings"] is not Dictionary:
		return _failure("codex meanings are not an object")
	if data["confirmed_destination_id"] is not String:
		return _failure("codex destination is not text")

	var state := CodexState.new()
	for id_value: Variant in data["observed_evidence_ids"]:
		if id_value is not String or CATALOG.get_evidence(id_value) == null:
			return _failure("codex contains an unknown evidence id")
		if state.observed_evidence_ids.has(id_value):
			return _failure("codex contains a duplicate evidence id")
		state.observed_evidence_ids.append(id_value)
	state.confirmed_destination_id = data["confirmed_destination_id"]
	var loaded_meanings := data["confirmed_meanings"] as Dictionary
	if state.confirmed_destination_id.is_empty():
		if not loaded_meanings.is_empty():
			return _failure("unconfirmed codex contains meanings")
	elif state.confirmed_destination_id == CATALOG.correct_destination_id:
		if not state.has_all_required_evidence() or loaded_meanings != CATALOG.expected_meanings():
			return _failure("confirmed codex truth is inconsistent")
		state.confirmed_meanings = loaded_meanings.duplicate(true)
	else:
		return _failure("codex destination is invalid")
	return {"ok": true, "state": state, "error": ""}


static func _failure(message: String) -> Dictionary:
	return {"ok": false, "state": null, "error": message}
