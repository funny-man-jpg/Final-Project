extends Node

@onready var Player = $Player
@onready var player_health_bar = $Player/Healthbar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	player_health_bar.max_value = Player.max_health
	player_health_bar.value = player_health_bar.max_value
	#basicenemy_health_bar.max_value = BasicEnemy.max_health
	#basicenemy_health_bar.value = basicenemy_health_bar.max_value



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#A signal to connect to the player's healthbar
func _on_player_health_change(new_health):
	player_health_bar.value = new_health

func _on_basic_enemy_new_enemy(enemy):
	# give the new enemy a reference to the player
	enemy.getPlayer($Player)



