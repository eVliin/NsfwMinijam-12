extends Node2D

@export var use_milliseconds: bool = false  # Editor-exposed toggle
@export var timer := 60

@onready var label: Label = $Label
@onready var countdown: Timer = $Timer

func _ready() -> void:
	countdown.wait_time = timer
	countdown.start()

func _process(_delta: float) -> void:
	label.text = _format_seconds(countdown.time_left)

func _format_seconds(time_left: float) -> String:
	var time := maxf(0, time_left)  # Use Godot 4's explicit float version
	var minutes := int(time / 60)
	var seconds := int(fmod(time, 60))
	
	if not use_milliseconds:
		return "%02d:%02d" % [minutes, seconds]
	
	var milliseconds := int(fmod(time, 1.0) * 100)
	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
