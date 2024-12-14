class_name LeechEnemy
extends CharacterBody2D


enum State {
	SPAWNING,
	IDLE,
	TRACKING,
	ATTACHED,
}


@export var health: float = 1
@export var damage: int = 1 
@export var speed: float = 200.0
@export var aggro_distance: float = 800 
@export var attach_distance: float = 50.0 
@export var damage_tick_rate: float = 1
@export var damage_lifespan: float = 3

var direction: Vector2
var target: Node
var target_destination: Vector2
var damage_timer: Timer

var _state : State
var _hits_dealt: int = 0
var _rng: RandomNumberGenerator
var _spawn_wander_timer: Timer
var _spawn_wander_direction: Vector2
var _spawn_wander_duration: float = 0.5

@onready var animation_tree:AnimationTree = $AnimationTree


func _ready() -> void:
	_state = State.SPAWNING
	_rng = RandomNumberGenerator.new()
	_spawn_wander_direction = Vector2(_rng.randf_range(-1, 1), _rng.randf_range(-1, 1)).normalized()
	
	_spawn_wander_timer = Timer.new()
	_spawn_wander_timer.one_shot = true
	add_child(_spawn_wander_timer)
	_spawn_wander_timer.start(_spawn_wander_duration)


func _physics_process(_delta: float) -> void:
	# Get the location of the player ship
	if target == null:
		#print("error, Leech enemy doesn't have ship targeted")
		destroy()
	
	# SPAWNING Logic
	if _state == State.SPAWNING:
		direction = _spawn_wander_direction
		velocity = direction * speed
		move_and_slide()
		if _spawn_wander_timer.is_stopped():
			_state = State.IDLE
	# TRACKING Logic
	elif _state == State.TRACKING:
		# Move the enemy if the enemy is TRACKING. 
		direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		# Attach to player if close enough
		if global_position.distance_to(target.global_position) < attach_distance:
			attach()
	
	# IDLE Logic
	elif _state == State.IDLE and global_position.distance_to(target.global_position) < aggro_distance:
		# Start tracking if player is within enemy range
		_state = State.TRACKING
	
	# ATTACHED Logic
	elif _state == State.ATTACHED:
		# Keep the enemy on the player
		global_position = target.global_position
		
		# Tick damage once timer finishes
		if damage_timer.is_stopped():
			_deal_damage()
	# Rotate Sprit accordingly to the direction it is going
	rotate(angle_difference(rotation, direction.angle()))

func take_damage(_damage: float) -> void:
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
		if (_hits_dealt >= damage_lifespan):
			destroy()


func destroy() -> void:
	# TODO Implement other logic for when enemy dies, i.e. sound effects, death animation
	queue_free()
