extends CharacterBody2D

signal enemy_health_change(new_health)
signal new_enemy(enemy)

# can be:
# basic
# sewer
@export var enemyType : String

const BASIC_SPEED = 300.0
const SEWER_SPEED = 150.0
const JUMP_VELOCITY = -400.0
var flipped = false
var cooldown = false
var max_basic_health = 100
var max_sewer_health = 200
var max_health
var health
var player
var hitStun = false
var healthbar
var spawnX
var spawnY

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animEnemy = $AnimatedSprite2D

func _ready():
	# store starting position
	spawnX = self.position.x
	spawnY = self.position.y
	
	# set the enemies health to max
	if self.enemyType == "basic":
		max_health = max_basic_health
	elif self.enemyType == "sewer":
		max_health = max_sewer_health
	
	health = max_health
	
	# set up the enemy's healthbar
	healthbar = $HealthBar
	healthbar.max_value = max_health
	healthbar.visible = false
	
	# set the enemy's display type tag (TEMPORARY)
	$TemporaryTypeTag.set_text(self.enemyType)
	
	# tell the main that a new enemy has been created
	emit_signal("new_enemy", self) 
	
	# connect itself to the player's death signal
	player.player_death.connect(reset_self)

# when hit
func take_damage(damage, knockback, hitstunValue):
	# get knocked back and stunned
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
	healthbar.visible = true
	healthbar.value = health
	#emit_signal("enemy_health_change", health)
	
	# check if dead
	if health <= 0:
		animEnemy.play("death")
		# remove itself from the game
		#queue_free()

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
				#animEnemy.play("idle")
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
					if self.enemyType == "basic":
						velocity.x = distanceToPlayer.normalized().x * BASIC_SPEED
						animEnemy.play("run")
					elif self.enemyType == "sewer":
						velocity.x = distanceToPlayer.normalized().x * SEWER_SPEED
						animEnemy.play("run")
	
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
	# attack based on the enemy type
	if self.enemyType == "basic":
		# choose between light or heavy attack
		if randi() % 2 == 0:
			$sword/AnimationPlayer.play("swing")
			animEnemy.play("attack")
			$sword/Sprite2D/HitBox.damage = 20
			$AttackCooldown.wait_time = 1.5
			$sword/Sprite2D/HitBox.knockback = calculate_knockback("light")
		else:
			$sword/AnimationPlayer.play("heavy_swing")
			animEnemy.play("attack")
			$sword/Sprite2D/HitBox.damage = 45
			$AttackCooldown.wait_time = 2.5
			$sword/Sprite2D/HitBox.knockback = calculate_knockback("heavy")
	elif self.enemyType == "sewer":
		# choose between heavy or special attack
		if randi() % 2 == 0:
			$sword/AnimationPlayer.play("heavy_swing")
			animEnemy.play("attack")
			$sword/Sprite2D/HitBox.damage = 45
			$AttackCooldown.wait_time = 2.5
			$sword/Sprite2D/HitBox.knockback = calculate_knockback("heavy")
		else:
			pass
			$sword/AnimationPlayer.play("ultra_heavy_swing")
			animEnemy.play("attack")
			$sword/Sprite2D/HitBox.damage = 70
			$AttackCooldown.wait_time = 3
			$sword/Sprite2D/HitBox.knockback = calculate_knockback("ultra_heavy")
	
	$sword/AnimationPlayer.queue("RESET")
	
	# put the enemy on attack cooldown
	$AttackCooldown.start()
	cooldown = true

func calculate_knockback(attack):
	var knockbackX
	var knockbackY
	
	# check if the enemy is flipped and set x accordingly
	if self.flipped:
		knockbackX = -1
	else:
		knockbackX = 1
	
	# check the type of attack and set the knockback values
	if attack == "light":
		knockbackX *= 200
		knockbackY = -100
	elif attack == "heavy":
		knockbackX *= 400
		knockbackY = -200
	else:
		knockbackX *= 600
		knockbackY = -300
	
	return Vector2(knockbackX, knockbackY)

func reset_self():
	# set position back to spawn position
	self.position.x = spawnX
	self.position.y = spawnY
	
	# set health back to max
	health = max_health
	
	# re-hide healthbar
	healthbar.visible = false


func _on_animated_sprite_2d_animation_finished():
	if animEnemy.animation == "attack":
		animEnemy.play("run")
	if animEnemy.animation == "death":
		queue_free()
	#if animEnemy.animation == "run":
		#animEnemy.play("idle")
