extends TextureRect
@onready var root = $"../.."
@export var rigid_body : PackedScene
var mouse_in : bool = false
signal cookable_added

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and mouse_in:
		var obj = rigid_body.instantiate()
		add_child(obj)
		emit_signal("cookable_added")
		
func _on_mouse_entered() -> void:
	mouse_in = true

func _on_mouse_exited() -> void:
	mouse_in = false
