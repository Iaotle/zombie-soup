extends Node2D

@export var calm_texture: Texture2D
@export var angry_texture: Texture2D
@export var ingredient: Array[String] = []

var sprite: Sprite2D
var target_pos: Vector2
var target_window: int
var current_ingredient: String
var state: String = "idle"
var demand_timer: Timer
var angry_timer: Timer

func _ready():
	randomize()
	spawn_zombie()

func spawn_zombie():
	if sprite:
		sprite.queue_free()
	sprite = Sprite2D.new()
	sprite.texture = calm_texture
	sprite.scale = Vector2(0.13, 0.13)
	add_child(sprite)

	var screen_size = get_viewport_rect().size
	var left_side = randi() % 2 == 0
	var off_x = - sprite.texture.get_width() * sprite.scale.x if left_side else screen_size.x + sprite.texture.get_width() * sprite.scale.x
	sprite.position = Vector2(off_x, 152)

	target_window = randi() % 2 + 1
	target_pos = Vector2(147, 152) if target_window == 1 else Vector2(512, 152)
	state = "walking"
	print("Spawned zombie, target window %d" % target_window)

	if not demand_timer:
		demand_timer = Timer.new()
		demand_timer.one_shot = true
		add_child(demand_timer)
		demand_timer.connect("timeout", Callable(self, "_on_demand_timeout"))
	if not angry_timer:
		angry_timer = Timer.new()
		angry_timer.one_shot = true
		add_child(angry_timer)
		angry_timer.connect("timeout", Callable(self, "_on_angry_timeout"))

func _process(delta):
	if state == "walking":
		sprite.position = sprite.position.move_toward(target_pos, 100 * delta)
		if sprite.position.distance_to(target_pos) < 5:
			sprite.position = target_pos
			state = "waiting"
			current_ingredient = ingredient[randi() % ingredient.size()] if ingredient.size() > 0 else ""
			print("Zombie arrived at window %d, demand: %s" % [target_window, current_ingredient])
			demand_timer.start(5)

func feed_zombie():
	if state == "waiting":
		print("Fed zombie with %s" % current_ingredient)
		demand_timer.stop()
		sprite.queue_free()
		spawn_zombie()

func _on_demand_timeout():
	print("Zombie not fed, getting angry")
	become_angry()

func become_angry():
	state = "angry"
	sprite.texture = angry_texture
	sprite.scale = Vector2(0.29, 0.29)
	sprite.position = Vector2(140, 162) if target_window == 1 else Vector2(500, 162)
	print("Zombie is angry!")
	angry_timer.start(5)

func _input(event):
	if state == "angry" and event is InputEventMouseButton and event.pressed:
		if event.position.distance_to(sprite.position) < sprite.texture.get_width() * sprite.scale.x * 0.5:
			print("Zombie shot!")
			angry_timer.stop()
			sprite.queue_free()
			spawn_zombie()

func _on_angry_timeout():
	print("Zombie not shot, game over")
	game_over()

func game_over():
	var label = Label.new()
	label.text = "Game Over"
	label.modulate = Color.RED
	# label.align = Label.Align.CENTER
	# label.valign = Label.VAlign.CENTER
	var center = get_viewport_rect().size / 2
	label.position = center - (label.get_size() / 2)
	add_child(label)
