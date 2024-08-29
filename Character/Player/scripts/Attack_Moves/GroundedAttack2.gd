extends PlayerBaseStrike

@export var damage: int = 20
@export var duration: int = 4
@export var knockback_amount: int = 1
@export var object_push: Vector2 = Vector2(300, 150)
@export var hitstun:int = 35

var cleaner_sprite: AnimatedSprite2D

func init(current_entity:Entity):
	super.init(current_entity)
	cleaner_sprite = attack_state.entity.get_node("Cleaner")
	
func enter(_msg: = {}):
	super.enter()
	cleaner_sprite.show()
	cleaner_sprite.flip_h = attack_state.entity.sprite.flip_h

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

func exit():
	super.exit()
	cleaner_sprite.hide()
