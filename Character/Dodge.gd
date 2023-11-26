extends BaseState

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

func enter(_msg: = {}):
	super.enter()
	dodge_timer = state_machine.get_timer("Dodge_Cooldown")
	dodge_timer.wait_time = dodge_cooldown
	entity.anim_player.connect("animation_finished", Callable(self, "end_dodge"))
	jump_node = state_machine.find_state("Jump")
	fall_node = state_machine.find_state("Fall")

func physics_process(delta: float):
	if facing_left():
		entity.motion.x = -dodge_speed
	else:
		entity.motion.x = dodge_speed
	entity.motion.y += jump_node.get_gravity() * delta
	if entity.motion.y > fall_node.maximum_fall_speed:
		entity.motion.y = fall_node.maximum_fall_speed 
	default_move_and_slide()
	if dodge_over:
		if Input.is_action_pressed("jump"):
			state_machine.transition_to("Jump")
			return
		elif !entity.is_on_floor():
			state_machine.transition_to("Fall")
			return
		elif Input.is_action_pressed("crouch"):
			print(-fall_node.max_speed)
			if state_machine.get_timer("Slide_Cooldown").is_stopped():
				if entity.motion.x <= -fall_node.max_speed:
					state_machine.transition_to("Slide")
					return
				elif entity.motion.x >= fall_node.max_speed:
					state_machine.transition_to("Slide")
					return
			state_machine.transition_to("Crouch")
			return
		elif get_movement_input() != 0:
			state_machine.transition_to("Run")
			return
		state_machine.transition_to("Idle")
		return
	elif is_actionable:
		if Input.is_action_pressed("jump"):
			state_machine.transition_to("Jump")
			return
		elif Input.is_action_pressed("crouch"):
			if state_machine.get_timer("Slide_Cooldown").is_stopped() and get_movement_input() != 0:
				if entity.motion.x <= -fall_node.max_speed:
					state_machine.transition_to("Slide")
					return
				elif entity.motion.x >= fall_node.max_speed:
					state_machine.transition_to("Slide")
					return
			state_machine.transition_to("Crouch")
			return
		elif get_movement_input() != 0:
			state_machine.transition_to("Run")
			return

func become_actionable():
	is_actionable = true
	
func end_dodge(_anim_name):
	dodge_over = true

func get_movement_input() -> int:
	var move = Input.get_axis("left", "right")
	return move

func exit():
	entity.sprite.position = Vector2.ZERO
	dodge_timer.start()
	dodge_over = false
	is_actionable = false
	entity.anim_player.disconnect("animation_finished", Callable(self, "end_dodge"))
