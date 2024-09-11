extends PlayerBaseStrike

@export var first_attack_damage: int = 15
@export var first_attack_push: Vector2 = Vector2(450,-100)
@export var first_attack_knockback_amount: int = 1
@export var first_attack_duration: int = 4
@export var first_attack_hitstun: int = 30




func physics_process(delta):
	super.physics_process(delta)
	if frame == 4:
		if entity.sprite.flip_h:
			entity.velocity.x -= lunge_distance * ( 1 - get_movement_input() )
		else:
			entity.velocity.x += lunge_distance * ( 1 + get_movement_input() )
	if frame == 7:
		var hitbox_info = {
		"position": Vector2(15,-0.75),
		"duration": first_attack_duration,
		"damage": first_attack_damage,
		"width": 15.75, 
		"height": 36.5,
		"knockback_amount": first_attack_knockback_amount,
		"knockback_angle": 360,
		"attack_type": "Normal",
		"object_push": first_attack_push,
		"hit_stop": hitstop,
		"hitstun": first_attack_hitstun
	}
		attack_state.create_hitbox(hitbox_info)
		
