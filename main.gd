extends Node

signal reset_enemies

@onready var Player = $Player
@onready var player_health_bar = $Player/Healthbar

# Called when the node enters the scene tree for the first time.
func _ready():
	# set up the title page and freeze the player until the game starts
	$TitlePage/StartButton.pressed.connect(start_game)
	$TitlePage.visible = true
	$Player.move = false
	
	# set up the player's health bar
	player_health_bar.max_value = Player.max_health
	player_health_bar.value = player_health_bar.max_value
	
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

func _on_basic_enemy_new_enemy(enemy):
	# give the new enemy a reference to the player
	enemy.getPlayer($Player)

func _on_basic_enemy_enemy_health_change(new_health):
	pass # Replace with function body.

func start_game():
	# make the title page dissapear and unfreeze the player
	$TitlePage.visible = false
	$Player.move = true
