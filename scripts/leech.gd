class_name LeechEnemy
extends CharacterBody2D


enum State {
	IDLE,
	TRACKING,
	ATTACHED,
}


var speed:float = 200.0
var turn_radius_factor:float = 100
var health:float = 10
var aggro_distance:float = 800
var attach_distance:float = 30.0
var damage_timer:Timer
var damage:float = 2.0
var direction:Vector2
var target_destination:Vector2

var _state := State.IDLE
var _attached_position:Vector2 

@onready var animation_tree:AnimationTree = $AnimationTree


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
		target_destination = global_position + Vector2(5,0)
	
	# Rotate Sprit accordingly
	rotate(angle_difference(rotation, direction.angle()))
	
	# TRACKING Logic
	if _state == State.TRACKING:
		# Move the enemy if the enemy is TRACKING. 
		direction = ((target_destination - global_position) / turn_radius_factor).normalized()
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
		
		# Tick damage once timer finishes
		if damage_timer.is_stopped():
			_deal_damage()


func take_damage(damage:float) -> void:
	health -= damage
	if health <= 0:
		destroy()


func attach() -> void:
	_state = State.ATTACHED
	print("attaching")
	$CollisionShape2D.disabled = true
	
	damage_timer = Timer.new()
	damage_timer.one_shot = true
	add_child(damage_timer)
	damage_timer.start(1)


func _deal_damage() -> void:
	if %Player != null:
		target_destination = %Player.global_position
	else:
		%Player.take_damage(damage)


func destroy() -> void:
	queue_free()
