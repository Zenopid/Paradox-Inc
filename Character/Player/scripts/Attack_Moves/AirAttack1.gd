extends PlayerAirStrike

@export var damage: int = 8

#var air_hitbox:Hitbox

func physics_process(delta:float):
	if Input.is_action_just_pressed("attack"):
		if Input.is_action_pressed("crouch"):
			buffer_attack = "GroundPound"
		else:
			buffer_attack = "AirAttack2"
#	entity.motion.x += air_accel * get_movement_input()
	super.physics_process(delta)

	air_attack_logic()
	if frame == 7:
		attack_state.create_hitbox(48.75, 24.75, damage, 1, 180, 5, "Normal", 0, Vector2(0.375, -2.125), Vector2(500, 50), 1)
#	elif frame > 7 and frame < 12:
#		air_hitbox.position = Vector2(entity.position.x + 0.375, entity.position.y - 2.125)

func current_active_hitbox():
	if frame > 12: 
		return false
	return true
