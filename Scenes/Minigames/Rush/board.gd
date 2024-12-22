extends Node2D

# Dimensions of the board.
@export var width: int = 6
@export var height: int = 6

const TILE_SIZE = 64

# List of pieces on the board.
var pieces: Array = []

# Adds a piece to the board after checking if the position is valid.
func add_piece(piece: Piece) -> bool:
	if is_valid_position(piece):
		pieces.append(piece)
		add_child(piece)
		return true
	return false

# Checks if the position of the piece is valid (within bounds and no overlaps).
func is_valid_position(piece: Piece) -> bool:
	for pos in piece.get_occupied_positions():
		if pos.x < 0 or pos.x >= width or pos.y < 0 or pos.y >= height:
			return false
		for existing_piece in pieces:
			if pos in existing_piece.get_occupied_positions():
				return false
	return true

# Checks if the puzzle is completed by ensuring all pieces are in place.
func check_puzzle_completed() -> bool:
	for piece in pieces:
		# If any piece is not snapped to the grid, the puzzle is not completed.
		if piece.position != piece.pposition * TILE_SIZE:
			return false
	return true
