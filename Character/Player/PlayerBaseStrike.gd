class_name PlayerBaseStrike extends BaseStrike

const STICK_TO_GROUND: int = 140

@onready var hit_sfx:AudioStreamPlayer = $Hit

@export_category("Buffer Variables")
@export var buffer_window: int = 13
@export var buffer_attack: String = "None"
@export var dodge_cancellable:bool = true
@export var dodge_window: int = 4
@export_category("Attack Variables")
@export var lunge_distance:int = 250
@export var hitstop: int = 3
@export_category("Camera")
@export var camera_shake_strength: float = 0
@onready var buffer_tracker:int = buffer_window

var attack_state: PlayerAttack
var can_dodge:bool 
var coyote_timer:Timer

func init(current_entity:Entity):
	entity = current_entity
	attack_state = get_parent()
	coyote_timer = attack_state.state_machine.get_timer("Coyote")

func enter(_msg: = {}):
	super.enter()
	buffer_tracker = 0
	can_dodge = dodge_cancellable

func get_movement_input() -> int:
	var move = Input.get_axis("left", "right")
	if move < 0:
		entity.sprite.flip_h = true
	elif move > 0:
		entity.sprite.flip_h = false
	return move

func on_attack_hit(object):
	if object is Entity and object != entity:
		#if the object is of the enity class, but it's not the entity that spawned the hitbox
		can_cancel = true 
		entity.camera.set_shake(camera_shake_strength)
		GlobalScript.hitstop_manager.apply_hitstop(hitstop)
		hit_sfx.play()

func physics_process(delta: float):
	var was_on_floor = grounded()
	entity = entity as Player
	entity.velocity.y = STICK_TO_GROUND
	super.physics_process(delta)
	if was_on_floor and !grounded() and coyote_timer.is_stopped():
		coyote_timer.start()
	if attack_state.state_machine.state_available("Fall"):
		entity.states.transition_to("Fall")
		return
	buffer_tracker = clamp(buffer_tracker, 0, buffer_tracker - 1)
	if frame >= dodge_window and dodge_window != -1:
		can_dodge = false
	entity.move_and_slide()

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
	attack_state.use_attack(buffer_attack)
	return

func _on_attack_over(name_of_attack:String):
	if !can_cancel:
		emit_signal("attack_whiffed", animation_name)
	if buffer_tracker > 0 and buffer_attack != "None" or buffer_window == -1:
		start_buffer_attack()
	else:
		emit_signal("leave_state")

func exit():
	super.exit()
	buffer_tracker = 0
