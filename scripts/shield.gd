class_name Shield
extends Node2D


const MAX_SHIELD_HEALTH:float = 25

@export var turn_speed: float = 5
@export var audio_manager: AudioManager

var shield_power_up: bool = false
var shield_down: bool = false
var playing_shield_sound: bool = false
var shield_health: float = MAX_SHIELD_HEALTH
var shield_recharge_rate: int = 2.5
var shield_recharge_delay: int = 2

var _shield_recharge_timer: Timer

@onready var animation: AnimationPlayer = $AnimationPlayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("shield_right"):
		rotation += turn_speed * delta
	if Input.is_action_pressed("shield_left"):
		rotation -= turn_speed * delta
	if Input.is_action_pressed("shield_power") and not shield_down:
		#animated_sprite_2d.play("on")
		if shield_power_up:
			animation.play("upgraded_shield")
		else:
			animation.play("on")
		if !playing_shield_sound && audio_manager:
			playing_shield_sound = true
			audio_manager.play_sfx("shields_on")
	else:
		if _shield_recharge_timer != null and _shield_recharge_timer.is_stopped():
			shield_health += shield_recharge_rate * delta
			if shield_health > MAX_SHIELD_HEALTH:
				shield_health = MAX_SHIELD_HEALTH
		animation.play("off")
		if playing_shield_sound && audio_manager:
			playing_shield_sound = false
			audio_manager.play_sfx("shields_off")
	if shield_down and shield_health == MAX_SHIELD_HEALTH:
		shield_down = false 


func take_damage(_damage: float) -> void:
	if not shield_down:
		shield_health -= _damage
		if shield_health <= 0:
			shield_health = 0
			shield_down = true
		_shield_recharge_timer = Timer.new()
		_shield_recharge_timer.one_shot = true
		add_child(_shield_recharge_timer)
		_shield_recharge_timer.start(shield_recharge_delay)
