class_name MoveableObject extends RigidBody2D

var being_pushed: bool = false
var push_speed: int

var push_count:int = 0
var max_frames_without_pushing:int = 5

var height_pre_pushing: int = 0

var should_reset:bool = false

var new_position: Vector2 = Vector2.ZERO

var current_level: GenericLevel

@export var health: int = 20
@export var current_timeline: String = "Future"

var is_on_slope:bool = false

func _ready():
	if get_parent() is GenericLevel:
		current_level = get_parent()
	elif get_parent() is Entity:
		current_level = get_parent().get_level()
	swap_state(current_level.get_current_timeline())
	current_level.connect("swapped_timeline", Callable(self, "swap_state"))

func swap_state(timeline):
	if timeline != current_timeline:
		disable()
	else:
		enable()

func swap_timeline():
	current_timeline = current_level.get_next_timeline_swap()
	disable()

func disable():
	set_physics_process(false)
	visible = false
	sleeping = true 
	set_continuous_collision_detection_mode(RigidBody2D.CCD_MODE_DISABLED)

func enable():
	set_physics_process(true)
	visible = true
	sleeping = false
	set_continuous_collision_detection_mode(RigidBody2D.CCD_MODE_CAST_SHAPE)

func _physics_process(delta):
	var ground_checker: RayCast2D 
	var num_of_ground_rays: int = 0
	for nodes in get_children():
		if nodes.get_class() == "RayCast2D":
			if nodes.get_collider() is Entity == false:
				ground_checker = nodes
				num_of_ground_rays += 1
	if num_of_ground_rays > 1:
		is_on_slope = true
	else:
		if ground_checker:
			var angle = ground_checker.get_collision_normal().angle_to(self.position)
			if angle > 0.02 or angle < -0.02:
				is_on_slope = true
	if being_pushed:
		if !is_on_slope:
			lock_rotation = true
		linear_velocity.x = clamp(linear_velocity.x, -push_speed, push_speed)
	else:
		lock_rotation = false
	if !$LeftSideChecker.is_colliding() and !$RightSideChecker.is_colliding() and !$SouthSideChecker.is_colliding() and !$NorthSideChecker.is_colliding():
		push_count += 1
		if push_count > max_frames_without_pushing:
			being_pushed = false
	else:
		push_count = 0
		height_pre_pushing = roundi(position.y)
		being_pushed = true
	if ground_checker:
		if ground_checker.is_colliding() and being_pushed:
			if !is_on_slope:
				gravity_scale = 0
				position.y = height_pre_pushing - 0.001
		else: 
			gravity_scale = 1
	else: 
		gravity_scale = 1
		
	print(is_on_slope)
	


func _integrate_forces(state):
	if should_reset:
		state.transform.origin = new_position
		should_reset = false

func set_new_location(pos):
	new_position = pos
	should_reset = true
