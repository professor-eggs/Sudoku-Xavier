extends Label

var pos = Vector2()
var value = 0
var neighbors = []
var blank_cell = false
var active = false
var debugging = false

onready var input_area = $LineEdit


class SudokuTileSorter:
	static func sort(a,b):
		return ( a.pos.x < b.pos.x ) or ( ( a.pos.x == b.pos.x ) and ( a.pos.y < b.pos.y ) )


func add_neighbor(neighbor):
	if not ( neighbors.has(neighbor) or neighbor == self ):
		neighbors.append(neighbor)


func sort_neighbors():
	neighbors.sort_custom(SudokuTileSorter, "sort")


func highlight(state):
	$ColorRect.visible = state


func _on_SudokuCell_mouse_entered():
	for n in neighbors:
		n.highlight(true)


func _on_SudokuCell_mouse_exited():
	for n in neighbors:
		n.highlight(false)


func set_value(value):
	self.value = value
	text = str(value)


func remove_value():
	self.value = null
	text = "x"


func make_invisible():
	text = ""
	blank_cell = true


func _process(delta):
	active = input_area.has_focus()
	if blank_cell:
		if active:
			text = input_area.text
		
		if debugging:
			if int (text) == value:
				modulate = Color (0.4,1,0.4,1)
			else:
				modulate = Color(1,0.4,0.4,1)


func _on_LineEdit_focus_exited():
	commit_text()
	input_area.clear()


func commit_text():
	debugging = true