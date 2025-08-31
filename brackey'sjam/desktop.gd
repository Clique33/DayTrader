extends Node2D

@export_range(10,1000,0.01) var initial_balance : float:
	set(value):
		if initial_balance == value:
			return
		initial_balance = value
		if not invest_app:
			return 
		invest_app.available_money = initial_balance
		if initial_balance > 100000:
			win()
@onready var invest_app: Chart = $Windows/InvestApp
@onready var work_app: WorkApp = $Windows/WorkApp
@onready var chat_app: ChatApp = $Windows/ChatApp
@onready var windows: Node = $Windows
@onready var clock: Label = $DesktopUI/Clock
@onready var clock_timer: Timer = $DesktopUI/ClockTimer
@onready var icons_container: VBoxContainer = $DesktopUI/IconsContainer
@onready var victory_timer: Timer = $VictoryTimer
@onready var victory_button: TextureButton = $DesktopUI/IconsContainer/VictoryButton
@onready var victory_label: Label = $DesktopUI/IconsContainer/VictoryLabel
@onready var defeat_timer: Timer = $DefeatTimer
@onready var initial_timer: Timer = $InitialTimer

var clock_ticks : int = 0
var _number_of_days : int = 1

func format_clock() -> void:
	var hours : int = clock_ticks/60
	var minutes : int = clock_ticks%60
	var hours_text  : String = "%d"
	var minutes_text  : String = "%d"
	if hours < 10: 
		hours_text  = "0%d";
	if minutes < 10: 
		minutes_text  = "0%d";
	clock.text = ("Day "+str(_number_of_days)+" "+hours_text+":"+minutes_text) % [hours,minutes]

func define_as_focused(current : Control):
	current.show()
	for window in windows.get_children():
		window.z_index = 2
	current.z_index = 3

func win():
	clock_timer.stop()
	for window in windows.get_children():
		window.hide()
	for item in icons_container.get_children():
		if item is TextureButton:
			item.disabled = true
	victory_timer.start()

func lose():
	clock_timer.stop()
	defeat_timer.start()
	print(defeat_timer.is_stopped()," ",defeat_timer.wait_time)
	$DefeatScreen.show()
	create_tween().tween_property(
						$DefeatScreen/CanvasModulate,
						"color", 
						Color.WHITE, 
						1.0
	)

func _ready() -> void:
	invest_app.available_money = initial_balance

func  _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		if $InitialScreen.visible:
			$DesktopUI.visible = true
			$InitialScreen/InitialLabel.visible = false
			create_tween().tween_property(
								$InitialScreen/CanvasModulate,
								"color", 
								Color.from_rgba8(0,0,0,0), 
								1.0
			)
			create_tween().tween_property(
								$InitialScreen,
								"visible", 
								false, 
								1.0
			)
			clock_timer.start()
		elif victory_button.visible:
			get_tree().reload_current_scene()

func _on_chart_button_pressed() -> void:
	define_as_focused(invest_app)

func _on_work_button_pressed() -> void:
	define_as_focused(work_app)

func _on_chat_button_pressed() -> void:
	define_as_focused(chat_app)


func _on_clock_timer_timeout() -> void:
	clock_ticks +=1
	if (clock_ticks == 24*60):
		clock_ticks = 0
		_number_of_days += 1
	if _number_of_days == 3:
		lose()
	format_clock()


func _on_work_app_reward(amount: float) -> void:
	initial_balance += amount


func _on_invest_app_money_moved(amount: float) -> void:
	initial_balance = amount


func _on_victory_timer_timeout() -> void:
	if victory_button.visible:
		return
	var cont : int = 0
	for item in icons_container.get_children():
		if cont > 1:
			break
		if item.visible:
			item.hide()
			cont+=1
	if cont != 0:
		victory_timer.start()
	else:
		victory_button.disabled = false
		victory_button.show()
		victory_label.show()


func _on_victory_button_pressed() -> void:
	$Victory/AnimationTree.play("new_animation")
	$Victory.play()

var first_time_on_defeat = true
var defeat_message = "You died due to too many days without sleep"
func _on_defeat_timer_timeout() -> void:
	if first_time_on_defeat:
		defeat_timer.wait_time = 0.05
		defeat_timer.start()
		first_time_on_defeat = false
		return
	if len($DefeatScreen/YouLoseLabel.text) < len(defeat_message):
		$DefeatScreen/YouLoseLabel.text += defeat_message[len($DefeatScreen/YouLoseLabel.text)]
	$DefeatScreen/YouLoseLabel.show()
	$DefeatScreen/YouLoseLabel.position = get_viewport_rect().size/2
	$DefeatScreen/YouLoseLabel.position.x -= $DefeatScreen/YouLoseLabel.size.x/2
	
var initial_message = """     I need $100,000.00...     
I will not sleep until I get it."""

func _on_initial_timer_timeout() -> void:
	if len($InitialScreen/InitialLabel.text) < len(initial_message):
		$InitialScreen/InitialLabel.text += initial_message[len($InitialScreen/InitialLabel.text)]
	$InitialScreen/InitialLabel.show()
	$InitialScreen/InitialLabel.position = get_viewport_rect().size/2
	$InitialScreen/InitialLabel.position.x -= $InitialScreen/InitialLabel.size.x/2
	
