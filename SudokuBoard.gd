extends GridContainer

signal cell_value_set

var base # A base of 3 will create a 9x9 grid, a base of 4 creates a 16x16 grid
var size # Length and width of the grid

var SudokuCell = preload("res://SudokuCell.tscn")
var cells = [] # Holds a list of all the cells in the grid
var all_options = [] # Holds the valid input choices for the player (1-9 in a typical sudoku game)

var next_button # Reference to the next button for debugging

var difficulty = 0.5 # Indicates approximately how many tiles are removed, higher number removes more tiles

func start():
	# Called by the parent to start the game
	
	# Keep the randomisation constant for testing
	var my_seed = "Godot Rocks"
	seed(my_seed.hash())
	# Optionally create the seed randomly
#	randomize()
	
	# Initialise length and width (size)
	size = base * base
	
	# Set the number of columns in the SudokuBoard GridContainer
	columns = base * base
	
	# Initialise the choices of input available to the plater (1-9 in a typical game)
	for i in size:
		all_options.append(i + 1)
	
	initialise_cells()
	generate_all_neighbors()
	
	# Fill the cells recursively
	if (fill_cells(cells.duplicate())):
		# If filled successfully, randomly make some cells invisible which then allows player input
		for cell in cells:
			if randf() < difficulty:
				cell.make_invisible()
	else:
		# If somehow the cells could not be filled, print error message
		# Need to handle this failure case better
		print("failure")


func initialise_cells():
	# Fill the cells[] array with blank SudokuCell objects
	# The array will have 81 items in a 9x9 game
	for i in ( size * size ):
		# Initialise cell on the GUI
		var cell = SudokuCell.instance()
		
		# Tell the cell its coordinate position
		cell.pos = index_to_coord(i)
		
		# Add the cell to the SudokuBoard GridContainer
		add_child(cell)
	
	# Assigns the cells[] array with all the children of the SudokuBoard GridContainer
	# This could have been done in the for loop above with "cells.append(cell)"
	cells = get_children().duplicate()


func index_to_coord(index):
	# Returns a Vector2 representation of a given index of the cells[] array
	return ( Vector2 ( int ( index % size ), int ( index / size ) ) )


func coord_to_index(coord):
	# Returns the index of a cell in the cells[] array corresponding to the given Vector2
	return ( coord.y * size + coord.x )


func get_cell_by_index(index):
	# Returns the cell at a given index
	return cells[index]


func get_cell_by_coord(coord):
	# Returns the cell at a given coordinate
	return get_cell_by_index(coord_to_index(coord))


func generate_all_neighbors():
	# Fill out and sort the neighbors[] array for each cell in the list
	# The neighbors[] array contains a list of all cells that need to be checked for duplicate numbers
	for cell in cells:
		for n in size:
			# Add all cells that share the same row, and all cells that share the same column
			cell.add_neighbor(cells[coord_to_index(Vector2(cell.pos.x, n))])
			cell.add_neighbor(cells[coord_to_index(Vector2(n, cell.pos.y))])
		
		# These variables contain the starting point of the square a given cell lives in
		# So for cells (0,0) (0,1) (0,2) (1,0) (1,1) (1,2) (2,0) (2,1) (2,2); the values below will all be (0,0)
		
		var rect_starting_i = ( int ( cell.pos.x / base ) ) * base
		var rect_starting_j = ( int ( cell.pos.y / base ) ) * base
		
		# Include the cells in the box in the cell's neighbors[] array
		# In a 9x9 game, we add 3 to the square's starting points and iterate over them
		for n in range ( rect_starting_i, rect_starting_i + base ):
			for m in range ( rect_starting_j, rect_starting_j + base):
				cell.add_neighbor(cells[coord_to_index(Vector2(n,m))])
		
		# Sort the neighbors[] array according to the custom sort function defined
		# I am not convinced that this is actually necessary, but it was in the medium.com article so I included it
		cell.sort_neighbors()


func fill_cells(remaining_cells):
	#yield(next_button, "pressed") # Doesn't work as intended
	# Recursive function to fill all cells with valid values
	
	# Pop the current_cell from the front of the stack to facilitate recursion
	var current_cell = remaining_cells.pop_front()
	
	# The neighbor_values[] array is a list of the values of each neighbor
	var neighbor_values = []
	for n in current_cell.neighbors:
		neighbor_values.append(n.value)
	
	# The options[] array is a list of valid values for the cell based on the values of each neighbor
	var options = []
	for i in size:
		if not neighbor_values.has(i+1):
			options.append(i + 1)
	
	# Randomise the list of available options
	options = shuffle_array(options)
	
	# Set the value of the current cell to the first of the options
	for value in options:
		current_cell.set_value(value)
		
		# Success case means that all the cells have been filled!
		if remaining_cells.empty():
			return true
		
		# Recursive call to try filling the next cell
		if fill_cells(remaining_cells):
			return true
	
	# If all the options fail, then we have to backtrack
	current_cell.remove_value()
	remaining_cells.push_front(current_cell)
	
	# We return false to cause the for loop on the previous cell to try the next value in the options[] array
	return false


func shuffle_array(arr, shuffled_array = []):
	# Takes an array as input and returns a randomised copy of the array
	# I don't think I had to do recursion here but it was practice for the fill_cells() function
	
	# Success case if the input array is empty, return the shuffled_array[]
	if arr.empty():
		return shuffled_array
	# If there are still items left to be randomised...
	else:
		# Append a random value from the input array to the shuffled_array[]
		var rand_index = randi() % arr.size()
		shuffled_array.push_back(arr[rand_index])
		arr.remove(rand_index)
		# Recursive call
		return shuffle_array(arr, shuffled_array)