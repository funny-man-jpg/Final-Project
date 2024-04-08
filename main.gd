extends Node

@export var basic_enemy: PackedScene

signal reset_enemies

@onready var Player = $Player
@onready var player_health_bar = $Player/Healthbar

var boss_enemies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# set up the title page and freeze the player until the game starts
	$TitlePage/StartButton.pressed.connect(start_game)
	$TitlePage.visible = true
	$Player.move = false
	
	# set up the player's health bar
	player_health_bar.max_value = Player.max_health
	player_health_bar.value = player_health_bar.max_value
	
	# connect the player to the boss
	$Boss.getPlayer($Player)
	
	# connect to the boss spawn signal
	$Boss.spawn_enemy.connect(spawn_enemy)
	
	#var enemies = get_tree().get_nodes_in_group("enemies")
	#for i in enemies:
		#i.new_enemy.connect(_on_basic_enemy_new_enemy)
		#i.enemy_health_change.connect(_on_player_health_change)
	#print($BasicEnemy2.is_connected("new_enemy", _on_basic_enemy_new_enemy))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# check that the player is still alive
	if $Player != null:
		# update the ability cooldowns
		$Player/Camera2D/UpslashCooldown.value = $Player/UpslashCooldown.time_left
		$Player/Camera2D/DashCooldown.value = $Player/DashCooldown.time_left
		$Player/Camera2D/TornadoCooldown.value = $Player/TornadoCooldown.time_left

#A signal to connect to the player's healthbar
func _on_player_health_change(new_health):
	player_health_bar.value = new_health
	
	# check if the player is dead
	if new_health <= 0:
		# delete all the enemies in the enemy list
		for e in boss_enemies:
			e.delete_self()
		
		# reset the enemy list
		boss_enemies = []

func _on_basic_enemy_new_enemy(enemy):
	# give the new enemy a reference to the player
	enemy.getPlayer($Player)

func _on_basic_enemy_enemy_health_change(new_health):
	pass # Replace with function body.

func start_game():
	# make the title page dissapear and unfreeze the player
	$TitlePage.visible = false
	$Player.move = true
	$TitleMusic.stop()
	$MainMusic.play()

func spawn_enemy(enemy_type):
	# instantiate the enemy scene
	var enemy = basic_enemy.instantiate()
	
	# set the right enemy type
	enemy.enemyType = enemy_type
	
	# place the enemy
	enemy.position = Vector2(8700, 3550)
	
	# give the player to the enemy
	enemy.getPlayer($Player)
	
	# add the enemy to the scene
	add_child(enemy)
	
	# add the enemy to the enemy list
	boss_enemies.append(enemy)

func _on_boss_area_body_entered(body):
	# check if the area is the player
	if body == $Player:
		$MainMusic.stop()
		$BossMusicIntro.play()
		$Boss.startup()



func _on_audio_stream_player_finished():
	$MainMusic.play()


func _on_title_music_finished():
	$TitleMusic.play()


func _on_boss_music_intro_finished():
	$BossMusicLoop.play()


func _on_boss_music_loop_finished():
	$BossMusicLoop.play()
