extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.attacking.connect(_pop)

func _pop():
	match Global.AttackTrack:
		1:
			show()
		2:
			animation_player.play("0")
		3:
			animation_player.play("1")

func cummed():
	match Global.AttackTrack:
		1:
			show()
		2:
			animation_player.play_backwards("0")
		3:
			animation_player.play_backwards("1")
	
	Global.AttackTrack -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
