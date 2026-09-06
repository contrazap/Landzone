class_name CommandProcessor
extends RefCounted

var _where_provider: Callable
var _journal: FieldJournal = null
var _coordinate_provider: Callable
var _coordinate_formatter: Callable
var _persist_callback: Callable
var _time_provider: Callable
var _run_seed: int = 0
var _codex: CodexState = null
var _codex_enabled: bool = false


func configure_where(where_provider: Callable) -> void:
	_where_provider = where_provider


func configure_journal(
	journal: FieldJournal,
	coordinate_provider: Callable,
	coordinate_formatter: Callable,
	run_seed: int,
	persist_callback: Callable
) -> void:
	_journal = journal
	_coordinate_provider = coordinate_provider
	_coordinate_formatter = coordinate_formatter
	_run_seed = run_seed
	_persist_callback = persist_callback


func set_time_provider(provider: Callable) -> void:
	_time_provider = provider


func configure_codex(codex: CodexState, enabled: bool) -> void:
	_codex = codex
	_codex_enabled = enabled


func submit_command(raw_command: String) -> String:
	var normalized := raw_command.strip_edges()
	if normalized.is_empty():
		return "ENTER A COMMAND"
	var tokenized := _tokenize(normalized)
	if not tokenized.ok:
		return tokenized.error
	var words: Array[String] = []
	words.assign(tokenized.tokens)
	var quoted: Array[bool] = []
	quoted.assign(tokenized.quoted)
	var verb := words[0].to_lower()
	match verb:
		"where":
			if words.size() != 1:
				return "USAGE: where"
			if not _where_provider.is_valid():
				return "WHERE UNAVAILABLE"
			return str(_where_provider.call())
		"journal":
			return _submit_journal(words, quoted)
		"codex":
			return _submit_codex(words)
		_:
			return "UNKNOWN COMMAND: %s" % verb


func _submit_codex(words: Array[String]) -> String:
	if _codex == null or not _codex_enabled:
		return "CODEX AVAILABLE AT KESTREL RESEARCH"
	if words.size() < 2:
		return "USAGE: codex search|evidence"
	match words[1].to_lower():
		"search":
			if words.size() < 3:
				return "USAGE: codex search <query>"
			var query := " ".join(PackedStringArray(words.slice(2)))
			var results := _codex.search(query)
			if results.is_empty():
				return "NO CODEX MATCHES: %s" % query
			return "CODEX MATCHES\n%s" % "\n".join(PackedStringArray(results))
		"evidence":
			if words.size() != 3:
				return "USAGE: codex evidence <term>"
			var result := _codex.evidence_lines(words[2])
			if not result.ok:
				return result.error
			var lines: Array[String] = ["EVIDENCE: %s" % words[2].to_upper()]
			lines.append_array(result.lines)
			return "\n".join(PackedStringArray(lines))
		_:
			return "UNKNOWN CODEX COMMAND: %s" % words[1].to_lower()


func _submit_journal(words: Array[String], quoted: Array[bool]) -> String:
	if _journal == null:
		return "JOURNAL UNAVAILABLE"
	if words.size() < 2:
		return "USAGE: journal add|find|read|tag|append"
	match words[1].to_lower():
		"add": return _journal_add(words, quoted)
		"find": return _journal_find(words)
		"read": return _journal_read(words)
		"tag": return _journal_tag(words)
		"append": return _journal_append(words, quoted)
		_: return "UNKNOWN JOURNAL COMMAND: %s" % words[1].to_lower()


func _journal_add(words: Array[String], quoted: Array[bool]) -> String:
	if words.size() != 3 or not quoted[2]:
		return "USAGE: journal add \"<text>\""
	if not _coordinate_provider.is_valid():
		return "LOCATION UNAVAILABLE"
	var stamp: Variant = _coordinate_provider.call()
	if stamp is not Dictionary:
		return "LOCATION UNAVAILABLE"
	var result := _journal.add_entry(words[2], stamp, _run_seed, _current_unix_time())
	if not result.ok:
		return result.error
	var entry := result.entry as JournalEntry
	var saved := _persist()
	return "ENTRY #%d %s\n%s" % [
		entry.entry_id,
		"SAVED" if saved else "ADDED | SAVE FAILED",
		_format_entry_location(entry),
	]


func _journal_find(words: Array[String]) -> String:
	if words.size() < 3:
		return "USAGE: journal find <query>"
	var query := " ".join(PackedStringArray(words.slice(2)))
	var results := _journal.find_entries(query)
	if results.is_empty():
		return "NO JOURNAL MATCHES: %s" % query
	var lines: Array[String] = ["MATCHES (NEWEST FIRST)"]
	for entry: JournalEntry in results:
		var tag_text := "" if entry.tags.is_empty() else " [%s]" % _join_tags(entry.tags)
		var preview := entry.text.replace("\n", " ")
		var preview_limit := maxi(24, 68 - tag_text.length())
		if preview.length() > preview_limit:
			preview = "%s..." % preview.left(preview_limit - 3)
		lines.append("#%d%s %s" % [entry.entry_id, tag_text, preview])
	return "\n".join(PackedStringArray(lines))


func _journal_read(words: Array[String]) -> String:
	if words.size() != 3:
		return "USAGE: journal read <id>"
	var entry_id := _parse_entry_id(words[2])
	if entry_id <= 0:
		return "INVALID ENTRY ID: %s" % words[2]
	var entry := _journal.get_entry(entry_id)
	if entry == null:
		return "ENTRY #%d NOT FOUND" % entry_id
	return "#%d | %s\nSEED %d | UTC %s\nTAGS %s\n%s" % [
		entry.entry_id,
		_format_entry_location(entry),
		entry.run_seed,
		Time.get_datetime_string_from_unix_time(entry.discovered_unix_time, true),
		"NONE" if entry.tags.is_empty() else _join_tags(entry.tags),
		entry.text,
	]


func _journal_tag(words: Array[String]) -> String:
	if words.size() < 4:
		return "USAGE: journal tag <id> <tag> [tag...]"
	var entry_id := _parse_entry_id(words[2])
	if entry_id <= 0:
		return "INVALID ENTRY ID: %s" % words[2]
	var tags: Array[String] = []
	tags.assign(words.slice(3))
	var result := _journal.add_tags(entry_id, tags)
	if not result.ok:
		return result.error
	var entry := result.entry as JournalEntry
	var saved := _persist()
	return "ENTRY #%d TAGS %s | %s" % [
		entry.entry_id, _join_tags(entry.tags), "SAVED" if saved else "SAVE FAILED"
	]


func _journal_append(words: Array[String], quoted: Array[bool]) -> String:
	if words.size() != 4 or not quoted[3]:
		return "USAGE: journal append <id> \"<text>\""
	var entry_id := _parse_entry_id(words[2])
	if entry_id <= 0:
		return "INVALID ENTRY ID: %s" % words[2]
	var result := _journal.append_text(entry_id, words[3])
	if not result.ok:
		return result.error
	var saved := _persist()
	return "ENTRY #%d APPENDED | %s" % [entry_id, "SAVED" if saved else "SAVE FAILED"]


func _tokenize(command: String) -> Dictionary:
	var tokens: Array[String] = []
	var quoted_tokens: Array[bool] = []
	var current := ""
	var in_quotes := false
	var token_started := false
	var token_quoted := false
	var escaping := false
	for index: int in command.length():
		var character := command.substr(index, 1)
		if escaping:
			if character != "\"" and character != "\\":
				return {"ok": false, "error": "INVALID ESCAPE: \\%s" % character}
			current += character
			token_started = true
			escaping = false
			continue
		if character == "\\" and in_quotes:
			escaping = true
			continue
		if character == "\"":
			in_quotes = not in_quotes
			token_started = true
			token_quoted = true
			continue
		if character == " " or character == "\t":
			if in_quotes:
				current += character
			elif token_started:
				tokens.append(current)
				quoted_tokens.append(token_quoted)
				current = ""
				token_started = false
				token_quoted = false
			continue
		current += character
		token_started = true
	if escaping:
		return {"ok": false, "error": "UNFINISHED ESCAPE"}
	if in_quotes:
		return {"ok": false, "error": "UNCLOSED QUOTE"}
	if token_started:
		tokens.append(current)
		quoted_tokens.append(token_quoted)
	return {"ok": true, "tokens": tokens, "quoted": quoted_tokens, "error": ""}


func _current_unix_time() -> int:
	if _time_provider.is_valid():
		return int(_time_provider.call())
	return int(Time.get_unix_time_from_system())


func _parse_entry_id(value: String) -> int:
	if not value.is_valid_int():
		return -1
	var parsed := value.to_int()
	return parsed if parsed > 0 else -1


func _format_entry_location(entry: JournalEntry) -> String:
	var stamp := {
		"region": String(entry.region_id),
		"north": entry.north_steps,
		"east": entry.east_steps,
		"facing": entry.facing,
	}
	# Entries carry their own recorded stamp, so retrieval stays readable away from
	# the surveyed region that produced it, such as Kestrel Research.
	if not _coordinate_formatter.is_valid():
		return CoordinateService.format_stamp(stamp)
	return str(_coordinate_formatter.call(stamp))


func _join_tags(tags: Array[String]) -> String:
	return ", ".join(PackedStringArray(tags))


func _persist() -> bool:
	return _persist_callback.is_valid() and bool(_persist_callback.call())
