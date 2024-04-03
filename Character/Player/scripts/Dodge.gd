extends PlayerBaseState

@onready var dodge_tracker:int = dodge_duration 
@onready var dodge_timer: Timer
@onready var superjump_timer:Timer

@export var dodge_boost: int = 25
@export var dodge_duration: int = 3
@export var dodge_speed: int = 50
@export var inital_fall_speed: int = 100
@export var dodge_cooldown: float = 0.9

var facing: String 

var is_actionable:bool = false
var dodge_over: bool = false

var jump_node: Jump
var fall_node: Fall
var jump_buffer:Timer

var bunny_hop_boost: float 

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	jump_node = state_machine.find_state("Jump")
	fall_node = state_machine.find_state("Fall")
	dodge_timer = state_machine.get_timer("Dodge_Cooldown")
	superjump_timer = state_machine.get_timer("Superjump")
	jump_buffer = state_machine.get_timer("Jump_Buffer")
	dodge_timer.wait_time = dodge_cooldown
	bunny_hop_boost = fall_node.bunny_hop_boost
	
func enter(_msg: = {}):
	super.enter()
	entity.anim_player.connect("animation_finished", Callable(self, "end_dodge"))
#	if entity.motion.y > inital_fall_speed:
#		entity.motion.y = inital_fall_speed
	entity.motion.y = clamp(entity.motion.y, inital_fall_speed, fall_node.maximum_fall_speed)
	entity.motion.x += dodge_boost * get_movement_input()
	if abs(entity.motion.x) > dodge_speed: 
		return
	if facing_left():
		entity.motion.x = -dodge_speed
	else:
		entity.motion.x = dodge_speed
	

func physics_process(delta: float):
	entity.motion.y += jump_node.get_gravity() * delta
	entity.motion.y = clamp(entity.motion.y, 0, fall_node.maximum_fall_speed)
	default_move_and_slide()
	if dodge_over:
		leave_dodge()
	if is_actionable:
		if grounded():
			if enter_crouch_state():
				return
			if enter_jump_state():
				return
			if get_movement_input() != 0:
				state_machine.transition_to("Run")
				return
			

func leave_dodge():
	if grounded():
		if Input.is_action_pressed("jump") or !jump_buffer.is_stopped():
			if !jump_buffer.is_stopped():
				entity.motion.x *= 1 + bunny_hop_boost
			state_machine.transition_to("Jump", {can_superjump = superjump_timer.is_stopped()})
			return
		if enter_crouch_state():
			return
		enter_move_state()
		return
	state_machine.transition_to("Fall")
	return

func become_actionable():
	is_actionable = true
	
func end_dodge(_anim_name):
	dodge_over = true

func get_movement_input() -> float:
	return Input.get_axis("left", "right")

func exit():
	entity.sprite.position = Vector2.ZERO
	dodge_timer.start()
	dodge_over = false
	is_actionable = false
	entity.anim_player.disconnect("animation_finished", Callable(self, "end_dodge"))
