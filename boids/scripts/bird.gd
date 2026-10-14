extends Area2D

var SPEED = 100
var FLOCK: Array[Area2D] = []

@onready var forward: RayCast2D = $Forward
@onready var hard_right: RayCast2D = $HardRight
@onready var hard_left: RayCast2D = $HardLeft
@onready var fl_soft: RayCast2D = $FLSoft
@onready var fr_soft: RayCast2D = $FRSoft


func _process(delta: float) -> void:
	var FINALDIR = birdact()
	if FINALDIR.length_squared() > 0.0001:
		rotation = rotate_toward(rotation,FINALDIR.angle(),deg_to_rad(180) * delta)
	# Move where you are facing
	position += Vector2.RIGHT.rotated(rotation) * SPEED * delta

# Check Birds
func _on_vision_area_entered(area: Area2D) -> void:
	if area != self and area not in FLOCK and area.is_in_group("boids"):
		FLOCK.append(area)

func _on_vision_area_exited(area: Area2D) -> void:
	if area in FLOCK:
		FLOCK.erase(area)

# turn away from corners
func keepin():
	var TURNAWAY = Vector2.ZERO
	if global_position.x >= 2200:
		TURNAWAY += Vector2.LEFT * 3
	if global_position.x <= -2200:
		TURNAWAY += Vector2.RIGHT * 3
	if global_position.y >= 1200:
		TURNAWAY += Vector2.UP * 3
	if global_position.y <= -1200:
		TURNAWAY += Vector2.DOWN * 3
	return TURNAWAY

# stay away from closest
func stayaway():
	var BROPUSHTOT = Vector2.ZERO
	if FLOCK.size() >= 1:
		for area in FLOCK:
			if global_position.distance_to(area.global_position) <= 50:
				var BROPUSHDIST = global_position - area.global_position
				BROPUSHTOT += BROPUSHDIST.normalized() / BROPUSHDIST.length()
	return BROPUSHTOT.normalized()

# follow where gang is going
func followlead():
	var GANGDIST = Vector2.ZERO
	if FLOCK.size() >= 1:
		for area in FLOCK:
			GANGDIST += Vector2.RIGHT.rotated(area.global_rotation)
	return GANGDIST.normalized()

# stay together
func apestrong():
	var APELOC = Vector2.ZERO
	var APEMEET: Vector2
	var DIRTOLOC = Vector2.ZERO
	if FLOCK.size() >= 1:
		for area in FLOCK:
			APELOC += area.global_position
		APEMEET = APELOC / FLOCK.size()
		DIRTOLOC = APEMEET - global_position
	return DIRTOLOC.normalized()

# act like a bird
func birdact():
	var BIRDDIR = Vector2.RIGHT.rotated(global_rotation)
	BIRDDIR += apestrong()
	BIRDDIR += followlead()
	BIRDDIR += stayaway() * 2
	BIRDDIR += keepin()
	BIRDDIR += avoidterrain() * 10
	return BIRDDIR

# check terrain
func avoidterrain():
	var DODGEDIR = Vector2.ZERO
	if forward.is_colliding():
		DODGEDIR -= (forward.to_global(forward.target_position) - forward.global_position).normalized()
	if hard_left.is_colliding():
		DODGEDIR -= (hard_left.to_global(hard_left.target_position) - hard_left.global_position).normalized()
	if hard_right.is_colliding():
		DODGEDIR -= (hard_right.to_global(hard_right.target_position) - hard_right.global_position).normalized()
	if fl_soft.is_colliding():
		DODGEDIR -= (fl_soft.to_global(fl_soft.target_position) - fl_soft.global_position).normalized()
	if fr_soft.is_colliding():
		DODGEDIR -= (fr_soft.to_global(fr_soft.target_position) - fr_soft.global_position).normalized()
	return DODGEDIR.normalized()
