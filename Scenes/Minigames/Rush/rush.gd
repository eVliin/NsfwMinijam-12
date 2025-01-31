extends Node2D

signal close

# Path to the database file
@export var database_path: String = "res://Scenes/Minigames/Rush/filtered_puzzles.txt"

const BOARD_SIZE = Vector2i(6, 6)  # Dimensão fixa do tabuleiro 6x6
const TILE_SIZE = 50  # Tamanho de cada tile em pixels

var pieces = []  # Lista para armazenar as peças detectadas

func load_board_from_string(board_desc: String):
	"""
	Converte a string do tabuleiro em uma matriz e detecta as peças
	"""
	var board_matrix = []  # Matriz 6x6 para armazenar o estado do tabuleiro
	var piece_positions = {}  # Dicionário para armazenar posições de peças
	
	# Converter a string em uma matriz 6x6
	for y in range(BOARD_SIZE.y):
		var row = []
		for x in range(BOARD_SIZE.x):
			var index = y * BOARD_SIZE.x + x
			var char = board_desc[index]
			row.append(char)
			
			# Armazena posições das peças
			if char != 'o' and char != 'x':
				if not piece_positions.has(char):
					piece_positions[char] = []
				piece_positions[char].append(Vector2i(x, y))
		board_matrix.append(row)
	
	detect_pieces(piece_positions)
	return board_matrix

func detect_pieces(piece_positions: Dictionary):
	"""
	Analisa as peças detectadas e define suas propriedades
	"""
	for key in piece_positions.keys():
		var positions = piece_positions[key]
		var size = positions.size()
		
		# Determina se a peça é horizontal ou vertical
		var horizontal = size > 1 and positions[1].x - positions[0].x == 1
		
		# Verifica se a peça é vermelha (tipo 'A')
		var is_red = (key == 'A')
		
		var piece_data = {
			"tipo": key,
			"posicao": positions[0],  # Posição inicial
			"tamanho": size,
			"horizontal": horizontal,
			"is_red": is_red  # Define a propriedade is_red
		}
		pieces.append(piece_data)

func place_pieces():
	"""
	Cria as instâncias das peças e as adiciona ao tabuleiro
	"""
	for piece in pieces:
		var piece_instance = preload("res://Scenes/Minigames/Rush/piece.tscn").instantiate()
		piece_instance.position = piece["posicao"] * TILE_SIZE
		piece_instance.size = piece["tamanho"]
		piece_instance.horizontal = piece["horizontal"]
		piece_instance.is_red = piece["is_red"]  # Passa a propriedade is_red
		$pieces.add_child(piece_instance)

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

func _ready():
	"""
	Executado ao iniciar a cena
	"""
	
	var random_puzzle
	
	# Load and parse the file
	var puzzles = load_puzzles(database_path)
	if puzzles.size() > 0:
		# Pick a random puzzle
		random_puzzle = puzzles[randi() % puzzles.size()]
	else:
		print("No puzzles found in the file.")
	
	var board_desc = random_puzzle
	load_board_from_string(board_desc)
	place_pieces()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Close"):
		close.emit()
		SignalBus.minigame_hide.emit()

func _on_bounds_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_released("Select"):
		close.emit()
