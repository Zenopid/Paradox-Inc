extends PlayerAirStrike

@export var sourspot_damage: int = 8
@export var sweetspot_damage: int = 15

@export var duration: int = 4
@export var knockback_amount: int = 1
@export var object_push: Vector2 = Vector2(300, 150)

var cleaner_sprite: AnimatedSprite2D

func init(current_entity:Entity):
	super.init(current_entity)
	cleaner_sprite = attack_state.entity.get_node("Cleaner")
	
func enter(_msg: = {}):
	super.enter()
	cleaner_sprite.show()
	cleaner_sprite.flip_h = attack_state.entity.sprite.flip_h



func physics_process(delta):
	if Input.is_action_just_pressed("attack"):
		if Input.is_action_pressed("crouch"):
			buffer_attack = "GroundPound"
	super.physics_process(delta)
	if frame == 9:
		var hitbox_info = {
			"position": Vector2(17, 2),
			"duration": duration,
			"damage": sourspot_damage,
			"width": 22, 
			"height": 30,
			"knockback_amount": knockback_amount,
			"knockback_angle": 360,
			"attack_type": "Normal",
			"object_push": object_push,
			"hit_stop": hitstop
		}
		attack_state.create_hitbox(hitbox_info)
	if frame == 13:
		var second_hitbox_info = {
			"position":  Vector2(35, -4),
			"duration": duration,
			"damage": sweetspot_damage,
			"width": 13, 
			"height": 28,
			"knockback_amount": knockback_amount,
			"knockback_angle": 360,
			"attack_type": "Normal",
			"object_push": object_push,
			"hit_stop": hitstop
		}
		attack_state.create_hitbox(second_hitbox_info)

func current_active_hitbox():
	if frame > 7:
		return false
	return true 

func exit():
	super.exit()
	cleaner_sprite.hide()
