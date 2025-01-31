extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Preloaded resources
const PRESENT_BLUE = preload("res://Assets/Sprites/Presents/presentblue.png")
const PRESENT_RED = preload("res://Assets/Sprites/Presents/presentred.png")
const PRESENT_WHITE = preload("res://Assets/Sprites/Presents/presentwhite.png")
const PUPPET_CYCLE_FRONT = preload("res://Assets/Sprites/Puppet_wakeup_front/Puppet_Cycle_front.tres")
const PUPPET_CYCLE_SIDE = preload("res://Assets/Sprites/Puppet_wakeup_side/Puppet_Cycle_side.tres")

@export_enum("left", "ground", "right") var pose: String
@export_range(1, 5) var aggro: int = 1

var attack: bool = false

# Internal variable for Stage
var _stage: int = 0  # Tracks the last puppet that attacked

var aggro_lvls: Dictionary = {
	1: Vector2(20, 30),
	2: Vector2(15, 25),
	3: Vector2(10, 25),
	4: Vector2(5, 20),
	5: Vector2(5, 15)
}

# Property for Stage
var Stage: int:
	get:
		return _stage
	set(value):
		# Reset to 0 if Stage reaches or exceeds 2
		if _stage >= 2:
			_stage = 0
		else:
			_stage += value

func _ready() -> void:
	animated_sprite_2d.connect("animation_finished", _on_animation_finished)
	SignalBus.connect("puppet_cummed", reset_last_attacker)
	_set_pose_animation()
	animated_sprite_2d.animation = str(Stage)
	_random_delay()

func _set_pose_animation() -> void:
	match pose:
		"left":
			animated_sprite_2d.sprite_frames = PUPPET_CYCLE_SIDE
			scale.x = abs(scale.x) * -1  # Ensure proper mirroring
		"ground":
			animated_sprite_2d.sprite_frames = PUPPET_CYCLE_FRONT
		"right":
			animated_sprite_2d.sprite_frames = PUPPET_CYCLE_SIDE

func _random_delay() -> void:
	if aggro_lvls.has(aggro):
		var range = aggro_lvls[aggro]
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var random_delay = rng.randf_range(range.x, range.y)
		
		print(name, " Next stage in ", str(random_delay), " seconds.")
		
		await get_tree().create_timer(random_delay).timeout
		Stage = 1
		animated_sprite_2d.play(str(Stage))
	else:
		print("Invalid aggro level: ", aggro)

func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "2":
		attack = true
	if attack:
		Global.AttackTrack += 1
		SignalBus.emit_signal("attacking")
		Global.AttackOrder.push_front(self)
	else:
		_random_delay()

# Reset the last attacker when AttackTrack is decremented
func reset_last_attacker() -> void:
	if Global.AttackOrder.size() > 0 and Global.AttackOrder.front() == self:
		print("Signal received by: ", name)
		print("Current AttackOrder: ", Global.AttackOrder)
		Stage = 1
		attack = false
		animated_sprite_2d.animation = str(Stage)
		_random_delay()
