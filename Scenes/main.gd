extends Node2D
# Define your enemy types here:
var ENEMY_DEFS = [
	# Add dictionaries here following the example above, e.g. skeleton, mutant, etc.
	{
		"name": "zombie",
		"calm_texture": preload("res://Sprites/zombie.png"),
		"angry_texture": preload("res://Sprites/zombie_mad.png"),
		"calm_scale": Vector2(0.13, 0.13),
		"angry_scale": Vector2(0.29, 0.29),
		"ingredients": ['eye', 'brains', 'heart'],
		"spawn_y": 152,
		"target_positions": {1: Vector2(147, 152), 2: Vector2(512, 152)},
		"angry_positions": {1: Vector2(140, 162), 2: Vector2(500, 162)},
		"angry_sound": preload("res://zombie_mad.mp3")
	},
	# same but for mutant:
	{
		"name": "mutant",
		"calm_texture": preload("res://Sprites/mutant.png"),
		"angry_texture": preload("res://Sprites/mutant_mad.png"),
		"calm_scale": Vector2(0.1, 0.1),
		"angry_scale": Vector2(0.1, 0.1),
		"ingredients": ['bones', 'ant'],
		"spawn_y": 141,
		"target_positions": {1: Vector2(147, 141), 2: Vector2(508, 141)},
		"angry_positions": {1: Vector2(140, 140), 2: Vector2(500, 140)},
		"angry_sound": preload("res://zombie_mad.mp3")
	}
]

# Tracks active enemies by window (1 or 2)
var active_enemies := {}

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
func _create_chat_bubble(enemy_sprite, ingredient_name):
	var chat_bubble = Sprite2D.new()
	chat_bubble.z_index = 1
	chat_bubble.texture = preload("res://Sprites/chat.png")
	chat_bubble.scale = Vector2(0.5, 0.5)
	chat_bubble.position = Vector2(0, 0)
	
	var ingredient_sprite = Sprite2D.new()
	ingredient_sprite.texture = load("res://Sprites/%s.png" % ingredient_name)
	# ingredient_sprite.position = chat_bubble.texture.get_size() * 0.5
	var bubble_size = chat_bubble.texture.get_size()
	var ingredient_size = ingredient_sprite.texture.get_size()
	var scale_ratio = min((bubble_size.x * 0.8) / ingredient_size.x, (bubble_size.y * 0.5) / ingredient_size.y)
	ingredient_sprite.scale = Vector2.ONE * scale_ratio
	chat_bubble.add_child(ingredient_sprite)

	enemy_sprite.add_child(chat_bubble)

func _process(delta):
	for window_id in active_enemies.keys():
		var data = active_enemies[window_id]
		var def = data["def"]
		var sprite = data["sprite"]
		match data["state"]:
			"walking":
				var target = def["target_positions"][window_id]
				sprite.position = sprite.position.move_toward(target, 100 * delta)
				if sprite.position.distance_to(target) < 5:
					sprite.position = target
					data["state"] = "waiting"
					data["current_ingredient"] = def["ingredients"][randi() % def["ingredients"].size()]
					print("%s arrived at window %d, demand: %s" % [def["name"], window_id, data["current_ingredient"]])
					# create res://Sprites/chat.png bubble, position it above the sprite. Put res://Sprites/{ingredient}.png inside it.
					_create_chat_bubble(sprite, data["current_ingredient"])
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
	sprite.texture = def["angry_texture"]
	sprite.scale = def["angry_scale"]
	sprite.position = def["angry_positions"][window_id]
	# Play angry sound
	var snd = AudioStreamPlayer2D.new()
	snd.stream = def["angry_sound"]
	add_child(snd)
	snd.play()
	print("%s is angry at window %d!" % [def["name"], window_id])
	data["angry_timer"].start(5)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and $Shotgun.picked_up:
		for window_id in active_enemies.keys():
			var data = active_enemies[window_id]
			var sprite = data["sprite"]
			if data["state"] == "angry" and event.position.distance_to(sprite.position) < sprite.texture.get_width() * sprite.scale.x * 0.5:
				$Shotgun.put_down_shotgun()
				print("%s at window %d shot!" % [data["def"]["name"], window_id])
				data["angry_timer"].stop()
				_remove_enemy(window_id)
				spawn_enemy(window_id)
				return

func _on_angry_timeout(window_id):
	print("%s at window %d not shot" % [active_enemies[window_id]["def"]["name"], window_id])
	$Player.take_damage()
	# flash screen red
	var flash = ColorRect.new()
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

func game_over():
	var label = Label.new()
	label.text = "Game Over"
	label.modulate = Color.RED
	var center = get_viewport_rect().size / 2
	label.position = center - (label.get_size() / 2)
	add_child(label)
