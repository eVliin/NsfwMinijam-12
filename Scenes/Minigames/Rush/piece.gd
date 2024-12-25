extends Node2D

var assets := []
enum PieceNames {TWO, THREE, FOUR}

func _ready() -> void:
	assets.append("res://Scenes/Minigames/Rush/rush1x2.png")
	assets.append("res://Scenes/Minigames/Rush/rush1x3.png")
	assets.append("res://Scenes/Minigames/Rush/rush1x4.png")
