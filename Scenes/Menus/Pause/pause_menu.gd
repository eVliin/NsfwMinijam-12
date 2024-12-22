extends Control

@onready var quit_confirm: PanelContainer = $PanelContainer/PanelContainer
@onready var v_box: VBoxContainer = $PanelContainer/VBoxContainer
@onready var main: GameController = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	quit_confirm.hide()
	SignalBus.pause.connect(_show)
	$PanelContainer/VBoxContainer/Resume.grab_focus()

func _show(is_paused: bool):
	if is_paused:
		show()
	else:
		hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resume_pressed() -> void:
	main.game_paused = false


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	quit_confirm.show()


func _on_back_pressed() -> void:
	quit_confirm.hide()


func _on_main_pressed() -> void:
	
	main.change_2d_scene("res://Assets/PLaceholder/empty.tscn",true)
	hide()
	quit_confirm.hide()
	main.change_gui_scene("res://Scenes/Menus/Main Menu/MainMenu.tscn",false,true)
