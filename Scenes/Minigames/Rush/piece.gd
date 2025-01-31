extends Node2D

signal complete

# Referências aos nós principais e raycasts
@onready var rush: Node2D = get_parent().get_parent()  # Assume que o nó principal do jogo está dois níveis acima
@onready var ray_back = $Node2D/RayCastBack
@onready var ray_front = $Node2D/RayCastFront

# Enum para nomes de peças (não utilizado no momento)
enum PieceNames {TWO, THREE, FOUR}

# Configurações da peça
var assets := []  # Array para carregar texturas
var size: int     # Tamanho da peça em blocos (2, 3 ou 4)
var horizontal: bool  # Orientação da peça
var sprite: Sprite2D  # Referência ao sprite atual
var is_red: bool      # Indica se é a peça vermelha especial

# Variáveis de controle
var mouse_pos: Vector2
var draggable = false
var previous_position: Vector2
var sizpos: int  # Tamanho da peça em pixels

# Limites de movimento
var minb = Vector2(-150, -150)  # Limite mínimo (esquerda/baixo)
var minf = Vector2(200, 200)    # Limite máximo (direita/cima)
const BOARD_LIMIT = 300         # Limite do tabuleiro

func _ready() -> void:
	# Carrega texturas
	assets = [
		"res://Scenes/Minigames/Rush/rushRed.png",   # 0 - Vermelha
		"res://Scenes/Minigames/Rush/rush1x2.png",   # 1 - Tamanho 2
		"res://Scenes/Minigames/Rush/rush1x3.png",   # 2 - Tamanho 3
		"res://Scenes/Minigames/Rush/rush1x4.png"    # 3 - Tamanho 4
	]

	# Configuração inicial
	sizpos = 50 * size
	var mul = size - 2  # Fator de ajuste para raycasts
	
	# Ajusta posição do raycast frontal baseado no tamanho
	$Node2D/RayCastFront.position.x += 50 * mul
	
	# Configura orientação
	if horizontal:
		sprite = $h
		$v.hide()
	else:
		sprite = $v
		$h.hide()
		$Node2D.rotation_degrees = 90   # Rotaciona raycasts para vertical
		$Node2D.position.x = 50         # Ajuste de posição para vertical

	# Carrega textura apropriada
	sprite.texture = load(assets[0] if is_red else assets[size - 1])
	
	# Habilita colisão correta
	var area_node = $Node2D/Area2D.get_node(str(size))
	if area_node:
		area_node.disabled = false
	else:
		push_error("Area2D não encontrada para tamanho: " + str(size))

	# Conecta sinais
	$Node2D/Area2D.input_event.connect(_on_area_2d_input_event)

func _process(delta: float) -> void:
	if draggable && Input.is_action_pressed("Select"):
		# Movimentação suave com limites
		var new_position = get_global_mouse_position() - mouse_pos
		if horizontal:
			new_position.x = clamp(new_position.x, minb.x, minf.x)
			new_position.y = global_position.y  # Mantém posição Y
		else:
			new_position.y = clamp(new_position.y, minb.y, minf.y)
			new_position.x = global_position.x  # Mantém posição X
		
		global_position = new_position
		
	# Ao soltar peça
	elif draggable && Input.is_action_just_released("Select"):
		_finalize_move()

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and not Global.is_dragging:
			# Inicia arrasto
			draggable = true
			Global.is_dragging = true
			mouse_pos = get_global_mouse_position() - global_position
			previous_position = global_position
			_update_limits()
			scale = Vector2(1.05, 1.05)

func _finalize_move() -> void:
	draggable = false
	Global.is_dragging = false
	scale = Vector2(1.0, 1.0)
	
	# Snap para grade
	global_position = Vector2(
		snapped(global_position.x, rush.TILE_SIZE),
		snapped(global_position.y, rush.TILE_SIZE)
	)

func _check_collision() -> bool:
	# Verifica colisões com outras peças
	for area in $Node2D/Area2D.get_overlapping_areas():
		var other_piece = area.get_parent().get_parent()
		if other_piece != self:
			print("Colisão com: ", other_piece.name)
			return true
	return false

func _update_limits() -> void:
	# Atualiza limites de movimento baseado em raycasts
	ray_back.force_raycast_update()
	ray_front.force_raycast_update()
	
	if horizontal:
		# Limites horizontais
		minb.x = ray_back.get_collision_point().x if ray_back.is_colliding() else -150
		minf.x = (ray_front.get_collision_point().x - sizpos) if ray_front.is_colliding() else (BOARD_LIMIT - sizpos)
		minb.y = -150  # Reseta limites verticais
		minf.y = BOARD_LIMIT
	else:
		# Limites verticais
		minb.y = ray_back.get_collision_point().y if ray_back.is_colliding() else -150
		minf.y = (ray_front.get_collision_point().y - sizpos) if ray_front.is_colliding() else (BOARD_LIMIT - sizpos)
		minb.x = -150  # Reseta limites horizontais
		minf.x = BOARD_LIMIT

func _on_area_2d_mouse_entered() -> void:
	if not Global.is_dragging:
		scale = Vector2(1.05, 1.05)

func _on_area_2d_mouse_exited() -> void:
	if not Global.is_dragging:
		scale = Vector2(1.0, 1.0)

func _on_vicheck_area_entered(area: Area2D) -> void:
	if is_red:
		complete.emit()
		print("Ganhou Porra")
