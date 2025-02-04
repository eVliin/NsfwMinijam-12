extends Area2D

@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	add_to_group("piece")
	input_event.connect(_on_input_event)

func _on_input_event(_viewport, event: InputEvent, _shape_idx):
	if event is InputEventScreenTouch:
		get_viewport().set_input_as_handled()
