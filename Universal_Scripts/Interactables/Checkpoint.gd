extends Area2D

signal reached_checkpoint()

@export var disabled_color: Color
@export var enabled_color: Color

@export var heal_amount: int = 25

var checkpoint_reached:bool

@export_enum("Future", "Past")var timeline:String = "Future"

@onready var vfx: Line2D = $Laser
func _ready():
	vfx.default_color = disabled_color
	

func _on_body_entered(body):
	if body is Player:
		if !checkpoint_reached:
			checkpoint_reached = true
			body.set_spawn(Vector2(position.x, position.y - 30), timeline)
			body.respawn_timeline = timeline
			body.heal(heal_amount)
			vfx.default_color = enabled_color
			GlobalScript.emit_signal("update_settings")
			set_deferred("monitoring",false)
			set_deferred("monitorable", false)
			emit_signal("reached_checkpoint")

func save():
	var save_dict = {
		"parent": get_parent().name,
		"checkpoint_reached": checkpoint_reached,
		"heal_amount": heal_amount,
		"timeline": timeline,
		"position": {
			"x": position.x,
			"y": position.y
		}
	}
	return save_dict
