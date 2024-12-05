class_name HurtBox
extends Area2D

var damage:int = 1

func _init() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(_hitbox:HitBox) -> void:
	if owner.has_method("take_damage"):
		owner.take_damage(_hitbox.damage)
	elif owner.has_method("destroy"):
		owner.destroy()
