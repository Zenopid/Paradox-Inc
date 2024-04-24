extends EntityStateMachine

@onready var wall_ray = $"%WallChecker"
@onready var ground_ray = $"%GroundChecker"
@onready var slope_ray_left = $"%SlopeCheckerLeft"
@onready var slope_ray_right = $"%SlopeCheckerRight"

func _on_level_timeline_swapped(new_timeline:String):
	if new_timeline.to_lower() == "future":
		set_collision(true, false)
	else:
		set_collision(false, true)
	
func set_collision(future_value:bool, past_value:bool):
	wall_ray.set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, future_value)
	wall_ray.set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, past_value)
	
	ground_ray.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, future_value)
	ground_ray.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, past_value)
	
	ground_ray.set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, future_value)
	ground_ray.set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, past_value)
	
	slope_ray_left.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, future_value)
	slope_ray_left.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, past_value)
	
	slope_ray_right.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, future_value)
	slope_ray_right.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, past_value)
