class_name ShieldHurtBox
extends Area2D

const DEFAULT_SHIELD_DAMAGE = 5
var shield_damage: int = 2

func _init() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(_hitbox: Hitbox) -> void:
	# Remove non player projectiles only
	if not _hitbox.owner.is_in_group("player_projectiles"):
		if _hitbox.owner.damage != null and _hitbox.owner.damage != 0:
			$"..".take_damage(_hitbox.owner.damage)
		else:
			$"..".take_damage(DEFAULT_SHIELD_DAMAGE)
		if _hitbox.owner.has_method("take_damge()"):
			_hitbox.owner.take_damage(shield_damage)
		else:
			_hitbox.owner.queue_free()
		
