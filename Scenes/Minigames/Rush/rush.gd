extends Node

# Path to the database file
const DATABASE_PATH: String = "res://Scenes/Minigames/Rush/filtered_puzzles.txt"

func _ready() -> void:
	# Load and parse the file
	var puzzles = load_puzzles(DATABASE_PATH)
	if puzzles.size() > 0:
		# Pick a random puzzle
		var random_puzzle = puzzles[randi() % puzzles.size()]
		print("Random Puzzle: ", random_puzzle)
	else:
		print("No puzzles found in the file.")

# Function to load puzzles from the file
func load_puzzles(file_path: String) -> Array:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var puzzles = []
	
	if file:
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line != "" and line.left(1) != "#":  # Check for non-empty and non-comment lines
				# Extract the board description from the line
				var parts = line.split(" ")
				if parts.size() >= 2:
					puzzles.append(parts[1])  # Add the board description
		file.close()
	else:
		print("Failed to open file: ", file_path)
	
	return puzzles
