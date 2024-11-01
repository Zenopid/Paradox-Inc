extends GenericLevel

@onready var level_animator: AnimationPlayer = $AnimationPlayer
@onready var puzzle_animator:AnimationPlayer = $"%PuzzleAnimator"
@onready var future_lasers: Node2D = $"%Future_Lasers"
@onready var past_lasers:Node2D = $"%Past_Lasers"
@onready var grapple_item: Area2D = $"%Grapple"
@onready var future_door:TileMapLayer = $"%FutureDoor"
@onready var puzzle_box:MoveableObject = $"%PuzzleBox"
@onready var exit_barrier:StaticBody2D = $%"ExitBarrier"
@export var laser_damage: int = 10
@export var laser_knockback = Vector2(10, 0)
@export var hitstun: int = 3


func _ready():
	init_tutorial_prompts()
	level_animator.play("Rest")
	for nodes in get_tree().get_nodes_in_group("Past Lasers"):
		for lasers in nodes.get_children():
			var area:Area2D = lasers.get_node("Area2D")
			area.add_to_group("Past Lasers")
			area.set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, false)
			area.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, true)
			area.set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, false)
			area.set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)
	get_tree().get_first_node_in_group("Past Lasers").remove_from_group("Past Lasers")
	for nodes in get_tree().get_nodes_in_group("Future Lasers"):
		for lasers in nodes.get_children():
			var area:Area2D = lasers.get_node("Area2D")
			area.add_to_group("Future Lasers")
			area.set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, true)
			area.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, false)
			area.set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
			area.set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, false)
	get_tree().get_first_node_in_group("Future Lasers").remove_from_group("Future Lasers")
	future_door.position = Vector2(1018, -5829)
	#$"%ExitBarrier".position = Vector2(-1349, -6039)

	#_on_swapped_timeline(current_timeline)
	
	super._ready()
	
	for i in get_node("Checkpoints").get_children():
		i.connect("reached_checkpoint", Callable(self, "_on_checkpoint_reached"))
	
	for switches in get_tree().get_nodes_in_group("PuzzleSwitches"):
		switches.connect("status_changed", Callable(self, "_on_puzzle_switch_activated"))


func _on_puzzle_switch_activated(activated):
	for switches in get_tree().get_nodes_in_group("PuzzleSwitches"):
		if !switches.activated:
			exit_barrier.position = Vector2(-1088.94, -6042.67)
			return
	if is_instance_valid(exit_barrier):
		level_animator.play("RemoveBarrier")


func init_tutorial_prompts():
	var grapple_prompt_text:String = "the Left Mouse Button" if Input.get_connected_joypads() == [] else "Left Trigger Button"
	$TutorialPrompts/Grapple.text = "Press " + grapple_prompt_text + " to use the grappling hook to 
	pull yourself or other objects around." 
	var grapple_boost_prompt_text:String= "the Right Mouse Button" if Input.get_connected_joypads() == [] else "Right Trigger Button"
	$"%GrappleBoost".text = "Press " + grapple_boost_prompt_text + " to fling yourself towards your grapple target."
	
func start_level():
	super.start_level()
	current_player.change_grapple_status(false)


func _on_player_respawning():
	super._on_player_respawning()
	level_animator.play("Rest")

func _on_laser_area_entered(body:PhysicsBody2D):
	if body is Entity:
		body.damage(laser_damage, laser_knockback, hitstun)

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

func _on_platform_rotate_switch_status_changed(new_status):
	if new_status:
		level_animator.play("RotateFloor")
	else:
		level_animator.pause()


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

func _on_checkpoint_reached(checkpoint_number:int):
	level_animator.play("move_bounds_" + str(checkpoint_number))


func _on_elevator_area_body_entered(body):
	level_animator.play("MoveElevator")


func _on_puzzle_switch_1_status_changed(activated):
	if activated:
		puzzle_animator.play("RotateFuturePlatform")
	else:
		puzzle_animator.stop(true)
