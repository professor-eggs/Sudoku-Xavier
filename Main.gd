extends Node

# A base of 3 will create a 9x9 grid, a base of 4 creates a 16x16 grid
export(int) var base = 3

# Background colors for the cell squares
export(Color) var BG_Color_1 = Color(0.0,0.0,0.0,1.0)
export(Color) var BG_Color_2 = Color(0.0,0.0,1.0,0.5)
var bg_colors = [BG_Color_1, BG_Color_2]

onready var bg_container = $Board/HBoxContainer/Container/BackgroundContainer
onready var game = $Board/HBoxContainer/Container/SudokuBoard
onready var next_button = $Board/HBoxContainer/VBoxContainer/Next
onready var start_button = $Board/HBoxContainer/VBoxContainer/Start


func _ready():
	game.base = base
	
	# Next button for stepping through game code when enabled
	# Used by doing yield(next_button, "pressed")
	game.next_button = next_button
	
	# Assigns the number of columns in the GridContainer to be the specified base (3 in a typical game)
	bg_container.columns = base
	
	# Color the background using BG_Color_1 BG_Color_2
	create_grid_background()
	

func _on_Start_pressed():
	start_button.disabled = true
	game.start()


func create_grid_background():
	for i in base:
		for j in base:
			var bg = ColorRect.new()
			bg.color = bg_colors[(i+j) % bg_colors.size()]
			bg.size_flags_horizontal = bg.SIZE_EXPAND_FILL
			bg.size_flags_vertical = bg.SIZE_EXPAND_FILL
			bg_container.add_child(bg)
