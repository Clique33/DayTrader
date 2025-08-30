extends Node2D
@onready var line_chart: Chart = $LineChart


func _on_chart_button_pressed() -> void:
	line_chart.show()
