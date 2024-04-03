extends PlayerBaseStrike

@export var dodge_cancel_frames: int = 4
@export_category("First Attack")
@export var first_attack_damage: int = 15
@export_category("Second Attack")
@export var second_attack_damage: int = 10

func physics_process(delta):
	super.physics_process(delta)
	if frame == 4:
		if entity.sprite.flip_h:
			entity.motion.x -= lunge_distance * ( 1 - get_movement_input())
		else:
			entity.motion.x += lunge_distance * ( 1 + get_movement_input() )
	if frame == 7:
		attack_state.create_hitbox(15.75, 36.5, first_attack_damage, 1, 360, 4, "Normal", 0, Vector2(15,-0.75), Vector2(450,-100), hitstop)
	if frame == 11:
		attack_state.create_hitbox(21, 13.25, second_attack_damage, 1, 90, 2, "Normal", 0, Vector2(6.5,-12), Vector2(200, -150), hitstop)
