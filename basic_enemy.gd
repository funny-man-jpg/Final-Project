extends CharacterBody2D

signal enemy_health_change(new_health)
signal new_enemy(enemy)

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var flipped = false
var cooldown = false
var max_health = 100
var health
var player
var hitStun = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	# set the enemies health to max
	health = max_health
	
	# tell the main that a new enemy has been created
	emit_signal("new_enemy", self) 

# when hit
func take_damage(damage, knockback, hitstunValue):
	# get hit up
	if !player.flipped:
		velocity.y = knockback.y
		velocity.x = knockback.x
	else:
		velocity.y = knockback.y
		velocity.x = -knockback.x
	hitStun = true
	$HitStun.start(hitstunValue)
	# lose health
	health -= damage
	emit_signal("enemy_health_change", health)
	
	# check if dead
	if health <= 0:
		# remove itself from the game
		queue_free()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# check that the player isn't null
		if player != null and hitStun == false:
			# find the distance to the player
			var distanceToPlayer = Vector2(player.position.x - self.position.x, player.position.y - self.position.y)
			
			# if the player is too far away, don't do anything
			if distanceToPlayer.length() < 750:
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
				
				# if the player is close enough, stop moving and attack
				if -180 < distanceToPlayer[0]  && distanceToPlayer[0] < 180: 
					# stop moving
					velocity.x = 0
					
					# check if on cooldown
					if !cooldown:
						# attack the player
						attack()
				else:
					# move towards the player
					velocity.x = distanceToPlayer.normalized().x * SPEED
	
	# move
	move_and_slide()

func getPlayer(p):
	player = p

func _on_attack_cooldown_timeout():
	# the enemy's attack cooldown is over
	cooldown = false

func _on_hit_stun_timeout():
	hitStun = false

func attack():
	# choose between light or heavy attack
	if randi() % 2 == 0:
		$sword/AnimationPlayer.play("swing")
	else:
		$sword/AnimationPlayer.play("heavy_swing")
	
	$sword/AnimationPlayer.queue("RESET")
	
	# put the enemy on attack cooldown
	$AttackCooldown.start()
	cooldown = true
	
func update_health():
	var healthbar = $HealthBar
	
	healthbar.value = health
	
	if health >= max_health:
		healthbar.visible = false
	else:
		healthbar.visible = true
