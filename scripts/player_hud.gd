class_name HealthBar
extends Control

@onready var progress_bar = $ProgressBar
@onready var shield_progress_bar = $ShieldProgressBar
@onready var boss_health_bar: ProgressBar = $"../BossHealth"
@onready var boss_core: Boss = $"../../BossCore"
@onready var ship_hull: ShipHull = %Ship/ShipHull
@onready var ship_shield: Shield = %Ship/ShipHull/Shield


func _ready() -> void:
	progress_bar.max_value = ship_hull.health
	progress_bar.value = ship_hull.health
	shield_progress_bar.max_value = ship_shield.shield_health
	shield_progress_bar.value = ship_shield.shield_health
	boss_health_bar.max_value = boss_core.health
	boss_health_bar.value = boss_core.health


func _process(delta: float) -> void:
	progress_bar.value = ship_hull.health
	shield_progress_bar.value = ship_shield.shield_health
	boss_health_bar.value = boss_core.health
