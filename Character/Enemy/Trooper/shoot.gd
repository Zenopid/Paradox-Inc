extends BaseState

const PROJECTILE_SPAWN_LOCATION = Vector2(55, -15)


@export var cooldown: float = 1.2
@export var projectile: PackedScene
@export var max_shooting_range: int = 750

@onready var los_shapecast:ShapeCast2D

var shoot_cd:Timer
var target:Vector2
var player:Player

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	shoot_cd = state_machine.get_timer("ShootCD")
	shoot_cd.wait_time = cooldown
	los_shapecast = state_machine.get_shapecast("LOS")

func enter(msg: = {}):
	target = msg["target_location"]
	super.enter()
	entity.velocity = Vector2.ZERO
	entity.sprite.flip_h = entity.global_position > target

func projectile_attack():
	var bullet_instance:TrooperBullet = projectile.instantiate()
	GlobalScript.game_node.add_child(bullet_instance)
	var points:Vector2 = entity.global_position + PROJECTILE_SPAWN_LOCATION
	var push:Vector2 = bullet_instance.object_push
	if entity.sprite.flip_h:
		points.x = abs(points.x) * -1
		push.x = abs(push.x) * -1
	var proj_info: = {
		"global_position": points,
		"projectile_owner": entity,
		"timeline": entity.current_timeline,
		"direction": entity.global_position.direction_to(target)
	}
	bullet_instance.set_parameters(proj_info)
	bullet_instance.call("set_" + entity.current_timeline.to_lower() + "_collision")
	print("Trooper bullet parameters:")
	print("---------------------------------")
	for i in  proj_info.keys():
		print(str(i) + ": " + str(proj_info[i]))
	print(bullet_instance.name)

func leave_state():
	state_machine.transition_to("Active")
	shoot_cd.start()
	
func conditions_met():
	for i in los_shapecast.get_collision_count():
		var collider = los_shapecast.get_collider(i)
		if collider is Player:
			return shoot_cd.is_stopped() and entity.global_position.distance_to(collider.global_position) <= max_shooting_range
	
