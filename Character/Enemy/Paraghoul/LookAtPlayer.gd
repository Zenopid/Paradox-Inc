extends BaseState

var original_target_position:Vector2
var los_raycast: RayCast2D
#@export var sprite_turn_speed: int = 20
#@export var ray_turn_speed: float = 0.7
@export var chase_speed: int = 450
@onready var player: Player
@onready var nav_timer:Timer
@onready var pathfinder: NavigationAgent2D
@onready var chase_location_update_rate: float = 0.1
func init(current_entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	los_raycast = state_machine.get_raycast("LOS")
	player = get_tree().get_first_node_in_group("Players")
	nav_timer = entity.nav_timer
	nav_timer.wait_time = chase_location_update_rate
	pathfinder = entity.pathfinder
	
func enter(_msg:= {}):
	super.enter()
	original_target_position = los_raycast.target_position
	nav_timer.connect("timeout", Callable(self, "_on_nav_timer_timeout"))
	
func physics_process(delta):
	los_raycast.look_at(entity.to_local( player.global_position - entity.global_position))
	if los_raycast.is_colliding():
		state_machine.transition_to("Shoot") #{"target_position" = target_position})
		return
	var dir:Vector2 = pathfinder.get_next_path_position() - entity.global_position
	entity.motion = dir.normalized() * chase_speed
	default_move_and_slide()
#	var target_position = player.transform.origin
#	if los_raycast.is_colliding():
#		state_machine.transition_to("Shoot", {"target_position" = target_position})
#		return
#	var new_transform = entity.sprite.transform.looking_at(target_position, Vector2.UP)
#	entity.sprite.transform.interpolate_with(new_transform, sprite_turn_speed * delta)
#	var tween = get_tree().create_tween()
#	tween.tween_property(los_raycast, "target_position", target_position, ray_turn_speed)
func _on_nav_timer_timeout():
	pathfinder.target_position = player.global_positionnkjnknkjn 
