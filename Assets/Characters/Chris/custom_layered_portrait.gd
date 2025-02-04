@tool
extends "res://addons/dialogic/Modules/LayeredPortrait/layered_portrait.gd"

## Chris Character Controller
##
## Manages visual presentation and animations for character 'Chris' in Dialogic dialogues.
## Handles eye movements, blinking, and speech synchronization.

### CONSTANTS ##################################################################
const CHARACTER_ID := "Chris"  # Unique identifier for Dialogic character recognition

### NODE REFERENCES ############################################################
@onready var mouth: AnimatedSprite2D = $Group1/Mouth
@onready var eyes: AnimatedSprite2D = $Group1/Eyes
@onready var blink_timer: Timer = $Group1/BlinkTimer
@onready var look_timer: Timer = $Group1/LookTimer

### INITIALIZATION #############################################################
func _ready() -> void:
	# Set initial eye state
	eyes.animation = "look"
	eyes.frame = 0
	
	# Configure behavioral timers
	setup_timer(blink_timer, 2.0, 10.0)   # Blink interval
	setup_timer(look_timer, 5.0, 40.0)    # Eye movement interval
	
	# Connect Dialogic signals
	Dialogic.Text.about_to_show_text.connect(_about_to_show_text)
	Dialogic.Text.text_finished.connect(_text_finished)
	eyes.animation_finished.connect(_on_eyes_animation_finished)

### TIMER MANAGEMENT ###########################################################
func setup_timer(timer: Timer, min_time: float, max_time: float) -> void:
	"""
	Configures a timer with random intervals between specified range
	
	Args:
		timer (Timer): Timer node to configure
		min_time (float): Minimum wait time in seconds
		max_time (float): Maximum wait time in seconds
	"""
	timer.wait_time = randf_range(min_time, max_time)
	timer.timeout.connect(_on_timer_timeout.bind(timer, min_time, max_time))
	timer.start()

func _on_timer_timeout(timer: Timer, min_time: float, max_time: float) -> void:
	"""
	Handles timer events to trigger eye animations
	
	Args:
		timer (Timer): Source timer (blink/look)
		min_time (float): Minimum interval for reset
		max_time (float): Maximum interval for reset
	"""
	if not eyes.is_playing():
		match timer:
			blink_timer: eyes.play("blink")
			look_timer: eyes.play("look")
	
	# Reset timer with new random interval
	timer.wait_time = randf_range(min_time, max_time)
	timer.start()

### VISUAL STATE MANAGEMENT ####################################################
func _on_eyes_animation_finished() -> void:
	"""Resets eyes to default state after animations complete"""
	eyes.animation = "look"
	eyes.frame = 0
	eyes.stop()

### DIALOGIC INTEGRATION #######################################################
func _about_to_show_text(info: Dictionary) -> void:
	"""
	Prepares character visuals when about to speak
	
	Args:
		info (Dictionary): Dialogic event data
	"""
	if is_character_chris(info):
		_highlight()

func _text_finished(info: Dictionary) -> void:
	"""
	Cleans up character visuals after speaking
	
	Args:
		info (Dictionary): Dialogic event data
	"""
	if is_character_chris(info):
		_unhighlight()

func is_character_chris(info: Dictionary) -> bool:
	"""
	Identifies if current character is Chris
	
	Args:
		info (Dictionary): Dialogic event data
	
	Returns:
		bool: True if character matches Chris' ID
	"""
	var character = info.get("character", "")
	return str(character).contains(CHARACTER_ID)

### VISUAL EFFECT CONTROLS #####################################################
func _highlight() -> void:
	"""Activates speaking state with mouth animation"""
	mouth.play("talk")

func _unhighlight() -> void:
	"""Returns to neutral state after speaking"""
	mouth.stop()
	mouth.frame = 0
