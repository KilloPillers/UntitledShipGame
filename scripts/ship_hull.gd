class_name ShipHull
extends RigidBody2D

@export var fadeToBlack: Node
@export var health: int = 100
@export var audio_manager: AudioManager

@onready var animated_sprite_2d = $HullAnimatedSprite
@onready var camera = $Camera2D

func _ready() -> void:
	animated_sprite_2d.play("default")


func take_damage(_damage: int) -> void:
	if health <= 0:
		return
	health -= _damage
	flash_white()
	shake_camera(_damage) 
	
	if health <= 0:
		health = 0
		_start_death()
		
	if (audio_manager):
		audio_manager.play_sfx("damaged")
	
	print("ouch, ship took ", _damage, " damage. Ship now has ", health, " health remaining")

func flash_white() -> void:
	animated_sprite_2d.modulate = Color(1.5,1.5,1.5,1)
	await get_tree().create_timer(0.1).timeout
	animated_sprite_2d.modulate = Color(1,1,1)	

func _start_death() -> void:
	$Engine.set_process(false)
	$Shield.set_process(false)
	$Gun.set_process(false)
	$Engine.hide()
	$Shield.hide()
	$Gun.hide()
	set_deferred("freeze", true)
	animated_sprite_2d.play("death")


func _on_hull_animated_sprite_frame_changed() -> void:
	if animated_sprite_2d.animation == "death" and animated_sprite_2d.frame == animated_sprite_2d.sprite_frames.get_frame_count("death") - 1:
		await get_tree().create_timer(1.0).timeout
		_fade_to_black_and_return_to_menu()


func _fade_to_black_and_return_to_menu() -> void:
	var current_alpha: float = 0.0
	var timer = get_tree().create_timer(0.1)
	while current_alpha < 1.0:
		current_alpha += 0.05
		fadeToBlack.color.a = current_alpha
		await timer.timeout
		timer = get_tree().create_timer(0.1)
	fadeToBlack.color.a = 1.0
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func shake_camera(damage: int):
	var original_position = camera.position
	#shake sensitivity 
	var shake_factor: int = 5 
	var intensity: int = damage * shake_factor
	var offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
	camera.position += offset
	await get_tree().create_timer(0.05).timeout
	camera.position = original_position
