extends Camera2D

var y_offset = 57
var in_bar = true
var target_position: Vector2
var is_moving = false
var move_speed = 400

func _ready():
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_down") and in_bar and not is_moving:
		in_bar = false
		target_position = position + Vector2(0, get_viewport_rect().size.y - y_offset)
		is_moving = true
	elif event.is_action_pressed("scroll_up") and not in_bar and not is_moving:
		in_bar = true
		target_position = position - Vector2(0, get_viewport_rect().size.y - y_offset)
		is_moving = true

func _process(delta):
	if is_moving:
		move_camera_smoothly(delta)

func move_camera_smoothly(delta: float):
	var direction = target_position - position
	if direction.length() < 5:
		position = target_position
		is_moving = false
	else:
		position += direction.normalized() * move_speed * delta
