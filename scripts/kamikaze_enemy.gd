class_name KamikazeEnemy
extends CharacterBody2D


enum State {
	IDLE,
	TRACKING,
	ATTACHED,
}

@export var health:int = 2
@export var speed:float = 300.0
@export var aggro_distance:float = 800 #TODO find a good value for this
@export var explosion_damage:float = 10 
@export var detonation_delay:float = 2 #TODO find a good value for this

var turn_radius_factor:float = 0.1
var attach_distance:float = 50.0
var detonation_timer:Timer
# damage is set to 0 so that it does no damage upon attaching to the player. This value is used in the hitbox.gd script
var damage:float = 0.0
var direction:Vector2
var target:Node
var target_destination:Vector2

var _state := State.IDLE

@onready var animation_tree:AnimationTree = $AnimationTree
@onready var sprite:Sprite2D = $Sprite2D

func _ready() -> void:
	animation_tree["parameters/conditions/exploding"] = false
	_state = State.IDLE
	if target != null:
		target_destination = target.global_position
	else:
		pass
		#print("error, Kamikaze enemy doesn't have ship targeted")
	direction = (target_destination - global_position).normalized()


func _physics_process(_delta: float) -> void:
	if target != null:
		target_destination = target.global_position
	else:
		target_destination = global_position
		#print("error, Kamikaze enemy doesn't have ship targeted")
	
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
	_manage_animation_tree_state()


func _manage_animation_tree_state() -> void:
	if _state == State.IDLE:
		animation_tree["parameters/conditions/exploding"] = false
	


func take_damage(_damage:int) -> void:
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
	#print("attaching, distance to target = ", global_position.distance_to(target_destination))
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
	# TODO Implement other logic for when enemy dies, i.e. sound effects, death animation
	queue_free()
