extends DarkstalkerMoveState

@export var wander_speed: int = 85
var dir

func enter(msg: = {}):
	print("time to wander")
	super.enter()
	if msg["direction"].to_lower() == "right":
		dir = 1
		entity.sprite.flip_h = false
		los_raycast.scale.x = 1
	else:
		dir = -1
		entity.sprite.flip_h = true
		los_raycast.scale.x = -1

func physics_process(delta:float):
	entity.motion.x = wander_speed * dir
	entity.motion.y = 50
	super.physics_process(delta)
	los_raycast.position = Vector2(entity.position.x -12, entity.position.y + 10)
	move()
	
func move():
	var current_dir = "Right" if dir == 1 else "Left"
	var inverse_dir = "Right" if current_dir == "Left" else "Left"
	var new_transform = Transform2D(entity.rotation, entity.position)
#	if entity.test_move(new_transform, entity.motion , null, entity.safe_margin, true) == true:
#		var rng = randi_range(1,2)
#		timer = behaviour_change_timer
#		match rng:
#			1:
#				state_machine.transition_to("Idle")
#			2:
#				dir *= -1
#				entity.sprite.flip_h = !entity.sprite.flip_h
#				los_raycast.scale.x *= -1
#		return
	entity.set_velocity(entity.motion)
	entity.set_up_direction(Vector2.UP)
	entity.set_floor_stop_on_slope_enabled(true)
	entity.set_max_slides(2)
	entity.set_floor_max_angle(PI/4)
	entity.move_and_slide()
