extends ParallaxBackground

@export var scroll_speed = 100

func _process(delta):
	for layer in get_children():
		if layer is ParallaxLayer:
			for sprite in layer.get_children():
					sprite.position.x -= scroll_speed * delta * layer.motion_scale.x
					if sprite.position.x < -sprite.texture.get_width():
						sprite.position.x += sprite.texture.get_width() * 2	
