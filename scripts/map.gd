extends Node2D


#Pause Testing---------------------
@onready var pause_menu = $PauseMenu/PauseMenu        

var is_paused = false  
#----------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#pause-----------------
func _on_pause_pressed() -> void:
	is_paused = true
	if is_paused:
		get_tree().paused = true
		pause_menu.show()
	else:
		get_tree().paused = false
#----------------------
