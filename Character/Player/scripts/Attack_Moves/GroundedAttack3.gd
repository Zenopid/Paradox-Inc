extends PlayerBaseStrike

@export var damage: int = 20
@export var duration: int = 4
@export var knockback_amount: int = 1
@export var object_push: Vector2 = Vector2(300, 150)

func physics_process(delta):
	super.physics_process(delta)
	if frame == 5:
		if entity.sprite.flip_h:
			entity.motion.x -= lunge_distance * ( 1 - get_movement_input() )
		else:
			entity.motion.x += lunge_distance  * ( 1 + get_movement_input() )
	if frame == 9:
		var hitbox_info = {
			"position": Vector2(17.475, 7.049),
			"duration": duration,
			"damage": damage,
			"width": 16.785, 
			"height": 21.48,
			"knockback_amount": knockback_amount,
			"knockback_angle": 360,
			"attack_type": "Normal",
			"object_push": object_push,
			"hit_stop": hitstop
		}
		attack_state.create_hitbox(hitbox_info)
