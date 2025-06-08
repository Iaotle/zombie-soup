extends Node2D

var heart_list : Array[TextureRect] = [];
var health = 4;

func _ready() -> void:
	var heart_parent = $HealthBar.get_child(0);
	for child in heart_parent.get_children():
		heart_list.append(child);

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("spacebar"):
		take_damage();

func take_damage():
	if health > 0:
		health -= 1;
		update_heart();
	if health == 0:
		game_over();
		# game over here


func game_over():
	var label = Label.new()
	label.text = "Game Over"
	label.modulate = Color.RED
	var center = get_viewport_rect().size / 2
	label.position = center - (label.get_size() / 2)
	add_child(label)
	var timer = Timer.new()
	timer.wait_time = 5.0  # Set the timer to 5 seconds
	timer.one_shot = true  # Make the timer one-shot

	# Connect the timeout signal to a function
	timer.timeout.connect(_on_timer_timeout)

	# Add the timer to the scene tree and start it
	add_child(timer)
	timer.start()

func _on_timer_timeout():
	# This function will be called when the timer times out
	get_tree().paused = false
	get_tree().reload_current_scene()
		
func update_heart():
	for i in range(heart_list.size()):
		heart_list[i].visible = i < health;
		print(health);
		
