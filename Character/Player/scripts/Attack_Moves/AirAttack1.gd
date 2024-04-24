extends PlayerAirStrike

@export var damage: int = 8

@export var duration: int = 4
@export var knockback_amount: int = 1
@export var object_push: Vector2 = Vector2(300, 150)

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
		var hitbox_info = {
			"position": Vector2(0.375, -2.125),
			"duration": duration,
			"damage": damage,
			"width": 48.75, 
			"height": 24.75,
			"knockback_amount": knockback_amount,
			"knockback_angle": 360,
			"attack_type": "Normal",
			"object_push": object_push,
			"hit_stop": hitstop
		}
		attack_state.create_hitbox(hitbox_info)
#	elif frame > 7 and frame < 12:
#		air_hitbox.position = Vector2(entity.position.x + 0.375, entity.position.y - 2.125)

func current_active_hitbox():
	if frame > 12: 
		return false
	return true
