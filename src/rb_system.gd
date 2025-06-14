extends RigidBody2D

@export var content : String = "Undefined"
@export var bullet_price : int = 1
@export var can_double_click : bool = true
var mouse_in : bool = false
signal clicked
signal double_clicked

var held = false

func _ready() -> void:
	z_index = 3

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and mouse_in:
		clicked.emit(self)
	if event.is_action_released("left_click") and mouse_in:
		double_clicked.emit(content, position)
		# TODO: don't free if soup
		queue_free()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click and mouse_in and can_double_click:
			double_clicked.emit(content, position)
			queue_free()
		
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

func _on_mouse_entered() -> void:
	mouse_in = true

func _on_mouse_exited() -> void:
	mouse_in = false
