# PuppetController.gd
# Manages puppet animations, attack patterns, and aggression levels

extends Node2D

### Resources & References ###
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Preloaded assets
const PRESENT_BLUE = preload("res://Assets/Sprites/Presents/presentblue.png")
const PRESENT_RED = preload("res://Assets/Sprites/Presents/presentred.png")
const PRESENT_WHITE = preload("res://Assets/Sprites/Presents/presentwhite.png")
const PUPPET_CYCLE_FRONT = preload("res://Assets/Sprites/Puppet_wakeup_front/Puppet_Cycle_front.tres")
const PUPPET_CYCLE_SIDE = preload("res://Assets/Sprites/Puppet_wakeup_side/Puppet_Cycle_side.tres")

### Configuration ###
@export_enum("left", "ground", "right") var pose: String
@export_range(1, 5) var aggro: int = 1

### State Management ###
var attack: bool = false
var _stage: int = 0  # Tracks attack progression stage
var aggro_lvls: Dictionary = {
	1: Vector2(20, 30),  # Min/max delay ranges for each aggression level
	2: Vector2(15, 25),
	3: Vector2(10, 25),
	4: Vector2(5, 20),
	5: Vector2(5, 15)
}

### Stage Property ###
var Stage: int:
	get: return _stage
	set(value):
		# Cycle through stages 0-2
		_stage = (_stage + value) % 3  # Improved cycling logic

### Initialization ###
func _ready() -> void:
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	SignalBus.puppet_cummed.connect(reset_last_attacker)
	
	initialize_puppet()

func initialize_puppet():
	_set_pose_animation()
	animated_sprite_2d.animation = str(Stage)
	_random_delay()

### Animation Setup ###
func _set_pose_animation() -> void:
	match pose:
		"left":
			animated_sprite_2d.sprite_frames = PUPPET_CYCLE_SIDE
			scale.x = -abs(scale.x)  # Mirror sprite
		"ground":
			animated_sprite_2d.sprite_frames = PUPPET_CYCLE_FRONT
		"right":
			animated_sprite_2d.sprite_frames = PUPPET_CYCLE_SIDE
			scale.x = abs(scale.x)  # Ensure right-facing

### Attack Timing System ###
var _rng = RandomNumberGenerator.new()  # Reusable RNG instance

func _random_delay() -> void:
	if aggro_lvls.has(aggro):
		var delay_range = aggro_lvls[aggro]
		_rng.randomize()
		var random_delay = _rng.randf_range(delay_range.x, delay_range.y)
		
		print("%s next attack in: %.1fs" % [name, random_delay])
		await get_tree().create_timer(random_delay).timeout
		
		advance_stage()
	else:
		push_error("Invalid aggro level: %d" % aggro)

func advance_stage():
	Stage = 1
	animated_sprite_2d.play(str(Stage))

### Animation Handling ###
func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "2":
		trigger_attack()
	else:
		_random_delay()

func trigger_attack():
	attack = true
	Global.AttackTrack += 1
	SignalBus.attacking.emit()
	Global.AttackOrder.push_front(self)

### Attack Reset System ###
func reset_last_attacker() -> void:
	if Global.AttackOrder.size() > 0 && Global.AttackOrder.front() == self:
		print("Resetting attacker: ", name)
		Stage = 1
		attack = false
		animated_sprite_2d.animation = str(Stage)
		_random_delay()
