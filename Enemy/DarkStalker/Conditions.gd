class_name DarkStalkerConditions extends Node

@export var entity: Entity
@export var state_machine: EntityStateMachine
@export var detection_radius: int = 100

func will_be_grounded() -> bool:
	return state_machine.get_raycast("GroundChecker").is_colliding()

func nearby_entities() -> Array:
	var temp_area: Area2D = Area2D.new()
	var collision:CollisionShape2D = CollisionShape2D.new()
	var detect_sphere = CircleShape2D.new()
	var entity_array: = []
	detect_sphere.radius = detection_radius
	collision.shape = detect_sphere
	temp_area.add_child(collision)
	state_machine.add_child(temp_area)
	temp_area.position = entity.position
	for bodies in temp_area.get_overlapping_bodies():
		if bodies is Entity:
			entity_array.append(bodies)
	temp_area.queue_free()
	return entity_array
		
