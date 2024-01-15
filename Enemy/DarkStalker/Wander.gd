extends DarkstalkerMoveState

@export var wander_speed: int = 85
@export var push: int = 155
var dir

func enter(msg: = {}):
	super.enter()
	if msg["direction"].to_lower() == "right":
		dir = 1
		entity.sprite.flip_h = false
	elif msg["direction"].to_lower() == "left":
		dir = -1
		entity.sprite.flip_h = true
	entity.motion.x = wander_speed * dir

func physics_process(delta:float):
	super.physics_process(delta)
	move()
	push_objects()

func move():
	var current_dir = "Right" if dir == 1 else "Left"
	var inverse_dir = "Right" if current_dir == "Left" else "Left"
	var new_transform = Transform2D(entity.rotation, entity.position)
	if !ground_checker.is_colliding():
		entity.motion.x = 0
		var rng = randi_range(1,2)
		timer = behaviour_change_timer
		match rng:
			1:
				state_machine.transition_to("Idle")
			2:
				dir *= -1
				entity.sprite.flip_h = !entity.sprite.flip_h
		return
	entity.set_velocity(entity.motion)
	entity.set_up_direction(Vector2.UP)
	entity.set_floor_stop_on_slope_enabled(true)
	entity.set_max_slides(2)
	entity.set_floor_max_angle(PI/4)
	entity.move_and_slide()
	
func push_objects():
	for i in entity.get_slide_collision_count():
		var collision = entity.get_slide_collision(i)
		if collision.get_collider() is MoveableObject:
			collision.get_collider().call_deferred("apply_central_impulse", -collision.get_normal() * push ) 

