class_name Switch extends Area2D

var is_on: bool = false

signal status_changed(new_status: bool)

@export var timeline:String = "Future"
@export var level: GenericLevel

func _ready():
	level.connect("swapped_timeline", Callable(self, "swap_view"))

func _on_body_entered(body):
	is_on = true
	$OnSprite.show()
	$OffSprite.hide()
	emit_signal("status_changed", is_on)

func swap_view(new_timeline):
	if timeline != new_timeline:
		visible = false
		monitoring = false
	else:
		visible = true 
		monitoring = true

func _on_body_exited(body):
	if !has_overlapping_bodies():
		is_on = false
		$OnSprite.hide()
		$OffSprite.show()
		emit_signal("status_changed", is_on)
