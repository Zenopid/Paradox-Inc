class_name DarkstalkerMoveState extends BaseState

@export var behaviour_change_timer:float = 4
@onready var timer
var los_raycast: RayCast2D 
var ground_checker: RayCast2D
var vision_length: int = 250


func enter(msg: = {}):
	timer = behaviour_change_timer
	super.enter()
	var dir
	if facing_left():
		dir = -1
	else:
		dir = 1
	
func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	los_raycast = state_machine.get_raycast("LOS")
	ground_checker = state_machine.get_raycast("GroundChecker")
	ground_checker.add_exception(current_entity)
	los_raycast.add_exception(current_entity)
	
func physics_process(delta:float):
	var dir = -1 if entity.sprite.flip_h else 1
	timer -= delta
	
	if los_raycast.is_colliding():
		var object = los_raycast.get_collider()
		if object is Player:
			state_machine.transition_to("Chase")
			return
	
	if timer <= 0:
		timer = behaviour_change_timer
		change_behaviour()
	
	
func change_behaviour():
	var canChange:bool = false
	while !canChange:
		var rng = randi_range(1,3)
		match rng:
			1:
				canChange = true
				state_machine.transition_to("Idle")
				return "Idle"
			2:
				ground_checker.position.x = entity.position.x - 14
				ground_checker.force_update_transform()
				ground_checker.force_raycast_update()
				if ground_checker.is_colliding():
					canChange = true
					state_machine.transition_to("Wander", {direction = "Left"})
					return "Wander Left"
			3: 
				ground_checker.position.x = entity.position.x + 14
				ground_checker.force_update_transform()
				ground_checker.force_raycast_update()
				if ground_checker.is_colliding():
					canChange = true
					state_machine.transition_to("Wander", {direction = "Right"})
					return "Wander Right"
	
