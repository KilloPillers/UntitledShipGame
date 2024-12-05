extends Node2D

@export var speed : float = 20
@export var lifetime : float = 5

var time_left_ : float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	time_left_ = lifetime


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction_vector : Vector2 = Vector2(cos(rotation), sin(rotation))
	position += direction_vector * speed
	time_left_ -= delta
	if (time_left_ <= 0):
		queue_free()
	