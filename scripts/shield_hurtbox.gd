class_name ShieldHurtBox
extends Area2D


func _init() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(_hitbox: Hitbox) -> void:
	# Remove non player projectiles only
	if not _hitbox.owner.is_in_group("player_projectiles"):
		_hitbox.owner.queue_free()
