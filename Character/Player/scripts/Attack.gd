class_name PlayerAttack extends PlayerBaseState

signal new_attack(attack_name)

@export var friction:float = 0.2


var timer = 10

@export var hitbox: PackedScene



var frame: int = 0

var jump_script

var active_attack: BaseStrike

var has_init:bool = false

var ground_checker: RayCast2D 

var temp_position: Vector2

 

var active_hitboxes: = []
var hitbox_positions: = []
var num_of_active_hitboxes: int

var test_num:int = 0

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	for nodes in get_children():
		if nodes is BaseStrike:
			nodes.init(entity)
			nodes.set_attack_state(self)
			nodes.connect("leave_state", Callable(self, "exit_state"))
	
	jump_script = state_machine.find_state("Jump")
	ground_checker = state_machine.get_raycast("GroundChecker")

func create_hitbox(width, height,damage, kb_amount, angle, duration, type, angle_flipper, points, push, hitlag = 1):
	var hitbox_instance: Hitbox = hitbox.instantiate()
	if entity.sprite.flip_h:
		points = Vector2(-points.x, points.y)
		push = Vector2(-push.x, push.y)
	var hitbox_location = Vector2(entity.position.x + points.x, entity.position.y + points.y)
	add_child(hitbox_instance)
	hitbox_instance.set_parameters(damage, width, height, kb_amount, angle, type, angle_flipper, hitbox_location, duration, push)
	if active_attack:
		hitbox_instance.connect("hitbox_collided", Callable(active_attack, "on_attack_hit"))
	else:
		print("there's no attack.")
	num_of_active_hitboxes += 1
	return hitbox_instance

func enter(msg: = {}):
	temp_position = ground_checker.target_position
	ground_checker.target_position.y += 3
	#just to make attacks more consistant. sometimes they wouldn't work on slopes
	#cuz of hurtbox shifts
	entity.set_collision_mask_value(4,false)
	super.enter()
	if entity.is_on_floor():
		switch_attack("GroundedAttack1")
	else:
		if Input.is_action_pressed("crouch"):
			switch_attack("GroundPound")
		else:
			switch_attack("AirAttack1")

func on_attack_hit(object):
	pass

func _on_attack_over(anim_name):
	pass

func physics_process(delta: float) -> void:
	if enter_dodge_state() and active_attack.dodge_cancellable:
		active_attack.exit()
		return
	if active_attack:
		active_attack.physics_process(delta)
	default_move_and_slide()
	ground_checker.position = Vector2(entity.position.x, entity.position.y + 13.5)
	
func switch_attack(attack_name):
	if active_attack:
		active_attack.exit()
	if has_node(attack_name):
		active_attack = get_node(attack_name)
	if active_attack:
		active_attack.enter()
		emit_signal("new_attack",active_attack.name)

func exit_state():
	if Input.is_action_pressed("jump"):
		if jump_script.remaining_jumps > 0:
			state_machine.transition_to("Jump")
			return
	elif Input.is_action_pressed("dodge") and state_machine.get_timer("Dodge_Cooldown").is_stopped():
		state_machine.transition_to("Dodge")
		return
	elif enter_crouch_state():
		return
	elif !grounded():
		state_machine.transition_to("Fall")
		return
	enter_move_state()
	return
	
func clear_hitboxes():
	for nodes in entity.get_children():
		if nodes is Hitbox:
			nodes.queue_free()

func apply_lag(amount):
	if active_attack:
		active_attack.exit()
	active_attack = get_node("LandingLag")
	active_attack.enter({duration = amount})

func exit():
	if active_attack:
		active_attack.exit()
	entity.set_collision_mask_value(4, true)
	ground_checker.target_position = temp_position

