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
	if dodge_over or is_actionable:
		leave_dodge()

func leave_dodge():
	if enter_jump_state():
		return
	elif enter_dodge_state():
		return
	elif enter_crouch_state():
		return
	enter_move_state()
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
