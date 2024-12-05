extends Node2D

@export var rigidbody : RigidBody2D
@export var speed : float = 300
@export var friction : float = 0.01 # 0-1 value. 0.01 default takes about 4 seconds to stop.
@export var top_speed : float = 300
@export var turn_speed : float = 5


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("engine_right"):
		rotation += turn_speed * delta
	if Input.is_action_pressed("engine_left"):
		rotation -= turn_speed * delta
	if Input.is_action_pressed("engine_power"):
		#ship.position -= Vector2(cos(rotation), sin(rotation)) * speed
		
		var propulsion_direction_ : Vector2 = -Vector2(cos(rotation), sin(rotation)) * speed
		rigidbody.apply_central_force(propulsion_direction_) # Apply force
		
		if rigidbody.linear_velocity.length() > top_speed:
			rigidbody.linear_velocity *= (top_speed / rigidbody.linear_velocity.length())
	else:
		# Mannually apply a fake friction when the engine is de-powered.
		rigidbody.linear_velocity *= 1 - friction
		if (rigidbody.linear_velocity.length() < 10):
			rigidbody.linear_velocity *= 0 # Ensure the ship doesn't infinitely slow down.
