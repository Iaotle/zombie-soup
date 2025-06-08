extends RigidBody2D

var content : String

signal clicked

var held = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		print("[bowl] clicked")
		clicked.emit(self)
		
func _physics_process(delta):
	if held:
		global_transform.origin = get_global_mouse_position()
		
func pickup():
	if held:
		return
	freeze = true
	held = true

func drop(impulse=Vector2.ZERO):
	if held:
		freeze = false
	apply_central_impulse(impulse)
	held = false
