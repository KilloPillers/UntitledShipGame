class_name AudioManager
extends Node

var _current_song_id : int = 1 # Used for the game to keep track of the current song playing, 1-6
var _crossfader : AnimationPlayer
var _sfx_player : AudioStreamPlayer
var _engine_sfx_player : AudioStreamPlayer
var _shield_sfx_player : AudioStreamPlayer

var _shot_sound : AudioStream = preload("res://assets/Audio/shot.wav")
var _damaged_sound : AudioStream = preload("res://assets/Audio/damaged.wav")
var _engines_sound : AudioStream = preload("res://assets/Audio/engines.mp3")
var _shields_sound : AudioStream = preload("res://assets/Audio/shields.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_current_song_id = 1
	_crossfader = $Crossfader
	_crossfader.play("InitializeVolume")
	_sfx_player = $SFX
	_engine_sfx_player = $EngineSoundPlayer
	_shield_sfx_player = $ShieldSoundPlayer

# Public method for various other scripts to play sounds where needed.
# currently just for the ship. Enemy sounds ended being unpleasant with current spawnrates
# Call with one of the 6 key strings to command the sound players. The engines and shield sound
# effects are constant streams that ar eput on their own channel instead.
func play_sfx(sound_name : String) -> void:
	match sound_name:
		"shot":
			_sfx_player.stream = _shot_sound
			_sfx_player.pitch_scale = randf_range(0.8, 1.2)
			_sfx_player.play()
		"damaged":
			_sfx_player.stream = _damaged_sound
			_sfx_player.pitch_scale = randf_range(0.8, 1.2)
			_sfx_player.play()
		"engines_on":
			_engine_sfx_player.stream = _engines_sound
			_engine_sfx_player.play()
		"engines_off":
			_engine_sfx_player.stream = _engines_sound
			_engine_sfx_player.stop()
		"shields_on":
			_shield_sfx_player.stream = _shields_sound
			_shield_sfx_player.play()
		"shields_off":
			_shield_sfx_player.stream = _shields_sound
			_shield_sfx_player.stop()
		_:
			return

# The 5 functions below are signal receivers for the 5 music crossfade zones throughout the map
# If it isn't playing already, crossfade to the next song by activating an animation controlling
# the volume properties of the tracks in the animation player. All songs autoplay, but 5 are muted.
func _on_capsule_2_area_entered(area: Area2D) -> void:
	if (_current_song_id < 2):
		_current_song_id = 2
	else:
		return
	
	_crossfader.play("FadeToCapsule2")


func _on_capsule_3_area_entered(area: Area2D) -> void:
	if (_current_song_id < 3):
		_current_song_id = 3
	else:
		return
	
	_crossfader.play("FadeToCapsule3")


func _on_capsule_4_area_entered(area: Area2D) -> void:
	if (_current_song_id < 4):
		_current_song_id = 4
	else:
		return
	
	_crossfader.play("FadeToCapsule4")


func _on_capsule_5_area_entered(area: Area2D) -> void:
	if (_current_song_id < 5):
		_current_song_id = 5
	else:
		return
	
	_crossfader.play("FadeToCapsule5")


func _on_capsule_6_area_entered(area: Area2D) -> void:
	if (_current_song_id < 6):
		_current_song_id = 6
	else:
		return
	
	_crossfader.play("FadeToCapsule6")
