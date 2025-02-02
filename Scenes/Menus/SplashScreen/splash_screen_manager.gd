# SplashScreenManager.gd
# Handles sequential display of splash screens with configurable timing

extends Control

### Animation Timing Configuration ###
@export var in_time: float = 0.5          # Initial delay before fade-in
@export var fade_in_time: float = 0.5     # Duration of fade-in animation
@export var pause_time: float = 0.5       # Duration to display full opacity
@export var fade_out_time: float = 0.5    # Duration of fade-out animation
@export var out_time: float = 0.5         # Final delay after fade-out
@export var splash_screen_container: Node # Parent node containing splash screen elements

### Internal State ###
var splash_screens: Array = []            # Collection of splash screen elements

func _ready() -> void:
	initialize_splash_screens()
	start_splash_sequence()

func initialize_splash_screens() -> void:
	"""Load and prepare splash screen elements"""
	if splash_screen_container:
		splash_screens = splash_screen_container.get_children()
		# Initialize all screens to transparent
		for screen in splash_screens:
			if screen is CanvasItem:
				screen.modulate.a = 0.0
	else:
		push_error("Splash screen container not assigned!")

func start_splash_sequence() -> void:
	"""Begin sequential splash screen presentation"""
	if splash_screens.is_empty():
		push_warning("No splash screens found in container!")
		return_to_main_menu()
		return
	
	play_sequence()

func play_sequence() -> void:
	"""Play splash screens in sequence with configured timing"""
	for screen in splash_screens:
		if not screen is CanvasItem:
			continue
			
		create_screen_tween(screen)
		await get_tree().create_timer(get_total_animation_time()).timeout
	
	return_to_main_menu()

func create_screen_tween(screen: CanvasItem) -> void:
	"""Create and configure animation sequence for a single screen"""
	var tween = create_tween()
	tween.set_parallel(false)  # Ensure sequential animations
	
	# Animation sequence
	tween.tween_interval(in_time)
	tween.tween_property(screen, "modulate:a", 1.0, fade_in_time)
	tween.tween_interval(pause_time)
	tween.tween_property(screen, "modulate:a", 0.0, fade_out_time)
	tween.tween_interval(out_time)

func get_total_animation_time() -> float:
	"""Calculate total duration for one splash screen cycle"""
	return in_time + fade_in_time + pause_time + fade_out_time + out_time

func return_to_main_menu() -> void:
	"""Transition to main menu after all splash screens"""
	if Global.game_controller:
		Global.game_controller.change_gui_scene(Global.MAIN_MENU, true)
	else:
		push_error("Game controller not available in Global scope")
