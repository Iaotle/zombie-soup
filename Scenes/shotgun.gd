extends Sprite2D

@export var pov_sprite_path: String = "res://Sprites/shotgun-pov.png"
@export var reload_sound_path: String = "res://reload.mp3"
@export var fire_sounds: Array[String] = ["res://shotgun-fire-1.mp3", "res://shotgun-fire-2.mp3"]
@export var camera: Camera2D

var picked_up := false
var pov_sprite: Sprite2D
var crosshair = preload("res://Sprites/crosshair.png")
var empty = false

func _ready():
	set_process_input(true)


func _input(event):
	if !camera.in_bar:
		put_down_shotgun()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not picked_up and is_pixel_opaque(get_local_mouse_position()) and camera.in_bar:
			_pickup_shotgun()
		# elif picked_up:
		# 	# TODO: detect if the click is on an object in group 'enemies'
		# 	_fire_shotgun()
	# TODO: put down if left click on shotgun
	# also if right click, put down shotgun
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if picked_up:
			put_down_shotgun()
	# TODO: maybe make items not pickable
	# TODO: shoot ants with shotgun, kills all the ants instantly (or an area) (also fix the sprite) (crosshair becomes bigger etc)

func put_down_shotgun():
	if picked_up:
		pov_sprite.queue_free()
		picked_up = false
		visible = true
		Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
		print("Shotgun put down")

func _pickup_shotgun():
	picked_up = true
	visible = false
	# change the crosshair to res://Sprites/crosshair.png, offset by 24px
	Input.set_custom_mouse_cursor(crosshair, Input.CURSOR_ARROW, Vector2(24, 24))

	pov_sprite = Sprite2D.new()
	pov_sprite.z_index = 4
	pov_sprite.texture = load(pov_sprite_path)
	pov_sprite.scale = Vector2(0.3, 0.3) # Adjust scale as needed
	var viewport_size = get_viewport().get_visible_rect().size
	pov_sprite.position = Vector2(viewport_size.x / 2, viewport_size.y - 100)
	get_tree().current_scene.add_child(pov_sprite)
	if !empty:
		var reload_audio = AudioStreamPlayer.new()
		reload_audio.stream = load(reload_sound_path)
		get_tree().current_scene.add_child(reload_audio)
		reload_audio.play()
		reload_audio.connect('finished', reload_audio.queue_free)
func _fire_shotgun():
	var fire_audio = AudioStreamPlayer.new()
	var sound_path = fire_sounds[randi() % fire_sounds.size()]
	fire_audio.stream = load(sound_path)
	get_tree().current_scene.add_child(fire_audio)
	fire_audio.play()
	fire_audio.connect("finished", fire_audio.queue_free)
	var shell_audio = AudioStreamPlayer.new()
	shell_audio.stream = preload('res://shell_drop.mp3')
	get_tree().current_scene.add_child(shell_audio)
	shell_audio.connect("finished", shell_audio.queue_free)

	var start: float = randf_range(0, 1.8)
	shell_audio.play(start)
