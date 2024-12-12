class_name BOSS
extends Node2D

enum State {
	IDLE,
	PHASE1
}

@export var max_health:int = 30 # About 60 shots
@export var aggro_range:float = 1000 #Trigger boss fight
@export var spawn_rate:float = 1 #This many seconds between timed spawns.
@export var spawners:Array[EnemySpawner]

var boss_scaling = 1
var state:State
var health:int
var target_position:Vector2
var target_direction:Vector2
var rng_ : RandomNumberGenerator
var _timer:Timer

@onready var animation_tree:AnimationTree = $AnimationTree
@onready var sprite:AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	health = max_health
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.start(spawn_rate)
	
	state = State.IDLE
	rng_ = RandomNumberGenerator.new()


func _physics_process(_delta: float) -> void:
	if %Ship != null:
		target_position = %Ship/ShipHull.global_position
	if global_position.distance_to(target_position) < aggro_range:
		state = State.PHASE1
		if _timer != null and _timer.is_stopped():
			spawn()
			
	else:
		state = State.IDLE


func spawn() -> void:
	var rng_factor = rng_.randi_range(0, spawners.size() - 1)
	spawners[rng_factor].force_spawn(boss_scaling)
	
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.start(spawn_rate)





func take_damage(_damage:int) -> void:
	health -= _damage
	
	_timer.stop()
	spawn()
	
	if (health > max_health/2):
		boss_scaling = 1
	else:
		boss_scaling = 3 - 2 * (health/max_health)
	
	flash_white()
	if health <= 0:
		get_tree().change_scene_to_file("res://scenes/ending_cutscene.tscn")

func flash_white() -> void:
	sprite.modulate = Color(10,2,2,2) # red in this case
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1,1,1)

# Called by Hurtbox.gd
func destroy() -> void:
	queue_free()
