class_name MoveableObject extends RigidBody2D

var being_pushed: bool = false
var push_speed: int

var push_count:int = 0
var max_frames_without_pushing:int = 5

var height_pre_pushing: int = 0
func _physics_process(delta):
	var ground_checker: RayCast2D 
	var num_of_ground_rays: int = 0
	var is_on_slope: bool = false
	for nodes in get_children():
		if nodes.get_class() == "RayCast2D":
			if nodes.is_colliding():
				var collision = nodes.get_collider()
				if collision is Entity == false:
					ground_checker = nodes
					num_of_ground_rays += 1
	if num_of_ground_rays > 1:
		is_on_slope = true
	else:
		print(ground_checker)
		if ground_checker:
			var angle = ground_checker.get_collision_normal().angle_to(self.position)
			print(angle)
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
		height_pre_pushing = position.y
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
	if Input.is_action_pressed("view_timeline"):
		print(is_on_slope)
