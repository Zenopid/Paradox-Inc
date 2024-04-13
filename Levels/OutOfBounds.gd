class_name OutOfBounds extends Area2D

@export var damage:int = 25
@export var destroy_objects: bool = true 
@export_enum ("Future", "Past", "All") var timeline:String = "All"

func _ready():
	match timeline:
		"Future":
			enable_future_collision()
		"Past":
			enable_past_collision()
		"All":
			enable_future_collision()
			enable_past_collision()

func enable_future_collision():
	set_collision_layer_value(GlobalScript.collision_values.BOUNDARY_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.HITBOX_FUTURE, true)

func enable_past_collision():
	set_collision_layer_value(GlobalScript.collision_values.BOUNDARY_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.HITBOX_PAST, true)
func _on_body_entered(body):
	if body is Player:
		body.damage(damage, 0, 0, 0, true)
		if destroy_objects:
			body.respawn()
	elif body is MoveableObject or body is Enemy:
		if destroy_objects:
			body.remove_from_group("Grappled Objects")
			body.destroy()
	else:
		var body_parent = body.get_parent()
		if body_parent is Hook:
			if destroy_objects:
				body_parent.release()

func set_debug_color(color: Color):
	$CollisionShape2D.debug_color = color


func save():
	var save_dict = {
		"damage": damage,
		"position": {
			"x": position.x,
			"y": position.y
		}
	}
	return save_dict
