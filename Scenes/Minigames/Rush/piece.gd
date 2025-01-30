extends Node2D

var assets := []
enum PieceNames {TWO, THREE, FOUR}

var size
var horizontal
var sprite
var is_red

var draggable = false
var is_valid_move = false
var body_ref


func _ready() -> void:
	assets.append("res://Scenes/Minigames/Rush/rushRed.png")
	assets.append("res://Scenes/Minigames/Rush/rush1x2.png")
	assets.append("res://Scenes/Minigames/Rush/rush1x3.png")
	assets.append("res://Scenes/Minigames/Rush/rush1x4.png")
	
	if horizontal:
		sprite = $h
		$h.show()
		$v.hide()
	else:
		sprite = $v
		$v.show()
		$h.hide()
		$Area2D.rotation_degrees = 90
		$Area2D.position.x = 50
	
	if is_red:
		sprite.texture = load(assets[0])
	else:
		sprite.texture = load(assets[size - 1])
	$Area2D.get_node(str(size)).disabled = false


func _on_area_2d_mouse_entered() -> void:
	if not Global.is_dragging:
		draggable = true
		scale = Vector2(1.05, 1.05)


func _on_area_2d_mouse_exited() -> void:
	if not Global.is_dragging:
		draggable = false
		scale = Vector2(1, 1)
