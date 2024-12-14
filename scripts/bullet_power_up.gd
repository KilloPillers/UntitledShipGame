class_name BulletPowerUp
extends Area2D

@export var damage_buff: int = 0.5
@export var pierce_buff: int = 2
@export var bullets_per_fire_buff: int = 5

@onready var gun: Node2D = %Ship/ShipHull/Gun


func _ready() -> void:
	# CONNECT THE SIGNAL
	area_entered.connect(_on_body_entered)


# function for detecting when shape is entered by player 
func _on_body_entered(body: Node2D):
	# print power up of the body is entered
	print("Gun Power Up - Activated\n")
	apply_buff()


# function that improves base stats of the player
func apply_buff():
	# apply the bullet buffs
	gun.num_projectiles += bullets_per_fire_buff
	gun.pierce_buff += pierce_buff
	gun.damage_buff += damage_buff
	
	queue_free()
