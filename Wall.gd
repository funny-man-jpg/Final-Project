extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func take_damage(damage, knockback, hitstun):
	# check that a heavy attack was felt
	if damage == 45:
		queue_free()
