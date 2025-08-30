extends Control
class_name Chart

@export var margin : int = 10
@export var values_per_time : Array[float]
@export_range(0,1000000,0.01) var initial_value : float
@export_range(1,100000) var number_of_time_points : int:
	set(value):
		number_of_time_points = value
		_pixels_per_time_tick = size.x/float(number_of_time_points)
@export var available_money : float:
	set(value):
		available_money = value
		if not available_value_frame:
			return
		available_value_frame.get_child(0).text = "Available : $%.2f" % (available_money)

	

@onready var stock_line: Line2D = $StockLine
@onready var timer: Timer = $Timer
@onready var value_label: Label = $ValueLabel
@onready var value_axis: Line2D = $ValueAxis
@onready var time_axis: Line2D = $TimeAxis
@onready var background: ColorRect = $Background
@onready var borders: ColorRect = $Borders
@onready var close_button: TextureButton = $CloseButton
@onready var move_button: TextureButton = $MoveButton
@onready var buy_button: TextureButton = $BuyButton
@onready var sell_button: TextureButton = $SellButton
@onready var invested_value_frame: TextureRect = $InvestedValueFrame
@onready var available_value_frame: TextureRect = $AvailableValueFrame

enum {LOST = 0, WON = 1}

var _initial_x_offset : int
var _initial_y_offset : int
var _pixels_per_time_tick : float = 0
var _pixels_per_value_tick : float = 0:
	set(value):
		_pixels_per_value_tick = value
		if not stock_line:
			return
		scale_values_from_chart()
var _max_visible_value : float
var _is_moving : bool = false
var _window_moving_offset : Vector2
var _amount_invested : float = 0:
	set(value):
		_amount_invested = value
		if not invested_value_frame:
			return
		invested_value_frame.get_child(0).text = "Invested : $%.2f" % (_amount_invested*current_value)
var _counter_timeouts : int = 0

var current_value : float:
	set(value):
		current_value = value
		if current_value*1.1 >= _max_visible_value:
			_max_visible_value = current_value * 1.1
			_pixels_per_value_tick = -(size.y/(_max_visible_value))
			print(_max_visible_value," ",_pixels_per_value_tick)
		if not invested_value_frame:
			return
		invested_value_frame.get_child(0).text = "Invested : $%.2f" % (_amount_invested*current_value)


func scale_values_from_chart() -> void:
	var point : Vector2
	for i in stock_line.get_point_count():
		point = stock_line.get_point_position(i)
		point.y = _initial_y_offset  + _pixels_per_value_tick * values_per_time[i]
		stock_line.set_point_position(i, point)

func change_by_percentage(percentage : float ) -> void:
	if(len(values_per_time) == 0):
		values_per_time.append(initial_value)
		return
	percentage = percentage / 100
	values_per_time.append(values_per_time[-1]*(1+percentage))

func reset():
	initial_value = current_value
	_max_visible_value = current_value * 1.2
	_counter_timeouts = 0
	stock_line.clear_points()
	values_per_time.clear()
	_ready()

func _get_next_point() -> Vector2:
	current_value = values_per_time[stock_line.get_point_count()]
	var next_time = _initial_x_offset + _pixels_per_time_tick*stock_line.get_point_count()
	var next_value = _initial_y_offset  + _pixels_per_value_tick*current_value
	return Vector2(next_time,next_value)

func _set_value_label(next_point : Vector2) -> void:
	value_label.text = "$%.2f" % current_value
	value_label.position = next_point
	if next_point.x + value_label.size.x >= size.x-margin:
		value_label.position.x = size.x-margin-value_label.size.x
	if next_point.y + value_label.size.y >= size.y-margin:
		value_label.position.y = size.y-margin-value_label.size.y

func _position_borders() -> void:
	borders.size.x = size.x+2*margin
	borders.size.y = size.y+10*margin
	borders.position = Vector2(-margin,-4*margin) 

func _position_buttons() -> void:
	close_button.scale = Vector2.ONE * 3.5*margin/close_button.size.x
	close_button.position = Vector2(size.x - close_button.size.x -margin,-3.5*margin)

	move_button.position = Vector2(-margin,-4*margin)
	move_button.size = Vector2(borders.size.x-40,4*margin)
	
	buy_button.size = Vector2(size.x/5,margin)
	buy_button.position = Vector2(margin,size.y+margin)
	buy_button.get_child(0).size = buy_button.size 
	
	sell_button.size = buy_button.size
	sell_button.position = buy_button.position + Vector2(buy_button.size.x + margin,0)
	sell_button.get_child(0).size = sell_button.size 
	
	invested_value_frame.size = buy_button.size
	invested_value_frame.position = sell_button.position + Vector2(sell_button.size.x + margin,0) 
	invested_value_frame.get_child(0).size = invested_value_frame.size 
	invested_value_frame.get_child(0).text = "Invested : $%.2f" % (_amount_invested*current_value)

	available_value_frame.size = buy_button.size
	available_value_frame.position = invested_value_frame.position + Vector2(available_value_frame.size.x + margin,0) 
	available_value_frame.get_child(0).size = available_value_frame.size 
	available_value_frame.get_child(0).text = "Available : $%.2f" % (available_money)

func _input(event: InputEvent) -> void:
	if event.is_action("ui_accept"):
		reset()

func _ready() -> void:
	size = get_viewport_rect().size / 2
	_position_borders()
	_position_buttons()
	_max_visible_value = 1.2*initial_value
	_pixels_per_time_tick = size.x/float(number_of_time_points)
	_pixels_per_value_tick = -size.y/float(2*initial_value)
	
	_initial_x_offset = margin
	_initial_y_offset = size.y - margin
	current_value = initial_value
	
	background.size = size
	value_axis.add_point(Vector2(_initial_x_offset,_initial_y_offset))
	value_axis.add_point(Vector2(_initial_x_offset,0))
	time_axis.add_point(Vector2(_initial_x_offset,_initial_y_offset))
	time_axis.add_point(Vector2(size.x,_initial_y_offset))

func _physics_process(delta: float) -> void:	
	if _is_moving:
		position = get_viewport().get_mouse_position() - _window_moving_offset
	
	if stock_line.get_point_count() == len(values_per_time): 
		return
		
	var next_point : Vector2 = _get_next_point()
	stock_line.add_point(next_point)
	_set_value_label(next_point)

func _on_timer_timeout() -> void:
	if _counter_timeouts >= number_of_time_points:
		return
	
	_counter_timeouts+=1
	var modifier : int = 1
	if(randf() < .33):
		modifier = -1
	change_by_percentage(randi_range(20,50)*modifier)

func _on_close_button_pressed() -> void:
	hide()

func _on_move_button_button_down() -> void:
	_is_moving = true
	_window_moving_offset = get_viewport().get_mouse_position()-global_position

func _on_move_button_button_up() -> void:
	_is_moving = false

func _on_buy_button_pressed() -> void:
	if _counter_timeouts >= number_of_time_points:
		return
	_amount_invested += available_money / current_value
	available_money = 0

func _on_sell_button_pressed() -> void:
	if _counter_timeouts >= number_of_time_points:
		return
	available_money += _amount_invested * current_value
	_amount_invested = 0
