extends HSlider

@export var disabled_color: Color
@export var enabled_color: Color
@onready var damage_box: OutOfBounds = get_parent().get_node("Area2D")

func _on_value_changed(value):
	damage_box.damage = value
	if value == 0:
		damage_box.monitoring = false
		damage_box.set_debug_color(disabled_color)
	else:
		damage_box.monitoring = true
		damage_box.set_debug_color(enabled_color)
