extends Control

@onready var video_player = $VideoStreamPlayer
@onready var play_button = $MarginContainer/VBoxContainer/Play
@onready var exit_button = $MarginContainer/VBoxContainer/Exit
@onready var title_text = $Label

func _process(delta: float) -> void:
	if video_player.is_playing() and Input.is_action_pressed("skip_cutscene"):
		get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
	#pass

func _on_play_pressed() -> void:
	play_button.hide()
	exit_button.hide()
	title_text.hide()
	video_player.show()
	video_player.stream = preload("res://assets/FinalProjectCutsceneReducedFlash.ogv")
	video_player.play()


func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
