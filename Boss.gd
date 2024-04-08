extends RigidBody2D

signal spawn_enemy(enemy_type)

var max_health = 600
var health
var stage = 1
var player
var healthbar

@onready var AnimPlayer = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# set up health and healthbar
	health = max_health
	healthbar = $HealthBar
	healthbar.max_value = max_health
	healthbar.value = health
	healthbar.visible = false
	
	# set up timer value
	$SpawnTimer.wait_time = 7

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset_self():
	# reset health and healthbar
	health = max_health
	healthbar.value = max_health
	healthbar.visible = false
	
	# reset stage
	stage = 1
	$SpawnTimer.wait_time = 7
	
	# stop the spawn timer
	$SpawnTimer.stop()

func take_damage(damage, knockback, hitstunValue):
	# lose health
	health -= damage
	healthbar.value = health
	healthbar.visible = true
	
	# check if next stage reached
	if health <= 200:
		stage = 3
		$SpawnTimer.wait_time = 3.5
	elif health <= 400:
		stage = 2
		$SpawnTimer.wait_time = 5.0
	
	# check if dead
	if health <= 0:
		AnimPlayer.play("death")
		queue_free()

func getPlayer(p):
	player = p
	
	# connect itself to the player's death signal
	player.player_death.connect(reset_self)

func startup():
	# start the spawn timer
	$SpawnTimer.start()
	
	# show the healthbar
	healthbar.visible = true

func _on_spawn_timer_timeout():
	# check the boss stage and spawn enemies appropriately
	if stage == 1:
		emit_signal("spawn_enemy", "basic")
	elif stage == 2:
		if randf() <= 0.75:
			emit_signal("spawn_enemy", "basic")
		else:
			emit_signal("spawn_enemy", "sewer")
	else:
		if randi() % 2 == 0:
			emit_signal("spawn_enemy", "basic")
		else:
			emit_signal("spawn_enemy", "sewer")


func _on_animated_sprite_2d_animation_finished():
	pass # Replace with function body.
