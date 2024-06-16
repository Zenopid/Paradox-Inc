class_name PlayerBaseState extends BaseState


	
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


func grounded():
	var ground_checker = state_machine.get_raycast("GroundChecker")
	ground_checker.force_raycast_update()
	if ground_checker.is_colliding() or entity.is_on_floor():
		return true
	return false

func ground_checker_colliding():
	var ground_checker = state_machine.get_raycast("GroundChecker")
	ground_checker.force_raycast_update()
	return ground_checker.is_colliding() 
func physics_process(delta:float):
	super.physics_process(delta)
	entity = entity as Player
	
