class_name Wallrun extends Walljump


@export var time_until_decay:float = 0.4
@export var acceleration: int = 25
@export var max_speed: int = 900

@onready var wallslide_node: Walljump
@onready var decay_timer:Timer

var hit_ground_post_wallrun:bool = true 




func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	decay_timer = state_machine.get_timer("Wallrun_Decay")
	decay_timer.wait_time = time_until_decay
	wallslide_node = state_machine.find_state("WallSlide")
	


func enter(msg: = {}):
	super.enter()
	decay_timer.start()

	
func physics_process(delta):
	wall_checker.position = Vector2(entity.position.x + (offset_x * get_facing_as_int()), entity.position.y - offset_y)
	if grounded():
		state_machine.transition_if_available([
			"Dodge",
			"Slide",
			"Crouch",
			"Run",
			"Idle"
		])
		return
	if !wall_checker.is_colliding():
		state_machine.transition_to("Fall")
		return
		
	if !Input.is_action_pressed("jump"):
		if state_machine.transition_if_available(["WallSlide"]):
			return
		
	current_slide_speed = clamp(current_slide_speed, base_slide_speed, max_slide_speed)
	if eject_tracker <= 0:
		state_machine.transition_to("Fall")
		return
	entity.move_and_slide() 
	
	if decay_timer.is_stopped() or !hit_ground_post_wallrun:
		entity.velocity.y *= decel_rate
		if entity.velocity.y > -50 and entity.velocity.y < 2:
			state_machine.transition_to("WallSlide")
			return
	else:
		entity.velocity.y += acceleration
		if entity.velocity.y > max_speed:
			entity.velocity.y = max_speed

func inactive_process(_delta:float ) -> void:
	if grounded():
		hit_ground_post_wallrun = true 

func get_movement_input() -> float:
	var move = Input.get_axis("left", "right")
	if move < 0:
		cleaner_sprite.flip_h = false
		cleaner_sprite.rotation_degrees = 90
	elif move > 0:
		cleaner_sprite.flip_h = true 
		cleaner_sprite.rotation_degrees = -90
	return move

		
func exit():
	super.get_movement_input()
	cleaner_sprite.rotation_degrees = 0
	previous_wall_direction = wall_direction
	eject_tracker = eject_timer
	wall_checker.enabled = false
	wallbounce_timer.stop() 
	previous_speed = Vector2.ZERO
	cleaner_sprite.hide()
	hit_ground_post_wallrun = false
	
func conditions_met() -> bool:
	if wall_checker.is_colliding() and !grounded() and Input.is_action_pressed("jump"):
		if entity.sprite.flip_h and get_movement_input() < 0:
			return true
		elif !entity.sprite.flip_h and get_movement_input() > 0:
			return true
	return false
	
