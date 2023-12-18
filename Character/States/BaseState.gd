class_name BaseState extends State

@export var animation_name: String 

var state_machine: EntityStateMachine

func init(current_entity: Entity, s_machine: EntityStateMachine):
	entity = current_entity
	state_machine = s_machine

func enter(_msg: = {}):
	entity.anim_player.play(animation_name)

func get_movement_input() -> int:
	var move = Input.get_axis("left", "right")
	if move < 0:
		entity.sprite.flip_h = true
	elif move > 0:
		entity.sprite.flip_h = false
	return move

func get_inverse_movement_input(type):
	var move = get_movement_input()
	if move < 0:
		if type == "String" or type == "string":
			return "right"
		else:
			return 1
	elif move > 0:
		if type == "String" or type == "string":
			return "left"
		else:
			return -1
	return ""

func facing_left() -> bool:
	if entity.sprite.flip_h:
		return true
	else:
		return false

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
	
func casting_portal() -> bool:
	if !Input.is_action_pressed("portal_a") and !Input.is_action_pressed("portal_b"):
		return false
	return true

func enter_move_state():
	if !casting_portal():
		var move_state = "Run" if get_movement_input() != 0 else "Idle"
		state_machine.transition_to(move_state)
		return true
	return false

func enter_crouch_state():
	if !casting_portal():
		if Input.is_action_pressed("crouch"):
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
	if Input.is_action_just_pressed("jump"):
		if state_machine.get_timer("Superjump").is_stopped():
			state_machine.transition_to("Jump")
		else:
			state_machine.transition_to("Jump", {can_superjump = true})
		return true
	return false

func enter_dodge_state():
	if Input.is_action_just_pressed("dodge") and state_machine.get_timer("Dodge_Cooldown").is_stopped():
		state_machine.transition_to("Dodge")
		return true
	return false

func enter_portal_state():
	if Input.is_action_just_pressed("portal_a"):
		state_machine.transition_to("Portal", {state = state_machine.get_current_state(),portal_type = "A"})
		return true
	if Input.is_action_just_pressed("portal_b"):
		state_machine.transition_to("Portal", {state = state_machine.get_current_state(), portal_type = "B"})
		return true
	return false

func enter_attack_state():
	if Input.is_action_just_pressed("attack"):
		state_machine.transition_to("Attack")
		return true
	return false

func can_wallslide():
	var wall_checker = state_machine.get_raycast("WallChecker")
	var ground_checker = state_machine.get_raycast("GroundChecker")
	if wall_checker.is_colliding() and !ground_checker.is_colliding() and get_movement_input() != 0:
		state_machine.transition_to("WallSlide")
		return true
	return false

func can_fall():
	var ground_checker = state_machine.get_raycast("GroundChecker")
	var coyote_timer = state_machine.get_timer("Coyote")
	
	if !ground_checker.is_colliding() and !entity.is_on_floor() and coyote_timer.is_stopped():
		state_machine.transition_to("Fall")
		return true
	return false
	
