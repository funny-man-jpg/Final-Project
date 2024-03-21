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
	# give the enemy the player's location (to be changed later so that the enemy goes to the player when in range)
	if $Player != null:
		if $BasicEnemy != null:
			$BasicEnemy.getPlayerPos($Player.position.x, $Player.position.y)
		if $BasicEnemy2 != null:
			$BasicEnemy2.getPlayerPos($Player.position.x, $Player.position.y)



func _on_basic_enemy_2_enemy_2_health_change(new_health):
	basicenemy2_health_bar.value = new_health


func _on_basic_enemy_enemy_health_change(new_health):
	basicenemy_health_bar.value = new_health


func _on_player_health_change(new_health):
	player_health_bar.value = new_health
