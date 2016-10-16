extends Control

# Grid Properties
export (int) var columns = 5
export (int) var rows = 5

# Generation Properties
export (int) var fill_percent = 50
export (bool) var enable_wall = true
export (int) var softness_value = 5

# Display for Demonstration
export (int, "Only Tiles", "Only Dots", "Both", "None") var display = 0 setget set_display
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
			var point_value = null
			
			# If we are enabling walls, we make sure the edges of our map are solid
			if(enable_wall):
				if(x == 0 || x == columns || y == 0 || y == rows):
					point_value = 1
			
			# If we have not set any point value, we generate it
			if(point_value == null):
				randomize() 
				var rand_value = rand_range(0, 100)
				point_value = 1 if (rand_value < fill_percent) else 0
			
			# Store value in grid_map
			grid_map[x].append(point_value)


func soften_grid_map():
	for x in range(0, columns):
		for y in range(0, rows):
			var surrounding = get_surrounding_solid_tile_value(x,y)
			if(surrounding < 4):
				grid_map[x][y] = 0
			elif(surrounding > 4):
				grid_map[x][y] = 1


func get_surrounding_solid_tile_value(x, y):
	var solid_count = 0
	# Check a 3x3 area around the x,y coordinate given inside grid map
	for tile_x in range(x-1, x+2):
		for tile_y in range(y-1, y+2):
			# Prevent out of bound errors
			if(tile_x >= 0 && tile_x < columns && tile_y <= rows && tile_y > 0):
				# Prevent adding our own x & y value
				if(tile_x != x || tile_y != y): 
					solid_count += grid_map[tile_x][tile_y] # Append values
			else:
				solid_count += 1
	return solid_count
	


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
	# Update screen
	update_screen()
	
	# Generate
	_on_btn_generate_pressed()


# Updates screen according to number of columns and rows
func update_screen():
	# Automatically adjust camera to the number of columns and rows
	get_node("camera").set_zoom(Vector2(columns/20,rows/20))
	
	# Update UI
	var fill_percent_node = get_node("canvas_layer/control/panel_container/hbox/fill_percent_container/fill_percent_text_edit")
	fill_percent_node.set_text(str(fill_percent))
	
	var softness_node = get_node("canvas_layer/control/panel_container/hbox/softness_container1/softness_edit_text")
	softness_node.set_text(str(softness_value))
	
	var walls_node = get_node("canvas_layer/control/panel_container/hbox/walls_container/walls_check_button")
	walls_node.set_pressed(enable_wall)

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
	elif(value == 2): 
		show_tiles = true
		show_dots = true
	else:
		show_tiles = false
		show_dots = false


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

func _on_btn_generate_pressed():
	get_node("tile_map").clear()
	grid_map = []
	# Generate grid map
	generate_grid_map()
	
	# Soften our grid map to make it more cave'y
	for i in range(softness_value):
		soften_grid_map()
	
	# Draw tiles
	if(show_tiles):
		draw_tiles()
	
	# Draw dots
	if(show_dots):
		draw_dots()

# Update fill percent after changing it
func _on_fill_percent_text_edit_focus_exit():
	var fill_percent_node = get_node("canvas_layer/control/panel_container/hbox/fill_percent_container/fill_percent_text_edit")
	var fill_percent_text = fill_percent_node.get_text()
	if(int(fill_percent_text) > 100):
		fill_percent = 100
		fill_percent_node.set_text("100")
	elif(int(fill_percent_text) < 0):
		fill_percent = 0
		fill_percent_node.set_text("0")
	elif(fill_percent_text != ""):
			fill_percent = int(fill_percent_text)
		


func _on_softness_edit_text_focus_exit():
	var softness_node = get_node("canvas_layer/control/panel_container/hbox/softness_container1/softness_edit_text")
	var softness_text = softness_node.get_text()
	
	if(typeof(int(softness_text)) == 2):
		if(int(softness_text) < 6 && int(softness_text) >= 0):
			softness_value = int(softness_text)
		else:
			softness_node.set_text(str(softness_value))


func _on_walls_check_button_toggled( pressed ):
	enable_wall = pressed
	pass # replace with function body
