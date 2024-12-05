class_name HitBox
extends Area2D

var damage:int = 1


# Called when the node enters the scene tree for the first time.
func _init() -> void:
	#area_entered.connect(_on_area_entered)
	pass


func _on_area_entered(_hurtbox:HurtBox) -> void:
	#if owner.has_method("take_damage"):
		#owner.take_damage(owner.damage)
	#if owner.has_method("destroy"):
		#owner.destroy()
	pass
