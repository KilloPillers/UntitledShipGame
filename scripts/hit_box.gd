class_name HitBox
extends Area2D

const DEFAULT_DAMAGE:int = 1

# NOTICE I have realized that this script is kind of pointless (as far as my understanding) because you 
# can just have all the logic go in the hurt_box.gd script instead, which is how it currently is implemented


func _init() -> void:
	# area_entered.connect(_on_area_entered)
	pass


func _on_area_entered(_hurtbox:HurtBox) -> void:
	pass
	
	#if _hurtbox.get_parent().has_method("take_damage"):
		#if "damage" in owner:
			#_hurtbox.get_parent().take_damage(owner.damage)
		#else:
			#_hurtbox.get_parent().take_damage(DEFAULT_DAMAGE)
	#if _hurtbox.owner.has_method("destroy"):
		#_hurtbox.owner.destroy()
