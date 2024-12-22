extends Node2D

@export_enum("left", "ground", "right") var color: String
@export_range(1,5) var aggro : int



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func random():
	var random_delay : float = RandomNumberGenerator.new().randf_range(0.1, 2.0)
	await get_tree().create_timer(random_delay).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
