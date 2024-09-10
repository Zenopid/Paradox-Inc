extends BaseState

const PROJECTILE_SPAWN_LOCATION = Vector2(5,5)


@export var cooldown: float = 1.2
@export var projectile: PackedScene
@export var max_shooting_range: int = 750


var shoot_cd:Timer
var target:Vector2
var player:Player

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	shoot_cd = state_machine.get_timer("ShootCD")
	shoot_cd.wait_time = cooldown
	player = get_tree().get_first_node_in_group("Players")

func enter(_msg: = {}):
	entity.velocity = Vector2.ZERO
	

func projectile_attack():
	var bullet_instance:TrooperBullet = projectile.instantiate()
	bullet_instance.projectile_owner = entity
	GlobalScript.game_node.add_child(bullet_instance)
	var points:Vector2 = entity.global_position + PROJECTILE_SPAWN_LOCATION
	var push:Vector2 = bullet_instance.object_push
	if !entity.sprite.flip_h:
		points.x = abs(points.x)
		push.x = abs(push.x)
	var proj_info: = {
		"global_position": points,
		"projectile_owner": entity,
		"timeline": entity.current_timeline
	}
	bullet_instance.set_parameters(proj_info)
	bullet_instance.call("set_" + entity.current_timeline.to_lower() +"_collision")
	state_machine.transition_to("Active")
	

func conditions_met():
	return shoot_cd.is_stopped() and entity.global_position.distance_to(player.global_position) <= max_shooting_range
	
