extends Area2D

@onready var danger_close: Area2D = $DangerClose

var SPEED = 300
var AGILITY = deg_to_rad(90)
var DETECTED: Array[Area2D] = []

func _physics_process(delta: float) -> void:
	var NEIGHBOR = find_closest()
	var ANGLETO = rotation
	if NEIGHBOR == null:
		ANGLETO = rotation
	else:
		var DIRTO = NEIGHBOR.global_position - global_position
		ANGLETO = DIRTO.angle()
	rotation = rotate_toward(rotation,ANGLETO,AGILITY * delta)
	if is_danger_close():
		rotation += deg_to_rad(5)
	position += Vector2.RIGHT.rotated(rotation) * SPEED * delta

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area != self and area not in DETECTED:
		DETECTED.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
	DETECTED.erase(area)

func find_closest() -> Area2D:
	var CLOSEST: Area2D = null
	var MINDISTANCE: = INF
	for area in DETECTED:
		var DISTANCE = global_position.distance_squared_to(area.global_position)
		if DISTANCE < MINDISTANCE:
			CLOSEST = area
			MINDISTANCE = DISTANCE
	return CLOSEST

func is_danger_close() -> bool:
	for area in danger_close.get_overlapping_areas():
		if area != self:
			return true
	return false
