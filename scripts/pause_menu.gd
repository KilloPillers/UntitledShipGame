extends Control
#ICON https://www.flaticon.com/free-icon/pause-button_3240602?term=pause&page=1&position=14&origin=search&related_id=3240602

@onready var pause_menu = $"../PauseMenu"  

func _ready() -> void:
	pause_menu.hide()  


func resume():
	print("Resuming game...")
	get_tree().paused = false


#back to menu
func _on_quit_pressed() -> void:
	print("Quit button pressed")
	get_tree().paused = false  
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_resume_pressed() -> void:
	print("Resume button pressed")
	pause_menu.hide() 
	resume()
