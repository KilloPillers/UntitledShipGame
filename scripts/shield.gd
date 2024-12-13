extends Node2D

@export var turn_speed : float = 5

#@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation = $AnimationPlayer

var shield_power_up = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("shield_right"):
		rotation += turn_speed * delta
	if Input.is_action_pressed("shield_left"):
		rotation -= turn_speed * delta
	if Input.is_action_pressed("shield_power"):
		#animated_sprite_2d.play("on")
		if shield_power_up:
			animation.play("upgraded_shield")
		else:
			animation.play("on")
		pass
		# will enable a trigger, can't implement till boid projectiles are added
	else:
		animation.play("off")
