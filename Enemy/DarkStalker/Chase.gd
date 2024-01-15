extends BaseState

var los_raycast: RayCast2D
var ground_checker: RayCast2D
var chase_location: Vector2
var chase_object

@export var chase_speed: int = 315
@export var acceleration: int = 15
@export var chase_view_distance: int = 450
@export var turning_speed: float = 0.2

var reached_target: bool = false
var teleport_script

var old_view_distance: int

var scanning_for_tp_spot: bool = false




func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	los_raycast = state_machine.get_raycast("LOS")
	ground_checker = state_machine.get_raycast("GroundChecker")
	ground_checker.add_exception(current_entity)
	los_raycast.add_exception(current_entity)
	teleport_script = state_machine.find_state("Teleport")

func enter(_msg: = {}):
	reached_target = false
	chase_location = los_raycast.get_collision_point()
	chase_object = los_raycast.get_collider()
	super.enter()
	los_raycast.lock_view_distance()
	#we lock it because we want to do custom look stuff
	old_view_distance = los_raycast.target_position.x
	los_raycast.target_position.x = chase_view_distance
	scanning_for_tp_spot = false
	
#func set_los_target_posiiton():
#	if los_raycast.is_colliding():
#		var point = los_raycast.get_collision_point()
#		var dir = -1 if entity.sprite.flip_h else 1
#		var angle = los_raycast.get_angle_to(point)
#		var tween = get_tree().create_tween()
#		tween.tween_property(los_raycast,"rotation", angle, turning_speed)
#		var new_target_position: Vector2
#		new_target_position.x = (point.x - entity.position.x) * dir * -1
		

func physics_process(delta):
	var dir: int 
	if chase_location.x < entity.position.x:
		dir = -1
	else:
		dir = 1
	entity.motion.x += dir * acceleration
	entity.motion.x = clamp(entity.motion.x, -chase_speed, chase_speed)
	
	
	
	default_move_and_slide()
#	set_los_target_posiiton()
	if los_raycast.is_colliding():
		chase_object = los_raycast.get_collider()
		if chase_object is Player:
			chase_location = los_raycast.get_collision_point()
	

	if entity.position.x + 20 > chase_location.x and entity.position.x - 20 < chase_location.x:
		if should_teleport():
			return
		else:
			reached_target = true 
		if chase_object is Player and los_raycast.is_colliding():
			state_machine.transition_to("Attack")
			return
		state_machine.transition_to("Idle")
		return
	elif !ground_checker.is_colliding():
		if should_teleport():
			return
		var wander_dir = "left" if chase_speed < 0 else "right"
		state_machine.transition_to("Wander", {direction = wander_dir})
		entity.sprite.flip_h = !entity.sprite.flip_h
		return
func should_teleport() -> bool:
	var dir = -1 if entity.sprite.flip_h else 1
	var angle = los_raycast.get_angle_to(chase_location)
	los_raycast.rotation = deg_to_rad(angle)
	los_raycast.force_raycast_update()
	if los_raycast.is_colliding():
		var tp_spot: Vector2 = los_raycast.get_collision_point()
		tp_spot = Vector2(tp_spot.x + 30 * dir, tp_spot.y - 10)
		state_machine.transition_to("Teleport", {Location = tp_spot})
		return true
	return false
func has_reached_target():
	return true if reached_target == true else false

func exit():
	los_raycast.unlock_view_distance()
