extends Node2D

# Path to the database file
@export var database_path: String = "res://Scenes/Minigames/Rush/filtered_puzzles.txt"

# Grid and tile settings
@export var grid_dimensions: Vector2i = Vector2i(6, 6)  # Default grid size (6x6)
@export var cell_size: int = 50  # Size of each cell in pixels
@onready var grid_parent = $Pieces  # A Node2D to hold grid elements
@export var tile_scene: PackedScene  # Drag-and-drop tiles (e.g., a Sprite2D scene)

func _ready() -> void:
	# Load and parse the file
	var puzzles = load_puzzles(database_path)
	if puzzles.size() > 0:
		# Pick a random puzzle
		var random_puzzle = puzzles[randi() % puzzles.size()]
		initialize_grid(random_puzzle)
	else:
		print("No puzzles found in the file.")

# Function to load puzzles from the file
func load_puzzles(file_path: String) -> Array:
	var file = FileAccess.open(file_path, FileAccess.ModeFlags.READ)
	var puzzles = []
	
	if file:
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line != "" and line.left(1) != "#":  # Skip empty and comment lines
				var parts = line.split(" ")
				if parts.size() >= 2:
					puzzles.append(parts[1])  # Extract only the puzzle board
		file.close()
	else:
		push_error("Failed to open file: %s" % file_path)
	
	return puzzles

# Function to initialize the grid with the puzzle layout
func initialize_grid(puzzle: String) -> void:
	for y in range(grid_dimensions.y):
		for x in range(grid_dimensions.x):
			var index = y * grid_dimensions.x + x
			if index < puzzle.length():
				var cxhar = puzzle[index]
				if cxhar != "o":  # Skip empty cells
					var tile = tile_scene.instantiate()
					tile.position = Vector2(x * cell_size, y * cell_size)
					tile.name = "%d_%d" % [x, y]  # Name the tile based on grid coordinates
					
					# Determine rotation based on character (example logic below)
					tile.rotation = get_rotation_from_character(cxhar)

					grid_parent.add_child(tile)

# Function to determine rotation based on the puzzle character
func get_rotation_from_character(cxhar: String) -> float:
	# Example logic: Map characters to rotation angles (in radians)
	match cxhar:
		"H":  return 0    # No rotation
		"V":  return PI / 2  # 90 degrees
		"L":  return PI     # 180 degrees
		"D":  return -PI / 2  # -90 degrees (270 degrees)
		_ :   return 0    # Default to no rotation
