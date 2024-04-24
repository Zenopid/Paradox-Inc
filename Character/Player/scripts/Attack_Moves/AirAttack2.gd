extends PlayerAirStrike

@export var damage: int = 8

@export var duration: int = 4
@export var knockback_amount: int = 1
@export var object_push: Vector2 = Vector2(300, 150)



func physics_process(delta):
	if Input.is_action_just_pressed("attack"):
		if Input.is_action_pressed("crouch"):
			buffer_attack = "GroundPound"
	super.physics_process(delta)
	air_attack_logic()
	if frame == 4:
		var hitbox_info = {
			"position": Vector2(15.55, 1.235),
			"duration": duration,
			"damage": damage,
			"width": 18.4, 
			"height": 31.47,
			"knockback_amount": knockback_amount,
			"knockback_angle": 360,
			"attack_type": "Normal",
			"object_push": object_push,
			"hit_stop": hitstop
		}
		var second_hitbox_info = {
			"position":  Vector2(0.327, -10.528),
			"duration": duration,
			"damage": damage,
			"width": 16.45, 
			"height": 8.78,
			"knockback_amount": knockback_amount,
			"knockback_angle": 360,
			"attack_type": "Normal",
			"object_push": object_push,
			"hit_stop": hitstop
		}
		attack_state.create_hitbox(hitbox_info)
		attack_state.create_hitbox(second_hitbox_info)
		
		
#	elif frame > 4 and frame < 7:
#		air_hitbox_1.position = Vector2(entity.position.x + 15.55 * facing, entity.position.y + 1.235)
#		air_hitbox_2.position = Vector2(entity.position.x + 0.327 * facing, entity.position.y - 10.528)

func current_active_hitbox():
	if frame > 7:
		return false
	return true 
