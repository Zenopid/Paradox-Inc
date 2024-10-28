class_name Walljump extends PlayerBaseState

@export var eject_timer: float = 0.4
@export var base_slide_speed: int = 45
@export var max_slide_speed: int = 450
@export var crouch_slide_boost:int = 5
@export var wallbouce_timer: float = 0.2
@export var decay_multiplier: float = 1.7
@export var jump_decay_rate: float = 0.1
@export var jump_boost: Vector2 = Vector2 (50, -25)
@export var decel_rate: float = 0.7
@export var  minimum_jump_decay :float = 0.2
@export var slide_speed_increase: int = 10
@onready var eject_tracker: float = eject_timer
@onready var current_slide_speed: int
@onready var wallrun_node:Wallrun

var wallslide_timer: Timer
var wall_checker: ShapeCast2D
var offset_x: float = 12.5
var offset_y: float = 10.5
var wall_direction: int 
var jump_decay: float = 1.0
var previous_wall_direction: int
var wallbounce_timer: Timer
var jump_buffer:Timer
var previous_speed: Vector2 = Vector2.ZERO
var has_slid_downward:bool = false

var disengaging_wall:bool = false 


func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	wallbounce_timer = state_machine.get_timer("Wallbounce")
	jump_buffer = state_machine.get_timer("Jump_Buffer")
	wall_checker = state_machine.get_shapecast("WallScanner")
	current_slide_speed = base_slide_speed
	wallrun_node = state_machine.find_state("WallRun")
	
func enter(msg: = {}):
	has_slid_downward = false
	entity.camera.override_facing_logic = true
	_check_facing()
	if msg.has("previous_speed"):
		previous_speed = msg["previous_speed"]
	wall_direction = -1 if entity.sprite.flip_h else 1
	wall_checker.position.x = entity.position.x + offset_x * wall_direction
	wall_checker.enabled = true
	if previous_wall_direction != wall_direction:
		jump_decay = 1
		current_slide_speed = base_slide_speed
		wallrun_node.hit_ground_post_wallrun = true
	super.enter()
	wallbounce_timer.start()

func input(event: InputEvent) -> void:
	super.input(event)

	if Input.is_action_just_pressed("jump") or !jump_buffer.is_stopped() :
		var speed_bonus:Vector2 = jump_boost
		speed_bonus.x = jump_boost.x * wall_direction
		previous_speed *= int(wallbounce_timer.is_stopped()) * -1
		state_machine.transition_to("Jump", {
			"add_jump" =  1,
			"double_jump_multiplier" = jump_decay, 
			"double_jump_bonus_speed" = Vector2((abs(previous_speed.x) * sign(jump_boost.x)) + speed_bonus.x, speed_bonus.y + (previous_speed.y /2))
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
	if entity.velocity.y > 0:
		has_slid_downward = true
	elif entity.velocity.y < 0 and state_machine.state_available("WallRun"):
		disengaging_wall = false
		state_machine.transition_to("WallRun")
		return
	if grounded() or eject_tracker <= 0:
		state_machine.transition_if_available([
			"Fall",
			"Jump",
			"Dodge",
			"Slide",
			"Crouch",
			"Run",
			"Idle"
		])
		return
		
	if sign(get_movement_input()) != wall_direction or !wall_checker.is_colliding():
		eject_tracker -= delta * decay_multiplier
	else:
		eject_tracker = eject_timer
			
	if entity.velocity.y > current_slide_speed:
		entity.velocity.y *= decel_rate
	else:
		if Input.is_action_pressed("crouch"):
			current_slide_speed += crouch_slide_boost
	current_slide_speed = clamp(current_slide_speed, base_slide_speed, max_slide_speed)
	entity.velocity = Vector2(0, current_slide_speed)
	entity.move_and_slide() 

func get_inverse_wall_direction() -> int:
	return wall_direction * -1

func inactive_process(_delta:float ) -> void:
	if grounded():
		reset_wallslide_conditions()

func reset_wallslide_conditions():
	jump_decay = 1
	current_slide_speed = base_slide_speed

func exit() -> void:
	if disengaging_wall:
		entity.sprite.flip_h = ! entity.sprite.flip_h
	disengaging_wall = true
	_check_facing() 
	previous_wall_direction = wall_direction
	eject_tracker = eject_timer
	wall_checker.enabled = false
	wallbounce_timer.stop() 
	previous_speed = Vector2.ZERO
	entity.camera.override_facing_logic = false
	has_slid_downward = false

func conditions_met() -> bool:
	if wall_checker.is_colliding() and !grounded() and !Input.is_action_pressed("jump"):
		return get_movement_input() != 0
	return false

func _check_facing():
	var facing = entity.camera.facing
	var current_facing = get_facing_as_int()
	if current_facing != facing:
		facing = current_facing
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(entity.camera, "FOLLOW_OFFSET:x", abs(entity.camera.LOOK_AHEAD_FACTOR) * facing, entity.camera.SHIFT_DURATION)
