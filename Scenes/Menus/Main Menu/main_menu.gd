# MainMenu.gd
# Handles main menu navigation and scene transitions

extends Control

func _ready() -> void:
	# Set initial focus for controller support
	$"Container/New game".grab_focus()

	# TODO: Add logic to enable/disable Continue button based on save existence
	# if SaveSystem.has_save():
	#     $Container/Continue.disabled = false

func _on_new_game_pressed() -> void:
	"""Handle new game initialization"""
	# Start fresh game state
	Global.reset_game_state()
	
	# Load game world and UI
	Global.game_controller.change_2d_scene(Global.TEST_ROOM)
	await Global.game_controller.transitioned_out  # Wait for transition completion
	Global.game_controller.change_gui_scene(Global.HUD, false, true)

func _on_continue_pressed() -> void:
	"""Handle game continuation"""
	# TODO: Implement save/load system
	# if SaveSystem.load_game():
	#     Global.game_controller.change_2d_scene(Global.current_level)
	#     Global.game_controller.change_gui_scene(Global.HUD)
	# else:
	#     show_error("No save files found!")
	pass

func _on_settings_pressed() -> void:
	"""Open settings menu"""
	pass

func _on_exit_pressed() -> void:
	"""Handle game exit"""
	# TODO: Add confirmation dialog
	# TODO: Save game state before exiting
	get_tree().quit()
