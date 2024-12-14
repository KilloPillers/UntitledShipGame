extends Node2D

@export var turn_speed : float = 5
@export var audio_manager : AudioManager

@onready var animation : AnimationPlayer = $AnimationPlayer

var shield_power_up : bool = false

var playing_shield_sound : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("shield_right"):
		rotation += turn_speed * delta
	if Input.is_action_pressed("shield_left"):
		rotation -= turn_speed * delta
	if Input.is_action_pressed("shield_power"):
		#animated_sprite_2d.play("on")
		if shield_power_up:
			animation.play("upgraded_shield")
		else:
			animation.play("on")
		if !playing_shield_sound && audio_manager:
			playing_shield_sound = true
			audio_manager.play_sfx("shields_on")
	else:
		animation.play("off")
		if playing_shield_sound && audio_manager:
			playing_shield_sound = false
			audio_manager.play_sfx("shields_off")
