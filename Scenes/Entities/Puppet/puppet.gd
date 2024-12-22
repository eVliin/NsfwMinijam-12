extends Node2D

const PRESENTBLUE = preload("res://Assets/Sprites/Presents/presentblue.png")
const PRESENTRED = preload("res://Assets/Sprites/Presents/presentred.png")
const PRESENTWHITE = preload("res://Assets/Sprites/Presents/presentwhite.png")

@export_enum("left", "ground", "right") var pose: String
@export_range(1, 5) var aggro: int = 1


var Stage : int = 0:
	get:
		return Stage
	set(value):
		if Stage >= 2:
			Stage = 0
		else:
			Stage += value
		random()

var aggro_lvls: Dictionary = {
	1: Vector2(20, 30),
	2: Vector2(15, 25),
	3: Vector2(10, 25),
	4: Vector2(5, 20),
	5: Vector2(5, 15)
}

func _ready():
	random()

func random():
	# Ensure the aggro level exists in the dictionary
	if aggro_lvls.has(aggro):
		var range: Vector2 = aggro_lvls[aggro]
		var rng = RandomNumberGenerator.new()
		rng.randomize()  # Randomize to ensure different sequences each run
		var random_delay: float = rng.randf_range(range.x, range.y)
		await get_tree().create_timer(random_delay).timeout
		Stage = 1
		print(Stage)
	else:
		print("Invalid aggro level: ", aggro)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
