# Final-Project


Current sources for used code:
@export var jump_height : float
@export var jump_time_to_peak: float
@export var jump_time_to_descent : float

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0

func get_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity

from: https://www.youtube.com/watch?v=IOe1aGY6hXA
used for: Smoother movement


Hitboxes: https://www.youtube.com/watch?v=JWjzSn95bM0


NOTE FOR LATER: IN THE PLAYER CLASS USE LINEAR ALGEBRA(TRANSFORM2D) TO TRY TO GET TRANSFORMATIONS WORKING FOR FLIPPING THE SWORD OVER THE Y AXIS