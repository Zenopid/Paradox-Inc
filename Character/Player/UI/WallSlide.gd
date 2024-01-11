extends PlayerBaseState

var wall_direction: String 
@export var eject_timer: float = 0.4
@export var slide_speed: int = 45
@export var max_slide_speed: int = 450
@onready var eject_tracker: float = eject_timer

@export var crouch_slide_boost:int = 5

@export var wallslide_cooldown: float = 0.6

@export var decay_multiplier: float = 1.7
var wallslide_timer: Timer
var number_of_passes:int = 0

var wall_checker: RayCast2D

var offset_x: float = 12.5
var offset_y: float = 10.5

var jump_node: Jump

func enter(_msg: = {}):
	jump_node = state_machine.get_node("Jump")
	wall_checker = state_machine.get_raycast("WallChecker")
	if entity.motion.x < 0:
		wall_direction = "left"
		wall_checker.position.x  = entity.position.x - offset_x
	else:
		wall_direction = "right"
		wall_checker.position.x = entity.position.x + offset_x
	wall_checker.enabled = true
	super.enter()
	
func input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump"):
		jump_node.remaining_jumps += 1
		state_machine.transition_to("Jump")
		return

func physics_process(delta):
	wall_checker.position.y = entity.position.y - offset_y
	if grounded():
		if enter_crouch_state():
			return
		if enter_move_state():
			return
	if !wall_checker.is_colliding():
		state_machine.transition_to("Fall")
		return
	if !Input.is_action_pressed(wall_direction):
		eject_tracker -= delta * decay_multiplier
	else:
		eject_tracker = eject_timer
	if eject_tracker <= 0:
		entity.sprite.flip_h = ! entity.sprite.flip_h
		wall_checker.position.x *= -1
		state_machine.transition_to("Fall")
		return
	if Input.is_action_pressed("crouch"):
		entity.motion.y = clamp(entity.motion.y, entity.motion.y + crouch_slide_boost, max_slide_speed)
	else:
		entity.motion.y = slide_speed
	default_move_and_slide() 

func exit() -> void:
	eject_tracker = eject_timer
	wall_checker.enabled = false
