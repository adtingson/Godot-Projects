extends Area2D

var SPEED = 100
var FLOCK: Array[Area2D] = []

func _process(delta: float) -> void:
	var FINALDIR = birdact()
	if FINALDIR.length_squared() > 0.0001:
		rotation = rotate_toward(rotation,FINALDIR.angle(),deg_to_rad(180) * delta)
	# Move where you are facing
	position += Vector2.RIGHT.rotated(rotation) * SPEED * delta

# Check Birds
func _on_vision_area_entered(area: Area2D) -> void:
	if area != self and area not in FLOCK:
		FLOCK.append(area)

func _on_vision_area_exited(area: Area2D) -> void:
	FLOCK.erase(area)

# turn away from corners
func keepin():
	var TURNAWAY = Vector2.ZERO
	if global_position.x >= 2200:
		TURNAWAY += Vector2.LEFT * 3
	if global_position.x <= -2200:
		TURNAWAY += Vector2.RIGHT * 3
	if global_position.y >= 1100:
		TURNAWAY += Vector2.UP * 3
	if global_position.y <= -1100:
		TURNAWAY += Vector2.DOWN * 3
	return TURNAWAY

# find closest
func closest():
	var MINDIST = INF
	var CLOSEST: Area2D = null
	for area in FLOCK:
		var DISTANCE = global_position.distance_to(area.global_position)
		if DISTANCE < MINDIST:
			MINDIST = DISTANCE
			CLOSEST = area
	return CLOSEST

# stay away from closest by at least 150px
func stayaway():
	var BRO = closest()
	if BRO:
		var BROAWAY = global_position - BRO.global_position
		if BROAWAY.length() <= 150:
			return BROAWAY.normalized()
	return Vector2.ZERO

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
	var APEMEET
	if FLOCK.size() >= 1:
		for area in FLOCK:
			APELOC += area.global_position
		APEMEET = APELOC / FLOCK.size()
		var DISTTOLOC = APEMEET - global_position
		return DISTTOLOC.normalized()
	return APELOC

# act like a bird
func birdact():
	var BIRDDIR = Vector2.RIGHT.rotated(global_rotation)
	BIRDDIR += apestrong()
	BIRDDIR += followlead()
	BIRDDIR += stayaway() * 1.2
	BIRDDIR += keepin() * 3
	return BIRDDIR
