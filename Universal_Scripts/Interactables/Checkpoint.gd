class_name Checkpoint extends Area2D

signal reached_checkpoint()

@export var checkpoint_number:int = 1
@export var disabled_color: Color
@export var enabled_color: Color

@export var heal_amount: int = 25

var checkpoint_reached:bool

@export_enum ("Future", "Past") var timeline:String = "Future"

@onready var vfx: Line2D = $Laser
var status_loaded_from_file:bool = false 

func _on_body_entered(body):
	if body is Player and !checkpoint_reached:
		checkpoint_reached = true
		body.on_checkpoint_reached(heal_amount, timeline, Vector2(position.x, position.y - 30))
		vfx.default_color = enabled_color
		GlobalScript.save_game()
		disable()

func disable():
	set_deferred("monitoring",false)
	set_deferred("monitorable", false)
	emit_signal("reached_checkpoint", checkpoint_number)
