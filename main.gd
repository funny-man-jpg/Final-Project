extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# give the enemy the player's location (to be changed later so that the enemy goes to the player when in range)
	if $Player != null:
		if $BasicEnemy != null:
			$BasicEnemy.getPlayerPos($Player.position.x, $Player.position.y)
		if $BasicEnemy2 != null:
			$BasicEnemy2.getPlayerPos($Player.position.x, $Player.position.y)
