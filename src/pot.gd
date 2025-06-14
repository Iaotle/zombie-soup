extends Area2D

@onready var sprite = $AnimatedSprite2D
var bowl = preload("res://Scenes/bowl.tscn")

var brain_broth = Recipe.new()
var eye_soup 	= Recipe.new()
var contents : Array[String] = []

var has_eye 	= false;
var has_brain 	= false;
var has_bone 	= false;
var has_ant 	= false;

signal content_added
signal food_spawned

func _ready() -> void:
	brain_broth.init_receipe("BrainBonesBroth", 5, ["brains", "bones"]);
	eye_soup.init_receipe("EyeSoup", 2, ["eye", "ant"]);
	#emit_signal("content_added");
	$CookingTimer.hide()
	sprite.play("default");

func content_check():
	print('abcd', contents)
	for i in contents:
		match i:
			"eye":
				has_eye = true
			"ant":
				has_ant = true
			"brains":
				has_brain = true
			"bones":
				has_bone = true
	if contents.size() == 2:
		contents.clear()
		if has_eye and has_ant:
			spawn_bowl("Eye and Ants Soup")
		elif has_eye and has_brain:
			spawn_bowl("Eye-Brains Coordinator Brew")
		elif has_eye and has_bone:
			spawn_bowl("Bone-Eye Balm")
		elif has_ant and has_brain:
			spawn_bowl("Ant-Brain Creepy Crawlie")
		elif has_ant and has_bone:
			spawn_bowl("Crunchy Fossil Special")
		elif has_brain and has_bone:
			spawn_bowl("Brains and Bones Broth")
		else:
			spawn_bowl("Garbage")
		has_eye = false
		has_ant = false
		has_brain = false
		has_bone = false
		return

func spawn_bowl(content : String):
	var food = bowl.instantiate()
	food.content = content
	food.get_node("CenterContainer/Label").text = content

	# Generate a strong placeholder color based on a hash of the content
	var h = hash(content)
	var r = (h >> 16) & 0xFF
	var g = (h >> 8) & 0xFF
	var b = h & 0xFF
	var color = Color8(r, g, b, 255)  # fully opaque

	food.get_node("Bowl").modulate = color
	# TODO: disable double-click on soups

	add_child(food)
	emit_signal("food_spawned")

	
func _on_food_cooked():
	content_check()
	
