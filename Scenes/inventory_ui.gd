extends CanvasLayer

@export var spawer : PackedScene

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
	ants.init_item('ants', 15);
	eyes.init_item('eyes', 0);
	brains.init_item('brains', 0);
	bones.init_item('bones', 13);
	
	ants_label.text 	= str(ants.amount);
	eyes_label.text 	= str(eyes.amount);
	brains_label.text 	= str(brains.amount);
	bones_label.text 	= str(bones.amount);
	
