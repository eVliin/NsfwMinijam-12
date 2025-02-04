@tool
extends "res://addons/dialogic/Modules/LayeredPortrait/layered_portrait.gd"

## CHARACTER CONFIGURATION #####################################################
const CHARACTER_ID := "Chris"  # Unique identifier for portrait recognition

## NODE REFERENCES #############################################################
@onready var mouth: AnimatedSprite2D = $Group1/Mouth
@onready var eyes: AnimatedSprite2D = $Group1/Eyes
@onready var blink_timer: Timer = $Group1/BlinkTimer
@onready var look_timer: Timer = $Group1/LookTimer

## LIFE CYCLE METHODS ##########################################################
func _ready() -> void:
	# Initialize eye state
	eyes.animation = "look"
	eyes.frame = 0
	
	# Set up random timers for natural-looking animations
	setup_timer(blink_timer, 2, 10)    # Blink every 2-10 seconds
	setup_timer(look_timer, 5, 40)     # Look around every 5-40 seconds
	
	# Connect signals
	eyes.animation_finished.connect(_on_eyes_animation_finished)
	Dialogic.Text.about_to_show_text.connect(_about_to_show_text)
	Dialogic.Text.text_finished.connect(_text_finished)

## TIMER MANAGEMENT ############################################################
func setup_timer(timer: Timer, min_time: float, max_time: float) -> void:
	"""
	Configures a timer with random interval and connects its timeout signal
	@param timer: Timer node to configure
	@param min_time: Minimum wait time in seconds
	@param max_time: Maximum wait time in seconds
	"""
	timer.wait_time = randf_range(min_time, max_time)
	timer.timeout.connect(_on_timer_timeout.bind(timer, min_time, max_time))
	timer.start()

func _on_timer_timeout(timer: Timer, min_time: float, max_time: float) -> void:
	"""
	Handles timer timeouts to trigger eye animations when no animation is playing
	"""
	if not eyes.is_playing():
		if timer == blink_timer:
			eyes.play("blink")
		else:
			eyes.play("look")
	
	# Reset timer with new random interval
	timer.wait_time = randf_range(min_time, max_time)
	timer.start()

## ANIMATION CONTROL ###########################################################
func _on_eyes_animation_finished() -> void:
	"""
	Resets eyes to default state after any animation completes
	"""
	eyes.animation = "look"
	eyes.frame = 0
	eyes.stop()

## DIALOGIC INTEGRATION ########################################################
func _about_to_show_text(info: Dictionary) -> void:
	"""
	Handles Dialogic's 'about to show text' event for character highlighting
	"""
	if info.has("character") and CHARACTER_ID in str(info["character"]):
		_highlight()

func _text_finished(info: Dictionary) -> void:
	"""
	Handles Dialogic's 'text finished' event to remove character highlighting
	"""
	if info.has("character") and CHARACTER_ID in str(info["character"]):
		_unhighlight()

func _highlight() -> void:
	"""
	Activates speaking state with mouth animation
	"""
	mouth.play("talk")

func _unhighlight() -> void:
	"""
	Returns to neutral state after speaking
	"""
	mouth.stop()
	mouth.frame = 0
