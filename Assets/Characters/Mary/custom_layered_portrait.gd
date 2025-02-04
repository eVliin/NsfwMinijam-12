@tool
extends "res://addons/dialogic/Modules/LayeredPortrait/layered_portrait.gd"

## Mary Character Controller
##
## Handles visual presentation and animations for character 'Mary' in Dialogic dialogues.
## Manages layered sprites with automatic blinking, speech animations, and screen effects.

signal animation_finished  # Emitted when character's transition animation completes

### CONSTANTS ##################################################################
const CHARACTER_ID := "Mary"  # Unique identifier for Dialogic character recognition

### NODE REFERENCES ############################################################
@onready var mouth: AnimatedSprite2D = $Group1/Mouth
@onready var eyes: AnimatedSprite2D = $Group1/Eyes
@onready var blink_timer: Timer = $Group1/BlinkTimer
@onready var tvStatic: AnimatedSprite2D = $Group1/AnimatedSprite2D

### STATE VARIABLES ############################################################
var next_character_is_mary := false  # Tracks if next speaker is Mary

### INITIALIZATION #############################################################
func _ready() -> void:
	# Set initial visual states
	self.visible = false
	_reset_eye_state()
	
	# Configure eye blinking with random intervals (2-10 seconds)
	setup_timer(blink_timer, 2.0, 10.0)
	
	# Connect Dialogic system signals
	Dialogic.Text.about_to_show_text.connect(_about_to_show_text)
	Dialogic.Text.text_finished.connect(_text_finished)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

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
	Handles blink timer events to create natural eye movements
	"""
	if not eyes.is_playing():
		eyes.play("blink")
	
	# Reset timer with new random interval
	timer.wait_time = randf_range(min_time, max_time)
	timer.start()

### VISUAL STATE MANAGEMENT ####################################################
func _reset_eye_state() -> void:
	"""Resets eyes to default neutral state"""
	eyes.animation = "blink"
	eyes.frame = 0
	eyes.stop()

func _toggle_character_visibility(visible: bool) -> void:
	"""
	Controls character visibility with TV static transition effect
	
	Args:
		visible (bool): Whether to show the character
	"""
	
	tvStatic.visible = visible
	tvStatic.play("default")
	
	if not visible:
		tvStatic.visible = !visible
		await animation_finished  # Wait for transition effect to complete
	
	self.visible = visible

### DIALOGIC INTEGRATION #######################################################
func _about_to_show_text(info: Dictionary) -> void:
	"""
	Handles pre-text display setup when Mary is about to speak
	
	Args:
		info (Dictionary): Dialogic event data
	"""
	next_character_is_mary = is_character_mary(info)
	if next_character_is_mary:
		_highlight()

func _text_finished(info: Dictionary) -> void:
	"""
	Handles post-text cleanup when dialogue line completes
	
	Args:
		info (Dictionary): Dialogic event data
	"""
	unhighlight(info)

### CHARACTER IDENTIFICATION ###################################################
func is_character_mary(info: Dictionary) -> bool:
	"""
	Determines if current speaking character is Mary
	
	Args:
		info (Dictionary): Dialogic event data containing character information
	
	Returns:
		bool: True if current character matches Mary's ID
	"""
	var character = info.get("character", "")
	return str(character).contains(CHARACTER_ID)

### VISUAL EFFECT CONTROLS #####################################################
func _highlight() -> void:
	"""Activates speaking visual state with mouth animation"""
	if not self.visible:
		_toggle_character_visibility(true)
	mouth.play("talk")

func unhighlight(info: Dictionary) -> void:
	"""
	Returns to neutral state when speech completes
	
	Args:
		info (Dictionary): Dialogic event data for character verification
	"""
	mouth.stop()
	mouth.frame = 0
	
	if not is_character_mary(info):
		_toggle_character_visibility(false)

### EVENT CLEANUP ##############################################################
func _on_timeline_ended() -> void:
	"""Ensures character is hidden when dialogue ends"""
	_toggle_character_visibility(false)

### ANIMATION HANDLING #########################################################
func _on_animated_sprite_2d_animation_finished() -> void:
	"""Handles completion of transition animations"""
	animation_finished.emit()
	tvStatic.visible = false
