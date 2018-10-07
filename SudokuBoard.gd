extends GridContainer

signal cell_value_set

var size
var base

var SudokuCell = preload("res://SudokuCell.tscn")
var cells = []
var all_options = []

var next_button
var difficulty = 0.5

func start():
	var my_seed = "Godot Rocks"
	seed(my_seed.hash())
	
	size = base * base
	columns = base * base
	
	for i in size:
		all_options.append(i + 1)
	
	initialise_cells()
	generate_all_neighbors()
	
	if (fill_cells(cells.duplicate())):
		for cell in cells:
			if randf() > difficulty:
				cell.make_invisible()
	else:
		print("failure")


func initialise_cells():
	for i in ( size * size ):
		# Initialise cell on the GUI
		var cell = SudokuCell.instance()
		cell.text = "-"
		cell.size_flags_horizontal = cell.SIZE_EXPAND_FILL
		cell.size_flags_vertical = cell.SIZE_EXPAND_FILL
		cell.align = cell.ALIGN_CENTER
		cell.valign = cell.VALIGN_CENTER
		
		# Initialise cell info
		cell.pos = index_to_coord(i)
		add_child(cell)
	
	cells = get_children().duplicate()


func index_to_coord(index):
	# Returns a Vector2 representation of a given index
		return ( Vector2 ( int ( index % size ), int ( index / size ) ) )


func coord_to_index(coord):
	# Returns the index of a cell corresponding to the given Vector2
	return ( coord.y * size + coord.x )


func get_cell_by_coord(coord):
	# Returns the cell at a given coordinate
	return get_cell_by_index(coord_to_index(coord))


func get_cell_by_index(index):
	# Returns the cell at a given index
	return cells[index]


func generate_all_neighbors():
	# Fill out and sort the neighbor array for each cell in the list
	for cell in cells:
		for n in size:
			cell.add_neighbor(cells[coord_to_index(Vector2(cell.pos.x, n))])
			cell.add_neighbor(cells[coord_to_index(Vector2(n, cell.pos.y))])
		
		var rect_starting_i =  ( int ( cell.pos.x / base ) ) * base
		var rect_starting_j =  ( int ( cell.pos.y / base ) ) * base
		
		for n in range ( rect_starting_i, rect_starting_i + base ):
			for m in range ( rect_starting_j, rect_starting_j + base):
				cell.add_neighbor(cells[coord_to_index(Vector2(n,m))])
		
		cell.sort_neighbors()


func fill_cells(remaining_cells):
	
	
	var current_cell = remaining_cells.pop_front()
	
	var neighbor_values = []
	for n in current_cell.neighbors:
		neighbor_values.append(n.value)
	
	
	var options = []
	for i in size:
		if not neighbor_values.has(i+1):
			options.append(i + 1)
	
	
	options = shuffle_array(options)
	
	for value in options:
		current_cell.set_value(value)
		
		if remaining_cells.empty():
			return true
		
		if fill_cells(remaining_cells):
			return true
	
	current_cell.remove_value()
	remaining_cells.push_front(current_cell)
	return false


func shuffle_array(arr, shuffled_array = []):
	if arr.empty():
		return shuffled_array
	else:
		var rand_index = randi() % arr.size()
		shuffled_array.push_back(arr[rand_index])
		arr.remove(rand_index)
		return shuffle_array(arr, shuffled_array)