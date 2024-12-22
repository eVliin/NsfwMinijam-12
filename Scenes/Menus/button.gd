extends Button

const SELECTOR = preload("res://Assets/UI/selector.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_hovered():
		grab_focus()
	if has_focus():
		icon = SELECTOR
	else:
		icon = null
