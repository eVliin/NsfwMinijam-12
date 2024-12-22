extends Node2D

# Define the class Piece for easy instantiation.
class_name Piece

# Enumeration for possible orientations of the piece.
enum Orientation { HORIZONTAL, VERTICAL }

# Exported variables to be editable in the editor.
@export var pposition: Vector2i = Vector2.ZERO  # Initial position of the piece.
@export var size: int = 1                       # Size of the piece.
@export var orientation: int = Orientation.HORIZONTAL  # Orientation of the piece, exported as an integer.

# Constant for tile size (can be adjusted).
const TILE_SIZE = 64  # Adjust the tile size to your needs.
var sprite: Sprite2D  # Reference to the sprite.

var dragging = false  # Flag to check if the piece is being dragged.
var drag_offset: Vector2 = Vector2.ZERO  # Offset to keep the piece under the cursor when dragging.

# Reference to the Rush scene to notify when the piece is dragged.
@onready var rush_scene = get_node("/root/Rush")  # Update this path if necessary.

# Initializes the piece with the given values.
func initialize(position: Vector2i, size: int, orientation: int):
	self.pposition = position
	self.size = size
	self.orientation = orientation

	# Adds a Sprite to represent the piece visually.
	sprite = Sprite2D.new()
	sprite.texture = preload("res://Assets/Sprites/Presents/presentblue.png")  # Your texture path
	add_child(sprite)

	# Adjusts the position of the Sprite.
	sprite.position = pposition * TILE_SIZE

# Returns the occupied positions by the piece on the board.
func get_occupied_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for i in range(size):
		if orientation == Orientation.HORIZONTAL:
			positions.append(pposition + Vector2i(i, 0))
		else:
			positions.append(pposition + Vector2i(0, i))
	return positions

# Handles input (mouse events) for dragging the piece.
func _unhandled_input(event: InputEvent):
	# Ensure the sprite is initialized.
	if sprite == null:  
		return
	
	# Check for mouse button press.
	if event is InputEventMouseButton:
		if event.is_action_pressed("Select"):
			# Start dragging when mouse clicks on the piece.
				if sprite.get_rect().has_point(get_local_mouse_position()):
					dragging = true
					drag_offset = sprite.position - event.position
		else:
				# Stop dragging when the mouse button is released.
				dragging = false
				snap_to_grid()  # Snap the piece back to the grid.

	if dragging:
		# While dragging, move the piece with the mouse.
		sprite.position = event.position + drag_offset
		rush_scene.on_piece_dragged()  # Notify Rush that a piece has been moved.

# Snaps the piece back to the nearest valid grid position.
func snap_to_grid():
	var snapped_position = Vector2(
		int(sprite.position.x / TILE_SIZE) * TILE_SIZE,
		int(sprite.position.y / TILE_SIZE) * TILE_SIZE
	)
	sprite.position = snapped_position
	pposition = Vector2(int(snapped_position.x / TILE_SIZE), int(snapped_position.y / TILE_SIZE))
