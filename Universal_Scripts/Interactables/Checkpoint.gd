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
		if !checkpoint_reached:
			checkpoint_reached = true
			body.set_spawn(Vector2(position.x, position.y - 30))
			body.heal(heal_amount)
			var color_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
			color_tween.tween_property($Line2D,"default_color", enabled_color, 0.6)
			$Line2D.default_color = enabled_color
