extends PlayerBaseStrike

@export var damage: int = 20
@export var duration: int = 4
@export var knockback_amount: int = 1
@export var object_push: Vector2 = Vector2(300, 150)
@export var hitstun:int = 35


func physics_process(delta):
	super.physics_process(delta)
	if frame == 6:
		if entity.sprite.flip_h:
			entity.velocity.x -= lunge_distance * ( 1 - get_movement_input() )
		else:
			entity.velocity.x += lunge_distance  * ( 1 + get_movement_input() )
	if frame == 9:
		var hitbox_info = {
			"position": Vector2(16.79, 4.5),
			"duration": duration,
			"damage": damage,
			"width": 14.93, 
			"height": 26,
			"knockback_amount": knockback_amount,
			"knockback_angle": 360,
			"attack_type": "Normal",
			"object_push": object_push,
			"hit_stop": hitstop
		}
		attack_state.create_hitbox(hitbox_info)
