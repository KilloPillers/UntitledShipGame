extends CanvasModulate

# variables that controls the light to dark transition. Smaller means longer transition
@export var light_gradient : float = 0.1

@onready var ship: Node2D = %Ship
@onready var ship_hull: ShipHull = $"../Ship/ShipHull"

var depth : float

var ship_origin

func _ready() -> void:
	ship_origin = ship_hull.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var curr_pos = ship_hull.global_position
	depth = ship_origin.y - curr_pos.y 
	if depth < 0:
		_adjust_brightness(color)

func _adjust_brightness(curr_color : Color) -> void:
	# modulates the brightness of the environment the deeper the ship is.
	var brightness_factor = clampf(1.0 - depth * light_gradient, 0.0, 1.0)
	
	# compute the new color
	color = Color(curr_color.r * brightness_factor,  curr_color.g * brightness_factor, curr_color.b * brightness_factor, curr_color.a)
	
