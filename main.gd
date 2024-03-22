extends Node

@onready var Player = $Player
@onready var player_health_bar = $Player/HealthBar
@onready var BasicEnemy = $BasicEnemy
@onready var basicenemy_health_bar = $BasicEnemy/HealthBar
@onready var BasicEnemy2 = $BasicEnemy2
@onready var basicenemy2_health_bar = $BasicEnemy2/HealthBar


# Called when the node enters the scene tree for the first time.
func _ready():
	player_health_bar.max_value = Player.max_health
	player_health_bar.value = player_health_bar.max_value
	basicenemy_health_bar.max_value = BasicEnemy.max_health
	basicenemy_health_bar.value = basicenemy_health_bar.max_value
	basicenemy2_health_bar.max_value = BasicEnemy2.max_health
	basicenemy2_health_bar.value = basicenemy2_health_bar.max_value


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_basic_enemy_2_enemy_2_health_change(new_health):
	basicenemy2_health_bar.value = new_health

func _on_basic_enemy_enemy_health_change(new_health):
	basicenemy_health_bar.value = new_health

func _on_player_health_change(new_health):
	player_health_bar.value = new_health

func _on_basic_enemy_new_enemy(enemy):
	# give the new enemy a reference to the player
	enemy.getPlayer($Player)


func _on_basic_enemy_2_new_enemy(enemy):
	# give the new enemy a reference to the player
	enemy.getPlayer($Player)
