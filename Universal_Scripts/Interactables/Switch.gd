class_name Switch extends Area2D

var is_on: bool = false

signal status_changed(new_status: bool)
@export_enum ("Future", "Past") var timeline:String = "Future"
@onready var level: GenericLevel
@onready var on_sprite: Sprite2D = $OnSprite
@onready var off_sprite: Sprite2D = $OffSprite

func _ready():
	level = get_tree().get_first_node_in_group("CurrentLevel")
	level.connect("swapped_timeline", Callable(self, "swap_view"))
	swap_view(level.current_timeline)
	
func _on_body_entered(body):
	is_on = true
	on_sprite.show()
	off_sprite.hide()
	emit_signal("status_changed", is_on)

func swap_view(new_timeline):
	if new_timeline != timeline:
		visible = false
		monitoring = false
	else:
		visible = true
		monitoring = true

func _on_body_exited(body):
	if monitoring:
		if !has_overlapping_bodies():
			is_on = false
			on_sprite.hide()
			off_sprite.show()
			emit_signal("status_changed", is_on)

func save():
	var save_dict = {
		"monitoring": monitoring,
		"visible": visible,
		"is_on": is_on,
		"timeline": timeline
	}
	return save_dict
