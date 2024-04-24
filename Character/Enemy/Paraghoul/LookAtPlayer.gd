extends BaseState

var original_target_position:Vector2
var los_raycast: RayCast2D
@export var sprite_turn_speed: int = 20
@export var ray_turn_speed: float = 0.7
@onready var player: Player
func init(current_entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	los_raycast = state_machine.get_raycast("LOS")
	player = get_tree().get_first_node_in_group("Players")

func enter(_msg:= {}):
	super.enter()
	original_target_position = los_raycast.target_position
	
func physics_process(delta):
	los_raycast.look_at(entity.to_local( player.global_position - entity.global_position))
	if los_raycast.is_colliding():
		state_machine.transition_to("Shoot") #{"target_position" = target_position})
		return
#	var target_position = player.transform.origin
#	if los_raycast.is_colliding():
#		state_machine.transition_to("Shoot", {"target_position" = target_position})
#		return
#	var new_transform = entity.sprite.transform.looking_at(target_position, Vector2.UP)
#	entity.sprite.transform.interpolate_with(new_transform, sprite_turn_speed * delta)
#	var tween = get_tree().create_tween()
#	tween.tween_property(los_raycast, "target_position", target_position, ray_turn_speed)
