class_name BaseState extends State

@export var animation_name: String 

var state_machine: EntityStateMachine

func init(current_entity: Entity, s_machine: EntityStateMachine):
	entity = current_entity
	state_machine = s_machine

func enter(_msg: = {}):
	entity.anim_player.play(animation_name)

func facing_left() -> bool:
	return entity.sprite.flip_h

func default_move_and_slide():
	entity.set_velocity(entity.motion)
	entity.set_up_direction(Vector2.UP)
	entity.set_floor_stop_on_slope_enabled(true)
	entity.set_max_slides(4)
	entity.set_floor_max_angle(PI/4)
	entity.move_and_slide()
	entity.motion = entity.velocity

func update():
	pass
	
