extends PlayerBaseState

@export var dodge_duration: int = 3
@onready var dodge_tracker:int = dodge_duration 
@export var dodge_speed: int = 50

@onready var dodge_timer: Timer

@export var dodge_cooldown: float = 0.9

var facing: String 

var is_actionable:bool = false
var dodge_over: bool = false

var jump_node: Jump
var fall_node: Fall

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	jump_node = state_machine.find_state("Jump")
	fall_node = state_machine.find_state("Fall")

func enter(_msg: = {}):
	super.enter()
	dodge_timer = state_machine.get_timer("Dodge_Cooldown")
	dodge_timer.wait_time = dodge_cooldown
	entity.anim_player.connect("animation_finished", Callable(self, "end_dodge"))
	if abs(entity.motion.x) > dodge_speed: 
		return
	if facing_left():
		entity.motion.x = -dodge_speed
	else:
		entity.motion.x = dodge_speed

func physics_process(delta: float):
	entity.motion.y += jump_node.get_gravity() * delta
	if entity.motion.y > fall_node.maximum_fall_speed:
		entity.motion.y = fall_node.maximum_fall_speed 
	entity.motion.y = clamp(entity.motion.y, 0, fall_node.maximum_fall_speed)
	default_move_and_slide()
	if dodge_over:
		leave_dodge()
	if is_actionable:
		if grounded():
			enter_move_state()
		state_machine.transition_to("Fall")
		return

func leave_dodge():
	if grounded():
		if Input.is_action_pressed("jump"):
			state_machine.transition_to("Jump", {can_superjump = state_machine.get_timer("Superjump").is_stopped()})
			return
		if Input.is_action_pressed("crouch") and grounded():
			state_machine.transition_to("Slide")
			return
		enter_move_state()
		return
	state_machine.transition_to("Fall")
	return

func become_actionable():
	is_actionable = true
	
func end_dodge(_anim_name):
	dodge_over = true

func get_movement_input() -> int:
	return Input.get_axis("left", "right")

func exit():
	entity.sprite.position = Vector2.ZERO
	dodge_timer.start()
	dodge_over = false
	is_actionable = false
	entity.anim_player.disconnect("animation_finished", Callable(self, "end_dodge"))
