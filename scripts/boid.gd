extends Area2D

@onready var ray_folder := $RayFolder.get_children()

@export var shooting_range: float = 500.0  # Distance within which the boid can shoot
@export var shooting_angle_tolerance: float = 0.02  # Radians of angle tolerance for shooting
@export var shoot_cooldown: float = 1.0  # Time between consecutive shots
@export var projectile: PackedScene

var last_shot_time: float = 0.0  # Tracks the last shot time
var boids_i_see := []
var velocity := Vector2.ZERO
var health: int = 10
var speed := 6.0
var movv := 400
var target: Node
var is_targeting: bool = false
var targeting_time: float = 3.0
var targeting_interval: float = 5.0
var random_jitter_strength: float = 0.5

var shoot_timer: Timer
var targeting_timer: Timer
var interval_timer: Timer

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready() -> void:
	randomize()
	velocity = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized() * speed  # Random initial direction
	
	 # Create and set up the targeting timer
	targeting_timer = Timer.new()
	targeting_timer.one_shot = true
	targeting_timer.connect("timeout", _on_targeting_time_timeout)
	add_child(targeting_timer)
	
	# Create and set up the interval timer
	interval_timer = Timer.new()
	interval_timer.one_shot = true
	interval_timer.connect("timeout", _on_interval_timer_timeout)
	add_child(interval_timer)
	
	# Create and set up the shoot cooldown timer
	shoot_timer = Timer.new()
	shoot_timer.one_shot = true  # Ensures it runs only once per cooldown
	add_child(shoot_timer)

	# Start the interval timer
	interval_timer.wait_time = targeting_interval
	interval_timer.start()


func _physics_process(delta: float) -> void:
	var flocking_force = Vector2.ZERO
	if boids_i_see:
		flocking_force = calculate_flocking_force()
	
	var wall_avoidance_force = check_collision()
	
	var targeting_force = calculate_targeting_force()
	
	var random_jitter = calculate_random_jitter() if not is_targeting else Vector2.ZERO
	
	# Combine forces with weights
	velocity += flocking_force * 0.1 + wall_avoidance_force * 2.5 + targeting_force * 1.0 + random_jitter
	
	velocity = velocity.normalized() * speed
	move()
	
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
	# Generate a small random vector
	var jitter = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	return jitter * random_jitter_strength


func calculate_flocking_force() -> Vector2:
	var flocking_force := Vector2.ZERO
	if boids_i_see:
		var number_of_boids := boids_i_see.size()
		var average_velocity := Vector2.ZERO
		var average_position := Vector2.ZERO
		var separation_force := Vector2.ZERO
		
		for boid in boids_i_see:
			average_velocity += boid.velocity
			average_position += boid.global_position
			
			# Separation: Steer away from nearby boids
			var distance = (global_position - boid.global_position).length()
			if distance < movv:  # Only apply separation within `movv` range
				var factor = (movv - distance) / movv  # Stronger force closer to the boid
				separation_force += (global_position - boid.global_position).normalized() * factor
		
		average_velocity /= number_of_boids
		average_position /= number_of_boids
		
		# Combine components of the flocking behavior
		flocking_force += ((average_velocity - velocity) / 2) * 1  # Alignment
		flocking_force += (average_position - global_position) * .25  # Cohesion 
		flocking_force += separation_force * 20.0  # separation
	
	return flocking_force


func check_collision() -> Vector2:
	var avoidance_force := Vector2.ZERO
	for ray in ray_folder:
		var r: RayCast2D = ray
		if r.is_colliding():
			if r.get_collider().is_in_group("obstacle"):
				var collision_point = r.get_collision_point()
				var collision_normal = r.get_collision_normal()
				var distance = (global_position - collision_point).length()

				# Calculate the normal vector (steering direction)
				var normal = (global_position - collision_point).normalized()
				
				# Apply the reflection force
				avoidance_force += normal * sqrt(1/distance)
				
	return avoidance_force

	
func calculate_targeting_force() -> Vector2:
	if not is_targeting or not target:
		return Vector2.ZERO
	return (target.global_position - global_position).normalized() * speed


func move() -> void:
	global_position += velocity


func _on_vision_area_entered(area: Area2D) -> void:
	if area != self and area.is_in_group("boid"):
		boids_i_see.append(area)


func _on_vision_area_exited(area: Area2D) -> void:
	if area:
		boids_i_see.erase(area)


func _on_targeting_time_timeout() -> void:
	is_targeting = false  # Stop targeting
	# Start the interval timer
	interval_timer.wait_time = targeting_interval
	interval_timer.start()
	

func _on_interval_timer_timeout() -> void:
	is_targeting = true  # Start targeting
	# Start the targeting timer
	targeting_timer.wait_time = targeting_time
	targeting_timer.start()


func check_and_shoot() -> void:
	# Calculate the distance to the target
	var distance_to_target = global_position.distance_to(target.global_position)
	# Calculate the angle to the target
	var direction_to_target = (target.global_position - global_position).normalized()
	var angle_to_target = direction_to_target.angle()
	
	# Check if the boid is within shooting range
	if distance_to_target <= shooting_range:
		# Check if the boid is looking at the target within tolerance
		var angle_difference = abs(rotation - angle_to_target)
		if angle_difference <= shooting_angle_tolerance or angle_difference >= TAU - shooting_angle_tolerance:
			# Check cooldown
			if shoot_timer.time_left == 0: # Timer is ready to shoot again
				_fire_projectile()
				shoot_timer.start(shoot_cooldown) # Start the cooldown timer


func _fire_projectile() -> void:
	var new_projectile = projectile.instantiate()
	get_tree().root.add_child(new_projectile)
	new_projectile.rotation = rotation
	new_projectile.global_position = global_position
