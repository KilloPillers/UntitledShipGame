class_name LeechEnemy
extends CharacterBody2D


enum State {
	IDLE,
	TRACKING,
	ATTACHED,
}


@export var health:float = 1
@export var damage:int = 1 
@export var speed:float = 200.0 #TODO adjust this for game feel
@export var aggro_distance:float = 800 #TODO adjust this for game feel
@export var attach_distance:float = 50.0 
@export var damage_tick_rate:float = 1 #TODO adjust this for game feel
@export var damage_lifespawn:float = 5 #TODO bandaid, how many times the leech hits before dying.

var turn_radius_factor:float = 100
var direction:Vector2
var target:Node
var target_destination:Vector2
var damage_timer:Timer

var _state := State.IDLE
var _hits_dealt:int = 0

@onready var animation_tree:AnimationTree = $AnimationTree


func _ready() -> void:
	_state = State.IDLE
	if target != null:
		target_destination = target.global_position
	else:
		target_destination = global_position
		#print("error, Leech enemy doesn't have ship targeted")
	direction = (target_destination - global_position).normalized()


func _physics_process(_delta: float) -> void:
	# Get the location of the player ship
	if target != null:
		target_destination = target.global_position
	else:
		target_destination = global_position
		#print("error, Leech enemy doesn't have ship targeted")
	
	# Rotate Sprit accordingly to the direction it is going
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


func take_damage(_damage:float) -> void:
	health -= _damage
	if health <= 0:
		destroy()


func attach() -> void:
	_state = State.ATTACHED
	#print("attaching")
	$CollisionShape2D.disabled = true
	
	damage_timer = Timer.new()
	damage_timer.one_shot = true
	add_child(damage_timer)
	damage_timer.start(0)


func _deal_damage() -> void:
	if target != null:
		target.take_damage(damage)
		damage_timer = Timer.new()
		damage_timer.one_shot = true
		add_child(damage_timer)
		damage_timer.start(damage_tick_rate)
		
		#TEMPORARY
		_hits_dealt += 1
		if (_hits_dealt >= 5):
			destroy()


func destroy() -> void:
	# TODO Implement other logic for when enemy dies, i.e. sound effects, death animation
	queue_free()
