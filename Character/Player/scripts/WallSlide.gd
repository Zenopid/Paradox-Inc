class_name Walljump extends PlayerBaseState

@export var eject_timer: float = 0.4
@export var base_slide_speed: int = 45
@export var max_slide_speed: int = 450
@export var crouch_slide_boost:int = 5
@export var Wallbouce_timer: float = 0.2
@export var decay_multiplier: float = 1.7
@export var jump_decay_rate: float = 0.1
@export var jump_boost: Vector2 = Vector2 (50, -25)
@export var decel_rate: float = 0.7
@export var  minimum_jump_decay :float = 0.2
@export var slide_speed_increase: int = 10
@onready var eject_tracker: float = eject_timer
@onready var current_slide_speed: int 
var wallslide_timer: Timer
var number_of_passes:int = 0
var wall_checker: ShapeCast2D
var offset_x: float = 12.5
var offset_y: float = 10.5
var wall_direction: String 
var jump_node: Jump
var jump_decay: float = 1.0
var previous_wall_direction: String
var wallbounce_timer: Timer
var jump_buffer:Timer
var previous_speed: float = 0




func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	wallbounce_timer = state_machine.get_timer("Wallbounce")
	jump_buffer = state_machine.get_timer("Jump_Buffer")
	jump_node = state_machine.get_node("Jump")
	wall_checker = state_machine.get_shapecast("WallScanner")
	current_slide_speed = base_slide_speed
	
func enter(msg: = {}):
	if msg.has("previous_speed"):
		previous_speed = msg["previous_speed"]
	var move = get_movement_input()
	if wall_checker.position.x < 0:
		wall_direction = "left"
	else:
		wall_direction = "right"
	wall_checker.position.x = entity.position.x + offset_x * sign(move)
	wall_checker.enabled = true
	if previous_wall_direction != wall_direction:
		jump_decay = 1
		current_slide_speed = base_slide_speed
	super.enter()
	wallbounce_timer.start()
	
func input(event: InputEvent) -> void:
	super.input(event)

	if Input.is_action_just_pressed("jump") or !jump_buffer.is_stopped() :
		var speed_bonus:Vector2 = jump_boost
		speed_bonus.x = jump_boost.x if wall_direction == "left" else -jump_boost.x
		state_machine.transition_to("Jump", {
			"add_jump" =  1,
			"double_jump_multiplier" = jump_decay, 
			"double_jump_bonus_speed" = Vector2((abs(previous_speed) * sign(jump_boost.x)) + speed_bonus.x, speed_bonus.y)
			}
			)
		current_slide_speed += slide_speed_increase
		jump_decay = clampf(jump_decay, minimum_jump_decay, jump_decay - jump_decay_rate)
		return 
	state_machine.transition_if_available([
		"Dodge",
		"Attack"
	])


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
		
	if !Input.is_action_pressed(wall_direction):
		eject_tracker -= delta * decay_multiplier
	else:
		eject_tracker = eject_timer
			
	if Input.is_action_pressed("crouch"):
		entity.velocity.y = clamp(entity.velocity.y, entity.velocity.y + crouch_slide_boost, max_slide_speed)
	elif entity.velocity.y > current_slide_speed:
		entity.velocity.y *= decel_rate
	else:
		entity.velocity.y = current_slide_speed
		
	current_slide_speed = clamp(current_slide_speed, base_slide_speed, max_slide_speed)
	if eject_tracker <= 0:
		state_machine.transition_to("Fall")
		return
	entity.move_and_slide() 

func get_inverse_wall_direction() -> String:
	if wall_direction == "left":
		return "right"
	return "left"

func inactive_process(_delta:float ) -> void:
	if grounded():
		reset_wallslide_conditions()

func reset_wallslide_conditions():
	jump_decay = 1
	current_slide_speed = base_slide_speed

func exit() -> void:
	entity.sprite.flip_h = ! entity.sprite.flip_h
	previous_wall_direction = wall_direction
	eject_tracker = eject_timer
	wall_checker.enabled = false
	wallbounce_timer.stop() 
	previous_speed = 0

func conditions_met() -> bool:
	if wall_checker.is_colliding() and !grounded() and !Input.is_action_pressed("jump"):
		if entity.sprite.flip_h and get_movement_input() < 0:
			return true
		elif !entity.sprite.flip_h and get_movement_input() > 0:
			return true
	return false