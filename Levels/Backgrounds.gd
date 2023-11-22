extends ParallaxLayer

func _ready():
	position.x = get_parent().get_parent().position.x

func _process(delta):
	motion_mirroring.x = get_viewport().get_visible_rect().size.x
