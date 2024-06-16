extends BaseState

const PROJECTILE_SPAWN_LOCATION:Vector2 = Vector2(50, 20)


@export var crash_range: int = 450
@export var cooldown: float = 2.5
@export var crash_speed: int = 500

@export var minimum_crash_height:int = 250
@export_category("Packed Scenes")
@export var shockwave: PackedScene
@export var hitbox: PackedScene
@export var startup_frames:int = 24
@export var max_crash_time: float = 2.5

@onready var cd_timer: Timer 
@onready var ground_checker: RayCast2D
@onready var frame_tracker: int = 0
@onready var max_crash_timer:Timer 

var has_hit_ground:bool = false

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	cd_timer = state_machine.get_timer("Crash_Cooldown")
	cd_timer.wait_time = cooldown
	ground_checker = state_machine.get_raycast("GroundChecker")
	max_crash_timer = state_machine.get_timer("Max_Crash_Duration")
	max_crash_timer.wait_time = max_crash_time
	
	
func enter (_msg: = {}):
	super.enter(_msg)
	frame_tracker = 0
	has_hit_ground = false
	entity.set_collision_mask_value(GlobalScript.collision_values.PROJECTILE_FUTURE, false)
	entity.set_collision_mask_value(GlobalScript.collision_values.PROJECTILE_PAST, false)
	entity.set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, false)
	entity.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, false)
	max_crash_timer.start()
	#proj invlv during ground pound
	
func _on_ground_pound_interrupt(amount: int ):
	state_machine.transition_to("Dazed")
	
func physics_process(delta:float):
	if max_crash_timer.is_stopped():
		state_machine.transition_to("Chase")
		return
	frame_tracker += 1
	if frame_tracker > startup_frames:
		entity.velocity  = Vector2(0, crash_speed)
	ground_checker.global_position = Vector2(entity.global_position.x, entity.global_position.y + 30)
	entity.move_and_slide()
	if grounded() and !has_hit_ground:
		entity.connect("damaged", Callable(self, "_on_ground_pound_interrupt"))
		emit_shockwave()

func emit_shockwave():
	has_hit_ground = true 
	entity = entity as ParaGhoul
	entity.anim_player.play("CrashLand")
	var shockwave_left:Shockwave = shockwave.instantiate()
	var shockwave_right:Shockwave = shockwave.instantiate()
	shockwave_left = shockwave_left as Shockwave
	shockwave_right = shockwave_right as Shockwave
	var points:Vector2 = Vector2(entity.global_position.x, entity.global_position.y + PROJECTILE_SPAWN_LOCATION.y)
	GlobalScript.game_node.add_child(shockwave_left)
	GlobalScript.game_node.add_child(shockwave_right)
	var left_shockwave_info: = {
		"global_position": Vector2(points.x + (-PROJECTILE_SPAWN_LOCATION.x), points.y),
		"projectile_owner": entity,
		"direction": Vector2(-1, 0)
		
	} 
	var right_shockwave_info: = {
		"global_position": Vector2(points.x + PROJECTILE_SPAWN_LOCATION.x, points.y),
		"projectile_owner": entity,
		"direction": Vector2(1, 0),
	}
	
	shockwave_left.set_parameters(left_shockwave_info)
	shockwave_right.set_parameters(right_shockwave_info)
	if entity.anim_player.get_current_animation() == "CrashLand":
		await entity.anim_player.animation_finished
	state_machine.transition_to("Chase")
	
func grounded():
	entity.ground_raycast.force_raycast_update()
	return entity.ground_raycast.is_colliding() or entity.is_on_floor()

func conditions_met():
	entity = entity as ParaGhoul
	if is_instance_valid(entity.link_object):
		if !entity.link_object.get_object_type().contains("Garbage Container"):
			return false
	else:
		return false 
		
	ground_checker.global_position = Vector2(entity.global_position.x, entity.global_position.y + 10)
	var previous_target_position:Vector2 = entity.ground_raycast.target_position
	entity.ground_raycast.target_position.y = crash_range
	entity.ground_raycast.force_raycast_update()
	if entity.ground_raycast.is_colliding():
		var distance_to_ground = abs (entity.ground_raycast.get_collision_point().y - entity.global_position.y)
		if distance_to_ground >= minimum_crash_height:
			entity.ground_raycast.target_position = previous_target_position
			return cd_timer.is_stopped()
	entity.ground_raycast.target_position = previous_target_position
	return false

func exit():
	entity.disconnect("damaged", Callable(self, "_on_ground_pound_interrupt"))
	entity.set_collision_mask_value(GlobalScript.collision_values.PROJECTILE_FUTURE, false)
	entity.set_collision_mask_value(GlobalScript.collision_values.PROJECTILE_PAST, false)
	entity.set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, true)
	entity.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, true)
	cd_timer.start()
	entity.set_color()
