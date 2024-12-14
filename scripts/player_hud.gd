class_name HealthBar
extends Control

@onready var progress_bar = $ProgressBar
@onready var boss_health: ProgressBar = $"../BossHealth"

@onready var boss_core: Boss = $"../../BossCore"


var boss_hp: int = 30
var hp: int = 100
var is_paused = false  


func _ready() -> void:
	progress_bar.value = hp
	boss_hp = boss_core.health
	#boss_health.max_value = boss_hp


func _process(delta: float) -> void:
	hp = %Ship/ShipHull.health
	progress_bar.value = hp
	boss_health.value = boss_core.health
	#print(boss_core.health)
