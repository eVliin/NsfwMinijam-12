# PauseMenu.gd
# Handles pause menu functionality and navigation

extends Control

### Node References ###
@onready var quit_confirm: PanelContainer = $PanelContainer/PanelContainer
@onready var v_box: VBoxContainer = $PanelContainer/VBoxContainer
@onready var main: GameController = $"../.."

### Constants ###
const MAIN_MENU_PATH = "res://Scenes/Menus/Main Menu/MainMenu.tscn"
const EMPTY_SCENE_PATH = "res://Assets/Placeholder/empty.tscn"  # Fixed typo

func _ready() -> void:
	# Initial setup
	hide()
	quit_confirm.hide()
	
	# Signal connections
	SignalBus.pause.connect(_show)
	
	# UI Focus
	$PanelContainer/VBoxContainer/Resume.grab_focus()

func _show(is_paused: bool) -> void:
	"""Toggle pause menu visibility"""
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0 if is_paused else 0.0, 0.2)
	visible = is_paused
	if is_paused:
		# Reset focus when reopening
		$PanelContainer/VBoxContainer/Resume.grab_focus()

### Button Handlers ###
func _on_resume_pressed() -> void:
	"""Resume game gameplay"""
	main.game_paused = false

func _on_options_pressed() -> void:
	"""TODO: Implement options menu"""
	# Example implementation:
	# main.change_gui_scene("res://Scenes/Menus/OptionsMenu.tscn", true)
	pass

func _on_quit_pressed() -> void:
	"""Show quit confirmation dialog"""
	quit_confirm.show()
	# Set focus to confirmation dialog's back button
	$PanelContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Back.grab_focus()

func _on_back_pressed() -> void:
	"""Return to main pause menu"""
	quit_confirm.hide()
	# Return focus to quit button
	$PanelContainer/VBoxContainer/Quit.grab_focus()

func _on_main_pressed() -> void:
	"""Return to main menu"""
	# Clean up game state
	main.change_2d_scene(EMPTY_SCENE_PATH, true)
	
	# Hide menus
	hide()
	quit_confirm.hide()
	
	# Load main menu
	main.change_gui_scene(MAIN_MENU_PATH, false, true)
	
	# Ensure game is unpaused
	main.game_paused = false
