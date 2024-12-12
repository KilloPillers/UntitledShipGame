class_name EnemySpawner
extends Node2D

enum EnemyType {
	BOID,
	KAMIKAZE,
	LEECH,
}


@export var enemy_type:EnemyType
@export var enemy_scene: PackedScene
@export var enemy_target: Node
@export var spawn_rate: float = 1.0
@export var spawn_amount: int = 5
@export var spawn_cap: int = 20
@export var despawn_distance: float = 500.0  # Maximum distance to the target before stopping spawns
@export var aggro_distance:int = 800 # for leeches and kamikaze's
@export var is_boss_spawner:bool = false

var boss_scaling:float = 1 # only used by boss spawners to progressively make enemies stronger.
var timer: Timer

var _debug_timer: Timer



func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = spawn_rate
	timer.connect("timeout", _on_spawn)
	timer.start()
	

func _on_spawn() -> void:
	if is_target_too_far():
		# prints debug info 
		#if _debug_timer == null or _debug_timer.is_stopped():
			#_debug_timer = Timer.new()
			#add_child(_debug_timer)
			#_debug_timer.start(5)
			#print("Target is too far, stopping spawns and despawning all boids.")
		
		despawn_distant_enemies()
		return
	# cycle_spawn_amount refers to the amount of enemies to spawn
	# in this cycle. Its normally spawn_amount but in the rare
	# instances where spawn_amount will exceed spawn capacity
	# we must change it so that it wont. 
	var cycle_spawn_amount = spawn_amount
	var number_of_spawned_enemies = len($EnemyFolder.get_children())
	# Makes sure that the amount spawned this cycle does not 
	# exceed the spawn cap
	if number_of_spawned_enemies + spawn_amount > spawn_cap:
		cycle_spawn_amount = spawn_cap - number_of_spawned_enemies
	
	# Spawn the appropriate amount of enemies
	for i in range(cycle_spawn_amount):
		if enemy_type == EnemyType.BOID:
			spawn_boid()
		if enemy_type == EnemyType.KAMIKAZE:
			spawn_kamikaze()
		if enemy_type == EnemyType.LEECH:
			spawn_leech()

# used by the boss to manually spawn enemies on spawners
func force_spawn(power_scale:float) -> void:
	var number_of_spawned_enemies = len($EnemyFolder.get_children())
	if number_of_spawned_enemies > spawn_cap:
		return
		
	for i in range(spawn_amount):
		if enemy_type == EnemyType.BOID:
			spawn_boid()
		if enemy_type == EnemyType.KAMIKAZE:
			spawn_kamikaze()
		if enemy_type == EnemyType.LEECH:
			spawn_leech()

func spawn_boid() -> void:
	var boid = enemy_scene.instantiate()
	boid.global_position = $EnemyFolder.global_position - global_position
	boid.target = enemy_target # Target for boids to move towards
	boid.targeting_time = randi_range(3, 6) # Move towards target for 3-6 seconds
	boid.targeting_interval = randi_range(10, 20) # Every 10-20 seconds
	#boid.modulate = Color(randf(), randf(), randf())
	$EnemyFolder.add_child(boid)
	
	if (is_boss_spawner):
		boid.health *= boss_scaling


func spawn_kamikaze() -> void:
	print("spawning Kamikaze Enemy")
	var kamikaze_enemy = enemy_scene.instantiate()
	kamikaze_enemy.target = enemy_target
	kamikaze_enemy.global_position = $EnemyFolder.global_position - global_position
	kamikaze_enemy.aggro_distance = aggro_distance
	#boid.modulate = Color(randf(), randf(), randf())
	$EnemyFolder.add_child(kamikaze_enemy)
	
	if (is_boss_spawner):
		kamikaze_enemy.health *= boss_scaling


func spawn_leech() -> void:
	print("spawning Leech Enemy")
	var leech_enemy = enemy_scene.instantiate()
	leech_enemy.target = enemy_target
	leech_enemy.global_position = $EnemyFolder.global_position - global_position
	leech_enemy.aggro_distance = aggro_distance
	#boid.modulate = Color(randf(), randf(), randf())
	$EnemyFolder.add_child(leech_enemy)
	
	if (is_boss_spawner):
		leech_enemy.health *= boss_scaling


func is_target_too_far() -> bool:
	# Calculate the distance between the target and the player
	var distance_to_target = global_position.distance_to(enemy_target.global_position)
	return distance_to_target > despawn_distance


func despawn_distant_enemies() -> void:
	# Remove distant boids from the BoidFolder
	for enemy in $EnemyFolder.get_children():
		var distance_to_target = enemy.global_position.distance_to(enemy_target.global_position)
		if distance_to_target > 1500: # hard coded value represents the camera view
			enemy.queue_free()
