class_name Turret
extends CharacterBody2D

enum State {
	IDLE,
	TARGETING,
}

@export var projectile:PackedScene

const HEALTH:int = 20

var aggro_range:float = 500
var accuracy_angle:float = PI / 2
var damage:float = 2
var target_position:Vector2
var state:State
var target_direction:Vector2
var shooting_delay:float = 0.4
var bullet_spread:float = 0.2
var rng_ : RandomNumberGenerator
var _timer:Timer

@onready var animation_tree:AnimationTree = $AnimationTree


func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.start(shooting_delay)
	
	state = State.IDLE
	rng_ = RandomNumberGenerator.new()


func _physics_process(delta: float) -> void:
	target_position = %Player.global_position
	if global_position.distance_to(target_position) < aggro_range:
		state = State.TARGETING
		target_direction = (target_position - global_position).normalized()
		rotate(angle_difference(rotation, target_direction.angle()))
		if _timer != null and _timer.is_stopped():
			fire()
			
	else:
		state = State.IDLE
	
	_manage_animation_tree_state()


func fire() -> void:
	var new_projectile = projectile.instantiate()
	get_tree().root.add_child(new_projectile)
	var rng_factor = rng_.randf_range(-bullet_spread, bullet_spread)
	new_projectile.direction = target_direction + Vector2(rng_factor, rng_factor)
	new_projectile.rotate(new_projectile.direction.angle() + PI/2)
	new_projectile.global_position = $ProjectileOrigin.global_position 
	new_projectile.get_node("Hitbox").collision_mask = 5
	
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.start(shooting_delay)


func _manage_animation_tree_state() -> void:
	if state == State.TARGETING:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/firing"] = true
	else:
		animation_tree["parameters/conditions/firing"] = false
		animation_tree["parameters/conditions/idle"] = true


# Called by Hurtbox.gd
func _deal_damage() -> void:
	if %Player != null:
		%Player.take_damage(damage)


# Called by Hurtbox.gd
func destroy() -> void:
	queue_free()
