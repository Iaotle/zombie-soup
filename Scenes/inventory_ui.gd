extends CanvasLayer

@export var spawner : Node2D
signal inventory_spawn
signal ant_added
signal organ_added

var item_list : Array[Label] = []

var ants 	= Item.new();
var eyes 	= Item.new();
var brains 	= Item.new();
var bones 	= Item.new();

var ants_label
var eyes_label
var brains_label
var bones_label

func _ready() -> void:
	ants_label 		= $HBoxContainer/Ants/Label
	eyes_label 		= $HBoxContainer/Eyes/Label
	brains_label 	= $HBoxContainer/Brains/Label
	bones_label 	= $HBoxContainer/Bones/Label
	
	
	ants.init_item('ants', 0);
	eyes.init_item('eyes', 1);
	brains.init_item('brains', 1);
	bones.init_item('bones', 1);
	
	$HBoxContainer/Ants.update_amount()
	$HBoxContainer/Eyes.update_amount()
	$HBoxContainer/Brains.update_amount()
	$HBoxContainer/Bones.update_amount()
	
	ants_label.text 	= str(ants.amount);
	eyes_label.text 	= str(eyes.amount);
	brains_label.text 	= str(brains.amount);
	bones_label.text 	= str(bones.amount);
	spawner.connect("update_ant_count", _update_ant_count)
	for node in get_tree().get_nodes_in_group("main"):
		node.organ_spawn.connect(_on_main_organ_spawn)
	
func _update_ant_count(i : int):
	ants.update_amount(i);
	ants_label.text = str(ants.amount);
	emit_signal("ant_added")
	
func _on_cookable_added(obj_name) -> void:
	match obj_name:
		"Ants":
			ants.update_amount(-1);
			ants_label.text = str(ants.amount);
		"Eyes":
			eyes.update_amount(-1);
			eyes_label.text = str(eyes.amount);
		"Brains":
			brains.update_amount(-1);
			brains_label.text = str(brains.amount);
		"Bones":
			bones.update_amount(-1);
			bones_label.text = str(bones.amount);
	for node in get_tree().get_nodes_in_group("pickable"):
		node.double_clicked.connect(_on_pickable_clicked)
	emit_signal("inventory_spawn")

func _on_pickable_clicked(obj_name, position):
	print('[pot]', obj_name, position)
	
	if (position.x > 320 and position.x < 400 and position.y > 200 and position.y < 225):
		var pot = get_tree().current_scene.get_node('Pot')
		pot.contents.append(obj_name)
		print('[POT] Ingredient %s added' % obj_name)
		pot.content_check()
		return
	match obj_name:
		"ant":
			ants.update_amount(1);
			emit_signal("ant_added")
			ants_label.text = str(ants.amount);
		"eye":
			eyes.update_amount(1);
			eyes_label.text = str(eyes.amount)
			organ_added.emit()
		"brains":
			brains.update_amount(1);
			brains_label.text = str(brains.amount)
			organ_added.emit()
		"bones":
			bones.update_amount(1);
			bones_label.text = str(bones.amount)
			organ_added.emit()
	
func _on_main_organ_spawn(content) -> void:
	print("[SIG] received ", content)
	for node in get_tree().get_nodes_in_group("pickable"):
		node.double_clicked.connect(_on_pickable_clicked)
