extends BaseStrike

@export var air_accel:int = 15



func physics_process(delta):
	if Input.is_action_just_pressed("attack"):
		if Input.is_action_pressed("crouch"):
			buffer_attack = "GroundPound"
		else:
			buffer_attack = "AirAttack2"
	entity.motion.x += air_accel * get_movement_input()
	entity.motion.x = clamp(entity.motion.x, -jump_script.max_speed, jump_script.max_speed)
	entity.motion.y += attack_state.jump_script.get_gravity() * delta 
	
	super.physics_process(delta)
	air_attack_logic()
	default_move_and_slide()
	if frame == 7:
		attack_state.create_hitbox(48.75, 24.75, 8, 1, 180, 5, "Normal", 0, Vector2(0.375, -2.125), Vector2(500, 50), 1)

func current_active_hitbox():
	if frame > 12: 
		return false
	return true