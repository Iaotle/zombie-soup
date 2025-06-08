extends HBoxContainer

@export var sep = 24

func _ready() -> void:
	add_theme_constant_override("separation", sep)
