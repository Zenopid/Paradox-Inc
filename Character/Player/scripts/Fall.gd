class_name Fall extends PlayerAirState

var jump_node: Jump
var walljump_node

@export var maximum_fall_speed: int = 400

var jump_buffer: Timer

@export var buffer_duration: float = 0.6
@export_range(0,1) var bunny_hop_boost: float = 0.05
var wall_checker: ShapeCast2D 
var ground_checker: RayCast2D

var speed_before_wallslide:float 

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	wall_checker = state_machine.get_shapecast("WallScanner")
	ground_checker = state_machine.get_raycast("GroundChecker")
	jump_node = state_machine.find_state("Jump")
	jump_buffer = state_machine.get_timer("Jump_Buffer")
	jump_buffer.wait_time = buffer_duration
	walljump_node = state_machine.find_state("WallSlide")

func enter(_msg: = {}) -> void:
	super.enter()
	wall_checker.enabled = true
	ground_checker.enabled = true

func input(_event: InputEvent):
	if Input.is_action_just_pressed("jump"):
		jump_buffer.start()
		if jump_node.remaining_jumps > 0: 
			state_machine.transition_to("Jump")
			return

func physics_process(delta):
	if can_wallslide(speed_before_wallslide):
		return
	elif !wall_checker.is_colliding():
		speed_before_wallslide = entity.velocity.x
	if enter_dodge_state():
		return
	super.physics_process(delta)
	entity.velocity.y = clamp(entity.velocity.y, entity.velocity.y + jump_node.get_gravity(), maximum_fall_speed)
	if grounded():
		walljump_node.reset_wallslide_conditions()
		if !jump_buffer.is_stopped():
			entity.velocity.x *= 1 + bunny_hop_boost
			state_machine.transition_to("Jump")
			jump_buffer.stop()
			return
		if enter_crouch_state():
			return
		entity.velocity.x *= 0.8
		enter_move_state()
		return
	set_raycast_positions()
	default_move_and_slide()
	
func set_raycast_positions():
	var facing = -1 if facing_left() else 1
	wall_checker.position.x = entity.position.x + 12.55 * facing
	wall_checker.position.y =  entity.position.y - 10.5 
	ground_checker.position = Vector2(entity.position.x, entity.position.y + 13.5)

func exit() -> void:
	if grounded():
		jump_node.remaining_jumps = jump_node.double_jumps
	wall_checker.enabled = false
	ground_checker.enabled = false
