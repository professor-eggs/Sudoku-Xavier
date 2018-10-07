extends Node

export(int) var base = 3

var size

var bg_colors = [Color(0.0,0.0,0.0,1.0), Color(0.0,0.0,1.0,0.5)]

onready var bg_container = $Board/HBoxContainer/Container/BackgroundContainer
onready var game = $Board/HBoxContainer/Container/SudokuBoard
onready var next_button = $Board/HBoxContainer/VBoxContainer/Next
onready var start_button = $Board/HBoxContainer/VBoxContainer/Start


func _ready():
	game.base = base
	game.next_button = next_button
	bg_container.columns = base
	create_grid_background()
	

func _on_Start_pressed():
	start_button.disabled = true
	game.start()


func create_grid_background():
	for i in (base * base):
		var bg = ColorRect.new()
		bg.color = bg_colors[i % bg_colors.size()]
		bg.size_flags_horizontal = bg.SIZE_EXPAND_FILL
		bg.size_flags_vertical = bg.SIZE_EXPAND_FILL
		bg_container.add_child(bg)
