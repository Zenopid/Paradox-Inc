extends BaseState

var wall_direction: String 
@export var eject_timer: float = 0.4
@export var slide_speed: int = 45
@export var max_slide_speed: int = 450
@onready var eject_tracker: float = eject_timer

@export var crouch_slide_boost:int = 5

@export var wallslide_cooldown: float = 0.6
var wallslide_timer: Timer
var number_of_passes:int = 0

var wall_checker: RayCast2D

var jump_node: Jump

func enter(_msg: = {}):
	jump_node = state_machine.get_node("Jump")
	wall_checker = state_machine.get_raycast("WallChecker")
	if entity.motion.x < 0:
		wall_direction = "left"
		wall_checker.position.x  = entity.position.x - 12.5
	elif entity.motion.x > 0:
		wall_direction = "right"
		wall_checker.position.x = entity.position.x + 12.5
	wall_checker.enabled = true
	super.enter()
	
func input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump"):
		jump_node.remaining_jumps += 1
		state_machine.transition_to("Jump")
		return

func physics_process(delta):
	wall_checker.position.y = entity.position.y - 10.5
	if entity.is_on_floor():
		if enter_crouch_state():
			return
		if enter_move_state():
			return
	if !wall_checker.is_colliding():
		state_machine.transition_to("Fall")
		return
	if !Input.is_action_pressed(wall_direction):
		eject_tracker -= delta
	else:
		eject_tracker = eject_timer
	if eject_tracker <= 0:
		entity.sprite.flip_h = ! entity.sprite.flip_h
		state_machine.transition_to("Fall")
		return
	if !Input.is_action_pressed("crouch"):
		entity.motion.y = slide_speed
	else:
		entity.motion.y += crouch_slide_boost
		if entity.motion.y > max_slide_speed:
			entity.motion.y = max_slide_speed
	default_move_and_slide() 

func exit() -> void:
	eject_tracker = eject_timer
	wall_checker.enabled = false
