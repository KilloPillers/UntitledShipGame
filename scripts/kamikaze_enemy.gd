class_name KamikazeEnemy
extends CharacterBody2D


enum State {
	IDLE,
	TRACKING,
	ATTACHED,
}


var speed:float = 300.0
var turn_radius_factor:float = 0.1
var health:float = 10
var aggro_distance:float = 1000
var attach_distance:float = 20.0
var detonation_timer:Timer
var explosion_damage:float = 10
# damage is set to 0 so that it does no damage upon attaching to the player. This value is used in the hitbox.gd script
var damage:float = 0.0
var direction:Vector2
var target_destination:Vector2

var _state := State.IDLE


func _ready() -> void:
	_state = State.IDLE
	if %Player != null:
		target_destination = %Player.global_position
	else:
		target_destination = global_position
	direction = (target_destination - global_position).normalized()


func _physics_process(delta: float) -> void:
	if %Player != null:
		target_destination = %Player.global_position
	else:
		target_destination = global_position
	
	# Rotate Sprit accordingly
	rotate(angle_difference(rotation, direction.angle()))
	
	# TRACKING Logic
	if _state == State.TRACKING:
		# Move the enemy if the enemy is TRACKING. 
		direction = ((target_destination - global_position) * turn_radius_factor).normalized()
		velocity = direction * speed
		move_and_slide()
		# Attach to player if close enough
		if global_position.distance_to(target_destination) < attach_distance:
			attach()
	
	# IDLE Logic
	elif _state == State.IDLE and global_position.distance_to(target_destination) < aggro_distance:
		# Start tracking if player is within enemy range
		_state = State.TRACKING
	
	# ATTACHED Logic
	elif _state == State.ATTACHED:
		# Keep the enemy on the player
		global_position = target_destination
		
		# Explode once timer finishes
		if detonation_timer.is_stopped():
			explode()


func take_damage(damage:float) -> void:
	health -= damage
	if health <= 0:
		destroy()


func attach() -> void:
	_state = State.ATTACHED
	print("attaching")
	$CollisionShape2D.disabled = true
	
	detonation_timer = Timer.new()
	detonation_timer.one_shot = true
	add_child(detonation_timer)
	detonation_timer.start(1)


func explode() -> void:
	_state = State.IDLE
	if %Player != null:
		%Player.take_damage(explosion_damage)
	
	queue_free()


func destroy() -> void:
	queue_free()
