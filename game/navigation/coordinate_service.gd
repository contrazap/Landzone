class_name CoordinateService
extends RefCounted

const SECTOR_ANGLE := PI / 4.0

var region_id: StringName
var origin: Vector2
var local_unit_pixels: float


func _init(
	configured_region_id: StringName,
	configured_origin: Vector2,
	configured_local_unit_pixels: float
) -> void:
	region_id = configured_region_id
	origin = configured_origin
	local_unit_pixels = maxf(configured_local_unit_pixels, 1.0)


func format_where(world_position: Vector2, facing_direction: Vector2) -> String:
	return format_stamp(capture_stamp(world_position, facing_direction))


func capture_stamp(world_position: Vector2, facing_direction: Vector2) -> Dictionary:
	var local_offset := world_position - origin
	var north_steps := roundi(-local_offset.y / local_unit_pixels)
	var east_steps := roundi(local_offset.x / local_unit_pixels)
	return {
		"region": String(region_id),
		"north": north_steps,
		"east": east_steps,
		"facing": format_facing(facing_direction),
	}


static func format_stamp(stamp: Dictionary) -> String:
	return "REGION %s | LOCAL %s %s | FACING %s" % [
		stamp["region"],
		format_axis(stamp["north"], "N", "S"),
		format_axis(stamp["east"], "E", "W"),
		stamp["facing"],
	]


static func format_facing(direction: Vector2) -> String:
	if direction.is_zero_approx():
		return "E"
	var sector := posmod(roundi(direction.angle() / SECTOR_ANGLE), 8)
	match sector:
		0:
			return "E"
		1:
			return "SE"
		2:
			return "S"
		3:
			return "SW"
		4:
			return "W"
		5:
			return "NW"
		6:
			return "N"
		_:
			return "NE"


static func format_axis(value: int, positive_prefix: String, negative_prefix: String) -> String:
	var prefix := positive_prefix if value >= 0 else negative_prefix
	return "%s%02d" % [prefix, absi(value)]
