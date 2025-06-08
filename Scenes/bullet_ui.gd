extends CanvasLayer

@export var bullet : PackedScene
var bullet_count : int = 5
var label
var main_node

func _ready() -> void:
	label = $HBoxContainer/TextureRect/Label
	for node in get_tree().get_nodes_in_group("main"):
		node.bullet_spawn.connect(_on_bullet_spawned)
	update_count(0)
	
func update_count(i: int):
	bullet_count += i
	bullet_count = max(bullet_count, 0)
	print("[BULL] " ,bullet_count)
	label.text = str(bullet_count)
	
func _on_bullet_spawned():
	for node in get_tree().get_nodes_in_group("bullet"):
		node.double_clicked.connect(_on_bullet_picked)
		
func _on_bullet_picked(content):
	update_count(1)
	print("[Bullet PICKED]")
