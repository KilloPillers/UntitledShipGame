extends Node2D


@onready var pause_menu = $PauseMenu/PauseMenu
@onready var boss_bar = $CanvasLayer2/BossHealth
var is_paused = false  



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pause_pressed() -> void:
	is_paused = true
	if is_paused:
		get_tree().paused = true
		pause_menu.show()
	else:
		get_tree().paused = false

func _on_area_2d_body_entered(body: Node):
	if body.name == "ShipHull":
		print("In boss area")
		boss_bar.show()
