class_name HurtBox
extends Area2D

const DEFAULT_DAMAGE:int = 1

func _init() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(_hitbox:HitBox) -> void:
	if owner.has_method("take_damage"):
		if _hitbox.owner.damage != null:
			owner.take_damage(_hitbox.owner.damage)
		else:
			owner.take_damage(DEFAULT_DAMAGE)
		
		# TODO if you want to add piercing to the bullet, this is the area you want to change. 
		# Could add a property to the bullets that indicated pierce value, and decrement here instead, 
		# and if it reaches 0 then destroy it
		_hitbox.owner.queue_free()
		
	elif get_parent().has_method("take_damage"):
		if _hitbox.owner.damage != null:
			get_parent().take_damage(_hitbox.owner.damage)
		else:
			get_parent().take_damage(DEFAULT_DAMAGE)
	elif owner.has_method("destroy"):
		owner.destroy()
