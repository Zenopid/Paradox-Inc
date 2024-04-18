extends ActionLeaf


@export var anim_name:String = "Run"
@export var attack_damage: int = 15
@export var hitstun: int = 1
@export var knockback_amount: int = 1
@export var push_factor: Vector2 = Vector2(600, -100)
@export var lunge_speed: int = 20
@export var friction: float = 0.6
var facing: int = 0
var frame: int = 0
var attack_ended: bool
var attack_connected: bool = false

var entity: Entity 

func before_run(actor: Node, blackboard: Blackboard) -> void:
	entity = actor
	attack_ended = false
	attack_connected = false
	frame = 0
	actor.anim_player.play(anim_name)
	facing = -1 if entity.sprite.flip_h else 1
	entity.motion.x = 0
	
func on_successful_attack(object):
	if object is Entity:
		attack_connected = true 

func tick(actor: Node, _blackboard: Blackboard) -> int:
	frame += 1
	#print(frame)
	if actor.is_in_hitstun():
		#print("in hitstun")
		actor.clear_hitboxes()
		return FAILURE
		
	if frame == 27:
		#print("attack ended")
		actor.clear_hitboxes()
		return SUCCESS
		
	if frame > 16 && frame && 20:
		entity.motion.x += facing * lunge_speed
	else:
		entity.motion.x *= friction
	if frame == 19:
		actor.create_hitbox(31.745, 42.426, attack_damage, knockback_amount, 180, 3, "Normal", 1, Vector2(25.672, 4.423), push_factor, 1)
	actor.default_move_and_slide()
	return RUNNING
