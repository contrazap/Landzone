class_name JournalEntry
extends RefCounted

const MAX_TOTAL_TEXT_LENGTH := 2000
const MAX_TAGS := 8
const MAX_TAG_LENGTH := 24
const VALID_FACINGS: Array[String] = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]

var entry_id: int = 0
var text: String = ""
var region_id: StringName = &""
var north_steps: int = 0
var east_steps: int = 0
var facing: String = "E"
var run_seed: int = 0
var discovered_unix_time: int = 0
var tags: Array[String] = []


func duplicate_entry() -> JournalEntry:
	var copy := JournalEntry.new()
	copy.entry_id = entry_id
	copy.text = text
	copy.region_id = region_id
	copy.north_steps = north_steps
	copy.east_steps = east_steps
	copy.facing = facing
	copy.run_seed = run_seed
	copy.discovered_unix_time = discovered_unix_time
	copy.tags.assign(tags)
	return copy


func validate() -> String:
	if entry_id <= 0:
		return "entry id must be positive"
	if text.strip_edges().is_empty() or text.length() > MAX_TOTAL_TEXT_LENGTH:
		return "entry text length is invalid"
	if String(region_id).strip_edges().is_empty():
		return "entry region is missing"
	if absi(north_steps) > 999999 or absi(east_steps) > 999999:
		return "entry local coordinate is out of range"
	if not VALID_FACINGS.has(facing):
		return "entry facing is invalid"
	if run_seed <= 0:
		return "entry run seed is invalid"
	if discovered_unix_time <= 0:
		return "entry discovery time is invalid"
	if tags.size() > MAX_TAGS:
		return "entry has too many tags"
	var seen: Dictionary = {}
	for tag: String in tags:
		if not is_valid_tag(tag) or tag != tag.to_lower() or seen.has(tag):
			return "entry tag is invalid"
		seen[tag] = true
	return ""


func to_dictionary() -> Dictionary:
	return {
		"id": entry_id,
		"text": text,
		"region": String(region_id),
		"north": north_steps,
		"east": east_steps,
		"facing": facing,
		"run_seed": run_seed,
		"discovered_unix_time": discovered_unix_time,
		"tags": tags.duplicate(),
	}


static func from_dictionary(value: Variant) -> Dictionary:
	if value is not Dictionary:
		return _failure("journal entry is not an object")
	var data := value as Dictionary
	var required_keys: Array[String] = [
		"id", "text", "region", "north", "east", "facing", "run_seed",
		"discovered_unix_time", "tags"
	]
	for key: String in required_keys:
		if not data.has(key):
			return _failure("journal entry is missing %s" % key)

	var id_result := _parse_integer(data["id"])
	var north_result := _parse_integer(data["north"])
	var east_result := _parse_integer(data["east"])
	var seed_result := _parse_integer(data["run_seed"])
	var time_result := _parse_integer(data["discovered_unix_time"])
	if not id_result.ok or not north_result.ok or not east_result.ok:
		return _failure("journal entry has a non-integer coordinate or id")
	if not seed_result.ok or not time_result.ok:
		return _failure("journal entry has a non-integer seed or discovery time")
	if data["text"] is not String or data["region"] is not String or data["facing"] is not String:
		return _failure("journal entry has invalid text metadata types")
	if data["tags"] is not Array:
		return _failure("journal entry tags are not an array")

	var entry := JournalEntry.new()
	entry.entry_id = id_result.value
	entry.text = data["text"]
	entry.region_id = StringName(data["region"])
	entry.north_steps = north_result.value
	entry.east_steps = east_result.value
	entry.facing = data["facing"]
	entry.run_seed = seed_result.value
	entry.discovered_unix_time = time_result.value
	for tag_value: Variant in data["tags"]:
		if tag_value is not String:
			return _failure("journal entry contains a non-text tag")
		entry.tags.append(tag_value)
	var validation_error := entry.validate()
	if not validation_error.is_empty():
		return _failure(validation_error)
	return {"ok": true, "entry": entry, "error": ""}


static func is_valid_tag(tag: String) -> bool:
	if tag.is_empty() or tag.length() > MAX_TAG_LENGTH:
		return false
	for index: int in tag.length():
		var code := tag.unicode_at(index)
		var is_letter := code >= 97 and code <= 122
		var is_digit := code >= 48 and code <= 57
		if not is_letter and not is_digit and code != 95 and code != 45:
			return false
	return true


static func _parse_integer(value: Variant) -> Dictionary:
	if value is int:
		return {"ok": true, "value": value}
	if value is float and is_finite(value) and value == floorf(value):
		return {"ok": true, "value": int(value)}
	return {"ok": false, "value": 0}


static func _failure(message: String) -> Dictionary:
	return {"ok": false, "entry": null, "error": message}
