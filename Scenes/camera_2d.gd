extends Camera2D

var y_offset = 57
var in_bar = true
var target_position: Vector2
var is_moving = false
var move_speed = 400

# store the sign's original local position
var sign_default_pos: Vector2

func _ready():
	set_process_input(true)
	sign_default_pos = $SignMouseDown.position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_down") and in_bar and not is_moving:
		in_bar = false
		$SignMouseDown.hide()           # keep it hidden
		target_position = position + Vector2(0, get_viewport_rect().size.y - y_offset)
		is_moving = true

	elif event.is_action_pressed("scroll_up") and not in_bar and not is_moving:
		in_bar = true
		# do not show the sign here
		target_position = position - Vector2(0, get_viewport_rect().size.y - y_offset)
		is_moving = true
		# only bounce if it were visible
	if $SignMouseDown.visible:
		bounce_sign()

func _process(delta):
	if is_moving:
		move_camera_smoothly(delta)

func move_camera_smoothly(delta: float):
	var direction = target_position - position
	if direction.length() < 5:
		position = target_position
		is_moving = false
		# bounce on arrival if the sign is visible
		if $SignMouseDown.visible:
			bounce_sign()
	else:
		position += direction.normalized() * move_speed * delta

func bounce_sign():
	# Godot 4 Tween-based non-linear bounce
	var tween = create_tween()
	# move up by 10px with a sine ease
	tween.tween_property(
		$SignMouseDown, "position",
		sign_default_pos - Vector2(0, 10),
		0.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# then drop back with a bounce curve
	tween.tween_property(
		$SignMouseDown, "position",
		sign_default_pos,
		0.5
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
