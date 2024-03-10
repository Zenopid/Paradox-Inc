extends Area2D

@export var disabled_color: Color
@export var enabled_color: Color

@export var heal_amount: int = 25

var checkpoint_reached:bool

@export var Timeline:String = "Future"

func _ready():
	$Line2D.default_color = disabled_color


func _on_body_entered(body):
	if body is Player:
		var character: Player = body
		if !checkpoint_reached:
			checkpoint_reached = true
			body.set_spawn(Vector2(position.x, position.y - 30))
			body.heal(heal_amount)
			$Line2D.default_color = enabled_color
			GlobalScript.emit_signal("update_settings")

func save():
	var save_dict = {
		"parent": get_parent().name,
		"checkpoint_reached": checkpoint_reached,
		"heal_amount": heal_amount,
		"timeline": Timeline,
		"position": {
			"x": position.x,
			"y": position.y
		}
	}
	return save_dict
