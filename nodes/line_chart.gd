extends Node2D
class_name Chart

@export var values_per_time : Array[float]
@export_range(0,1000000,0.01) var initial_value : float
@export_range(1,100000) var number_of_time_points : int:
	set(value):
		number_of_time_points = value
		if(get_viewport() == null): 
			return
		_pixels_per_time_tick = get_viewport_rect().size.x/float(number_of_time_points)

@onready var stock_line: Line2D = $StockLine
@onready var timer: Timer = $Timer
@onready var value_label: Label = $ValueLabel

enum {LOST = 0, WON = 1}

var _initial_x_offset : int
var _initial_y_offset : int
var _pixels_per_time_tick : int
var _pixels_per_value_tick : int
var _max_visible_value : float

var current_value : float:
	set(value):
		current_value = value
		if(get_viewport() == null): 
			return
		if current_value >= 2*initial_value:
			_pixels_per_value_tick = -(get_viewport_rect().size.y/_max_visible_value*2)
			_max_visible_value *= 2

func change_by_percentage(percentage : float ) -> void:
	if(len(values_per_time) == 0):
		values_per_time.append(initial_value)
		return
	percentage = percentage / 100
	values_per_time.append(values_per_time[-1]*(1+percentage))
	
func _get_next_point() -> Vector2:
	current_value = values_per_time[stock_line.get_point_count()]
	var next_time = _initial_x_offset + _pixels_per_time_tick*stock_line.get_point_count()
	var next_value = _initial_y_offset  + _pixels_per_value_tick*current_value
	return Vector2(next_time,next_value)

func _set_value_label(next_point : Vector2) -> void:
	value_label.text = "R$%.2f" % current_value
	value_label.position = Vector2(next_point)

func _ready() -> void:
	current_value = initial_value
	_max_visible_value = 2*initial_value
	if _pixels_per_time_tick == 0:
		_pixels_per_time_tick = get_viewport_rect().size.x/float(number_of_time_points)
	if _pixels_per_value_tick == 0:
		_pixels_per_value_tick = -get_viewport_rect().size.y/float(2*initial_value)
	_initial_x_offset = -get_viewport_rect().size.x/2
	_initial_y_offset = get_viewport_rect().size.y/2

func _physics_process(delta: float) -> void:
	if stock_line.get_point_count() == len(values_per_time): 
		return
	var next_point : Vector2 = _get_next_point()
	stock_line.add_point(next_point)
	_set_value_label(next_point)

func _on_timer_timeout() -> void:
	print(_pixels_per_time_tick," ",_pixels_per_value_tick)
	var modifier : int = 1
	if(randi_range(LOST,WON)):
		modifier = 1
	change_by_percentage(randi_range(20,51)*modifier)
