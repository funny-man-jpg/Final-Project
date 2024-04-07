extends Node2D

signal hit
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getFlipped():
	if owner.has_method("getDirection"):
		print(owner.getDirection)
		return owner.getDirection

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_hit_box_hit():
	emit_signal("hit")
