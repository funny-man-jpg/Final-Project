extends CharacterBody2D

signal enemy2_health_change(new_health)

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var playerX
var playerY
var flipped = false
var cooldown = false
var max_health = 100
var health

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	# set the enemies health to max
	health = max_health
	pass

# when hit
func take_damage(damage):
	# get hit up (DO THIS)
	velocity.y = -700
	#
	# lose health
	health -= damage
	emit_signal("enemy2_health_change", health)
	
	# check if dead
	if health <= 0:
		# remove itself from the game
		queue_free()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# find the distance to the player
		var distanceToPlayer = Vector2(playerX - self.position.x, playerY - self.position.y)
		
		# point towards the player
		if distanceToPlayer.x > 0:
			$AnimatedSprite2D.flip_h = false
			$sword.position.x = 85
			if flipped == true:
				flipped = false
				$sword.scale.x *= -1
		else:
			$AnimatedSprite2D.flip_h = true
			$sword.position.x = -85
			if flipped == false:
				flipped = true
				$sword.scale.x *= -1
		
		# if the player is close enough, attack
		if distanceToPlayer.length() < 250:
			# check if on cooldown
			if !cooldown:
				# attack the player
				$sword/AnimationPlayer.play("swing")
				$sword/AnimationPlayer.queue("RESET")
				
				# put the enemy on attack cooldown
				$AttackCooldown.start()
				cooldown = true
		else:
			# move towards the player
			velocity.x = distanceToPlayer.normalized().x * SPEED
	
	move_and_slide()

func getPlayerPos(x, y):
	playerX = x
	playerY = y


func _on_attack_cooldown_timeout():
	# the enemy's attack cooldown is over
	cooldown = false
