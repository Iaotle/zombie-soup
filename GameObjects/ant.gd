extends Sprite2D

# Speed of the ant in pixels per second
var speed := 100.0

# Current velocity vector
var velocity := Vector2.ZERO

# Size of the viewport
var screen_size := Vector2.ZERO
# Y coordinate marking the start of the lower half
var lower_y := 0.0

func _ready() -> void:
	randomize()
	# Cache the viewport size and compute the lower half boundary
	screen_size = get_viewport().get_visible_rect().size
	lower_y = screen_size.y / 2.0

	# Place the ant at a random position within the lower half
	position = Vector2(
		randf() * screen_size.x,
		lower_y + randf() * (screen_size.y - lower_y)
	)

	# Give it a random normalized direction, scaled by speed
	velocity = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized() * speed

	set_process(true)


func _process(delta: float) -> void:
	# Compute the new position
	var new_pos = position + velocity * delta

	# Bounce horizontally if it goes off-screen
	if new_pos.x < 0.0 or new_pos.x > screen_size.x:
		velocity.x = -velocity.x
		new_pos.x = clamp(new_pos.x, 0.0, screen_size.x)

	# Bounce vertically if it exits the lower-half region
	if new_pos.y < lower_y or new_pos.y > screen_size.y:
		velocity.y = -velocity.y
		new_pos.y = clamp(new_pos.y, lower_y, screen_size.y)

	position = new_pos

	# Rotate the sprite to face its velocity direction.
	# Since the texture points up by default, add PI/2.
	rotation = velocity.angle() + PI/2


func _input(event: InputEvent) -> void:
	# Detect a left‐mouse‐button click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		# Compute the sprite's rectangle in global coordinates
		var tex_size = Vector2(texture.get_width() * scale.x, texture.get_height() * scale.y)
		var top_left = global_position - (tex_size * 0.5)
		var sprite_rect = Rect2(top_left, tex_size)

		if sprite_rect.has_point(mouse_pos):
			hide()
			set_process(false)
