extends CanvasLayer

@export var bullet : PackedScene
var bullet_count : int = 5
var label
var main_node

func _ready() -> void:
	label = $HBoxContainer/TextureRect/Label
	update_count(0)
	
func update_count(i: int):
	bullet_count += i
	bullet_count = max(bullet_count, 0)
	print("[BULL] " ,bullet_count)
	label.text = str(bullet_count)