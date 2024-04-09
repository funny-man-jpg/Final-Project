extends CharacterBody2D

signal health_change(new_health)
signal player_death()

const MAXSPEED = 500.0
const ACCEL = 2000
var flipped = false
var cooldown = false
var dashCooldown = false
var upslashCooldown = false
var tornadoCooldown = false
var ladder_on = false
var max_health = 200
var ladder_speed = 500
var health
var move = true
var spawnX = -359
var spawnY = 542
var knockbacked
var hitstun = false
var dying = false

@export var jump_height : float
@export var jump_time_to_peak: float
@export var jump_time_to_descent : float

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var animPlayer = $AnimatedSprite2D

var dash = false

func _ready():
	# set the player's health
	health = max_health
	
	# make sure the sword is placed properly as well
	$sword.position.x = 40

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func get_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func _physics_process(delta):
	if move and !dying:
		# Add the gravity.
		if not is_on_floor():
			velocity.y += get_gravity() * delta
		if hitstun == false:
			if ladder_on == true:
				velocity.y = 0
				if Input.is_action_pressed("ladder_up"):
					velocity.y = -ladder_speed
					animPlayer.play("climb")
				elif Input.is_action_pressed("ladder_down"):
					velocity.y = ladder_speed
					animPlayer.play("climb")
				else:
					#animPlayer.play("idle")
					if not is_on_floor():
						velocity.y += get_gravity() * delta
				
			
			
			# Handle jump.
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = jump_velocity
				animPlayer.play("jump")
				
			#if velocity.y > 0:
				#animPlayer.play("idle")

			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			var direction = Input.get_axis("move_left", "move_right")
			# if someone has a more efficient way for this please fix it
			var swordPosition = position.x - $sword.position.x
			#Use linear algebra later
			if direction > 0:
				$AnimatedSprite2D.flip_h = false
				$sword.position.x = 40
				if flipped == true:
					flipped = false
					$sword.scale.x *= -1
			elif direction < 0:
				$AnimatedSprite2D.flip_h = true
				$sword.position.x = -40
				if flipped == false:
					flipped = true
					$sword.scale.x *= -1
			
			if direction and dash == false:
				velocity.x += direction * ACCEL * delta
				if !$sword/AnimationPlayer.is_playing():
					animPlayer.play("run")
			elif dash == false:
				velocity.x = lerp(velocity.x, 0.0, 0.2)
				#if abs(velocity.x) < 10 and is_on_floor() and animPlayer.animation == "run":
					#animPlayer.play("idle")
			if dash == false:
				velocity.x = clamp(velocity.x, -MAXSPEED, MAXSPEED)
		
		attack()
		move_and_slide()
		

func attack():
	# check that the player tried to attack and that they're not on cooldown
	if Input.is_action_just_pressed("attack") and !cooldown:
		# attack
		$sword/AnimationPlayer.play("swing")
		$sword/AnimationPlayer.queue("RESET")
		animPlayer.play("attack1")
		$sword/Sprite2D/HitBox.damage = 20
		$sword/Sprite2D/HitBox.knockback = Vector2(200, -300)
		$sword/Sprite2D/HitBox.hitStunValue = 1
		
		# put the player on cooldown
		$AttackCooldown.start()
		cooldown = true
	if Input.is_action_just_pressed("heavy_attack") and !cooldown:
		# attack
		$sword/AnimationPlayer.play("heavy_swing")
		$sword/AnimationPlayer.queue("RESET")
		animPlayer.play("attack2")
		$sword/Sprite2D/HitBox.damage = 45
		$sword/Sprite2D/HitBox.knockback = Vector2(400, -400)
		$sword/Sprite2D/HitBox.hitStunValue = 1.4
		
		# put the player on cooldown
		$AttackCooldown.start()
		cooldown = true
	if Input.is_action_just_pressed("upslash") and !upslashCooldown:
		# attack
		$sword/AnimationPlayer.play("upslash")
		$sword/AnimationPlayer.queue("RESET")
		animPlayer.play("attack3")
		$sword/Sprite2D/HitBox.damage = 30
		$sword/Sprite2D/HitBox.knockback = Vector2(100, -500)
		$sword/Sprite2D/HitBox.hitStunValue = 1.3
		
		# put the player on cooldown
		$UpslashCooldown.start()
		upslashCooldown = true
	if Input.is_action_just_pressed("dash") and !dashCooldown:
		# attack
		$sword/AnimationPlayer.play("dash")
		animPlayer.play("attack5")
		var direction = Input.get_axis("move_left", "move_right")
		velocity.x = 1000 * direction
		dash = true;
		$DashTimer.start()
		$sword/AnimationPlayer.queue("RESET")
		$sword/Sprite2D/HitBox.damage = 25
		$sword/Sprite2D/HitBox.knockback = Vector2(200, -100)
		$sword/Sprite2D/HitBox.hitStunValue = 0.5
		
		# put the player on cooldown
		$DashCooldown.start()
		dashCooldown = true
	if Input.is_action_just_pressed("TornadoSlash") and !tornadoCooldown:
		# attack
		$sword/AnimationPlayer.play("TornadoAttack")
		animPlayer.play("attack4")
		$sword/AnimationPlayer.queue("RESET")
		$sword/Sprite2D/HitBox.damage = 20
		$sword/Sprite2D/HitBox.knockback = Vector2(100, -300)
		$sword/Sprite2D/HitBox.hitStunValue = 1
		
		# put the player on cooldown
		$TornadoCooldown.start()
		tornadoCooldown = true

func take_damage(damage, knockback, hitStun):
	animPlayer.play("hurt")
	# get knocked back
	velocity.x = knockback.x
	velocity.y = knockback.y
	hitstun = true
	$hitStun.start(hitStun)
	# lose health
	health -= damage
	print(health)
	# get the health signal
	emit_signal("health_change", health)
	
	# check if dead
	if health <= 0:
		animPlayer.play("death")
		dying = true
		# reset player
		#respawn()

func _on_attack_cooldown_timeout():
	# the cooldown is over
	cooldown = false

func _on_dash_timer_timeout():
	dash = false

func _on_dash_cooldown_timeout():
	dashCooldown = false

func _on_upslash_cooldown_timeout():
	upslashCooldown = false

func _on_tornado_cooldown_timeout():
	tornadoCooldown = false

func respawn():
	# tell the main that the player died
	emit_signal("player_death")
	
	# put the player back at spawn
	self.position.x = spawnX
	self.position.y = spawnY
	
	# set the player's health to max
	health = max_health
	emit_signal("health_change", health)
	
	# reset the player's cooldowns and timers
	#$AttackCooldown.stop()
	#$DashTimer.stop()
	#$DashCooldown.stop()
	#$UpslashCooldown.stop()
	#$TornadoCooldown.stop()
	
	# reset the player's velocity to 0
	self.velocity.y = 0
	self.velocity.x = 0
	
	# reset the dying variable
	dying = false

#animation play
func _on_animated_sprite_2d_animation_finished():
	if animPlayer.animation == "attack1":
		animPlayer.play("idle")
	if animPlayer.animation == "attack2":
		animPlayer.play("idle")
	if animPlayer.animation == "attack3":
		animPlayer.play("idle")
	if animPlayer.animation == "attack4":
		animPlayer.play("idle")
	if animPlayer.animation == "attack5":
		animPlayer.play("idle")
	if animPlayer.animation == "run":
		animPlayer.play("idle")
	if animPlayer.animation == "jump":
		animPlayer.play("idle")
	if animPlayer.animation == "climb":
		animPlayer.play("idle")
	if animPlayer.animation == "death":
		respawn()
		animPlayer.play("idle")
	if animPlayer.animation == "hurt":
		animPlayer.play("idle")

func _on_hit_stun_timeout():
	hitstun = false

func _on_sword_hit():
	dash = false
