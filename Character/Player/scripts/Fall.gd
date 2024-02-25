class_name Fall extends AirState

var jump_node: Jump

@export var maximum_fall_speed: int = 400

var jump_buffer: Timer

@export var buffer_duration: float = 0.6
@export_range(0,1) var bunny_hop_boost: float = 0.05
var wall_checker: RayCast2D 
var ground_checker: RayCast2D

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	wall_checker = state_machine.get_raycast("WallChecker")
	ground_checker = state_machine.get_raycast("GroundChecker")
	jump_node = state_machine.find_state("Jump")
	jump_buffer = state_machine.get_timer("Jump_Buffer")
	jump_buffer.wait_time = buffer_duration


func enter(_msg: = {}) -> void:
	super.enter()
	wall_checker.enabled = true
	ground_checker.enabled = true
	
func input(_event: InputEvent):
	if Input.is_action_just_pressed("jump"):
		if jump_node.remaining_jumps > 0: 
			state_machine.transition_to("Jump")
			return
		else:
			jump_buffer.start()

func physics_process(delta):
	if can_wallslide():
		return
	if enter_dodge_state():
		return
	super.physics_process(delta)
	entity.motion.y = clamp(entity.motion.y, entity.motion.y + jump_node.get_gravity() * delta, maximum_fall_speed)
	if grounded():
		if !jump_buffer.is_stopped():
			entity.motion.x *= 1 + bunny_hop_boost
			state_machine.transition_to("Jump")
			jump_buffer.stop()
			return
		if Input.is_action_pressed("crouch") and abs(entity.motion.x) >= max_speed and state_machine.get_timer("Slide_Cooldown").is_stopped() and get_movement_input() != 0:
			state_machine.transition_to("Slide")
			return
		entity.motion.x *= 0.8
		if enter_crouch_state():
			return
		enter_move_state()
		return
	set_raycast_positions()
	default_move_and_slide()
	
func set_raycast_positions():
	if facing_left():
		wall_checker.position.x = entity.position.x - 12.55
	else:
		wall_checker.position.x = entity.position.x + 12.55
	wall_checker.position.y =  entity.position.y - 10.5 
	ground_checker.position = Vector2(entity.position.x, entity.position.y + 13.5)

func exit() -> void:
	if grounded():
		jump_node.remaining_jumps = jump_node.double_jumps
	wall_checker.enabled = false
	ground_checker.enabled = false
