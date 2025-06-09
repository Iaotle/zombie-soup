extends Label

var score : int = 0
var main_node

func _ready() -> void:
	z_index = 3
	
	update_score()
	for node in get_tree().get_nodes_in_group("main"):
		main_node = node
		node.enemy_killed.connect(add)
		node.enemy_satisfied.connect(add)

func update_score():
	text = "SCORE: " + str(score)

func add(val : int):
	score += val
	update_score()

func substract(val : int):
	if (score >= val):
		score -= val
	else:
		score = 0
	update_score()

func _on_damage_taken() -> void:
	substract(15)
