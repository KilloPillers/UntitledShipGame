extends Node2D

@export var spawn_rate: float = 1.0
@export var spawn_amount: int = 5
@export var boid_scene: PackedScene
@export var spawn_cap: int = 20

var timer: Timer


func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = spawn_rate
	timer.connect("timeout", _on_spawn)
	timer.start()
	print(global_position)
	

func _on_spawn() -> void:
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
	boid.global_position = global_position
	print(boid.global_position)
	boid.modulate = Color(randf(), randf(), randf())
	$BoidFolder.add_child(boid)
