extends TextureRect
@onready var root = $"../.."

func _get_drag_data(at_position: Vector2) -> Variant:
	var data = "ant"
	var preview = null
	set_drag_preview(preview)
	return data
