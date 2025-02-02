# Rush Hour minigame controller
extends Node2D

## Emitted when the minigame should be closed
signal close

## Path to the puzzle database file
@export var database_path: String = "res://Scenes/Minigames/Rush/filtered_puzzles.txt"

## Constants for board configuration
const BOARD_SIZE = Vector2i(6, 6)   # Standard Rush Hour board size
const TILE_SIZE = 50                # Visual size of each grid cell in pixels

var pieces = []  # Stores detected piece configurations from current puzzle

func load_board_from_string(board_desc: String) -> Array:
	"""
	Converts a puzzle string into a board matrix and detects pieces
	@param board_desc: String representation of the board (36 characters)
	@return: 2D array representing the board state
	"""
	var board_matrix = []    # 6x6 board representation
	var piece_positions = {} # Stores positions of each piece character
	
	# Parse the board description string
	for y in range(BOARD_SIZE.y):
		var row = []
		for x in range(BOARD_SIZE.x):
			var index = y * BOARD_SIZE.x + x
			var char = board_desc[index]
			row.append(char)
			
			# Track non-empty spaces (o = empty, x = obstruction)
			if char != 'o' and char != 'x':
				if not piece_positions.has(char):
					piece_positions[char] = []
				piece_positions[char].append(Vector2i(x, y))
		board_matrix.append(row)
	
	detect_pieces(piece_positions)
	return board_matrix

func detect_pieces(piece_positions: Dictionary) -> void:
	"""
	Analyzes piece positions to determine their properties
	@param piece_positions: Dictionary of character positions from puzzle string
	"""
	for key in piece_positions.keys():
		var positions = piece_positions[key]
		var size = positions.size()
		
		# Determine orientation based on second position
		var horizontal = size > 1 and positions[1].x - positions[0].x == 1
		
		# Special handling for red piece (target vehicle)
		var is_red = (key == 'A')  # 'A' is reserved for red target vehicle
		
		pieces.append({
			"tipo": key,            # Piece identifier
			"posicao": positions[0],# Top-left position (Vector2i)
			"tamanho": size,        # Number of occupied cells (2 or 3)
			"horizontal": horizontal,# Movement axis orientation
			"is_red": is_red        # Special flag for target vehicle
		})

func place_pieces() -> void:
	"""Instantiates and positions piece scenes based on detected configuration"""
	for piece in pieces:
		var piece_instance = preload("res://Scenes/Minigames/Rush/piece.tscn").instantiate()
		# Set piece properties from puzzle data
		piece_instance.position = piece["posicao"] * TILE_SIZE
		piece_instance.size = piece["tamanho"]
		piece_instance.horizontal = piece["horizontal"]
		piece_instance.is_red = piece["is_red"]
		$pieces.add_child(piece_instance)

func load_puzzles(file_path: String) -> Array:
	"""
	Loads puzzle database from text file
	@return: Array of puzzle strings in format "XXXXX...XX" (36 characters)
	"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	var puzzles = []
	
	if file:
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			# Skip empty lines and comments
			if line != "" and not line.begins_with("#"):
				var parts = line.split(" ")
				if parts.size() >= 2:
					puzzles.append(parts[1])  # Extract puzzle string
		file.close()
	else:
		push_error("Failed to open puzzle database: %s" % file_path)
	
	return puzzles

func _ready() -> void:
	"""Initializes the minigame with a random puzzle"""
	var puzzles = load_puzzles(database_path)
	
	if puzzles.is_empty():
		push_error("No puzzles found in database!")
		return
	
	# Select random puzzle and initialize board
	var random_puzzle = puzzles.pick_random()
	load_board_from_string(random_puzzle)
	place_pieces()

func _input(event: InputEvent) -> void:
	"""Handles game closure input"""
	if Input.is_action_just_pressed("Close"):
		close.emit()
		SignalBus.minigame_hide.emit()

func _on_bounds_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	"""Handles click events on game bounds (close interaction)"""
	if Input.is_action_just_pressed("Select"):
		close.emit()
