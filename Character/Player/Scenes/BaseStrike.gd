class_name BaseStrike extends Attack

signal leave_state()
var can_cancel:bool = false

var attack_state: Attack
var is_on_floor: bool 
var frame_tracker: int = 1
var perform_attack_logic:bool = true

@export var landing_lag: int = 0
@export var buffer_window: int = 13
@onready var buffer_tracker:int = buffer_window
@export var buffer_attack: String = "None"

@export var lunge_distance:int = 250
@export var dodge_cancellable:bool = true

@export_enum("Ground", "Air") var attack_type: String = "Ground"



func set_attack_state(state):
	attack_state = state

func enter(_msg: = {}):
	if !entity.anim_player.is_connected("animation_finished", Callable(self, "_on_attack_over")):
		entity.anim_player.connect("animation_finished", Callable(self, "_on_attack_over"))
	frame = 0
	buffer_tracker = 0
	entity.anim_player.play(animation_name)
	can_cancel = false

func current_active_hitbox():
	pass

func air_attack_logic():
	if entity.is_on_floor():
		if current_active_hitbox():
			attack_state.apply_lag(landing_lag)
		else:
			attack_state.apply_lag(int(landing_lag/2))

func physics_process(delta):
	if attack_type == "Ground" and !grounded():
		state_machine.transition_to("Fall")
		return
	if Input.is_action_just_pressed("attack"):
		if can_cancel:
			start_buffer_attack()
			return 
		buffer_tracker = buffer_window
	if enter_dodge_state() and frame <= 4 and dodge_cancellable:
		exit()
		return
	entity.motion.x *= friction
	frame += 1
	buffer_tracker = clamp(buffer_tracker, 0, buffer_tracker - 1)

func on_attack_hit(object):
#	print_debug(object)
	if object is Entity and object != entity:
		#if the object is of the enity class, but it's not the entity that spawned the hitbox
		can_cancel = true 

func start_buffer_attack():
	if Input.is_action_pressed("left"):
		entity.sprite.flip_h = true
	elif Input.is_action_pressed("right"):
		entity.sprite.flip_h = false
	attack_state.switch_attack(buffer_attack)
	return

func _on_attack_over(name_of_attack):
	if buffer_tracker > 0 and buffer_attack != "None":
		start_buffer_attack()
	else:
		emit_signal("leave_state")

func exit():
	if entity.anim_player.is_connected("animation_finished", Callable(self, "_on_attack_over")):
		entity.anim_player.disconnect("animation_finished", Callable(self, "_on_attack_over"))
	frame = 0
	buffer_tracker = 0
