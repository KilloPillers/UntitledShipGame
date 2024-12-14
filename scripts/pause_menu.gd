extends Control


@onready var pause_menu = $"../PauseMenu"  


func _ready() -> void:
	pause_menu.hide()  


func resume():
	print("Resuming game...")
	get_tree().paused = false


#delete after done testing 
func _on_delete_later_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/healthbar.tscn")
#------------------------
#back to menu
func _on_quit_pressed() -> void:
	print("Quit button pressed")
	get_tree().paused = false  
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_resume_pressed() -> void:
	print("Resume button pressed")
	pause_menu.hide() 
	resume()
