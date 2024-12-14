extends Node2D

var num := 100
var margin := 100
var screensize: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screensize = get_viewport_rect().size
	randomize()


func spawnBoid() -> void:
	var boid: Area2D = preload("res://scenes/boid.tscn").instantiate()
	$boidFolder.add_child(boid)
	boid.modulate = Color(randf(), randf(), randf())
	boid.global_position = Vector2((randi_range(0+margin,screensize.x-margin)), 
								   (randi_range(0+margin,screensize.y-margin)))
	print(boid.global_position)
