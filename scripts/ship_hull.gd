class_name ShipHull
extends RigidBody2D


@export var health:int = 100


func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func take_damage(_damage:int) -> void:
	health -= _damage
	if health <= 0:
		health = 0
		_start_death()
	print("ouch, ship took ", _damage, " damage. Ship now has ", health, " health remaining")


func _start_death() -> void:
	#TODO implement logic for the player dying, like take away player control, play dying animation, fade to black, return to title screen
	pass 
