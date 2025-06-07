extends Node2D


var heart_list : Array[TextureRect] = [];
var health = 4;

func _ready() -> void:
	var heart_parent = $HealthBar.get_child(0);
	for child in heart_parent.get_children():
		heart_list.append(child);

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("spacebar"):
		take_damage();

func take_damage():
	if health > 0:
		health -= 1;
		update_heart();
	if health == 0:
		pass;
		# game over here
		
func update_heart():
	print("heeee")
	for i in range(heart_list.size()):
		heart_list[i].visible = i < health;
		print(health);
		
