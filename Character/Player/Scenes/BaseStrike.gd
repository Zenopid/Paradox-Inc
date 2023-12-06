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
	buffer_tracker = 0
	if !entity.anim_player.is_connected("animation_finished", Callable(self, "_on_attack_over")):
		entity.anim_player.connect("animation_finished", Callable(self, "_on_attack_over"))
	entity.anim_player.play(animation_name)
	set_buffer_attack(buffer_attack)

func physics_process(delta):
	if Input.is_action_just_pressed("attack"):
		buffer_tracker = buffer_window
	buffer_tracker -= 1
	if buffer_tracker <= 0:
		buffer_tracker = 0

func on_attack_hit(object):
	if object is Entity:
		can_cancel = true 

func _on_attack_over(attack_name):
#	if buffer_attack != "":
#		if buffer_tracker != 0:
#			attack_state.switch_attack(buffer_attack)
	if buffer_tracker > 0 and buffer_attack != "None":
		attack_state.switch_attack(buffer_attack)
		return
	emit_signal("leave_state")


func exit():
	buffer_tracker = 0
	if entity.anim_player.is_connected("animation_finished", Callable(self, "_on_attack_over")):
		entity.anim_player.disconnect("animation_finished", Callable(self, "_on_attack_over"))
