class_name FieldJournal
extends RefCounted

const MAX_NEW_TEXT_LENGTH := 240
const MAX_SEARCH_RESULTS := 5

var entries: Array[JournalEntry] = []
var next_entry_id: int = 1


func add_entry(
	text: String,
	coordinate_stamp: Dictionary,
	run_seed: int,
	discovered_unix_time: int
) -> Dictionary:
	var cleaned_text := text.strip_edges()
	if cleaned_text.is_empty():
		return _failure("NOTE TEXT REQUIRED")
	if cleaned_text.length() > MAX_NEW_TEXT_LENGTH:
		return _failure("NOTE TOO LONG (MAX %d)" % MAX_NEW_TEXT_LENGTH)
	var stamp_error := _validate_coordinate_stamp(coordinate_stamp)
	if not stamp_error.is_empty():
		return _failure("LOCATION UNAVAILABLE")
	if run_seed <= 0 or discovered_unix_time <= 0:
		return _failure("JOURNAL METADATA UNAVAILABLE")

	var entry := JournalEntry.new()
	entry.entry_id = next_entry_id
	entry.text = cleaned_text
	entry.region_id = StringName(coordinate_stamp["region"])
	entry.north_steps = coordinate_stamp["north"]
	entry.east_steps = coordinate_stamp["east"]
	entry.facing = coordinate_stamp["facing"]
	entry.run_seed = run_seed
	entry.discovered_unix_time = discovered_unix_time
	var validation_error := entry.validate()
	if not validation_error.is_empty():
		return _failure("JOURNAL METADATA UNAVAILABLE")
	entries.append(entry)
	next_entry_id += 1
	return {"ok": true, "entry": entry, "error": ""}


func get_entry(entry_id: int) -> JournalEntry:
	for entry: JournalEntry in entries:
		if entry.entry_id == entry_id:
			return entry
	return null


func find_entries(query: String) -> Array[JournalEntry]:
	var results: Array[JournalEntry] = []
	var normalized_query := query.strip_edges().to_lower()
	if normalized_query.is_empty():
		return results
	for index: int in range(entries.size() - 1, -1, -1):
		var entry := entries[index]
		var matches := entry.text.to_lower().contains(normalized_query)
		if not matches:
			for tag: String in entry.tags:
				if tag.contains(normalized_query):
					matches = true
					break
		if matches:
			results.append(entry)
			if results.size() == MAX_SEARCH_RESULTS:
				break
	return results


func add_tags(entry_id: int, requested_tags: Array[String]) -> Dictionary:
	var entry := get_entry(entry_id)
	if entry == null:
		return _failure("ENTRY #%d NOT FOUND" % entry_id)
	if requested_tags.is_empty():
		return _failure("TAG REQUIRED")
	var normalized: Array[String] = []
	for requested_tag: String in requested_tags:
		var tag := requested_tag.strip_edges().to_lower()
		if not JournalEntry.is_valid_tag(tag):
			return _failure("INVALID TAG: %s" % requested_tag)
		if not normalized.has(tag) and not entry.tags.has(tag):
			normalized.append(tag)
	if entry.tags.size() + normalized.size() > JournalEntry.MAX_TAGS:
		return _failure("TOO MANY TAGS (MAX %d)" % JournalEntry.MAX_TAGS)
	entry.tags.append_array(normalized)
	return {"ok": true, "entry": entry, "error": ""}


func append_text(entry_id: int, appended_text: String) -> Dictionary:
	var entry := get_entry(entry_id)
	if entry == null:
		return _failure("ENTRY #%d NOT FOUND" % entry_id)
	var cleaned_text := appended_text.strip_edges()
	if cleaned_text.is_empty():
		return _failure("APPEND TEXT REQUIRED")
	if cleaned_text.length() > MAX_NEW_TEXT_LENGTH:
		return _failure("APPEND TOO LONG (MAX %d)" % MAX_NEW_TEXT_LENGTH)
	var combined := "%s\n%s" % [entry.text, cleaned_text]
	if combined.length() > JournalEntry.MAX_TOTAL_TEXT_LENGTH:
		return _failure("ENTRY TOO LONG (MAX %d)" % JournalEntry.MAX_TOTAL_TEXT_LENGTH)
	entry.text = combined
	return {"ok": true, "entry": entry, "error": ""}


func to_dictionary() -> Dictionary:
	var serialized_entries: Array[Dictionary] = []
	for entry: JournalEntry in entries:
		serialized_entries.append(entry.to_dictionary())
	return {"next_entry_id": next_entry_id, "entries": serialized_entries}


static func from_dictionary(value: Variant) -> Dictionary:
	if value is not Dictionary:
		return _load_failure("journal is not an object")
	var data := value as Dictionary
	if not data.has("next_entry_id") or not data.has("entries"):
		return _load_failure("journal is missing required fields")
	var next_result := JournalEntry._parse_integer(data["next_entry_id"])
	if not next_result.ok or next_result.value <= 0:
		return _load_failure("journal next id is invalid")
	if data["entries"] is not Array:
		return _load_failure("journal entries are not an array")

	var journal := FieldJournal.new()
	var previous_id := 0
	for entry_value: Variant in data["entries"]:
		var entry_result := JournalEntry.from_dictionary(entry_value)
		if not entry_result.ok:
			return _load_failure(entry_result.error)
		var entry := entry_result.entry as JournalEntry
		if entry.entry_id <= previous_id:
			return _load_failure("journal ids are not strictly increasing")
		journal.entries.append(entry)
		previous_id = entry.entry_id
	if next_result.value <= previous_id:
		return _load_failure("journal next id would reuse an entry id")
	journal.next_entry_id = next_result.value
	return {"ok": true, "journal": journal, "error": ""}


func _validate_coordinate_stamp(stamp: Dictionary) -> String:
	for key: String in ["region", "north", "east", "facing"]:
		if not stamp.has(key):
			return "missing %s" % key
	if stamp["region"] is not String and stamp["region"] is not StringName:
		return "invalid region"
	if stamp["north"] is not int or stamp["east"] is not int or stamp["facing"] is not String:
		return "invalid coordinate types"
	if String(stamp["region"]).strip_edges().is_empty():
		return "invalid region"
	if not JournalEntry.VALID_FACINGS.has(stamp["facing"]):
		return "invalid facing"
	return ""


func _failure(message: String) -> Dictionary:
	return {"ok": false, "entry": null, "error": message}


static func _load_failure(message: String) -> Dictionary:
	return {"ok": false, "journal": null, "error": message}
