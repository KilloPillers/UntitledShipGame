class_name CollapsibleWall
extends StaticBody2D

@export var health:int = 2


func take_damage(_damage:int) -> void:
	health -= _damage
	if health <= 0:
		destroy()


func destroy() -> void:
	queue_free()
