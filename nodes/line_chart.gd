extends Node2D
class_name Chart

@export var values_per_time : Array[float]
@export var initial_value : float = 1.0

@onready var stock_line: Line2D = $StockLine
@onready var timer: Timer = $Timer
@onready var value_label: Label = $ValueLabel

enum {LOST = 0, WON = 1}

var _initial_x_offset : int
var _initial_y_offset : int
var _last_added_value : float
var _pixels_per_time_tick : int = 30
var _pixels_per_value_tick : int = -100

func change_by_percentage(percentage : float ) -> void:
	if(len(values_per_time) == 0):
		values_per_time.append(initial_value)
		return
	percentage = percentage / 100
	values_per_time.append(values_per_time[-1]*(1+percentage))
	
func _get_next_point() -> Vector2:
	_last_added_value = values_per_time[stock_line.get_point_count()]
	var next_time = _initial_x_offset + _pixels_per_time_tick*stock_line.get_point_count()
	var next_value = _initial_y_offset  + _pixels_per_value_tick*_last_added_value
	return Vector2(next_time,next_value)

func _set_value_label(next_point : Vector2) -> void:
	value_label.text = "R$%.2f" % _last_added_value
	value_label.position = Vector2(next_point)

func _ready() -> void:
	_initial_x_offset = -get_viewport_rect().size.x/2
	_initial_y_offset = 0

func _physics_process(delta: float) -> void:
	if stock_line.get_point_count() == len(values_per_time): 
		return
	var next_point : Vector2 = _get_next_point()
	stock_line.add_point(next_point)
	_set_value_label(next_point)

func _on_timer_timeout() -> void:
	var modifier : int = 1
	if(randi_range(LOST,WON)):
		modifier = -1
	change_by_percentage(randi_range(20,51)*modifier)
