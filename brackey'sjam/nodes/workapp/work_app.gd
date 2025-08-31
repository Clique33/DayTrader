extends Control
class_name WorkApp

signal moved
signal reward(amount : float)

@onready var background: ColorRect = $Window/Background
@onready var borders: ColorRect = $Window/Borders
@onready var close_button: TextureButton = $Window/CloseButton
@onready var move_button: TextureButton = $Window/MoveButton
@onready var tab_container: TabContainer = $Content/TabContainer
@onready var easy_button: Button = $Content/TabContainer/Job/EasyButton
@onready var easy_progress_bar: ProgressBar = $Content/TabContainer/Job/EasyProgressBar
@onready var easy_timer: Timer = $Content/EasyTimer
@onready var reward_label: Label = $Content/RewardLabel
@onready var job: VBoxContainer = $Content/TabContainer/Job


var margin : int = 10
var _initial_x_offset : int
var _initial_y_offset : int
var _is_moving : bool = false
var _is_easy_job_in_progress : bool = false
var _is_rewarding : bool = false
var _window_moving_offset : Vector2
var _initial_time : int

func _create_window() -> void:
	background.size = size
	borders.size.x = size.x+2*margin
	borders.size.y = size.y+10*margin
	borders.position = Vector2(-margin,-4*margin) 
	_position_buttons()

func _position_buttons() -> void:
	close_button.scale = Vector2.ONE * 3.5*margin/close_button.size.x
	close_button.position = Vector2(size.x - close_button.size.x -margin,-3.5*margin)

	move_button.position = Vector2(-margin,-4*margin)
	move_button.size = Vector2(borders.size.x-40,4*margin)

func _create_content() -> void:
	tab_container.size = background.size
	#easy_jobs.size = tab_container.size
	reward_label.position = background.size/2
	
func _ready() -> void:
	size = get_viewport_rect().size / 2
	_create_window()
	_create_content()
	
	_initial_x_offset = margin
	_initial_y_offset = size.y - margin
	
func _physics_process(delta: float) -> void:	
	if _is_moving:
		position = get_viewport().get_mouse_position() - _window_moving_offset
	if _is_easy_job_in_progress:
		easy_progress_bar.value += easy_progress_bar.step
	if _is_rewarding:
		reward_label.position.y -= 1
	
func _on_close_button_pressed() -> void:
	hide()

func _on_move_button_button_down() -> void:
	_is_moving = true
	emit_signal("moved")
	_window_moving_offset = get_viewport().get_mouse_position()-global_position

func _on_move_button_button_up() -> void:
	_is_moving = false

func _on_easy_button_pressed() -> void:
	easy_button.disabled = true
	_is_easy_job_in_progress = true
	easy_progress_bar.value = easy_progress_bar.min_value
	easy_progress_bar.show()
	easy_timer.wait_time = 1
	easy_timer.start()
	_initial_time = Time.get_ticks_msec()

func _on_easy_timer_timeout() -> void:
	if abs(easy_progress_bar.value - easy_progress_bar.max_value) < 0.1:
		var reward : float = 50*(Time.get_ticks_msec()-_initial_time)/1000
		emit_signal("reward",reward)
		reward_label.text = "$%.2f" % reward
		reward_label.show()
		reward_label.get_child(0).start()
		_is_rewarding = true
		easy_button.disabled = false
		easy_progress_bar.value = easy_progress_bar.min_value
		easy_progress_bar.hide()
		_is_easy_job_in_progress = false
	else:
		easy_timer.start()


func _on_reward_timer_timeout() -> void:
	_is_rewarding = false
	reward_label.hide()
	reward_label.position = background.size/2
