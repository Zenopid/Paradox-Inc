class_name Fall extends PlayerAirState


@onready var land_sfx:AudioStreamPlayer = $"%Land"

@export var maximum_fall_speed: int = 400
@export var buffer_duration: float = 0.6
@export_range(0,1) var bunny_hop_boost: float = 0.05

var jump_buffer: Timer
var coyote_timer:Timer 

var jump_node: Jump
var walljump_node:Walljump

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
	
	coyote_timer = state_machine.get_timer("Coyote")

func enter(_msg: = {}) -> void:
	super.enter()
	wall_checker.enabled = true
	ground_checker.enabled = true

func input(event: InputEvent):
	super.input(event)
	if !jump_buffer.is_stopped() and grounded():
		entity.velocity.x *=  1 + bunny_hop_boost
	state_machine.transition_if_available([
		"Jump",
		"Attack",
		"Dodge",
		"Slide",
		"Crouch", 
		"Run",
		"Idle",
	])

func physics_process(delta):
	if state_machine.state_available("WallSlide"):
		state_machine.transition_to("WallSlide", {previous_speed = speed_before_wallslide})
	elif !wall_checker.is_colliding():
		speed_before_wallslide = entity.velocity.x

	super.physics_process(delta)
	entity.velocity.y = clamp(entity.velocity.y, entity.velocity.y + jump_node.get_gravity(), maximum_fall_speed)
	if grounded():
		state_machine.transition_if_available([
			"Jump",
			"Slide",
			"Crouch",
			"Dodge",
			"Run",
			"Idle",
		])
		return
	set_raycast_positions()
	default_move_and_slide()
	
func set_raycast_positions():
	wall_checker.position.x = entity.position.x + 12.55 * get_facing_as_int()
	wall_checker.position.y =  entity.position.y - 10.5 
	ground_checker.position = Vector2(entity.position.x, entity.position.y + 13.5)

func exit() -> void:
	if grounded():
		walljump_node.reset_wallslide_conditions()
		jump_node.remaining_jumps = jump_node.double_jumps
		land_sfx.play()
	wall_checker.enabled = false
	ground_checker.enabled = false

func inactive_process(delta:float) -> void:
	if !grounded() and coyote_timer.is_stopped():
		coyote_timer.start()

func conditions_met() -> bool:
	if coyote_timer.is_stopped() and !grounded():
		return true
	return false
