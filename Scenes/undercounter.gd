extends Node2D

# The ant scene to instantiate
@export var ant: PackedScene

# How often (in seconds) to spawn an ant
@export var timeout: float = 1.0

# Reference to the Timer node
var spawn_timer: Timer
signal update_ant_count

func _ready() -> void:
	# Grab the Timer that should be a child of this Node2D
	spawn_timer = Timer.new();
	# Make sure the Timer is set up with our exported interval
	spawn_timer.wait_time = timeout
	spawn_timer.one_shot = false    # keep repeating
	spawn_timer.autostart = true

	# Connect the timeout signal if not already connected in the editor
	spawn_timer.timeout.connect(_on_timer_timeout)
	add_child(spawn_timer)

func _on_timer_timeout() -> void:
	# Instantiate and add the ant to the scene tree at this node’s position
	var new_ant = ant.instantiate()
	new_ant.position = global_position
	add_child(new_ant)
	new_ant.connect("ant_clicked", _update_ui)

func _update_ui():
	emit_signal("update_ant_count");
