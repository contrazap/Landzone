class_name Stalker
extends CharacterBody2D

signal state_changed(previous_state: State, new_state: State)
signal attack_committed(direction: Vector2)
signal attack_landed
signal pulse_hit(hits_remaining: int)
signal defeated
signal encounter_reset(reset_count: int)

enum State {
	CONCEALED,
	TELEGRAPH,
	COMMITTED,
	RECOVERY,
	DEFEATED,
}

@export_range(50.0, 400.0, 5.0) var trigger_range: float = 235.0
@export_range(0.6, 3.0, 0.05) var telegraph_duration: float = 0.8
@export_range(0.1, 2.0, 0.05) var committed_duration: float = 0.55
@export_range(1.0, 1000.0, 5.0) var committed_speed: float = 430.0
@export_range(0.2, 3.0, 0.05) var recovery_duration: float = 0.7
@export_range(1, 10, 1) var required_hits: int = 3
@export_range(0.05, 0.5, 0.01) var hit_flash_duration: float = 0.14

@onready var trigger_area: Area2D = $TriggerArea
@onready var trigger_shape: CollisionShape2D = $TriggerArea/CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var hint_ring: Line2D = $HintRing
@onready var body_shape: Polygon2D = $Body
@onready var eye: Polygon2D = $Eye
@onready var telegraph_glow: Polygon2D = $TelegraphGlow
@onready var telegraph_ring: Line2D = $TelegraphRing
@onready var attack_core: Polygon2D = $AttackCore
@onready var recovery_ring: Line2D = $RecoveryRing
@onready var hit_flash: Polygon2D = $HitFlash
@onready var defeated_mark: Line2D = $DefeatedMark
@onready var hit_flash_timer: Timer = $HitFlashTimer

var current_state: State = State.CONCEALED
var state_elapsed_seconds: float = 0.0
var hits_remaining: int = 3
var committed_direction: Vector2 = Vector2.ZERO
var attack_active: bool = false
var target_player: BasinExplorer = null
var reset_count: int = 0


func _ready() -> void:
	(trigger_shape.shape as CircleShape2D).radius = trigger_range
	hits_remaining = required_hits
	trigger_area.body_entered.connect(_on_trigger_body_entered)
	attack_area.body_entered.connect(_on_attack_body_entered)
	hit_flash_timer.timeout.connect(_on_hit_flash_timer_timeout)
	_set_attack_active(false)
	_update_presentation()


func _physics_process(delta: float) -> void:
	if current_state == State.CONCEALED:
		begin_telegraph(target_player)
	advance_state(delta)
	if current_state == State.COMMITTED:
		velocity = committed_direction * committed_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO


func begin_telegraph(player: BasinExplorer) -> bool:
	if current_state != State.CONCEALED or player == null or not player.is_alive:
		return false
	if global_position.distance_to(player.global_position) > trigger_range:
		return false

	target_player = player
	_change_state(State.TELEGRAPH)
	return true


func set_target_player(player: BasinExplorer) -> void:
	target_player = player


func reset_encounter(spawn_position: Vector2) -> void:
	var previous_state := current_state
	reset_count += 1
	global_position = spawn_position
	velocity = Vector2.ZERO
	committed_direction = Vector2.ZERO
	state_elapsed_seconds = 0.0
	hits_remaining = required_hits
	current_state = State.CONCEALED
	hit_flash_timer.stop()
	hit_flash.visible = false
	attack_active = false
	attack_area.monitoring = false
	attack_shape.disabled = true
	trigger_area.monitoring = true
	trigger_shape.disabled = false
	_update_presentation()
	if previous_state != current_state:
		state_changed.emit(previous_state, current_state)
	encounter_reset.emit(reset_count)


func capture_encounter() -> RunState.BasinEncounterState:
	var snapshot := RunState.BasinEncounterState.new()
	snapshot.position = global_position
	snapshot.behavior_state = current_state
	snapshot.elapsed_seconds = state_elapsed_seconds
	snapshot.hits_remaining = hits_remaining
	snapshot.committed_direction = committed_direction
	return snapshot


func restore_encounter(snapshot: RunState.BasinEncounterState, allowed_bounds: Rect2) -> void:
	var restored_state := clampi(snapshot.behavior_state, State.CONCEALED, State.DEFEATED) as State
	global_position = Vector2(
		clampf(snapshot.position.x, allowed_bounds.position.x, allowed_bounds.end.x),
		clampf(snapshot.position.y, allowed_bounds.position.y, allowed_bounds.end.y)
	)
	current_state = restored_state
	hits_remaining = clampi(snapshot.hits_remaining, 0, required_hits)
	if current_state == State.DEFEATED:
		hits_remaining = 0
	elif hits_remaining == 0:
		hits_remaining = 1
	var state_limit := _duration_for_state(current_state)
	state_elapsed_seconds = clampf(snapshot.elapsed_seconds, 0.0, state_limit)
	committed_direction = (
		snapshot.committed_direction.normalized()
		if not snapshot.committed_direction.is_zero_approx()
		else Vector2.RIGHT
	) if current_state == State.COMMITTED else Vector2.ZERO
	velocity = committed_direction * committed_speed if current_state == State.COMMITTED else Vector2.ZERO
	hit_flash_timer.stop()
	hit_flash.visible = false
	trigger_area.monitoring = current_state != State.DEFEATED
	trigger_shape.disabled = current_state == State.DEFEATED
	attack_active = current_state == State.COMMITTED
	attack_area.monitoring = attack_active
	attack_shape.disabled = not attack_active
	_update_presentation()


func _duration_for_state(state: State) -> float:
	match state:
		State.TELEGRAPH:
			return telegraph_duration
		State.COMMITTED:
			return committed_duration
		State.RECOVERY:
			return recovery_duration
		_:
			return 0.0


func advance_state(delta: float) -> void:
	if delta <= 0.0 or current_state == State.CONCEALED or current_state == State.DEFEATED:
		return

	state_elapsed_seconds += delta
	match current_state:
		State.TELEGRAPH:
			if state_elapsed_seconds >= telegraph_duration:
				_commit_attack()
		State.COMMITTED:
			if state_elapsed_seconds >= committed_duration:
				_change_state(State.RECOVERY)
		State.RECOVERY:
			if state_elapsed_seconds >= recovery_duration:
				_change_state(State.CONCEALED)


func receive_pulse_hit() -> bool:
	if current_state == State.DEFEATED:
		return false

	hits_remaining -= 1
	hit_flash.visible = true
	hit_flash_timer.start(hit_flash_duration)
	pulse_hit.emit(hits_remaining)
	if hits_remaining == 0:
		_change_state(State.DEFEATED)
		defeated.emit()
	return true


func _commit_attack() -> void:
	if target_player == null or not is_instance_valid(target_player) or not target_player.is_alive:
		_change_state(State.CONCEALED)
		return

	var target_offset := target_player.global_position - global_position
	committed_direction = target_offset.normalized() if not target_offset.is_zero_approx() else Vector2.RIGHT
	_change_state(State.COMMITTED)
	attack_committed.emit(committed_direction)


func _change_state(next_state: State) -> void:
	if current_state == next_state:
		return

	var previous_state := current_state
	current_state = next_state
	state_elapsed_seconds = 0.0
	match current_state:
		State.CONCEALED:
			_set_attack_active(false)
			call_deferred("_try_begin_for_overlapping_player")
		State.TELEGRAPH:
			_set_attack_active(false)
		State.COMMITTED:
			_set_attack_active(true)
		State.RECOVERY:
			_set_attack_active(false)
		State.DEFEATED:
			_set_attack_active(false)
			velocity = Vector2.ZERO
			trigger_area.set_deferred(&"monitoring", false)
			trigger_shape.set_deferred(&"disabled", true)
	_update_presentation()
	state_changed.emit(previous_state, current_state)


func _set_attack_active(active: bool) -> void:
	attack_active = active
	attack_area.set_deferred(&"monitoring", active)
	attack_shape.set_deferred(&"disabled", not active)


func _update_presentation() -> void:
	hint_ring.visible = current_state == State.CONCEALED
	telegraph_glow.visible = current_state == State.TELEGRAPH
	telegraph_ring.visible = current_state == State.TELEGRAPH
	attack_core.visible = current_state == State.COMMITTED
	recovery_ring.visible = current_state == State.RECOVERY
	defeated_mark.visible = current_state == State.DEFEATED

	match current_state:
		State.CONCEALED:
			body_shape.color = Color(0.11, 0.14, 0.17, 0.38)
			eye.color = Color(0.42, 0.25, 0.16, 0.38)
		State.TELEGRAPH:
			body_shape.color = Color(0.28, 0.12, 0.08, 1.0)
			eye.color = Color(1.0, 0.58, 0.18, 1.0)
		State.COMMITTED:
			body_shape.color = Color(0.46, 0.08, 0.055, 1.0)
			eye.color = Color(1.0, 0.23, 0.1, 1.0)
		State.RECOVERY:
			body_shape.color = Color(0.25, 0.25, 0.28, 0.9)
			eye.color = Color(0.44, 0.68, 0.72, 0.8)
		State.DEFEATED:
			body_shape.color = Color(0.08, 0.09, 0.11, 0.55)
			eye.color = Color(0.08, 0.09, 0.11, 0.5)
			hit_flash.visible = false


func _try_begin_for_overlapping_player() -> void:
	if current_state != State.CONCEALED:
		return
	for body: Node2D in trigger_area.get_overlapping_bodies():
		var player := body as BasinExplorer
		if player != null and begin_telegraph(player):
			return


func _on_trigger_body_entered(body: Node2D) -> void:
	var player := body as BasinExplorer
	if player != null:
		begin_telegraph(player)


func _on_attack_body_entered(body: Node2D) -> void:
	if current_state != State.COMMITTED or not attack_active:
		return
	var player := body as BasinExplorer
	if player != null and player.die():
		attack_landed.emit()
		_change_state(State.RECOVERY)


func _on_hit_flash_timer_timeout() -> void:
	hit_flash.visible = false
