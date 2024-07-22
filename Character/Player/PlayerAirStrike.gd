class_name PlayerAirStrike extends BaseStrike


@export_category("Buffer Variables")
@export var buffer_window: int = 13
@export var buffer_attack: String = "None"
@export var dodge_cancellable:bool = true
@export var dodge_window: int = 3
@export_category("Camera")
@export var camera_shake_strength: float = 0

@export_category("Air Attack Properties")
@export var gravity_modifier: float = 1.0
@export var landing_lag: int  = 2
@export_category("")
@export var hitstop: int = 3

var max_speed: int = 250
var air_acceleration: int = 10
var attack_state: PlayerAttack
var jump_script_gravity: float
var buffer_tracker = buffer_window
var can_dodge:bool 
var jump_node: Jump
var fall_node: Fall


func init(current_entity:Entity):
	
	super.init(current_entity)
	attack_state = current_entity.states.find_state("Attack")
	max_speed = attack_state.jump_script.max_speed
	air_acceleration = attack_state.jump_script.air_acceleration
	jump_node = current_entity.states.find_state("Jump")
	fall_node = current_entity.states.find_state("Fall")

func air_attack_logic():
	
	if get_movement_input() != 0:
		if entity.sprite.flip_h:
			if entity.velocity.x > -max_speed:
				entity.velocity.x -= air_acceleration
				if entity.velocity.x < -max_speed:
					entity.velocity.x = -max_speed
		else:
			if entity.velocity.x < max_speed:
				entity.velocity.x += air_acceleration
				if entity.velocity.x > max_speed:
					entity.velocity.x = max_speed

	if entity.is_on_floor():
		if current_active_hitbox():
			attack_state.apply_lag(landing_lag)
		else:
			attack_state.apply_lag(roundi((landing_lag/2)))
	entity.velocity.y = clamp(entity.velocity.y, entity.velocity.y + jump_node.get_gravity(), fall_node.maximum_fall_speed)
	entity.move_and_slide()


func physics_process(delta):
	air_attack_logic()
	super.physics_process(delta)
	buffer_tracker = clamp(buffer_tracker, 0, buffer_tracker - 1)

	if frame >= dodge_window and dodge_window != -1:
		can_dodge = false


func get_movement_input() -> int:
	var move = Input.get_axis("left", "right")
	if move < 0:
		entity.sprite.flip_h = true
	elif move > 0:
		entity.sprite.flip_h = false
	return move

func on_attack_hit(object):
	if object is Entity and object != entity:
		#if the object is of the entity class, but it's not the entity that spawned the hitbox
		can_cancel = true 
		entity.camera.set_shake(camera_shake_strength)

func enter(_msg: = {}):
	super.enter()
	buffer_tracker = 0
	can_dodge = dodge_cancellable

func input(event):
	super.input(event)
	if Input.is_action_just_pressed("attack"):
		buffer_tracker = buffer_window
		if can_cancel and buffer_attack != "None":
			start_buffer_attack()
			return 

func start_buffer_attack():
	var axis = Input.get_axis("left", "right")
	entity.sprite.flip_h = axis < 0
	attack_state.use_attack(buffer_attack)
	return

func _on_attack_over(name_of_attack:String):
	if !can_cancel:
		emit_signal("attack_whiffed", animation_name)
	if buffer_attack != "None":
		if buffer_tracker > 0 or buffer_window == -1:
			start_buffer_attack()
			return
	attack_state.state_machine.transition_if_available([
		"Jump",
		"Dodge",
		"Fall"
	])

func exit():
	super.exit()
	buffer_tracker = 0

