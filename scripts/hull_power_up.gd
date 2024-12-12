class_name hullPowerUp
extends Area2D

@export var health_buff: float = 20
@export var speed_buff: float = 10
@export var rotation_speed_buff: float = 3.0

@onready var ship_hull: ShipHull = %Ship/ShipHull
@onready var engine: Node2D = %Ship/ShipHull/Engine
@onready var shield: Node2D = %Ship/ShipHull/Shield
@onready var gun: Node2D = %Ship/ShipHull/Gun

func _ready() -> void:
	# CONNECT THE SIGNAL
	area_entered.connect(_on_body_entered)
	modulate = Color(randf(),randf(), randf())
	
# function for detecting when shape is entered by player 
func _on_body_entered(body: Node2D):
	# print power up of the body is entered
	print("Hull Power Up - Activated\n")
	apply_buff()
	
# function that improves base stats of the player
func apply_buff():
	# apply the health buffs
	ship_hull.health = ship_hull.health + health_buff
	
	# player body speed buff
	engine.speed = engine.speed + speed_buff
	
	# apply the rotation speed buffs to all 
	engine.turn_speed = engine.turn_speed + rotation_speed_buff
	shield.turn_speed = shield.turn_speed + rotation_speed_buff
	gun.turn_speed_max = gun.turn_speed_max + rotation_speed_buff
	
	queue_free()
