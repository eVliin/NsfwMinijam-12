extends Node2D

@export_enum("Red", "Blue", "White") var color: String

const BLUE = preload("res://Assets/PLaceholder/present/texture.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match color:
		"Blue":
			$Sprite2D.texture = BLUE

func _on_area_2d_input_event(viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event && Input.is_action_just_pressed("dialogic_default_action"):
		SignalBus.present_open.emit(name)
		SignalBus.pop_open.emit()
