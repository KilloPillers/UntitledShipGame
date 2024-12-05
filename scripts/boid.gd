extends Area2D

@onready var ray_folder := $RayFolder.get_children()
var boids_i_see := []
var velocity := Vector2.ZERO
var speed := 6.0
var movv := 400
var target: Node
var is_targeting: bool = false
var targeting_time: float = 3.0
var targeting_interval: float = 5.0

var targeting_timer: Timer
var interval_timer: Timer

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
	
	# Start the interval timer
	interval_timer.wait_time = targeting_interval
	interval_timer.start()


func _physics_process(delta: float) -> void:
	var flocking_force = Vector2.ZERO
	if boids_i_see:
		flocking_force = calculate_flocking_force()
	
	var wall_avoidance_force = check_collision()
	
	var targeting_force = calculate_targeting_force()
	
	# Combine forces with weights
	velocity += flocking_force * 0.1 + wall_avoidance_force * 2.5 + targeting_force * 1.0 
	
	velocity = velocity.normalized() * speed
	move()
	
	if velocity.length() > 0: 
		rotation = lerp_angle(rotation, velocity.angle(), 0.1)


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
			if r.get_collider().is_in_group("wall"):
				var collision_point = r.get_collision_point()
				var collision_normal = r.get_collision_normal()
				var distance = (global_position - collision_point).length()
				
				# Calculate the reflection direction using the normal
				var reflection = velocity.bounce(collision_normal).normalized()
				
				# Calculate steering strength based on distance
				var strength = clamp(5 / max(1, distance), 0, 1)  # Adjust values as needed
				
				# Apply the reflection force
				avoidance_force += reflection * strength * speed
				
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
