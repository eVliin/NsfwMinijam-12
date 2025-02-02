# TransitionController.gd
# Handles screen transitions and loading animations
extends CanvasLayer

## Emitted when the entrance transition completes
signal transitioned_in()
## Emitted when the exit transition completes
signal transitioned_out()

# Node references
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var margin_container: MarginContainer = $MarginContainer

func transition_in() -> void:
	"""Play the entrance transition animation"""
	animation_player.play("in")

func transition_out() -> void:
	"""Play exit transition with scaling effect"""
	# Create a smooth scaling effect while playing exit animation
	create_tween().tween_property(
		margin_container, 
		"scale", 
		Vector2.ZERO, 
		0.3
	)
	animation_player.play("out")

func transition_to() -> void:
	"""Complete transition sequence (entrance + loading)"""
	transition_in()
	await transitioned_in
	_on_animation_player_animation_finished("in")

func _on_animation_player_animation_finished(anim_name: String) -> void:
	"""Handle animation completion events"""
	match anim_name:
		"in":
			# Start loading animation after entrance transition
			animation_player.play("Loading")
			transitioned_in.emit()
		"out":
			# Notify when exit transition completes
			transitioned_out.emit()
