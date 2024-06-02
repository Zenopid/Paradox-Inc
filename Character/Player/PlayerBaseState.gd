class_name PlayerBaseState extends BaseState


func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	
func input(event):
	entity = entity as Player
	if Input.is_action_just_pressed("jump"):
		state_machine.get_timer("Jump_Buffer").start()
	if Input.is_action_just_released("crouch"):
		state_machine.get_timer("Superjump").start()
	if Input.is_action_just_pressed("dodge"):
		state_machine.get_timer("Dodge_Buffer").start()
	if Input.is_action_just_pressed("attack"):
		state_machine.get_timer("Attack_Buffer").start()

func enter_move_state():
	state_machine.transition_to("Run") if get_movement_input() != 0 else state_machine.transition_to("Idle")
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
		var movestate: PlayerMoveState = state_machine.find_state("Run")
		if state_machine.get_timer("Slide_Cooldown").is_stopped():
			if get_movement_input() != 0:
				if abs(entity.velocity.x) >= movestate.move_speed:
					state_machine.transition_to("Slide")
					return true
		state_machine.transition_to("Crouch")
		return true
	return false

func enter_jump_state():
	var jump_buffer:Timer = state_machine.get_timer("Jump_Buffer")
	if Input.is_action_just_pressed("jump") or !jump_buffer.is_stopped():
		if !grounded() and state_machine.find_state("Jump").get_jumps() <= 0:
			return
		if !jump_buffer.is_stopped():
			entity.velocity.x *= 1 + state_machine.find_state("Fall").bunny_hop_boost
		if Input.is_action_pressed("crouch") or !state_machine.get_timer("Superjump").is_stopped():
			state_machine.transition_to("Jump", {can_superjump = true})
		else: 
			state_machine.transition_to("Jump")
		return true
	return false

func enter_dodge_state():
	if !state_machine.get_timer("Dodge_Buffer") or Input.is_action_just_pressed("dodge"):
		if state_machine.get_timer("Dodge_Cooldown").is_stopped():
			state_machine.transition_to("Dodge")
			return true
	return false

func can_wallslide(current_speed: float = 0):
	var wall_checker = state_machine.get_shapecast("WallScanner")
	var ground_checker = state_machine.get_raycast("GroundChecker")
	if wall_checker.is_colliding():
		ground_checker.force_raycast_update()
		if !ground_checker.is_colliding():
			if wall_checker.position.x < entity.position.x and get_movement_input() < 0:
				state_machine.transition_to("WallSlide", {previous_speed = current_speed})
				return true
			elif wall_checker.position.x > entity.position.x and get_movement_input() > 0:
				state_machine.transition_to("WallSlide", {previous_speed = current_speed})
				return true
	return false


func grounded():
	var ground_checker = state_machine.get_raycast("GroundChecker")
	ground_checker.force_raycast_update()
	if ground_checker.is_colliding() or entity.is_on_floor():
		return true
	return false

func physics_process(delta:float):
	super.physics_process(delta)
	entity = entity as Player
	
