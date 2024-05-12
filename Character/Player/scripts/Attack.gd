class_name PlayerAttack extends PlayerBaseState

signal new_attack(attack_name)

@onready var landing_lag = $LandingLag

@export var hitbox: PackedScene

var frame: int = 0

var jump_script: Jump
var fall_script: Fall

var active_attack: BaseStrike

var has_init:bool = false

var ground_checker: RayCast2D 

var temp_position: Vector2
var timer = 10

var hitbox_positions: = []
var num_of_active_hitboxes: int

var test_num:int = 0

var attack_options = {}
func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	jump_script = state_machine.find_state("Jump")
	fall_script = state_machine.find_state("Fall")
	ground_checker = state_machine.get_raycast("GroundChecker")
	for nodes in get_children():
		nodes.init(entity)
		nodes.connect("leave_state", Callable(self, "exit_state"))
		attack_options[nodes.name] = nodes

func create_hitbox(hitbox_info:= {}):
	if entity.sprite.flip_h:
		hitbox_info["position"].x  *= -1
	hitbox_info["hitbox_owner"] = entity
#	var hitbox_location = Vector2(entity.position.x + points.x, entity.position.y + points.y)
#	var hitbox_location = points
	var hitbox_instance: Hitbox = hitbox.instantiate()
	entity.add_child(hitbox_instance)
	hitbox_instance.set_parameters(hitbox_info)

	hitbox_instance.call("set_" + entity.get_level().current_timeline.to_lower() + "_collision")
	if active_attack:
		hitbox_instance.connect("hitbox_collided", Callable(active_attack, "on_attack_hit"))
	hitbox_instance.add_to_group("Player Hitboxes")
	return hitbox_instance

func enter(msg: = {}):
	temp_position = ground_checker.target_position
	ground_checker.target_position.y += 3
	#just to make attacks more consistant. sometimes they wouldn't work on slopes
	#cuz of hurtbox shifts
	super.enter()
	if entity.is_on_floor():
		use_attack("GroundedAttack1")
	else:
		if Input.is_action_pressed("crouch"):
			return use_attack("GroundPound")
		use_attack("AirAttack1")

func input(event: InputEvent):
	active_attack.input(event)

func on_attack_hit(object):
	pass

func _on_attack_over(anim_name):
	pass

func physics_process(delta: float) -> void:
	if enter_dodge_state() and active_attack.can_dodge:
		active_attack.exit()
		return
	if active_attack:
		active_attack.physics_process(delta)
	ground_checker.position = Vector2(entity.position.x, entity.position.y + 13.5)
	
func use_attack(attack_name) -> bool:
	if active_attack:
		active_attack.exit()
	if attack_options.has(attack_name):
		active_attack = attack_options[attack_name]
		active_attack.enter()
		emit_signal("new_attack",active_attack.name)
		return true
	return false

func exit_state():
	if Input.is_action_pressed("jump"):
		if jump_script.remaining_jumps > 0:
			state_machine.transition_to("Jump")
			return
	elif enter_dodge_state():
		return
	elif enter_crouch_state():
		return
	elif !grounded():
		state_machine.transition_to("Fall")
		return
	enter_move_state()
	return
	
func clear_hitboxes():
	for nodes in get_tree().get_nodes_in_group("Player Hitboxes"):
		nodes.queue_free()

func apply_lag(amount):
	if active_attack:
		active_attack.exit()
	active_attack = landing_lag
	active_attack.enter({duration = amount})

func exit():
	if active_attack:
		active_attack.exit()
	ground_checker.target_position = temp_position
