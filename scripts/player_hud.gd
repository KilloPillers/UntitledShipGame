class_name HealthBar
extends Control

@onready var progress_bar = $ProgressBar
@onready var boss_health: ProgressBar = $"../BossHealth"

@onready var boss_core: BOSS = $"../../BossCore"

var boss_hp = 30
var hp = 100
var is_paused = false  

func _ready() -> void:
    progress_bar.value = hp

func _process(delta: float) -> void:
    hp = %Ship/ShipHull.health
    progress_bar.value = hp
    boss_health.value = boss_core.health
