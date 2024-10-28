extends BaseState


var los_shapecast:ShapeCast2D

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	los_shapecast = state_machine.get_shapecast("LOS")

func physics_process(delta):
	los_shapecast.global_position = entity.global_position
	if los_shapecast.is_colliding():
		for i in los_shapecast.get_collision_count():
			var collider = los_shapecast.get_collider(i)
			if collider is Player:
				los_shapecast.look_at(collider.global_position)
				state_machine.transition_to("Active")
				return
	
