extends Node2D

@export var projectile : PackedScene
@export var cooldown_max : float = 0.5
@export var bullet_spread : float = 0.05
@export var turn_speed : float = 5
var cur_cooldown_ : float = 0
var rng_ : RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng_ = RandomNumberGenerator.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("gun_right"):
		rotation += turn_speed * delta
	if Input.is_action_pressed("gun_left"):
		rotation -= turn_speed * delta
	if Input.is_action_pressed("gun_power"):
		if (cur_cooldown_ <= 0):
			cur_cooldown_ = cooldown_max
			var new_projectile = projectile.instantiate()
			get_tree().root.add_child(new_projectile)
			new_projectile.rotation = rotation
			new_projectile.rotation += (rng_.randf_range(-bullet_spread, bullet_spread))
			new_projectile.global_position = $ProjectileOrigin.global_position 
			
	if (cur_cooldown_ > 0):
		cur_cooldown_ -= delta
