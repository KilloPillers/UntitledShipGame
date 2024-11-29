class_name CollapsibleWall
extends StaticBody2D


func _ready() -> void:
	pass
func destroy() -> void:
	print("hit wall!")
	queue_free()
