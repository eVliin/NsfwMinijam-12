# Rush Hour Puzzle Piece Controller
# Handles piece movement, collision detection, and win condition checking

extends Node2D

signal complete  # Emitted when the red piece reaches the exit

### Node References ###
@onready var rush: Node2D = get_parent().get_parent()  # Parent puzzle controller
@onready var ray_back = $Node2D/RayCastBack           # Rear collision detector
@onready var ray_front = $Node2D/RayCastFront         # Front collision detector

### Piece Configuration ###
enum PieceNames {TWO, THREE, FOUR}  # Unused - consider removing or implementing
var assets := []                    # Texture paths for different piece sizes
var size: int                       # Piece size in tiles (2-4)
var horizontal: bool                # Movement orientation
var sprite: Sprite2D                # Current visible sprite
var is_red: bool                    # Special flag for target vehicle
var sizpos: int                     # Pixel size based on piece length

### Movement Control ###
var mouse_pos: Vector2              # Mouse offset during drag
var draggable = false               # Drag state flag
var previous_position: Vector2      # Position before movement
var minb = Vector2(-150, -150)      # Movement bounds minimum
var minf = Vector2(200, 200)        # Movement bounds maximum
const BOARD_LIMIT = 300             # Board boundary constant

func _ready() -> void:
	"""Initialize piece visual and collision components"""
	# Load piece textures [red, size2, size3, size4]
	assets = [
		"res://Scenes/Minigames/Rush/rushRed.png",
		"res://Scenes/Minigames/Rush/rush1x2.png",
		"res://Scenes/Minigames/Rush/rush1x3.png",
		"res://Scenes/Minigames/Rush/rush1x4.png"
	]

	# Calculate piece dimensions
	sizpos = 50 * size
	var mul = size - 2  # Raycast position multiplier

	# Ajusta posição do raycast frontal baseado no tamanho
	$Node2D/RayCastFront.position.x += 50 * mul
	
	 # Configure orientation
	if horizontal:
		sprite = $h
		$v.hide()
	else:
		sprite = $v
		$h.hide()
		$Node2D.rotation_degrees = 90  # Rotate collision detectors
		$Node2D.position.x = 50        # Vertical position adjustment

	# Set appropriate texture
	sprite.texture = load(assets[0] if is_red else assets[size - 1])

	# Enable correct collision shape
	var area_node = $Node2D/Area2D.get_node(str(size))
	if area_node:
		area_node.disabled = false
	else:
		push_error("Missing collision area for size: " + str(size))

	# Connect input signals
	$Node2D/Area2D.input_event.connect(_on_area_2d_input_event)

func _process(delta: float) -> void:
	"""Handle piece dragging and movement constraints"""
	if draggable && Input.is_action_pressed("Select"):
		# Smooth position update with boundaries
		var new_position = get_global_mouse_position() - mouse_pos
		if horizontal:
			new_position.x = clamp(new_position.x, minb.x, minf.x)
			new_position.y = global_position.y  # Lock vertical position
		else:
			new_position.y = clamp(new_position.y, minb.y, minf.y)
			new_position.x = global_position.x  # Lock horizontal position
		
		global_position = new_position
		
	# Finalize movement on release
	elif draggable && Input.is_action_just_released("Select"):
		_finalize_move()


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	"""Handle drag start input"""
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and not Global.is_dragging:
			# Initiate drag operation
			draggable = true
			Global.is_dragging = true
			mouse_pos = get_global_mouse_position() - global_position
			previous_position = global_position
			_update_limits()
			scale = Vector2(1.05, 1.05)  # Visual feedback

func _finalize_move() -> void:
	"""Complete drag operation and snap to grid"""
	draggable = false
	Global.is_dragging = false
	scale = Vector2(1.0, 1.0)
	
	# Snap to grid system
	global_position = Vector2(
		snapped(global_position.x, rush.TILE_SIZE),
		snapped(global_position.y, rush.TILE_SIZE)
	)

func _check_collision() -> bool:
	"""Detect collisions with other pieces (currently unused)"""
	for area in $Node2D/Area2D.get_overlapping_areas():
		var other_piece = area.get_parent().get_parent()
		if other_piece != self:
			print("Collision with: ", other_piece.name)
			return true
	return false

func _update_limits() -> void:
	"""Update movement boundaries based on raycast collisions"""
	ray_back.force_raycast_update()
	ray_front.force_raycast_update()
	
	# Horizontal piece constraints
	if horizontal:
		minb.x = ray_back.get_collision_point().x if ray_back.is_colliding() else -150
		minf.x = (ray_front.get_collision_point().x - sizpos) if ray_front.is_colliding() else (BOARD_LIMIT - sizpos)
		minb.y = -150  # Reset vertical limits
		minf.y = BOARD_LIMIT
	# Vertical piece constraints
	else:
		minb.y = ray_back.get_collision_point().y if ray_back.is_colliding() else -150
		minf.y = (ray_front.get_collision_point().y - sizpos) if ray_front.is_colliding() else (BOARD_LIMIT - sizpos)
		minb.x = -150  # Reset horizontal limits
		minf.x = BOARD_LIMIT

func _on_area_2d_mouse_entered() -> void:
	"""Hover effect"""
	if not Global.is_dragging:
		scale = Vector2(1.05, 1.05)

func _on_area_2d_mouse_exited() -> void:
	"""Reset hover effect"""
	if not Global.is_dragging:
		scale = Vector2(1.0, 1.0)

func _on_vicheck_area_entered(area: Area2D) -> void:
	"""Win condition check for red piece"""
	if is_red:
		complete.emit()
		print("Puzzle Complete!")
