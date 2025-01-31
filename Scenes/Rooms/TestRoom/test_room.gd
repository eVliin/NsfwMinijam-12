extends Node2D

const MINIGAME_PRESENT = preload("res://Scenes/Minigames/Present/MinigamePresent.tscn")
const RUSH = preload("res://Scenes/Minigames/Rush/rush.tscn")

var popUpTrack :int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.pop_open.connect(_pop_up)
	SignalBus.minigame_show.connect(_pop_up)
	SignalBus.minigame_show.connect(_minigame)
	SignalBus.pop_close.connect(_pop_close)
	SignalBus.attacking.connect(_pop_up)
	Global.AttackTrack = 0
	Dialogic.start('TestDialogue')
	popUpTrack = 0
	for i in $Presents.get_child_count():
		
		var instance = MINIGAME_PRESENT.instantiate()
		instance.name = str(i)
		$Camera2D/MinigameLayer.add_child(instance)

func _minigame(id, type):
	print(id, type)
	var target_scene
	match type:
		"rush": target_scene = RUSH
		_: 
			push_error("Tipo de minigame inválido: ", type)
			return
	
	var existing_node = $Camera2D/MinigameLayer/minigames.get_node_or_null(str(id))
	
	if existing_node:
		# Se já existe, apenas torna visível
		existing_node.visible = true
	else:
		# Cria nova instância se não existir
		var new_instance = target_scene.instantiate()
		new_instance.name = str(id)
		$Camera2D/MinigameLayer/minigames.add_child(new_instance)
		new_instance.visible = true

func _pop_up():
	popUpTrack += 1
	set_process_input(false)
	$Camera2D.set_process_input(false)

func _pop_close():
	popUpTrack -= 1
	if popUpTrack <= 0:
		set_process_input(true)
		$Camera2D.set_process_input(true)

var _point : int = 0

@export var point : int:
	set(value):
		_point = value
		$Camera2D/MinigameLayer/Label.text=str("Agrro level: ", value, "
		press up or down to change it (yes you are helping me debug this)")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up") && $"Puppets/0".aggro < 5:
		$"Puppets/0".aggro += 1
		$"Puppets/1".aggro += 1
		$"Puppets/2".aggro += 1
		point = $"Puppets/0".aggro
	
	if Input.is_action_just_pressed("ui_down") && $"Puppets/0".aggro > 1:
		$"Puppets/0".aggro -= 1
		$"Puppets/1".aggro -= 1
		$"Puppets/2".aggro -= 1
		point = $"Puppets/0".aggro
