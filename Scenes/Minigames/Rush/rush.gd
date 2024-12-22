extends Node

# Constant for tile size (same as defined in Piece).
const TILE_SIZE = 64

# Reference to the board node.
@onready var board = $Board

# Variable to track if the user has moved any piece.
var puzzle_started = false

func _ready() -> void:
	generate_pieces()

# Function to generate the pieces.
func generate_pieces():
	# Add the primary piece.
	var primary_piece = Piece.new()
	primary_piece.initialize(Vector2i(0, board.height / 2), 2, Piece.Orientation.HORIZONTAL)
	if board.add_piece(primary_piece):
		instantiate_piece(primary_piece)

	# Add other pieces randomly.
	var attempts = 0
	while board.pieces.size() < 11 and attempts < 50:
		attempts += 1
		var size = randi() % 2 + 2
		var orientation = Piece.Orientation.HORIZONTAL if randi() % 2 == 0 else Piece.Orientation.VERTICAL
		var position = Vector2i(randi() % board.width, randi() % board.height)
		
		var new_piece = Piece.new()
		new_piece.initialize(position, size, orientation)

		# Add the piece if the position is valid.
		if board.add_piece(new_piece):
			instantiate_piece(new_piece)

# Function to instantiate the piece in the scene.
func instantiate_piece(piece: Piece):
	var piece_instance = piece.duplicate()
	piece_instance.position = piece.pposition * TILE_SIZE
	board.add_child(piece_instance)

# Checks if the puzzle is completed and prints the result.
func _process(delta):
	# Only start checking for completion after user moves the pieces.
	if puzzle_started and board.check_puzzle_completed():
		print("Puzzle Completed!")

# Function to mark when the user starts interacting with pieces.
func on_piece_dragged():
	# The puzzle has started when a piece is moved.
	puzzle_started = true
