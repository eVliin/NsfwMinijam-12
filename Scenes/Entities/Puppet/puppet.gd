extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const PRESENTBLUE = preload("res://Assets/Sprites/Presents/presentblue.png")
const PRESENTRED = preload("res://Assets/Sprites/Presents/presentred.png")
const PRESENTWHITE = preload("res://Assets/Sprites/Presents/presentwhite.png")
const PUPPET_CYCLE_FRONT = preload("res://Assets/Sprites/Puppet_wakeup_front/Puppet_Cycle_front.tres")
const PUPPET_CYCLE_SIDE = preload("res://Assets/Sprites/Puppet_wakeup_side/Puppet_Cycle_side.tres")


@export_enum("left", "ground", "right") var pose: String
@export_range(1, 5) var aggro: int = 1

var attacking = false

var Stage : int = 0:
	get:
		return Stage
	set(value):
		if Stage >= 2:
			Stage = 0
		else:
			Stage += value

var aggro_lvls: Dictionary = {
	1: Vector2(20, 30),
	2: Vector2(15, 25),
	3: Vector2(10, 25),
	4: Vector2(5, 20),
	5: Vector2(5, 15)
}

func _ready():
	match pose:
		"left":
			animated_sprite_2d.sprite_frames = PUPPET_CYCLE_SIDE
			scale.x = -scale.x
		"ground":
			animated_sprite_2d.sprite_frames = PUPPET_CYCLE_FRONT
		"right":
			animated_sprite_2d.sprite_frames = PUPPET_CYCLE_SIDE
	animated_sprite_2d.play(str(Stage))
	random()

func random():
	# Ensure the aggro level exists in the dictionary
	if aggro_lvls.has(aggro):
		var range: Vector2 = aggro_lvls[aggro]
		var rng = RandomNumberGenerator.new()
		rng.randomize()  # Randomize to ensure different sequences each run
		var random_delay: float = rng.randf_range(range.x, range.y)
		await get_tree().create_timer(random_delay).timeout
		Stage = 1
		print(Stage)
		animated_sprite_2d.play(str(Stage))
	else:
		print("Invalid aggro level: ", aggro)


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "2":
		attacking = true
		Global.AttackTrack += 1
		SignalBus.emit_signal("attacking")
	if attacking:
		print("FUCK")
	else:
		random()
