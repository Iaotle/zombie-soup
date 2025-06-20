extends Node2D

@export var bullet: PackedScene
@export var eye: PackedScene
@export var brains: PackedScene
@export var bones: PackedScene
@export var ant: PackedScene
signal organ_spawn
signal enemy_killed
signal enemy_satisfied
var SOUP_DEFS = ['[soup] Eye and Ants Soup', '[soup] Eye-Brains Coordinator Brew', '[soup] Bone-Eye Balm [bones eye]', '[soup] Ant-Brain Creepy Crawlie [brains]', '[soup] Crunchy Fossil Special [ant bones]', '[soup] Brains and Bones Broth']


# Define your enemy types here:
var ENEMY_DEFS = [
	# Add dictionaries here following the example above, e.g. skeleton, mutant, etc.
	 {
		"name": "zombie",
		"calm_texture": preload("res://Sprites/zombie.png"),
		"angry_texture": preload("res://Sprites/zombie_mad.png"),
		"calm_scale": Vector2(0.13, 0.13),
		"angry_scale": Vector2(0.139, 0.139),
		"ingredients": ['eye', 'brains'],
		"on_kill": ['eye', 'bones'],
		"spawn_y": 142,
		"target_positions": {1: Vector2(144, 142), 2: Vector2(498, 142)},
		"angry_positions": {1: Vector2(133, 161), 2: Vector2(509, 161)},
		"angry_sound": preload("res://zombie_mad.mp3"),
	 },
	{
		"name": "mutant",
		"calm_texture": preload("res://Sprites/mutant.png"),
		"angry_texture": preload("res://Sprites/mutant_mad.png"),
		"calm_scale": Vector2(0.1, 0.1),
		"angry_scale": Vector2(0.1, 0.1),
		"ingredients": ['bones', 'ant', 'eye'],
		"on_kill": ['eye', 'brains'],
		"spawn_y": 136,
		"target_positions": {1: Vector2(135, 136), 2: Vector2(518, 136)},
		"angry_positions": {1: Vector2(146, 133), 2: Vector2(512, 133)},
		"angry_sound": preload("res://mutant_mad.mp3"),
	},
	{
		"name": "snake",
		"calm_texture": preload("res://Sprites/snake.png"),
		"angry_texture": preload("res://Sprites/snake_mad.png"),
		"calm_scale": Vector2(0.1, 0.1),
		"angry_scale": Vector2(0.1, 0.1),
		"ingredients": ['eye', 'bones'],
		"on_kill": ['eye', 'brains'],
		"spawn_y": 158,
		"target_positions": {1: Vector2(135, 158), 2: Vector2(515, 158)},
		"angry_positions": {1: Vector2(127, 158), 2: Vector2(519, 158)},
		"angry_sound": preload("res://snake_mad.mp3")
	},
	{
		"name": "dog",
		"calm_texture": preload("res://Sprites/dog.png"),
		"angry_texture": preload("res://Sprites/dog_mad.png"),
		"calm_scale": Vector2(0.1, 0.1),
		"angry_scale": Vector2(0.117, 0.117),
		"ingredients": ['bones'],
		"on_kill": ['eye', 'brains'],
		"spawn_y": 158,
		"target_positions": {1: Vector2(128, 158), 2: Vector2(524, 158)},
		"angry_positions": {1: Vector2(143, 150), 2: Vector2(506, 149)},
		"angry_sound": preload("res://dog_mad.mp3")
	},
	{
		"name": "scorpion",
		"calm_texture": preload("res://Sprites/scorpion_ugly.png"),
		"angry_texture": preload("res://Sprites/scorpion_mad.png"),
		"calm_scale": Vector2(0.121, 0.121),
		"angry_scale": Vector2(0.114, 0.114),
		"ingredients": ['eye'],
		"on_kill": ['eye', 'bones', 'ant'],
		"spawn_y": 148,
		"target_positions": {1: Vector2(129, 148), 2: Vector2(522, 148)},
		"angry_positions": {1: Vector2(136, 151), 2: Vector2(507, 151)},
		"angry_sound": preload("res://zombie_mad.mp3")
	},
	{
		"name": "yeti",
		"calm_texture": preload("res://Sprites/yeti.png"),
		"angry_texture": preload("res://Sprites/yeti_mad.png"),
		"calm_scale": Vector2(0.1, 0.1),
		"angry_scale": Vector2(0.1, 0.1),
		"ingredients": ['bones', 'brains', 'eye', 'ant'],
		"on_kill": ['brains', 'bones'],
		"spawn_y": 133,
		"target_positions": {1: Vector2(126, 133), 2: Vector2(525, 133)},
		"angry_positions": {1: Vector2(131, 133), 2: Vector2(514, 133)},
		"angry_sound": preload("res://yeti_mad.mp3")
	}
]

# TODO: throw or move bullets etc into the part of the screen where the UI is

var active_bubbles := {}
# Tracks active enemies by window (1 or 2)
var active_enemies := {}
#drag and drop mechanic
var held_object = null

func set_held_object(obj: RigidBody2D):
	held_object = obj
	print(held_object)

func _ready():
	randomize()
	# Spawn one enemy in window 1 immediately.
	spawn_enemy(1)
	# Delay spawn for window 2.
	var spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	add_child(spawn_timer)
	spawn_timer.connect("timeout", Callable(self, "_on_delayed_spawn"))
	spawn_timer.start(5)

func _on_pickable_clicked(object):
	if !held_object:
		object.pickup()
		held_object = object

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if held_object and !event.pressed:
			held_object.drop(Input.get_last_mouse_velocity())
			held_object = null

func update_pickables() -> void:
	for node in get_tree().get_nodes_in_group("pickable"):
		node.clicked.connect(_on_pickable_clicked)

func _on_pot_food_spawned() -> void:
	update_pickables()

func _on_drop_area_1_mouse_entered() -> void:
	if held_object:
		print("[AREA 1]: ", held_object.content)
		if active_enemies[1] and active_enemies[1].state != "angry":
			if active_enemies[1].current_ingredient == held_object.content or held_object.content.to_lower().contains(active_enemies[1].current_ingredient):
				satisfied(1, true if held_object.content.contains('[soup]') else false)
			else:
				_become_angry(1)
	if $Shotgun.picked_up:
		_become_angry(1)

func _on_drop_area_2_mouse_entered() -> void:
	if held_object:
		print("[AREA 2]: ", held_object.content)
		if active_enemies.size() == 2 and active_enemies[2] and active_enemies[2].state != "angry":
			if active_enemies[2].current_ingredient == held_object.content or held_object.content.to_lower().contains(active_enemies[2].current_ingredient):
				satisfied(2, true if held_object.content.contains('[soup]') else false)
			else:
				_become_angry(2)
	if $Shotgun.picked_up:
		_become_angry(2)

func satisfied(index: int, soup: bool = false):
	print('satisfied with soup: ', soup)
	_remove_enemy(index);
	spawn_enemy(index)
	enemy_satisfied.emit(100 if soup else 10)
	for i in range(0, held_object.bullet_price):
		var temp = bullet.instantiate()
		temp.z_index = 3
		temp.position = Vector2(100, 100)
		add_child(temp)
	update_pickables();
	held_object.queue_free();
	
func spawn_organs(window_id: int):
	var enemy = active_enemies[window_id]["def"]
	var data = enemy["on_kill"]
	for i in data:
		var temp # Random upward force between 50 and 200
		match i:
			"eye":
				temp = eye.instantiate()
			"brains":
				temp = brains.instantiate()
			"bones":
				temp = bones.instantiate()
			"ant":
				temp = ant.instantiate()
		if (window_id == 1):
			temp.position = Vector2(130, 150);
		else:
			temp.position = Vector2(520, 150);
		# apply a vector with a somewhat random upwards direction
		# how far from straight up (in degrees) you’re willing to stray
		var max_degrees = 20
		var max_radians = deg_to_rad(max_degrees)
		
		# pick a random angle between –max and +max
		var random_angle = randf_range(-max_radians, max_radians)
		
		# rotate the UP vector by that angle, then scale it
		var strength = 500.63
		var vector = Vector2.UP.rotated(random_angle) * strength
		temp.apply_central_impulse(vector)
		temp.z_index = 3;
		add_child(temp);
		organ_spawn.emit(temp.content)
	update_pickables()

func _on_delayed_spawn():
	spawn_enemy(2)

func spawn_enemy(window_id):
	if active_enemies.has(window_id):
		return
	if ENEMY_DEFS.is_empty():
		push_error("No enemy definitions found!")
		return
	var def = ENEMY_DEFS[randi() % ENEMY_DEFS.size()]
	# Create and configure sprite
	var sprite = Sprite2D.new()
	if window_id == 2:
		sprite.flip_h = true
	sprite.add_to_group("enemies")
	sprite.z_index = -1;
	sprite.texture = def["calm_texture"]
	sprite.scale = def["calm_scale"]
	# Determine off-screen spawn X
	var screen_size = get_viewport_rect().size
	var off_x = - sprite.texture.get_width() * sprite.scale.x if window_id == 1 else screen_size.x + sprite.texture.get_width() * sprite.scale.x
	sprite.position = Vector2(off_x, def["spawn_y"])
	add_child(sprite)
	# Create timers
	var demand_timer = Timer.new()
	demand_timer.one_shot = true
	add_child(demand_timer)
	demand_timer.connect("timeout", Callable(self, "_on_demand_timeout").bind(window_id))
	var angry_timer = Timer.new()
	angry_timer.one_shot = true
	add_child(angry_timer)
	angry_timer.connect("timeout", Callable(self, "_on_angry_timeout").bind(window_id))
	# Store enemy data
	active_enemies[window_id] = {
		"def": def,
		"sprite": sprite,
		"state": "walking",
		"demand_timer": demand_timer,
		"angry_timer": angry_timer,
		"current_ingredient": ""
	}
	print("Spawned %s in window %d" % [def["name"], window_id])
# TODO: make shotty shoot out the bottles
# TODO: put a glow on the lightbulb
# TODO: bullets should spawn in correct window
func _create_chat_bubble(ingredient_name: String, window_id: int):
	var chat_bubble = Sprite2D.new()
	chat_bubble.z_index = 3
	chat_bubble.texture = preload("res://Sprites/chat.png")
	chat_bubble.scale = Vector2(0.1, 0.1)
	chat_bubble.position = Vector2(0, 0)
	chat_bubble.position = Vector2(230, 90) if window_id == 1 else Vector2(416, 98)
	if window_id == 2:
		chat_bubble.flip_h = true;
	
	var ingredient_sprite = Sprite2D.new()
	ingredient_sprite.texture = load("res://Sprites/%s.png" % ingredient_name)
	var bubble_size = chat_bubble.texture.get_size()
	var ingredient_size = ingredient_sprite.texture.get_size()
	var scale_ratio = min((bubble_size.x * 0.8) / ingredient_size.x, (bubble_size.y * 0.5) / ingredient_size.y)
	ingredient_sprite.scale = Vector2.ONE * scale_ratio
	# the chat bubble has a tail, which means we need to position the ingredient sprite slightly above the center of the bubble
	ingredient_sprite.translate(Vector2(0, -50))
	chat_bubble.add_child(ingredient_sprite)

	# get root:
	var root = get_tree().get_root()

	root.add_child(chat_bubble)
	active_bubbles[window_id] = chat_bubble

func _process(delta):
	for window_id in active_enemies.keys():
		var data = active_enemies[window_id]
		var def = data["def"]
		var sprite = data["sprite"]
		match data["state"]:
			"walking":
				var target = def["target_positions"][window_id]
				sprite.position = sprite.position.move_toward(target, 100 * delta)
				if sprite.position.distance_to(target) < 2:
					sprite.position = target
					data["state"] = "waiting"
					data["current_ingredient"] = def["ingredients"][randi() % def["ingredients"].size()]

					# Play brain sound if this is a zombie demanding brains
					if def["name"] == "zombie" and data["current_ingredient"] == "brains":
						var brain_sound = AudioStreamPlayer2D.new()
						brain_sound.stream = preload("res://brain.mp3")
						brain_sound.position = sprite.position
						add_child(brain_sound)
						brain_sound.play()
						brain_sound.connect('finished', brain_sound.queue_free)

					print("%s arrived at window %d, demand: %s" % [def["name"], window_id, data["current_ingredient"]])
					_create_chat_bubble(data["current_ingredient"], window_id)
					sprite.z_index = 0
					data["demand_timer"].start(5)
			"angry":
				pass

func feed_enemy(window_id):
	if not active_enemies.has(window_id):
		return
	var data = active_enemies[window_id]
	if data["state"] == "waiting":
		print("Fed %s with %s" % [data["def"]["name"], data["current_ingredient"]])
		data["demand_timer"].stop()
		_remove_enemy(window_id)
		spawn_enemy(window_id)

func _on_demand_timeout(window_id):
	var data = active_enemies[window_id]
	print("%s at window %d not fed, getting angry" % [data["def"]["name"], window_id])
	_become_angry(window_id)

func _become_angry(window_id):
	var data = active_enemies[window_id]
	data["state"] = "angry"
	var def = data["def"]
	var sprite = data["sprite"]
	if window_id == 2:
		sprite.flip_h = true
	sprite.texture = def["angry_texture"]
	sprite.scale = def["angry_scale"]
	sprite.position = def["angry_positions"][window_id]
	# Play angry sound with stereo panning
	var snd = AudioStreamPlayer2D.new()
	snd.stream = def["angry_sound"]
	var screen_size = get_viewport_rect().size
	# 0.3 * width for left, 0.7 * width for right
	snd.position.x = screen_size.x * (0 if window_id == 1 else 1)
	snd.position.y = screen_size.y / 2
	add_child(snd)
	snd.play()
	snd.connect('finished', snd.queue_free)
	print("%s is angry at window %d!" % [def["name"], window_id])
	data["angry_timer"].start(5)
	if active_bubbles.has(window_id):
		active_bubbles[window_id].queue_free()
		active_bubbles.erase(window_id)


func _input(event):
	# TODO: ctrl+s to mute/unmute sound effects
	if event.is_action_pressed("toggle_music"):
		var music_player = get_tree().current_scene.get_node("Music")
		if music_player:
			music_player.playing = !music_player.playing
		print("Music toggled: %s" % music_player.playing)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and $Shotgun.picked_up:
		for window_id in active_enemies.keys():
			var data = active_enemies[window_id]
			var sprite = data["sprite"]
			if data["state"] == "angry" and event.position.distance_to(sprite.position) < sprite.texture.get_width() * sprite.scale.x * 0.5:
				var bullets = $Player/bullet_ui.bullet_count
				if bullets == 0:
					print("No bullets left!")
					$Shotgun.empty = true
					# play sound for no bullets
					var trigger_click = AudioStreamPlayer.new()
					trigger_click.stream = preload("res://gun_empty.mp3")
					get_tree().current_scene.add_child(trigger_click)
					trigger_click.play()
					trigger_click.connect("finished", trigger_click.queue_free)
					return
				else:
					$Shotgun.empty = false
				$Player/bullet_ui.update_count(-1)
				enemy_killed.emit(5)
				$Shotgun.put_down_shotgun()
				print("%s at window %d shot!" % [data["def"]["name"], window_id])
				data["angry_timer"].stop()
				spawn_organs(window_id)
				_remove_enemy(window_id)
				spawn_enemy(window_id)
				$Shotgun._fire_shotgun()
				return

func _on_angry_timeout(window_id):
	print("%s at window %d not shot" % [active_enemies[window_id]["def"]["name"], window_id])
	$Player.take_damage()
	# flash screen red
	var flash = ColorRect.new()
	flash.z_index = 1000
	flash.color = Color(1, 0, 0, 0.5)
	flash.size = get_viewport_rect().size
	flash.position = Vector2.ZERO
	add_child(flash)
	# Fade out the flash using Tween
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.5)
	tween.connect("finished", Callable(flash, "queue_free"))
	# remove enemy
	_remove_enemy(window_id)
	spawn_enemy(window_id)

func _remove_enemy(window_id):
	var data = active_enemies[window_id]
	data["sprite"].queue_free()
	data["demand_timer"].queue_free()
	data["angry_timer"].queue_free()
	active_enemies.erase(window_id)
	if active_bubbles.has(window_id):
		active_bubbles[window_id].queue_free()
		active_bubbles.erase(window_id)
