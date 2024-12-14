class_name Turret
extends CharacterBody2D

enum State {
	IDLE,
	CHARGING_UP,
	FIRING,
}

@export var health: int = 5
@export var damage: float = 1
@export var aggro_range: float = 500 
@export var shooting_delay: float = 0.4 #TODO adjust this for game feel. If this is adjusted then the shooting animation needs to be adjusted
@export var bullet_spread: float = 0.2
@export var projectile: PackedScene

var state: State
var target_position: Vector2
var target_direction: Vector2
var rng_: RandomNumberGenerator
var max_light_level: float
var charging_up_duration: float = 1.5
var _charing_up_timer: Timer
var _shooting_timer: Timer

@onready var light: Light2D = $Light
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite: Sprite2D = $Base


func _ready() -> void:
	_shooting_timer = Timer.new()
	_shooting_timer.one_shot = true
	add_child(_shooting_timer)
	_shooting_timer.start(shooting_delay)
	max_light_level = light.energy
	light.energy = 0 
	state = State.IDLE
	rng_ = RandomNumberGenerator.new()


func _physics_process(_delta: float) -> void:
	$TurretHealth.value = health
	if %Ship != null:
		target_position = %Ship/ShipHull.global_position
	else:
		print("error, Turret enemy doesn't have ship targeted")
		target_position = global_position
	
	if global_position.distance_to(target_position) > aggro_range:
		state = State.IDLE
		if light.energy > 0:
			light.energy -= _delta
		elif light.energy < 0:
			light.energy = 0
	
	# IDLE logic
	elif state == State.IDLE:
		state = State.CHARGING_UP
		_charing_up_timer = Timer.new()
		_charing_up_timer.one_shot = true
		add_child(_charing_up_timer)
		_charing_up_timer.start(charging_up_duration)
		
	# CHARGING_UP logic
	elif state == State.CHARGING_UP:
		if light.energy < max_light_level:
			light.energy += _delta
		elif light.energy > max_light_level:
			light.energy = max_light_level
		target_direction = (target_position - global_position).normalized()
		rotate(angle_difference(rotation, target_direction.angle()))
		if _charing_up_timer.is_stopped():
			state = State.FIRING
	
	# FIRING logic
	elif state == State.FIRING:
		target_direction = (target_position - global_position).normalized()
		rotate(angle_difference(rotation, target_direction.angle()))
		if _shooting_timer.is_stopped():
			fire()
	_manage_animation_tree_state()


func fire() -> void:
	var new_projectile = projectile.instantiate()
	get_tree().root.add_child(new_projectile)
	var rng_factor = rng_.randf_range(-bullet_spread, bullet_spread)
	new_projectile.rotation = rotation + rng_factor
	new_projectile.global_position = $ProjectileOrigin.global_position 
	
	_shooting_timer = Timer.new()
	_shooting_timer.one_shot = true
	add_child(_shooting_timer)
	_shooting_timer.start(shooting_delay)


func _manage_animation_tree_state() -> void:
	if state == State.FIRING:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/firing"] = true
	else:
		animation_tree["parameters/conditions/firing"] = false
		animation_tree["parameters/conditions/idle"] = true


# Called by Hurtbox.gd
func _deal_damage() -> void:
	if %Ship != null:
		%Ship/ShipHull.take_damage(damage)


func take_damage(_damage: int) -> void:
	health -= _damage
	flash_white()
	if health <= 0:
		destroy()


func flash_white() -> void:
	sprite.modulate = Color(10,10,10,10)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1,1,1)


# Called by Hurtbox.gd
func destroy() -> void:
	queue_free()
