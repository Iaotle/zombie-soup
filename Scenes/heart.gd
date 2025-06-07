extends AnimatedSprite2D

func _ready() -> void:
	# Create a Timer if it doesn't exist
	if not $Timer:
		var timer = Timer.new()
		add_child(timer)
		timer.name = "Timer"
		timer.one_shot = true

	# Set a random delay between 0 and 1 second
	$Timer.wait_time = randf_range(0, 1)
	$Timer.start()

	# Connect the timeout signal to start the animation
	$Timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	# Start the "beating" animation
	play("beating")
