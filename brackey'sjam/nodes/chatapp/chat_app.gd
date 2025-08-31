extends Control
class_name ChatApp

signal moved

@onready var background: ColorRect = $Window/Background
@onready var borders: ColorRect = $Window/Borders
@onready var close_button: TextureButton = $Window/CloseButton
@onready var move_button: TextureButton = $Window/MoveButton
@onready var contacts_container: ScrollContainer = $Content/ContactsContainer
@onready var chat_container: ScrollContainer = $Content/ChatContainer

var margin : int = 10
var _initial_x_offset : int
var _initial_y_offset : int
var _is_moving : bool = false
var _window_moving_offset : Vector2

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


func _ready() -> void:
	size = get_viewport_rect().size / 2
	_initial_x_offset = margin
	_initial_y_offset = size.y - margin
	
	_create_window()
	contacts_container.size = Vector2(12*margin,background.size.y-margin)
	contacts_container.position = Vector2(margin,margin)
	
	chat_container.size = Vector2(background.size.x-contacts_container.size.x-2*margin,background.size.y-margin)
	chat_container.position = Vector2(contacts_container.size.x+2*margin,margin)
	
func _physics_process(delta: float) -> void:	
	if _is_moving:
		position = get_viewport().get_mouse_position() - _window_moving_offset

func _on_close_button_pressed() -> void:
	hide()

func _on_move_button_button_down() -> void:
	_is_moving = true
	emit_signal("moved")
	_window_moving_offset = get_viewport().get_mouse_position()-global_position

func _on_move_button_button_up() -> void:
	_is_moving = false
