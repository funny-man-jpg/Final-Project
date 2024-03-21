extends CharacterBody2D

signal health_change(new_health)

const MAXSPEED = 500.0
const ACCEL = 2000
var flipped = false
var cooldown = false
var max_health = 200
var health

@export var jump_height : float
@export var jump_time_to_peak: float
@export var jump_time_to_descent : float

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0

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
	# Add the gravity.
	if not is_on_floor():
		velocity.y += get_gravity() * delta
	
	
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

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
		
	if direction:
		velocity.x += direction * ACCEL * delta
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.2)
	velocity.x = clamp(velocity.x, -MAXSPEED, MAXSPEED)
	
	attack()
	move_and_slide()

func attack():
	# check that the player tried to attack and that they're not on cooldown
	if Input.is_action_just_pressed("attack") and !cooldown:
		# attack
		$sword/AnimationPlayer.play("swing")
		$sword/AnimationPlayer.queue("RESET")
		
		# put the player on cooldown
		$AttackCooldown.start()
		cooldown = true

func take_damage(damage):
	# get hit up
	velocity.y = -700
	
	# lose health
	health -= damage
	# get the health signal
	emit_signal("health_change", health)
	
	# check if dead
	if health <= 0:
		# remove self from the game
		queue_free()


func _on_attack_cooldown_timeout():
	# the cooldown is over
	cooldown = false
