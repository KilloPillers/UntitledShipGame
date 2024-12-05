extends Control

@onready var progress_bar = $ProgressBar
@onready var pause_menu = $PauseMenu  

var hp = 100
var is_paused = false  

func _ready() -> void:
	progress_bar.value = hp

func _on_subtract_pressed() -> void:
	if hp > 0:
		hp -= 5
		progress_bar.value = hp
		print("Health: ", hp)
	else:
		print("dead")

func _on_add_pressed() -> void:
	if hp < 100:
		hp += 5
		progress_bar.value = hp
		print("Health: ", hp)
	else:
		print("Max")

func _on_pause_pressed() -> void:
	is_paused = true
	if is_paused:
		get_tree().paused = true
		pause_menu.show()
	else:
		get_tree().paused = false