# TilesMinigameController.gd
# =============================================
# Controller for a sliding tile puzzle minigame in Godot 4.3.
#
# This script generates a shuffled, solvable 3x3 board and handles:
#   - Board generation and solvability checking
#   - Instancing and placement of tile nodes
#   - Input handling and swipe detection
#   - Tile movement and win condition checking
#
# =============================================

extends Node2D

# --- SIGNALS ---
signal close  # Emitted to signal the game should close

# --- CONSTANTS ---
const BOARD_SIZE: Vector2i = Vector2i(3, 3)   # 3 columns x 3 rows
const TILE_SIZE: int = 100                     # Pixel size of each tile
const MAX_SHUFFLE_ATTEMPTS: int = 1000         # Max attempts for a solvable board

# --- GLOBAL VARIABLES ---
# Each tile is a dictionary with:
#   "number": the tile number (0 represents the empty tile)
#   "grid_pos": current grid position (Vector2i)
#   "original_pos": solved grid position (Vector2i)
var tiles: Array = []
var empty_pos: Vector2i = Vector2i(BOARD_SIZE.x - 1, BOARD_SIZE.y - 1)  # Empty tile default

# Variables for swipe input handling
var initial_pos: Vector2 = Vector2.ZERO
var is_dragging: bool = false


# ======================================================
#              GAME INITIALIZATION (_ready)
# ======================================================
func _ready() -> void:
	tiles = generate_solvable_board()
	if tiles.is_empty():
		push_error("Failed to generate solvable board after %d attempts." % MAX_SHUFFLE_ATTEMPTS)
		return
	place_tiles()


# ======================================================
#              BOARD GENERATION FUNCTIONS
# ======================================================
func generate_solvable_board() -> Array:
	"""
	Attempts to generate and return a solvable board configuration as an array of tile data dictionaries.
	"""
	var attempt: int = 0
	var board_data: Array = []
	while attempt < MAX_SHUFFLE_ATTEMPTS:
		var nums: Array = []
		for i in range(1, BOARD_SIZE.x * BOARD_SIZE.y):
			nums.append(i)
		nums.shuffle()
		nums.append(0)  # Append empty tile

		board_data.clear()
		for index in range(nums.size()):
			var num: int = nums[index]
			var grid_pos: Vector2i = Vector2i(index % BOARD_SIZE.x, index / BOARD_SIZE.x)
			board_data.append(create_tile_data(num, grid_pos))
		empty_pos = Vector2i(BOARD_SIZE.x - 1, BOARD_SIZE.y - 1)
		
		if is_solvable(board_data):
			return board_data
		attempt += 1

	return []  # Return empty array if no solvable board found

func create_tile_data(number: int, grid_pos: Vector2i) -> Dictionary:
	"""
	Creates and returns a dictionary for a tile with its current and solved positions.
	"""
	return {
		"number": number,
		"grid_pos": grid_pos,
		"original_pos": get_solved_position(number)
	}

func get_solved_position(number: int) -> Vector2i:
	"""
	Returns the solved grid position for a given tile number.
	The empty tile (0) is always at the bottom-right.
	"""
	if number == 0:
		return Vector2i(BOARD_SIZE.x - 1, BOARD_SIZE.y - 1)
	var idx: int = number - 1
	return Vector2i(idx % BOARD_SIZE.x, idx / BOARD_SIZE.x)

func is_solvable(board_data: Array) -> bool:
	"""
	Determines if the given board configuration is solvable.
	Counts inversions for a flat list of non-empty tile numbers.
	"""
	var inversions: int = 0
	var flat_numbers: Array = []
	for y in range(BOARD_SIZE.y):
		for x in range(BOARD_SIZE.x):
			var num: int = get_tile_number_at(Vector2i(x, y), board_data)
			if num != 0:
				flat_numbers.append(num)
				
	for i in range(flat_numbers.size()):
		for j in range(i + 1, flat_numbers.size()):
			if flat_numbers[i] > flat_numbers[j]:
				inversions += 1
				
	return inversions % 2 == 0

func get_tile_number_at(pos: Vector2i, board_data: Array) -> int:
	"""
	Returns the tile number at the specified grid position by scanning the given board data.
	"""
	for tile in board_data:
		if tile.grid_pos == pos:
			return tile.number
	return -1


# ======================================================
#            TILE INSTANCING AND PLACEMENT
# ======================================================
func place_tiles() -> void:
	"""
	Instantiates tile scenes, positions them on screen, assigns textures,
	and adds them to the $pieces container.
	"""
	var tile_scene: PackedScene = preload("res://Scenes/Minigames/Tiles/tile.tscn")
	for tile_data in tiles:
		var tile_node: Node2D = tile_scene.instantiate()
		tile_node.position = grid_to_screen_pos(tile_data.grid_pos)
		tile_node.name = str(tile_data.number)
		tile_node.set_meta("grid_pos", tile_data.grid_pos)
		tile_node.set_meta("number", tile_data.number)
		tile_node.add_to_group("piece")
		
		if tile_data.number != 0:
			var texture_path: String = "res://Scenes/Minigames/Tiles/tile%d.png" % tile_data.number
			var texture: Texture2D = load(texture_path)
			if texture:
				tile_node.get_node("Sprite2D").texture = texture
		else:
			tile_node.visible = false
		
		$pieces.add_child(tile_node)

func grid_to_screen_pos(grid_pos: Vector2i) -> Vector2:
	"""
	Converts a grid coordinate to a screen coordinate by centering the tile in its cell.
	"""
	return Vector2(grid_pos) * TILE_SIZE + Vector2.ONE * (TILE_SIZE / 2)


# ======================================================
#            INPUT HANDLING AND SWIPE DETECTION
# ======================================================
func _input(event: InputEvent) -> void:
	"""
	Processes input events for swipe detection and game closure.
	"""
	if Input.is_action_just_pressed("Select"):
		start_drag(event.position)
	elif Input.is_action_just_released("Select"):
		end_drag(event.position)
	
	if Input.is_action_just_pressed("ui_cancel"):
		close_game()

func _on_bounds_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("Select"):
		close_game()


func start_drag(position: Vector2) -> void:
	"""
	Records the initial position when a drag (swipe) starts.
	"""
	initial_pos = position
	is_dragging = true

func end_drag(final_pos: Vector2) -> void:
	"""
	Ends the drag, computes the swipe vector, and processes the swipe.
	"""
	if not is_dragging:
		return
	is_dragging = false
	var swipe_vector: Vector2 = initial_pos - final_pos  # Reverse order used intentionally
	process_swipe(swipe_vector)

func process_swipe(swipe_vector: Vector2) -> void:
	"""
	Determines the dominant swipe direction and attempts to move a tile.
	"""
	if swipe_vector.length() < 20:
		return  # Ignore short swipes
	
	var direction: Vector2i = Vector2i.ZERO
	if abs(swipe_vector.x) > abs(swipe_vector.y):
		direction.x = 1 if swipe_vector.x > 0 else -1
	elif abs(swipe_vector.y) > abs(swipe_vector.x):
		direction.y = 1 if swipe_vector.y > 0 else -1
	
	if direction != Vector2i.ZERO:
		attempt_move(direction)


# ======================================================
#         GAME LOGIC: MOVING TILES & WIN CHECK
# ======================================================
func attempt_move(direction: Vector2i) -> void:
	"""
	Attempts to move a tile into the empty space based on the swipe direction.
	"""
	var target_pos: Vector2i = empty_pos + direction
	if is_valid_position(target_pos):
		swap_tiles(empty_pos, target_pos)
		check_win_condition()

func is_valid_position(pos: Vector2i) -> bool:
	"""
	Checks whether the given grid position is within board bounds.
	"""
	return Rect2i(Vector2i.ZERO, BOARD_SIZE).has_point(pos)

func swap_tiles(empty_spot: Vector2i, target_pos: Vector2i) -> void:
	"""
	Swaps the tile at target_pos with the empty space, updating both visual and internal states.
	"""
	var tile_node: Node2D = get_tile_node_at(target_pos)
	if tile_node:
		animate_tile_movement(tile_node, empty_spot)
		tile_node.set_meta("grid_pos", empty_spot)
		update_tile_in_array(tile_node.get_meta("number"), empty_spot)
		update_empty_tile_in_array(empty_spot, target_pos)
		empty_pos = target_pos

func get_tile_node_at(grid_pos: Vector2i) -> Node2D:
	"""
	Returns the tile node at a given grid position from the $pieces container.
	"""
	for child in $pieces.get_children():
		if child.is_in_group("piece") and child.get_meta("grid_pos") == grid_pos:
			return child
	return null

func update_tile_in_array(tile_number: int, new_pos: Vector2i) -> void:
	"""
	Updates the grid position of the tile with the specified number in the 'tiles' array.
	"""
	for tile in tiles:
		if tile.number == tile_number:
			tile.grid_pos = new_pos
			break

func update_empty_tile_in_array(empty_spot: Vector2i, target_pos: Vector2i) -> void:
	"""
	Updates the grid position of the empty tile (number 0) in the 'tiles' array.
	"""
	for tile in tiles:
		if tile.number == 0:
			tile.grid_pos = target_pos
			break

func animate_tile_movement(tile_node: Node2D, new_grid_pos: Vector2i) -> void:
	"""
	Animates the movement of a tile node to a new grid position using a Tween.
	"""
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(tile_node, "position", grid_to_screen_pos(new_grid_pos), 0.2)

func check_win_condition() -> void:
	"""
	Checks if all tiles are in their solved positions and closes the game if solved.
	"""
	for tile in tiles:
		if tile.grid_pos != tile.original_pos:
			return
	print("Puzzle Solved!")
	close_game()


# ======================================================
#                  GAME CLOSURE
# ======================================================
func close_game() -> void:
	"""
	Emits the 'close' signal for external game closure handling.
	"""
	emit_signal("close")
