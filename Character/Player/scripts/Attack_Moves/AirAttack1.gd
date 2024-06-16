extends PlayerAirStrike

@export var damage: int = 8

@export var duration: int = 4
@export var knockback_amount: int = 1
@export var object_push: Vector2 = Vector2(300, 150)

func physics_process(delta:float):
	if Input.is_action_just_pressed("attack"):
		if Input.is_action_pressed("crouch"):
			buffer_attack = "GroundPound"
		else:
			buffer_attack = "AirAttack2"
	super.physics_process(delta)
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
			"hit_stop": hitstop,
		}  
		attack_state.create_hitbox(hitbox_info)
		
func current_active_hitbox():
	if frame > 12: 
		return false
	return true
