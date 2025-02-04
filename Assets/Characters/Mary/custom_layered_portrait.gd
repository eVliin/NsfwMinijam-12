@tool
extends "res://addons/dialogic/Modules/LayeredPortrait/layered_portrait.gd"

## CHARACTER CONFIGURATION #####################################################
const CHARACTER_ID := "Mary"  # Unique identifier for character recognition

## NODE REFERENCES #############################################################
@onready var mouth: AnimatedSprite2D = $Group1/Mouth
@onready var eyes: AnimatedSprite2D = $Group1/Eyes
@onready var blink_timer: Timer = $Group1/BlinkTimer
@onready var tvStatic: AnimatedSprite2D = $Group1/AnimatedSprite2D

## DIALOGIC STATE ##############################################################
var next_character_is_mary := false  # Tracks if next speaker is also Mary

## LIFE CYCLE METHODS ##########################################################
func _ready() -> void:
	# Initialize character visual state
	_reset_eye_state()
	setup_timer(blink_timer, 2, 10)  # Configure blink timer
	
	# Connect Dialogic signals
	Dialogic.Text.about_to_show_text.connect(_about_to_show_text)
	Dialogic.Text.text_finished.connect(_text_finished)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

## TIMER MANAGEMENT ############################################################
func setup_timer(timer: Timer, min_time: float, max_time: float) -> void:
	"""
	Configures a timer with random intervals between min_time and max_time
	@param timer: Timer node to configure
	@param min_time: Minimum wait time in seconds
	@param max_time: Maximum wait time in seconds
	"""
	timer.wait_time = randf_range(min_time, max_time)
	timer.timeout.connect(_on_timer_timeout.bind(timer, min_time, max_time))
	timer.start()

func _on_timer_timeout(timer: Timer, min_time: float, max_time: float) -> void:
	"""
	Handles timer timeout events for natural blinking animation
	"""
	if not eyes.is_playing():
		eyes.play("blink")
	
	# Reset timer with new random interval
	timer.wait_time = randf_range(min_time, max_time)
	timer.start()

## VISUAL STATE MANAGEMENT #####################################################
func _reset_eye_state() -> void:
	"""
	Resets eyes to default state (first frame of 'look' animation)
	"""
	eyes.animation = "look"
	eyes.frame = 0
	eyes.stop()

func _toggle_character_visibility(visible: bool) -> void:
	"""
	Controls overall character visibility
	@param visible: Whether the character should be visible
	"""
	tvStatic.visible = visible
	self.visible = visible

## DIALOGIC INTEGRATION ########################################################
func _about_to_show_text(info: Dictionary) -> void:
	"""
	Handles Dialogic's 'about to show text' event
	- Updates next speaker state
	- Activates highlighting if Mary is speaking
	"""
	next_character_is_mary = is_character_mary(info)
	if next_character_is_mary:
		_highlight()

func _text_finished(info: Dictionary) -> void:
	"""
	Handles Dialogic's 'text finished' event
	"""
	
	unhighlight(info)

## CHARACTER IDENTIFICATION ####################################################
func is_character_mary(info: Dictionary) -> bool:
	"""
	Determines if the current character is Mary
	@param info: Dialogic event dictionary
	@return: True if character matches Mary's ID
	"""
	var character = info.get("character", "")
	return str(character).contains(CHARACTER_ID)

## HIGHLIGHT CONTROLS ##########################################################
func _highlight() -> void:
	"""
	Activates speaking state:
	- Makes character visible
	- Starts mouth animation
	"""
	_toggle_character_visibility(true)
	tvStatic.play("default")
	mouth.play("talk")

func unhighlight(info: Dictionary) -> void:
	"""
	Returns to neutral state:
	- Stops mouth animation
	- Hides character
	"""
	mouth.stop()
	mouth.frame = 0
	print(is_character_mary(info))
	if !is_character_mary(info):
		_toggle_character_visibility(false)

func _on_timeline_ended() -> void:
	"""
	Ensures cleanup when dialogue timeline ends
	"""
	_toggle_character_visibility(false)

## ANIMATION HANDLING ##########################################################
func _on_animated_sprite_2d_animation_finished() -> void:
	"""
	Handles completion of character sprite animation
	"""
	tvStatic.visible = false
