extends BaseState

@export var decel_value:float = 0.85
@export var fall_speed: int = 400
var has_hit_ground:bool = false

@onready var shoot_cd:Timer
@onready var slam_cd:Timer
@onready var charge_cd:Timer
func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	shoot_cd = s_machine.get_timer("Shoot_Cooldown")
	slam_cd = s_machine.get_timer("Crash_Cooldown")
	charge_cd = s_machine.get_timer("Charge_Cooldown")
func enter(_msg: = {}):
	super.enter(_msg)
	for i in get_tree().get_nodes_in_group(entity.name + " Projectiles"):
		i.queue_free()
	entity.connect("damaged", Callable(self, "_on_dazed_hit"))

func _on_dazed_hit(amount:int ):
	entity.health -= amount
	if is_instance_valid(entity.link_object):
		entity.link_object.damage(amount)
	entity.health_bar._on_health_updated(entity.health)
	if entity.health <= 0:
		entity.kill()

func _on_stun_over():
	shoot_cd.start()
	slam_cd.start()
	charge_cd.start()
	state_machine.transition_to("Chase")

func physics_process(delta:float):
	entity.velocity.y = fall_speed
	entity.velocity.x *= decel_value
	if grounded() and !has_hit_ground:
		has_hit_ground = true
		entity.anim_player.play("Dazed") 
	entity.move_and_slide()

func exit():
	super.exit()
	entity.disconnect("damaged", Callable(self, "_on_dazed_hit"))
	has_hit_ground = false 
	
func grounded():
	entity.ground_raycast.force_raycast_update()
	return entity.ground_raycast.is_colliding() or entity.is_on_floor()
