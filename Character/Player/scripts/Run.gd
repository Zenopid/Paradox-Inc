extends PlayerMoveState



func conditions_met() -> bool:
	return get_movement_input() != 0 and grounded()
