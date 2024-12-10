extends Node2D

@export var spawn_rate: float = 1.0
@export var spawn_amount: int = 5
@export var boid_scene: PackedScene
@export var boid_target: Node
@export var spawn_cap: int = 20
@export var despawn_distance: float = 500.0  # Maximum distance to the target before stopping spawns


var timer: Timer
var _debug_timer: Timer


func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = spawn_rate
	timer.connect("timeout", _on_spawn)
	timer.start()
	print("My Posistion " , global_position)
	print("Parent position: ", get_parent().global_position)
	


func _on_spawn() -> void:
	if is_target_too_far():
		if _debug_timer == null or _debug_timer.is_stopped():
			_debug_timer = Timer.new()
			add_child(_debug_timer)
			_debug_timer.start(5)
			print("Target is too far, stopping spawns and despawning all boids.")
		
		despawn_distant_boids()
		return
	# cycle_spawn_amount refers to the amount of boids to spawn
	# in this cycle. Its normally spawn_amount but in the rare
	# instances where spawn_amount will exceed spawn capacity
	# we must change it so that it wont. 
	var cycle_spawn_amount = spawn_amount
	var number_of_spawned_boids = len($BoidFolder.get_children())
	# Makes sure that the amount spawned this cycle does not 
	# exceed the spawn cap
	if number_of_spawned_boids + spawn_amount > spawn_cap:
		cycle_spawn_amount = spawn_cap - number_of_spawned_boids
	
	# Spawn the appropriate amount of boids
	for i in range(cycle_spawn_amount):
			spawn_boid()
			


func spawn_boid() -> void:
	var boid = boid_scene.instantiate()
	boid.global_position = $BoidFolder.global_position - global_position
	boid.target = boid_target # Target for boids to move towards
	boid.targeting_time = randi_range(3, 6) # Move towards target for 3-6 seconds
	boid.targeting_interval = randi_range(10, 20) # Every 10-20 seconds
	boid.modulate = Color(randf(), randf(), randf())
	$BoidFolder.add_child(boid)
	
	
func is_target_too_far() -> bool:
	# Calculate the distance between the target and the player
	var distance_to_target = global_position.distance_to(boid_target.global_position)
	return distance_to_target > despawn_distance


func despawn_distant_boids() -> void:
	# Remove distant boids from the BoidFolder
	for boid in $BoidFolder.get_children():
		var distance_to_target = boid.global_position.distance_to(boid_target.global_position)
		if distance_to_target > 1500:
			boid.queue_free()
