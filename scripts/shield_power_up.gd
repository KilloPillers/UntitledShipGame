class_name ShieldPowerUp
extends Area2D


@onready var shield: Node2D = %Ship/ShipHull/Shield


func _ready() -> void:
	# CONNECT THE SIGNAL
	area_entered.connect(_on_body_entered)


# function for detecting when shape is entered by player 
func _on_body_entered(body: Node2D):
	# print power up of the body is entered
	print("Hull Power Up - Activated\n")
	apply_buff()


# function that improves base stats of the player
func apply_buff():
	# apply the health buffs
	shield.shield_power_up = true
	queue_free()
