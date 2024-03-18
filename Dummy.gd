extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func take_damage(damage):
	apply_central_impulse(Vector2(0, -1000))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
