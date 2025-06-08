extends CanvasLayer

@export var bullet : PackedScene
var bullet_count : int = 5
var label
var main_node

func _ready() -> void:
	label = $HBoxContainer/TextureRect/Label
	for node in get_tree().get_nodes_in_group("main"):
		node.organ_spawn.connect(_on_bullet_picked)
	
func update_count(i : int):
	bullet_count += i
	label.text = str(bullet_count)

func _on_bullet_picked():
	update_count(1)
