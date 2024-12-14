class_name Hurtbox
extends Area2D

const DEFAULT_DAMAGE: int = 1

func _init() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(_hitbox: Hitbox) -> void:
	if owner.has_method("take_damage"):
		if _hitbox.owner.damage != null:
			owner.take_damage(_hitbox.owner.damage)
		else:
			owner.take_damage(DEFAULT_DAMAGE)
		if(_hitbox.owner is PlayerProjectile):
			_hitbox.owner.pierce -= 1
			
			if _hitbox.owner.pierce == 0:
				_hitbox.owner.queue_free()
		else:
			_hitbox.owner.queue_free()
		
	elif get_parent().has_method("take_damage"):
		if _hitbox.owner.damage != null:
			get_parent().take_damage(_hitbox.owner.damage)
		else:
			get_parent().take_damage(DEFAULT_DAMAGE)
	elif owner.has_method("destroy"):
		owner.destroy()
