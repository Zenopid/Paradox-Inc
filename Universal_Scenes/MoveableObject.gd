class_name MoveableObject extends RigidBody2D

var being_pushed: bool = false
var push_speed: int

var push_count:int = 0
var max_frames_without_pushing:int = 5


func _physics_process(delta):
	if being_pushed:
		lock_rotation = true
		linear_velocity.x = clamp(linear_velocity.x, -push_speed, push_speed)
	else:
		lock_rotation = false
	if !$LeftSideChecker.is_colliding() and !$RightSideChecker.is_colliding():
		push_count += 1
		if push_count > max_frames_without_pushing:
			being_pushed = false
	else:
		push_count = 0
		being_pushed = true
	if $GroundChecker.is_colliding():
		gravity_scale = 0
	else:
		gravity_scale = 1

