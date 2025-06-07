extends Node2D

@export var time = 5
var mult = 100 / time
var progress_bar

var timer : Timer
signal food_cooked

func  _ready() -> void:
	timer = Timer.new()
	timer.autostart = false
	timer.one_shot = true
	timer.wait_time = time
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	progress_bar = $TextureProgressBar

func _process(delta: float) -> void:
	progress_bar.value = (time - timer.time_left) * mult

func _on_pot_content_added() -> void:
	timer.start()

func _on_timer_timeout():
	print("[CookingTimer] Done")
	emit_signal("food_cooked")
