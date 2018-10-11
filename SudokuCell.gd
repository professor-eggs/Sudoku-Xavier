extends Label

var pos = Vector2()
var value = 0
var neighbors = [] # A list containing all the cells that should be checked for duplicate numbers
var blank_cell = false
var active = false
var debugging = false

onready var input_area = $LineEdit


class SudokuTileSorter:
	static func sort(a,b):
		return ( a.pos.x < b.pos.x ) or ( ( a.pos.x == b.pos.x ) and ( a.pos.y < b.pos.y ) )


func _ready():
	# Dictate in code how a cell will be displayed by default
	# These could and probably should be set in the inspector
	text = "-"
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	align = ALIGN_CENTER
	valign = VALIGN_CENTER


func add_neighbor(neighbor):
	# Add a neighbor cell which should not share a value with the current cell
	# Only append the neighbor to the array if it does not exist already
	if not ( neighbors.has(neighbor) or neighbor == self ):
		neighbors.append(neighbor)


func sort_neighbors():
	# Sort neighbors based on the algorightm in the medium.com article
	# Not convinced it is actually needed but whatever lol
	neighbors.sort_custom(SudokuTileSorter, "sort")


func highlight(state):
	# Shows the ColorRect when hovering over a neighbor
	$ColorRect.visible = state


func _on_SudokuCell_mouse_entered():
	# Highlights neighbors on hover
	for n in neighbors:
		n.highlight(true)


func _on_SudokuCell_mouse_exited():
	# Disables highlight
	for n in neighbors:
		n.highlight(false)


func set_value(value):
	# Assigns value of the cell
	self.value = value
	text = str(value)


func remove_value():
	# Removes the value
	self.value = null
	text = "x"


func make_invisible():
	# Removes the text being displayed and marks it as a cell that has been blanked for user input
	text = ""
	blank_cell = true


func _process(delta):
	# input_area is actually a LineEdit node with 0 alpha to be fully transparent
	# If the cell is marked for user input, we accept the input from the LineEdit and display it in the Label
	# I did this because LineEdit didn't seem to have a vertical center feature
	active = input_area.has_focus()
	if blank_cell:
		if active:
			text = input_area.text
		
		# If we are debugging, mark correct answers in green and incorrect answers in red
		# Consider also marking the neighbor with the duplicated value
		if debugging:
			if int (text) == value:
				modulate = Color (0.4,1,0.4,1)
			else:
				modulate = Color(1,0.4,0.4,1)


func _on_LineEdit_focus_exited():
	# If the user clicks off the input_area LineEdit, commit the text (not really functional at the moment)
	# then clear the input_area
	commit_text()
	input_area.clear()


func commit_text():
	# This is called when the user clicks off a cell they have edited. It's not very functional at the moment
	debugging = true


func display_value():
	if blank_cell:
		text = ""
	else:
		text = str(value)


func show_text(txt):
	text = txt