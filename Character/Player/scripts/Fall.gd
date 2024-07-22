class_name Fall extends PlayerAirState


@onready var land_sfx:AudioStreamPlayer = $"%Land"

@export var maximum_fall_speed: int = 400
@export var buffer_duration: float = 0.6
@export_range(0,1) var bunny_hop_boost: float = 0.05

var jump_buffer: Timer
var coyote_timer:Timer 

var jump_node: Jump
var walljump_node:Walljump

var ground_checker: RayCast2D

var has_hit_ground:bool = false


func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	ground_checker = state_machine.get_raycast("GroundChecker")
	jump_node = state_machine.find_state("Jump")
	jump_buffer = state_machine.get_timer("Jump_Buffer")
	jump_buffer.wait_time = buffer_duration
	walljump_node = state_machine.find_state("WallSlide")
	
	coyote_timer = state_machine.get_timer("Coyote")


func input(event: InputEvent):
	super.input(event)
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
	super.physics_process(delta)
	entity = entity as Player
	var fall_speed = jump_node.get_gravity()
	if entity.grapple.swinging:
		fall_speed /= 2
	entity.velocity.y = clamp(entity.velocity.y, entity.velocity.y + fall_speed, maximum_fall_speed)
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
	ground_checker.position = Vector2(entity.position.x, entity.position.y + 13.5)

func exit() -> void:
	if grounded():
		land_sfx.play()
	super.exit()



func conditions_met() -> bool:
	if coyote_timer.is_stopped() and !grounded():
		return true
	return false
