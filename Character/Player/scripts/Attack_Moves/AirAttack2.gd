extends BaseStrike

@export var air_accel:int = 15
@export var damage: int = 5

var air_hitbox_1:Hitbox
var air_hitbox_2:Hitbox

func physics_process(delta):
	var facing = -1 if entity.sprite.flip_h else 1
	if Input.is_action_just_pressed("attack"):
		if Input.is_action_pressed("crouch"):
			buffer_attack = "GroundPound"
	entity.motion.x += air_accel * get_movement_input()
	entity.motion.x = clamp(entity.motion.x, -attack_state.jump_script.max_speed, attack_state.jump_script.max_speed)
	entity.motion.y += attack_state.jump_script.get_gravity() * delta
	
	super.physics_process(delta)
	air_attack_logic()
	if frame == 4:
		air_hitbox_1 = attack_state.create_hitbox(18.4, 31.47, damage, 1, 180, 3, "Normal", 0, Vector2(15.55, 1.235), Vector2(200, -350), 1)
		air_hitbox_2 = attack_state.create_hitbox(16.45, 8.78, damage, 1, 180, 3, "Normal", 0, Vector2(0.327, -10.528), Vector2(200, -350), 1)
	elif frame > 4 and frame < 7:
		air_hitbox_1.hitbox.position = Vector2(entity.position.x + 15.55 * facing, entity.position.y + 1.235)
		air_hitbox_2.hitbox.position = Vector2(entity.position.x + 0.327 * facing, entity.position.y - 10.528)

func current_active_hitbox():
	if frame > 7:
		return false
	return true
