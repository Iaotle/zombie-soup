extends Area2D

@onready var sprite = $AnimatedSprite2D
var bowl = preload("res://Scenes/bowl.tscn")

var brain_broth = Recipe.new()
var eye_soup 	= Recipe.new()
var contents : Array[String] = ["Brain", "Bone"]

var has_eye 	= false;
var has_brain 	= false;
var has_bone 	= false;
var has_ant 	= false;

signal content_added
signal food_spawned

func _ready() -> void:
	brain_broth.init_receipe("BrainBonesBroth", 5, ["Brain", "Bone"]);
	eye_soup.init_receipe("EyeSoup", 2, ["Eye", "Ant"]);
	emit_signal("content_added");
	sprite.play("default");

func content_check():
	for i in contents:
		match i:
			"Eye":
				has_eye = true
			"Ant":
				has_ant = true
			"Brain":
				has_brain = true
			"Bone":
				has_bone = true
	if contents.size() == 2:
		if has_ant and has_eye:
			spawn_bowl("Eye and Ants Soup")
			return 
		elif has_brain and has_bone:
			spawn_bowl("Brains and Bones Broth")
			return
	spawn_bowl("Garbage")

func spawn_bowl(content : String):
	var food = bowl.instantiate()
	food.content = content
	add_child(food)
	emit_signal("food_spawned")
	
func _on_food_cooked():
	content_check()
	
