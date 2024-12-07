class_name Mine
extends CharacterBody2D

enum State {
	IDLE,
	TRIGGERED,
	EXPLODING,
}

var health:float = 10
var damage:float = 10
var trigger_distance:float = 100
var detonation_delay:float = 3
var state:State
var _detonation_timer:Timer
var explosion_radius:float = 100

@onready var animation_tree:AnimationTree = $AnimationTree


func _ready() -> void:
	state = State.IDLE


func _physics_process(delta: float) -> void:
	if state == State.IDLE:
		if global_position.distance_to(%Player.global_position) <= trigger_distance:
			state = State.TRIGGERED
			_detonation_timer = Timer.new()
			_detonation_timer.one_shot = true
			add_child(_detonation_timer)
			_detonation_timer.start(detonation_delay)
	elif state == State.TRIGGERED:
		if _detonation_timer.is_stopped():
			explode()
	
	_manage_animation_tree_state()

func _manage_animation_tree_state() -> void:
	if state == State.IDLE:
		animation_tree["parameters/conditions/triggered"] = false
		animation_tree["parameters/conditions/exploding"] = false
	elif state == State.TRIGGERED:
		animation_tree["parameters/conditions/exploding"] = false
		animation_tree["parameters/conditions/triggered"] = true
	elif state == State.EXPLODING:
		animation_tree["parameters/conditions/triggered"] = false
		animation_tree["parameters/conditions/exploding"] = true
		

func explode() -> void:
	state = State.EXPLODING
	if global_position.distance_to(%Player.global_position) <= explosion_radius:
		%Player.take_damage(damage)
	destroy()


func destroy() -> void:
	queue_free()
