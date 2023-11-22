class_name MoveableObject extends RigidBody2D

var being_pushed: bool = false
var push_speed: int

func _physics_process(delta):
	if being_pushed:
		linear_velocity.x = clamp(linear_velocity.x, -push_speed, push_speed)

func start_pushing(force):
	being_pushed = true
	push_speed = force

func _on_body_exited(body):
	being_pushed = false
