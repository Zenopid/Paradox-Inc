class_name PlayerBaseState extends BaseState

func input(event):
	if Input.is_action_just_pressed("jump"):
		state_machine.get_timer("Jump_Buffer").start()
	if Input.is_action_just_released("crouch"):
		state_machine.get_timer("Superjump").start()

func casting_portal() -> bool:
#	if !Input.is_action_pressed("portal_a") and !Input.is_action_pressed("portal_b"):
#		return false
#	return true
	return false

func enter_move_state():
	var move_state = "Run" if get_movement_input() != 0 else "Idle"
	state_machine.transition_to(move_state)
	return true


func get_movement_input() -> float:
	var move = Input.get_axis("left", "right")
	if move < 0:
		entity.sprite.flip_h = true
	elif move > 0:
		entity.sprite.flip_h = false
	return move

func get_inverse_movement_input(type:String ):
	var move = get_movement_input()
	if move < 0:
		if type.to_lower() == "string":
			return "right"
		else:
			return 1
	elif move > 0:
		if type.to_lower() == "string":
			return "left"
		else:
			return -1
	return ""

func enter_crouch_state():
	if Input.is_action_pressed("crouch") and grounded():
		var movestate: MoveState = state_machine.find_state("Run")
		if state_machine.get_timer("Slide_Cooldown").is_stopped():
			if get_movement_input() != 0:
				if abs(entity.motion.x) >= movestate.move_speed:
					state_machine.transition_to("Slide")
					return true
		state_machine.transition_to("Crouch")
		return true
	return false

func enter_jump_state():
	var jump_buffer:Timer = state_machine.get_timer("Jump_Buffer")
	if Input.is_action_just_pressed("jump") or !jump_buffer.is_stopped():
		if !jump_buffer.is_stopped():
			entity.motion.x *= 1 + state_machine.find_state("Fall").bunny_hop_boost
		if Input.is_action_pressed("crouch") or !state_machine.get_timer("Superjump").is_stopped():
			state_machine.transition_to("Jump", {can_superjump = true})
		else: 
			state_machine.transition_to("Jump")
		return true
	return false

func enter_dodge_state():
	if Input.is_action_just_pressed("dodge") and state_machine.get_timer("Dodge_Cooldown").is_stopped():
		state_machine.transition_to("Dodge")
		return true
	return false

func enter_portal_state():
#	if Input.is_action_just_pressed("portal_a"):
#		state_machine.transition_to("Portal", {state = state_machine.get_current_state(),portal_type = "A"})
#		return true
#	if Input.is_action_just_pressed("portal_b"):
#		state_machine.transition_to("Portal", {state = state_machine.get_current_state(), portal_type = "B"})
#		return true
	return false

func enter_attack_state():
	if Input.is_action_just_pressed("attack"):
		state_machine.transition_to("Attack")
		return true
	return false

func can_wallslide():
	var wall_checker = state_machine.get_raycast("WallChecker")
	var ground_checker = state_machine.get_raycast("GroundChecker")
	var wall_jump_timer = state_machine.get_timer("Walljump_Cooldown")
	if wall_jump_timer.is_stopped():
		if wall_checker.is_colliding():
			ground_checker.force_raycast_update()
			if !ground_checker.is_colliding():
				if wall_checker.position.x < entity.position.x:
					if get_movement_input() < 0:
						state_machine.transition_to("WallSlide")
						return true
				else:
					if get_movement_input() > 0:
						state_machine.transition_to("WallSlide")
						return true
	return false

func can_fall():
	var coyote_timer = state_machine.get_timer("Coyote")
	if !grounded() and coyote_timer.is_stopped():
		state_machine.transition_to("Fall")

func grounded():
	var ground_checker = state_machine.get_raycast("GroundChecker")
	ground_checker.force_raycast_update()
	if ground_checker.is_colliding() or entity.is_on_floor():
		return true
	return false
