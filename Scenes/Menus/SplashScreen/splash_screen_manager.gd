extends Control

@export var in_time: float = 0.5
@export var fade_in_time: float = 0.5
@export var pause_time: float = 0.5
@export var fade_out_time: float = 0.5
@export var out_time: float = 0.5
@export var splash_screen_container : Node

var splash_screens : Array

func _ready() -> void:
	get_screens()
	fade()

func get_screens() -> void:
	splash_screens = splash_screen_container.get_children()
	for screen in splash_screens:
		screen.modulate.a = 0.0

func fade():
	for screen in splash_screens:
		var tween = self.create_tween()
		tween.tween_interval(in_time)
		tween.tween_property(screen, "modulate:a", 1.0, fade_in_time)
		tween.tween_interval(pause_time)
		tween.tween_property(screen, "modulate:a", 0.0, fade_out_time)
		tween.tween_interval(out_time)
		await tween.finished
	Global.game_controller.change_gui_scene(Global.MAIN_MENU)
