extends Node2D

@onready var pause_menu = $PauseMenu/PauseMenu
@onready var boss_bar = $CanvasLayer2/BossHealth

func _ready() -> void:
    pause_menu.hide()

func _process(delta: float) -> void:
    if Input.is_action_just_pressed("pause_game"):
        toggle_pause()

func toggle_pause() -> void:
    get_tree().paused = not get_tree().paused    
    if get_tree().paused:
        pause_menu.show()
    else:
        pause_menu.hide()

func _on_pause_pressed() -> void:
    toggle_pause()

func _on_area_2d_body_entered(body: Node):
    if body.name == "ShipHull":
        print("In boss area")
        boss_bar.show()
