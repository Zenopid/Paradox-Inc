extends BaseState


var los_shapecast:ShapeCast2D

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	los_shapecast = state_machine.get_shapecast("LOS")
	

# Called when the node enters the scene tree for the first time.
func enter(_msg: = {}):
	super.enter(_msg)

func physics_process(delta):
	if los_shapecast.is_colliding():
		for i in los_shapecast.get_collision_count():
			if los_shapecast.get_collider(i) is Entity and los_shapecast.get_collider(i) is not Enemy:
				state_machine.transition_to("Active")
				return
	
