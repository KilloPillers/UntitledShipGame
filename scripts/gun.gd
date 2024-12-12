extends Node2D

@export var projectile : PackedScene
@export var num_projectiles : int = 1
@export var cooldown_max : float = 0.40
@export var bullet_spread : float = 0.1
@export var turn_speed_max : float = 5.0
@export var turn_speed_ramp_time : float = 0.5 # Time to reach max turn speed
var cur_cooldown_ : float = 0.0
var damage_buff : int = 0
var pierce_buff : int = 0
var rng_ : RandomNumberGenerator
var turn_speed_current : float = 0 # Current rotation speed
var turn_speed_accumulated_time : float = 0 # Accumulated time for ramping up

@onready var animated_sprite_2d = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng_ = RandomNumberGenerator.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var is_turning = false
	
	if Input.is_action_pressed("gun_right"):
		is_turning = true
		turn_speed_accumulated_time += delta
		turn_speed_current = lerp(0.0, turn_speed_max, min(turn_speed_accumulated_time / turn_speed_ramp_time, 1.0))
		rotation += turn_speed_current * delta
	elif Input.is_action_pressed("gun_left"):
		is_turning = true
		turn_speed_accumulated_time += delta
		turn_speed_current = lerp(0.0, turn_speed_max, min(turn_speed_accumulated_time / turn_speed_ramp_time, 1.0))
		rotation -= turn_speed_current * delta
	
	if not is_turning:
		# Reset ramp-up when no turning input is active
		turn_speed_accumulated_time = 0
		turn_speed_current = 0
	
	if Input.is_action_pressed("gun_power"):
		if (cur_cooldown_ <= 0):
			cur_cooldown_ = cooldown_max

			for i in range(num_projectiles):
				var new_projectile = projectile.instantiate()
				new_projectile.damage += damage_buff
				new_projectile.pierce += pierce_buff
				get_tree().root.add_child(new_projectile)

				# Calculate spread angle
				var spread_angle = bullet_spread * 2  # Total angle of spread
				var angle_step = spread_angle / max(1, num_projectiles - 1)  # Avoid division by zero

				# Set the rotation for the projectile
				if num_projectiles > 1:
					new_projectile.rotation = rotation - bullet_spread + (i * angle_step)
				else:
					new_projectile.rotation = rotation
				new_projectile.global_position = $ProjectileOrigin.global_position

				animated_sprite_2d.play("shoot")
			
	elif not animated_sprite_2d.is_playing():
		animated_sprite_2d.play("off")
		
	if (cur_cooldown_ > 0):
		cur_cooldown_ -= delta
