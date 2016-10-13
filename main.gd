extends Control

# Grid Properties
export (int) var columns = 5
export (int) var rows = 5

# Display for Demonstration
export (int, "Only Tiles", "Only Dots", "Both") var display = 0 setget set_display
export (bool) var draw_grid = true
var show_tiles = true
var show_dots = false

# Constants
const screen_width = 640
const screen_height = 640

# Grid Map
var grid_map = []

# Generate a grid containing coordinates
func generate_grid_map():
	# We are adding +1 since the grid_map are the "dots" that decide whether or not it is filled
	for x in range(0, columns+1):
		# Creating a multi dimentional array
		grid_map.append([])
		for y in range(0, rows+1):
			# Randomize on/off state
			randomize() 
			var rand_int = int(rand_range(0, 2))
			
			# Store value in grid_map
			grid_map[x].append(rand_int)


# Draws marching square tiles
func draw_tiles():
	for x in range(0, columns):
		for y in range(0, rows):
			# Get on/off value from each surrounding point
			var dot_1 = grid_map[x][y]  	# Top left
			var dot_2 = grid_map[x+1][y] 	# Top right
			var dot_3 = grid_map[x+1][y+1] 	# Bottom right
			var dot_4 = grid_map[x][y+1] 	# Bottom left
			
			# Calculate the tile value
			var tile_value = dot_1 + (dot_2 * 2) + (dot_3 * 4) + (dot_4 * 8)

			# Create tile
			get_node("tile_map").set_cell(x,y,tile_value)


# Draws dots that indicate whether or not an area is filled 
func draw_dots():
	var dot_container = Node2D.new()
	dot_container.set_name("dot_container")
	add_child(dot_container)
	
	var dot_black = ImageTexture.new()
	dot_black.load("res://images/dot_black.png")
	
	var dot_white = ImageTexture.new()
	dot_white.load("res://images/dot_white.png")
	
	for x in range(0, columns+1):
		for y in range(0, rows+1):
			var sprite = Sprite.new()
			if(grid_map[x][y] == 1):
				sprite.set_texture(dot_black)
			else:
				sprite.set_texture(dot_white)
			sprite.set_pos(Vector2(x*32, y*32))
			
			dot_container.add_child(sprite)


# Start
func _ready():
	update_screen()


# Updates screen according to number of columns and rows
func update_screen():
	# Setup screen size
	OS.set_window_size(Vector2(screen_width, screen_height))
	get_viewport().set_size_override(true, Vector2(columns*32, rows*32))
	
	# Generate grid map
	generate_grid_map()
	
	# Draw tiles
	if(show_tiles):
		draw_tiles()
	
	# Draw dots
	if(show_dots):
		draw_dots()


# Updates values according to display choices
func set_display(value):
	# Only Tiles
	if(value == 0): 
		show_dots = false
		show_tiles = true
	# Only Dots
	elif(value == 1): 
		show_tiles = false
		show_dots = true
	# Both
	else: 
		show_tiles = true
		show_dots = true


# Draws background line grid
func _draw():
	if(draw_grid):
		var color = Color(0,0,0)
		var thickness = 1
		for x in range(0, columns+1):
			for y in range(0, rows+1):
				draw_line(Vector2(x*32,y*32), Vector2((x+1)*32,y*32), color, thickness)
				draw_line(Vector2((x+1)*32,y*32), Vector2((x+1)*32,(y+1)*32), color, thickness)
				draw_line(Vector2(x*32,y*32), Vector2(x*32,(y+1)*32), color, thickness)
				draw_line(Vector2(x*32,(y+1)*32), Vector2((x+1)*32,(y+1)*32), color, thickness)