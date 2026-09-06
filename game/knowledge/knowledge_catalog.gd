class_name KnowledgeCatalog
extends Resource

@export var terms: Array[AlienTermDefinition] = []
@export var evidence_records: Array[EvidenceDefinition] = []
@export var required_evidence_ids: PackedStringArray = []
@export var solution_tokens: PackedStringArray = []
@export var correct_destination_id: String = ""
@export var decoy_destination_id: String = ""


func get_term(token: String) -> AlienTermDefinition:
	var normalized := token.strip_edges().to_upper()
	for definition: AlienTermDefinition in terms:
		if definition.token == normalized:
			return definition
	return null


func get_evidence(evidence_id: String) -> EvidenceDefinition:
	for definition: EvidenceDefinition in evidence_records:
		if definition.evidence_id == evidence_id:
			return definition
	return null


func evidence_for_term(token: String) -> Array[EvidenceDefinition]:
	var matching: Array[EvidenceDefinition] = []
	var normalized := token.strip_edges().to_upper()
	for definition: EvidenceDefinition in evidence_records:
		if definition.term_tokens.has(normalized):
			matching.append(definition)
	return matching


func expected_meanings() -> Dictionary:
	var mappings: Dictionary = {}
	for definition: AlienTermDefinition in terms:
		mappings[definition.token] = definition.meaning
	return mappings


func validate() -> String:
	if terms.size() < 3 or evidence_records.size() < 2:
		return "knowledge catalog is incomplete"
	var seen_terms: Dictionary = {}
	for definition: AlienTermDefinition in terms:
		if definition == null or definition.token.is_empty() or definition.meaning.is_empty():
			return "knowledge catalog has an incomplete term"
		if definition.token != definition.token.to_upper() or seen_terms.has(definition.token):
			return "knowledge catalog has an invalid or duplicate term"
		seen_terms[definition.token] = true
	var seen_evidence: Dictionary = {}
	for definition: EvidenceDefinition in evidence_records:
		if (
			definition == null
			or definition.evidence_id.is_empty()
			or definition.title.is_empty()
			or definition.observation.is_empty()
			or seen_evidence.has(definition.evidence_id)
		):
			return "knowledge catalog has an invalid or duplicate evidence record"
		for token: String in definition.term_tokens:
			if not seen_terms.has(token):
				return "evidence references an unknown term"
		seen_evidence[definition.evidence_id] = true
	for evidence_id: String in required_evidence_ids:
		if not seen_evidence.has(evidence_id):
			return "required evidence id is unknown"
	for token: String in solution_tokens:
		if not seen_terms.has(token):
			return "solution references an unknown term"
	if correct_destination_id.is_empty() or decoy_destination_id.is_empty():
		return "knowledge destinations are incomplete"
	return ""
