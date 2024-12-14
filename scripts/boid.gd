class_name Boid
extends CharacterBody2D


@export var shooting_range: float = 900.0  # Distance within which the boid can shoot
@export var shooting_angle_tolerance: float = 0.02  # Radians of angle tolerance for shooting
@export var shoot_cooldown: float = 0.75  # Time between consecutive shots
@export var projectile: PackedScene
@export var min_distance_from_target: float = 200.0  # Minimum distance to maintain from the target
@export var evasion_distance: float = 400.0  # Distance to move away before reengaging
@export var evasion_time: float = 4.0  # Time to spend evading


var last_shot_time: float = 0.0  # Tracks the last shot time
var health: int = 1
var speed := 300.0
var movv := 400
var target: Node
var is_targeting: bool = false
var is_evading: bool = false
var targeting_time: float = 10.0
var targeting_interval: float = 5.0
var random_jitter_strength: float = 0.5

var _boids_i_see := []
var _shoot_timer: Timer
var _targeting_timer: Timer
var _interval_timer: Timer
var _evasion_timer: Timer

@onready var ray_folder := $RayFolder.get_children()
@onready var animated_sprite_2d = $AnimatedSprite2D


func _ready() -> void:
	randomize()
	velocity = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized() * speed  # Random initial direction
	
	# Create and set up the targeting timer
	_targeting_timer = Timer.new()
	_targeting_timer.one_shot = true
	_targeting_timer.connect("timeout", _on_targeting_time_timeout)
	add_child(_targeting_timer)
	
	# Create and set up the interval timer
	_interval_timer = Timer.new()
	_interval_timer.one_shot = true
	_interval_timer.connect("timeout", _on_interval_timer_timeout)
	add_child(_interval_timer)
	
	# Create and set up the shoot cooldown timer
	_shoot_timer = Timer.new()
	_shoot_timer.one_shot = true  # Ensures it runs only once per cooldown
	add_child(_shoot_timer)
	
	# Create and set up the evasion timer
	_evasion_timer = Timer.new()
	_evasion_timer.one_shot = true
	_evasion_timer.connect("timeout", _on_evasion_timeout)
	add_child(_evasion_timer)
	
	# Start the interval timer
	_interval_timer.wait_time = targeting_interval
	_interval_timer.start()


func _physics_process(_delta: float) -> void:
	$EnemyHealth.value = health
	var flocking_force := Vector2.ZERO
	if _boids_i_see:
		flocking_force = calculate_flocking_force()
	
	var wall_avoidance_force = check_collision()
	
	var targeting_force = calculate_targeting_force()
	
	var random_jitter = calculate_random_jitter() if not is_targeting else Vector2.ZERO
	
	# Combine forces with weights
	velocity += flocking_force * 0.5 + wall_avoidance_force * 200.0 + targeting_force * 1.0 + random_jitter
	
	velocity = velocity.normalized() * speed
	move_and_slide()
	
	if velocity.length() > 0: 
		rotation = lerp_angle(rotation, velocity.angle(), 0.1)
		
	# Check if the boid can shoot
	if is_targeting and target:
		check_and_shoot()
	
	if is_targeting:
		animated_sprite_2d.play("aggro")
	else:
		animated_sprite_2d.play("default")


func calculate_random_jitter() -> Vector2:
	var jitter = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	return jitter * random_jitter_strength


func calculate_flocking_force() -> Vector2:
	var flocking_force := Vector2.ZERO
	if _boids_i_see:
		var number_of_boids := _boids_i_see.size()
		var average_velocity := Vector2.ZERO
		var average_position := Vector2.ZERO
		var separation_force := Vector2.ZERO
		
		for boid in _boids_i_see:
			# Make sure the boid is not in the queue_free queue.
			if not is_instance_valid(boid):
				continue 
				
			#if not boid.is_targeting:
			#	continue
				
			average_velocity += boid.velocity
			average_position += boid.global_position
			
			var distance = (global_position - boid.global_position).length()
			if distance < movv:
				var factor = (movv - distance) / movv
				separation_force += (global_position - boid.global_position).normalized() * factor
		
		average_velocity /= number_of_boids
		average_position /= number_of_boids
		
		flocking_force += ((average_velocity - velocity) / 2) * 1
		flocking_force += (average_position - global_position) * .25
		flocking_force += separation_force * 40.0
	
	return flocking_force


func check_collision() -> Vector2:
	var avoidance_force := Vector2.ZERO
	for ray in ray_folder:
		var r: RayCast2D = ray
		if r.is_colliding():
			if r.get_collider() and r.get_collider().is_in_group("obstacle"):
				var collision_point = r.get_collision_point()
				var distance = (global_position - collision_point).length()
				var normal = (global_position - collision_point).normalized()
				avoidance_force += normal * sqrt(1/distance)
	return avoidance_force


func calculate_targeting_force() -> Vector2:
	if not is_targeting or not target:
		return Vector2.ZERO
		
	var distance_to_target = global_position.distance_to(target.global_position)
	
	if is_evading:
		# Already in evasion mode, continue moving away from the target
		var evade_direction = (global_position - target.global_position).normalized()
		return evade_direction * speed
	elif distance_to_target < min_distance_from_target:
		# Start evasion and reset targeting
		is_evading = true
		is_targeting = false
		_evasion_timer.start(evasion_time)
		_interval_timer.wait_time = evasion_time
		_interval_timer.start()
		
		# Calculate the initial evade direction
		var evade_direction = (global_position - target.global_position).normalized()
		return evade_direction * speed
	else:
		# Normal targeting behavio
		return (target.global_position - global_position).normalized() * speed


func move() -> void:
	global_position += velocity


func _on_vision_area_entered(area: Area2D) -> void:
	if area != self and area.is_in_group("boid"):
		_boids_i_see.append(area.owner)


func _on_vision_area_exited(area: Area2D) -> void:
	if area:
		_boids_i_see.erase(area.owner)


func _on_targeting_time_timeout() -> void:
	is_targeting = false
	_interval_timer.wait_time = targeting_interval
	_interval_timer.start()


func _on_interval_timer_timeout() -> void:
	is_targeting = true
	_targeting_timer.wait_time = targeting_time
	_targeting_timer.start()


func _on_evasion_timeout() -> void:
	is_evading = false


func check_and_shoot() -> void:
	if is_evading:
		return
	
	var distance_to_target = global_position.distance_to(target.global_position)
	var direction_to_target = (target.global_position - global_position).normalized()
	var angle_to_target = direction_to_target.angle()
	
	if distance_to_target <= shooting_range:
		var _angle_difference = abs(rotation - angle_to_target)
		if _angle_difference <= shooting_angle_tolerance or _angle_difference >= TAU - shooting_angle_tolerance:
			if _shoot_timer.time_left == 0:
				_fire_projectile()
				_shoot_timer.start(shoot_cooldown)

func _fire_projectile() -> void:
	var new_projectile = projectile.instantiate()
	get_tree().root.add_child(new_projectile)
	new_projectile.rotation = rotation
	new_projectile.global_position = global_position


func take_damage(_damage: int) -> void:
	health -= _damage
	if health <= 0:
		destroy()


func destroy() -> void:
	queue_free()
