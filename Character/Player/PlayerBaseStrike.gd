class_name PlayerBaseStrike extends BaseStrike

@export_category("Buffer Variables")
@export var buffer_window: int = 13
@export var buffer_attack: String = "None"
@export var dodge_cancellable:bool = true
@export_category("")
@export var lunge_distance:int = 250
@export var hitstop: int = 3
#@export var landing_lag: int = 0
@export_category("Camera")
@export var camera_shake_strength: float = 0
@onready var buffer_tracker:int = buffer_window

var attack_state: PlayerAttack
func init(current_entity:Entity):
	entity = current_entity
	attack_state = current_entity.states.find_state("Attack")

func enter(_msg: = {}):
	super.enter()
	buffer_tracker = 0

func get_movement_input() -> int:
	var move = Input.get_axis("left", "right")
	if move < 0:
		entity.sprite.flip_h = true
	elif move > 0:
		entity.sprite.flip_h = false
	return move

func on_attack_hit(object):
#	print_debug(object)
	if object is Entity and object != entity:
		#if the object is of the enity class, but it's not the entity that spawned the hitbox
		can_cancel = true 
		entity.camera.set_shake(camera_shake_strength)

func physics_process(delta: float):
	super.physics_process(delta)
	if !grounded():
		entity.states.transition_to("Fall")
		return
	buffer_tracker = clamp(buffer_tracker, 0, buffer_tracker - 1)

func input(event):
	super.input(event)
	if Input.is_action_just_pressed("attack"):
		buffer_tracker = buffer_window
		if can_cancel and buffer_attack != "None":
			start_buffer_attack()
			return 

func start_buffer_attack():
	if Input.is_action_pressed("left"):
		entity.sprite.flip_h = true
	elif Input.is_action_pressed("right"):
		entity.sprite.flip_h = false
	attack_state.switch_attack(buffer_attack)
	return

func _on_attack_over(name_of_attack):
	if !can_cancel:
		emit_signal("attack_whiffed", animation_name)
	if buffer_tracker > 0 and buffer_attack != "None" or buffer_window == -1:
		start_buffer_attack()
	else:
		emit_signal("leave_state")

func exit():
	super.exit()
	buffer_tracker = 0
