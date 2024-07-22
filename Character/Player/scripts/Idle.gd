extends PlayerMoveState

var cleaner_sprite:AnimatedSprite2D

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	cleaner_sprite = entity.get_node("Cleaner")
	
func enter(msg: = {}):
	cleaner_sprite.show()
	cleaner_sprite.flip_h = entity.sprite.flip_h
	super.enter(msg)

func conditions_met() -> bool:
	return grounded() and get_movement_input() == 0 

func exit():
	entity.get_node("Cleaner").hide()
	super.exit()
