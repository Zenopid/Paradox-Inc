extends GenericLevel

@onready var level_animator: AnimationPlayer = $AnimationPlayer
@onready var future_lasers: Node2D = $"%Future_Lasers"
@onready var past_lasers:Node2D = $"%Past_Lasers"
@onready var spinning_platform_1_future: = $"%Spinning_Platform"
@onready var grapple_item: Area2D = $"%Grapple"
@onready var future_door:TileMap = $"%FutureDoor"

@export var laser_damage: int = 10

func _ready():
	var grapple_prompt_text = "the Left Mouse Button" if Input.get_connected_joypads() == [] else "Left Trigger Button"
	$TutorialPrompts/Grapple.text = "Press " + grapple_prompt_text + " to use the grappling hook to 
	pull yourself or other objects around." 
	var grapple_boost_prompt_text = "the Right Mouse Button" if Input.get_connected_joypads() == [] else "Right Trigger Button"
	$"%GrappleBoost".text = "Press " + grapple_boost_prompt_text + " to fling yourself towards your grapple target."
	spinning_platform_1_future.rotation_degrees = 90
	level_animator.play("Rest")
	for nodes in get_tree().get_nodes_in_group("Past Lasers"):
		for lasers in nodes.get_children():
			lasers.get_node("Area2D").add_to_group("Past Lasers")
	get_tree().get_first_node_in_group("Past Lasers").remove_from_group("Past Lasers")
	for nodes in get_tree().get_nodes_in_group("Future Lasers"):
		for lasers in nodes.get_children():
			lasers.get_node("Area2D").add_to_group("Future Lasers")
	get_tree().get_first_node_in_group("Future Lasers").remove_from_group("Future Lasers")
	future_door.position = Vector2(1018, -5829)
	#_on_swapped_timeline(current_timeline)
	
	super._ready()

func start_level():
	super.start_level()
	current_player.change_grapple_status(false)

func _on_area_2d_body_entered(body):
	if body is Player:
		level_animator.play("MoveElevator")

func _on_player_respawning():
	super._on_player_respawning()
	level_animator.play("Rest")

func _on_laser_area_entered(body):
	if body is Entity:
		body.damage(laser_damage)

func _on_swapped_timeline(new_timeline:String):
	#super._on_swapped_timeline(new_timeline)
	for nodes in get_tree().get_nodes_in_group(new_timeline.capitalize() + " Lasers"):
		nodes.set_deferred("monitoring", true)
		nodes.set_deferred("monitorable",true)
	for nodes in get_tree().get_nodes_in_group(get_next_timeline_swap() + " Lasers"):
		nodes.set_deferred("monitoring",false)
		nodes.set_deferred("monitorable",false)
	get(new_timeline.to_lower() + "_lasers").show()
	get(get_next_timeline_swap().to_lower() + "_lasers").hide()

func _on_exit_body_entered(body):
	GlobalScript.emit_signal("level_over")

func _on_platform_rotate_switch_status_changed(new_status):
	if new_status:
		level_animator.play("RotateFloor")
	else:
		level_animator.pause()

func _on_checkpoint_reached_checkpoint():
	level_animator.play("move_bounds_1")

func _on_checkpoint_2_reached_checkpoint():
	level_animator.play("move_bounds_2")

func _on_checkpoint_3_reached_checkpoint():
	level_animator.play("move_bounds_3")

func _on_checkpoint_4_reached_checkpoint():
	level_animator.play("move_bounds_4")


func _on_laser_switch_past_1_status_changed(new_status):
	for lasers in get_tree().get_nodes_in_group("Laser_Switch_Past_1"):
		var laser:Area2D = lasers.get_node("Area2D")
		laser.set_deferred("monitoring", !new_status)
		laser.set_deferred("monitorable", !new_status)
		lasers.set_deferred("visible", !new_status)

func _on_grapple_body_entered(body):
	if body is Player:
		body.change_grapple_status(true)
		grapple_item.queue_free()

func _on_door_switch_status_changed(activated):
	if activated:
		level_animator.play("MoveDoor")


func _on_checkpoint_5_reached_checkpoint():
	level_animator.play("move_bounds_5")
