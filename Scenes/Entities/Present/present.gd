extends Node2D

@export_enum("red", "blue", "white") var color: String

const PRESENTBLUE = preload("res://Assets/Sprites/Presents/presentblue.png")
const PRESENTRED = preload("res://Assets/Sprites/Presents/presentred.png")
const PRESENTWHITE = preload("res://Assets/Sprites/Presents/presentwhite.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.start('TestDialogue')
	get_viewport().set_input_as_handled()
	match color:
		"blue":
			$Sprite2D.texture = PRESENTBLUE
		"red":
			$Sprite2D.texture = PRESENTRED
		"white":
			$Sprite2D.texture = PRESENTWHITE

func _on_area_2d_input_event(viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if Global.player_has_control:
		if event && Input.is_action_just_pressed("Select"):
			SignalBus.present_open.emit(name)
			SignalBus.pop_open.emit()
