extends Node2D

@export var turn_speed : float = 5

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
		pass
		# will enable a trigger, can't implement till boid projectiles are added
