extends CanvasLayer


signal transitioned_in()
signal transitioned_out()

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var margin_container: MarginContainer = $MarginContainer

func transition_in() -> void:
	animation_player.play("in")


func transition_out() -> void:
	await transitioned_in
	create_tween().tween_property(margin_container, "scale", Vector2.ZERO, 0.3)
	animation_player.play("out")


func transition_to() -> void:
	transition_in()
	await transitioned_in
	_on_animation_player_animation_finished("in")

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "in":
		animation_player.play("Loading")
		transitioned_in.emit()
	elif anim_name == "out":
		transitioned_out.emit()
