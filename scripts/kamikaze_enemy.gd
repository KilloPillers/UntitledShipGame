class_name KamikazeEnemy
extends CharacterBody2D


enum State {
	SPAWNING,
	IDLE,
	TRACKING,
	ATTACHED,
}

@export var health: int = 2
@export var speed: float = 280.0
@export var aggro_distance: float = 800 #TODO find a good value for this
@export var explosion_damage: float = 2 
@export var detonation_delay: float = 2 

var attach_distance: float = 50.0
var detonation_timer: Timer
# damage is set to 0 so that it does no damage upon attaching to the player. This value is used in the hitbox.gd script
var damage: int = 0
var direction := Vector2.ZERO
var target: Node

var _state : State
var _rng: RandomNumberGenerator
var _spawn_wander_timer: Timer
var _spawn_wander_direction: Vector2
var _spawn_wander_duration: float = 0.5

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	animation_tree["parameters/conditions/exploding"] = false
	_state = State.SPAWNING
	_rng = RandomNumberGenerator.new()
	_spawn_wander_direction = Vector2(_rng.randf_range(-1, 1), _rng.randf_range(-1, 1)).normalized()
	
	_spawn_wander_timer = Timer.new()
	_spawn_wander_timer.one_shot = true
	add_child(_spawn_wander_timer)
	_spawn_wander_timer.start(_spawn_wander_duration)


func _physics_process(_delta: float) -> void:
	if target == null:
		print("error, Kamikaze enemy doesn't have ship targeted")
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
		
		# Explode once timer finishes
		if detonation_timer.is_stopped():
			explode()
	# Rotate Sprit accordingly
	rotate(angle_difference(rotation, direction.angle()))
	_manage_animation_tree_state()


func _manage_animation_tree_state() -> void:
	if _state == State.IDLE:
		animation_tree["parameters/conditions/exploding"] = false
	


func take_damage(_damage: int) -> void:
	health -= _damage
	flash_white()
	if health <= 0:
		destroy()


func flash_white() -> void:
	sprite.modulate = Color(10,10,10,10)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1,1,1)


func attach() -> void:
	_state = State.ATTACHED
	$CollisionShape2D.disabled = true
	animation_tree["parameters/conditions/exploding"] = true
	
	detonation_timer = Timer.new()
	detonation_timer.one_shot = true
	add_child(detonation_timer)
	detonation_timer.start(1)


func explode() -> void:
	_state = State.IDLE
	if target != null:
		target.take_damage(explosion_damage)
	
	queue_free()


func destroy() -> void:
	queue_free()
