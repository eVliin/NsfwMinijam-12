extends Node2D

@export var debug_label_text: String = "Aggro level: {0},
press up or down to change it (yes you are helping me debug this)"
@export var point: int:
	set(value):
		_point = value
		$Camera2D/MinigameLayer/Label.text = debug_label_text.format([value])

const MINIGAME_PRESENT = preload("res://Scenes/Minigames/Present/MinigamePresent.tscn")
const RUSH = preload("res://Scenes/Minigames/Rush/rushminigame.tscn")

@onready var presents_node: Node = $Presents
@onready var camera_node: Node = $"Camera2D/Fnaf ass camera"
@onready var presents: Control = $Camera2D/MinigameLayer/presents
@onready var minigames_node: Node = $Camera2D/MinigameLayer/minigames

var _point: int = 0

func _ready() -> void:
	SignalBus.pop_open.connect(_pop_up)
	SignalBus.minigame_show.connect(_minigame)
	SignalBus.minigame_hide.connect(_minigame_close)
	SignalBus.pop_close.connect(_pop_close)
	SignalBus.attacking.connect(_pop_up)
	SignalBus.puppet_cummed.connect(_pop_close)
	
	Global.AttackTrack = 0
	Dialogic.start('TestDialogue')
	Global.popUpTrack = 0
	
	for i in presents_node.get_child_count():
		var instance = MINIGAME_PRESENT.instantiate()
		instance.name = str(i)
		presents.add_child(instance)

func _minigame(id, type):
	print(id, " ", type)
	presents.process_mode = Node.PROCESS_MODE_DISABLED
	
	var target_scene = RUSH if type == "rush" else null
	
	if not target_scene:
		push_error("Tipo de minigame inválido: ", type)
		return
	
	var existing_node = minigames_node.get_node_or_null(str(id))
	_pop_up()
	
	if existing_node:
		existing_node.visible = true
	else:
		var new_instance = target_scene.instantiate()
		new_instance.name = str(id)
		minigames_node.add_child(new_instance)
		new_instance.visible = true

func _minigame_close():
	_pop_close()
	update_presents_processing()

func update_presents_processing():
	var all_hidden = true
	print("ass")
	for child in minigames_node.get_children():
		if child.visible:
			all_hidden = false
			break
	if all_hidden:
		presents.process_mode = Node.PROCESS_MODE_INHERIT
		print("anus")
	else:
		Node.PROCESS_MODE_DISABLED

func _pop_up():
	Global.popUpTrack += 1
	print("pop track: ",Global.popUpTrack)
func _pop_close():
	Global.popUpTrack -= 1
	print("pop track: ",Global.popUpTrack)

func _process(delta: float) -> void:
	if Global.popUpTrack <= 0:
		presents_node.process_mode = Node.PROCESS_MODE_INHERIT
		camera_node.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		Global.cameraPan = 0
		presents_node.process_mode = Node.PROCESS_MODE_DISABLED
		camera_node.process_mode = Node.PROCESS_MODE_DISABLED
	
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
