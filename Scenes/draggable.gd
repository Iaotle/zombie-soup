extends TextureRect
@onready var root = $"../.."
@export var rigid_body : PackedScene
@export var amount = 0
var mouse_in : bool = false
var holding = false
var last_obj
var main_node
signal cookable_added

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("main"):
		main_node = node

func update_amount():
	match name:
		"Ants":
			amount = root.ants.amount
		"Eyes":
			amount = root.eyes.amount
		"Brains":
			amount = root.brains.amount
		"Bones":
			amount = root.bones.amount

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and mouse_in and amount > 0:
		var obj = rigid_body.instantiate()
		last_obj = obj
		main_node.set_held_object(obj)
		obj.z_index = 3
		obj.held = true
		holding = true
		add_child(obj)
		obj.reparent(main_node)
		emit_signal("cookable_added", name)
		update_amount()
	if event.is_action_released("left_click") and holding and last_obj:
		last_obj.held = false
		holding = false

func _on_mouse_entered() -> void:
	mouse_in = true

func _on_mouse_exited() -> void:
	mouse_in = false

func _on_inventory_ui_added() -> void:
	update_amount()
