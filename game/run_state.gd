class_name RunState
extends RefCounted


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


var basin_encounter: BasinEncounterState = null


func store_basin_encounter(snapshot: BasinEncounterState) -> void:
	basin_encounter = snapshot.duplicate_state()


func has_basin_encounter() -> bool:
	return basin_encounter != null
