extends PlayerBaseState

@export var eject_timer: float = 0.4
@export var slide_speed: int = 45
@export var max_slide_speed: int = 450
@export var crouch_slide_boost:int = 5
@export var wallslide_cooldown: float = 0.6
@export var decay_multiplier: float = 1.7
@export var jump_decay_rate: float = 0.1
@export var jump_boost: Vector2 = Vector2 (50, -25)
@export var decel_rate: float = 0.7

@onready var eject_tracker: float = eject_timer

var wallslide_timer: Timer
var number_of_passes:int = 0
var wall_checker: RayCast2D
var offset_x: float = 12.5
var offset_y: float = 10.5
var wall_direction: String 
var jump_node: Jump
var jump_decay: float = 1.0
var previous_wall_direction: String
var cooldown_timer: Timer
const  MINIMUM_JUMP_DECAY :float = 0.35

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	cooldown_timer = state_machine.get_timer("Walljump_Cooldown")
	jump_node = state_machine.get_node("Jump")
	wall_checker = state_machine.get_raycast("WallChecker")

func enter(_msg: = {}):
	if Input.is_action_pressed("left"):
		wall_direction = "left"
		wall_checker.position.x  = entity.position.x - offset_x
	elif Input.is_action_pressed("right"):
		wall_direction = "right"
		wall_checker.position.x = entity.position.x + offset_x
	wall_checker.enabled = true
	if previous_wall_direction != wall_direction:
		jump_decay = 1
		#Hopefully means that you jumped on another wall, because you're facing the other direction
	super.enter()
	
func input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump"):
		jump_node.remaining_jumps += 1
		var speed_bonus:Vector2 = jump_boost
		speed_bonus.x = jump_boost.x if wall_direction == "left" else -jump_boost.x
		state_machine.transition_to("Jump", {
			"double_jump_multiplier" = jump_decay, 
			"double_jump_bonus_speed" = speed_bonus}
			)
		jump_decay -= jump_decay_rate
		if jump_decay < MINIMUM_JUMP_DECAY:
			jump_decay = MINIMUM_JUMP_DECAY
		return

func physics_process(delta):
	var facing = -1 if facing_left() else 1
	wall_checker.position = Vector2(entity.position.x + (offset_x * facing), entity.position.y - offset_y)
	if grounded():
		if enter_dodge_state():
			return
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
		
	if Input.is_action_pressed("crouch"):
		entity.motion.y = clamp(entity.motion.y, entity.motion.y + crouch_slide_boost, max_slide_speed)
	elif entity.motion.y > slide_speed:
		entity.motion.y *= decel_rate
	else:
		entity.motion.y = slide_speed
	
	if eject_tracker <= 0:
		entity.sprite.flip_h = ! entity.sprite.flip_h
		wall_checker.position.x *= -1
		state_machine.transition_to("Fall")
		return
	default_move_and_slide() 


func exit() -> void:
	previous_wall_direction = wall_direction
	eject_tracker = eject_timer
	wall_checker.enabled = false
	cooldown_timer.start()
