extends EntityStateMachine

@onready var wall_ray = $"%WallChecker"
@onready var ground_ray = $"%GroundChecker"
@onready var slope_ray_left = $"%SlopeCheckerLeft"
@onready var slope_ray_right = $"%SlopeCheckerRight"

func _on_level_timeline_swapped(new_timeline:String):
	if new_timeline == "Future":
		
		wall_ray.set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, true)
		wall_ray.set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, false)
		
		ground_ray.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)
		ground_ray.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, false)
		
		ground_ray.set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
		ground_ray.set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, false)
		
		slope_ray_left.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)
		slope_ray_left.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, false)
		
		slope_ray_right.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)
		slope_ray_right.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, false)
	else:
		wall_ray.set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, false)
		wall_ray.set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, true)
		
		ground_ray.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, false)
		ground_ray.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
		
		ground_ray.set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, false)
		ground_ray.set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)
		
		slope_ray_left.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, false)
		slope_ray_left.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
		
		slope_ray_right.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, false)
		slope_ray_right.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
