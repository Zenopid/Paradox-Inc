extends PlayerMoveState


func conditions_met() -> bool:
	return grounded() and get_movement_input() == 0 
