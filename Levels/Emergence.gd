extends GenericLevel

@onready var elevator_animator: AnimationPlayer = $AnimationPlayer

@export var laser_damage: int = 10

func start_level():
	super.start_level()
	_on_swapped_timeline(current_timeline)
	elevator_animator.play("Rest")

func _on_area_2d_body_entered(body):
	if body is Player:
		elevator_animator.play("MoveElevator")

func _on_player_respawning():
	super._on_player_respawning()

func _on_laser_area_entered(body):
	if body is Entity:
		body.damage(laser_damage)

func _on_swapped_timeline(new_timeline):
	var timeline_name = new_timeline.to_lower()
	for nodes in get_tree().get_nodes_in_group("Laser"):
		var area: Area2D = nodes.get_node("Area2D")
		if nodes.get_parent().name.to_lower() != timeline_name:
			area.monitoring = false
		else:
			area.monitoring = true

func _on_exit_body_entered(body):
	GlobalScript.emit_signal("level_over")


func _on_platform_rotate_switch_status_changed(new_status):
	if new_status:
		elevator_animator.play("RotateFloor")
	else:
		elevator_animator.pause()
