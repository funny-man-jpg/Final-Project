class_name HitBox
extends Area2D

@export var damage = 10
var knockback = Vector2(0,0)
var hitStunValue = 1
signal hit

func _init():
	collision_layer = 2
	collision_mask = 0
	

