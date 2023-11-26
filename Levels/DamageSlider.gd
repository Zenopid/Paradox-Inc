extends HSlider

@export var disabled_color: Color
@export var enabled_color: Color
@onready var damage_box: OutOfBounds = get_parent().get_node("DamageBox")

var heal_player: bool 

func _ready():
	_on_value_changed(value)
	var textbox = get_parent().get_node_or_null("BoundaryText")
	if textbox:
		if heal_player == false:
			textbox.text = "Damage Box"
		else:
			textbox.text = "Heal Box"


func _on_value_changed(value):
	if heal_player:
		damage_box.damage = -value
	else:
		damage_box.damage = value
	if value == 0:
		damage_box.monitoring = false
		damage_box.set_debug_color(disabled_color)
	else:
		damage_box.monitoring = true
		damage_box.set_debug_color(enabled_color)

func _on_check_button_toggled(button_pressed):
	heal_player = button_pressed
	var textbox = get_parent().get_node_or_null("BoundaryText")
	if textbox:
		if heal_player == false:
			textbox.text = "Damage Box"
		else:
			textbox.text = "Heal Box"

