class_name MoveableObject extends RigidBody2D

func _integrate_forces(state):
	print(get_linear_velocity())
