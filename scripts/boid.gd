extends Area2D

@onready var ray_folder := $RayFolder.get_children()
var boids_i_see := []
var velocity := Vector2.ZERO
var speed := 4.0
var screensize : Vector2
var movv := 400


func _ready() -> void:
	screensize = get_viewport_rect().size
	randomize()
	velocity = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized() * speed  # Random initial direction
	

func _physics_process(delta: float) -> void:
	var flocking_force = Vector2.ZERO
	if boids_i_see:
		flocking_force = calculate_flocking_force()
	
	var wall_avoidance_force = check_collision()
	
	# Combine forces with weights
	velocity += flocking_force * 0.5 + wall_avoidance_force * 1.5  # Adjust weights as needed
	
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
		flocking_force += (average_velocity - velocity) / 2  # Alignment
		flocking_force += (average_position - global_position) * 0.25  # Cohesion (reduced weight)
		flocking_force += separation_force * 3.0  # Increased weight for separation
	
	return flocking_force



func check_collision() -> Vector2:
	var avoidance_force := Vector2.ZERO
	for ray in ray_folder:
		var r: RayCast2D = ray
		if r.is_colliding():
			if r.get_collider().is_in_group("wall"):
				var collision_point = r.get_collision_point()
				var distance = (global_position - collision_point).length()
				
				# Calculate the normal vector (steering direction)
				var normal = (global_position - collision_point).normalized()
				
				# Calculate steering strength based on distance
				var strength = clamp(10 / max(1, distance), 0, 1)  # Adjust 100 and 5 for sensitivity
				
				# Add the avoidance force
				avoidance_force += normal * strength
				
	return avoidance_force


func move() -> void:
	global_position += velocity
	if global_position.x < 0:
		global_position.x = screensize.x
	if global_position.x > screensize.x:
		global_position.x = 0
	if global_position.y < 0:
		global_position.y = screensize.y
	if global_position.y > screensize.y:
		global_position.y = 0


func _on_vision_area_entered(area: Area2D) -> void:
	if area != self and area.is_in_group("boid"):
		boids_i_see.append(area)


func _on_vision_area_exited(area: Area2D) -> void:
	if area:
		boids_i_see.erase(area)
