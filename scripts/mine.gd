class_name Mine
extends CharacterBody2D

enum State {
	IDLE,
	TRIGGERED,
	EXPLODING,
}

@export var health: int = 2
@export var damage: int = 10
@export var trigger_distance: float = 200
@export var detonation_delay: float = 1.0

var state:State
var _detonation_timer:Timer

@onready var animation_tree:AnimationTree = $AnimationTree
@onready var sprite:Sprite2D = $Sprite2D


func _ready() -> void:
	state = State.IDLE


func _physics_process(delta: float) -> void:
	if state == State.IDLE:
		if global_position.distance_to(%Ship/ShipHull.global_position) <= trigger_distance:
			state = State.TRIGGERED
			_detonation_timer = Timer.new()
			_detonation_timer.one_shot = true
			add_child(_detonation_timer)
			_detonation_timer.start(detonation_delay)
	elif state == State.TRIGGERED:
		$Light.energy += delta * 1.5
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


func take_damage(_damage:int) -> void:
	health -= _damage
	flash_white()
	if health <= 0:
		destroy()

func flash_white() -> void:
	sprite.modulate = Color(10,10,10,10)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1,1,1)

func destroy() -> void:
	queue_free()
