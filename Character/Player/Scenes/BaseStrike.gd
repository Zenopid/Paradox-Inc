class_name BaseStrike extends Attack

signal leave_state()
var can_cancel:bool = false

var attack_state: Attack

@export var buffer_window: int = 4
@onready var buffer_tracker:int = buffer_window

@export var buffer_attack: String = "None"

func set_attack_state(state):
	attack_state = state

func enter(_msg: = {}):
	if !entity.anim_player.is_connected("animation_finished", Callable(self, "_on_attack_over")):
		entity.anim_player.connect("animation_finished", Callable(self, "_on_attack_over"))
	frame = 0
	buffer_tracker = 0
	entity.anim_player.play(animation_name)
	set_buffer_attack(buffer_attack)

func physics_process(delta):
#	print_debug(entity.anim_player.is_connected("animation_finished", Callable(self, "_on_attack_over")))
	if can_fall():
		entity.motion.x = 0
		return
	if Input.is_action_just_pressed("attack"):
		buffer_tracker = buffer_window
	if enter_dodge_state() and frame <= 4:
		exit()
		return
	entity.motion.x *= friction
	frame += 1
	buffer_tracker = clamp(buffer_tracker, 0, buffer_tracker - 1)

func on_attack_hit(object):
	print(object)
	if object is Entity:
		can_cancel = true 

func _on_attack_over(attack_name):
	if buffer_tracker > 0 and buffer_attack != "None":
#		print_debug("Should be going to a buffered attack now.")
		if Input.is_action_pressed("left"):
			entity.sprite.flip_h = true
		elif Input.is_action_pressed("right"):
			entity.sprite.flip_h = false
		attack_state.switch_attack(buffer_attack)
		return
	emit_signal("leave_state")

func exit():
	if entity.anim_player.is_connected("animation_finished", Callable(self, "_on_attack_over")):
		entity.anim_player.disconnect("animation_finished", Callable(self, "_on_attack_over"))

	frame = 0
	buffer_tracker = 0
