class_name DarkstalkerMoveState extends BaseState

@export var behaviour_change_timer:float = 4
@onready var timer
var los_raycast: RayCast2D 

func enter(msg: = {}):
	timer = behaviour_change_timer
	super.enter()
	if facing_left():
		los_raycast.position.y = entity.position.y + 10
		los_raycast.position.x = entity.position.x -12
		los_raycast.scale.x = -1
	else:
		los_raycast.position.x = entity.position.x + 12
		los_raycast.position.y = entity.position.y + 10
		los_raycast.scale.x = 1

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	los_raycast = state_machine.get_raycast("LOS")

func physics_process(delta:float):
	timer -= delta
	if los_raycast.is_colliding():
		var object_seen = los_raycast.get_collider()
		if object_seen is Player:
			pass
#			state_machine.transition_to("Chase", {chase_target = los_raycast.get_collision_point()})
		elif object_seen is Enemy:
			pass
			# Note: add additional stuff for when it sees other enemies that arent like him
			# wait is that racist?
	elif timer <= 0:
		timer = behaviour_change_timer
		change_behaviour()

func change_behaviour():
	var rng = randi_range(1,3)
	match rng:
		1:
			state_machine.transition_to("Idle")
			return "Idle"
		2:
			state_machine.transition_to("Wander", {direction = "Left"})
			return "Wander Left"
		3: 
			state_machine.transition_to("Wander", {direction = "Right"})
			return "Wander Right"

	
