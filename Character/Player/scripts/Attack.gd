class_name Attack extends BaseState

signal new_attack(attack)

var attack_damage:int = 0
var attack_name: String

var combo_count:int = 1

@export var friction:float = 0.2


var timer = 10
#the attack index is a dict with every attack and their corresponding attack value.

@export var hitbox: PackedScene

var number_of_active_hitboxes: int = 0


var frame: int = 0

var jump_script: Jump

var active_attack:BaseStrike 

var has_init:bool = false

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	for nodes in get_children():
		if nodes is BaseStrike:
			nodes.init(current_entity,s_machine)
			nodes.set_attack_state(self)
			nodes.connect("leave_state", Callable(self, "exit_state"))
			nodes.hitbox = hitbox
	jump_script = state_machine.find_state("Jump")

func create_hitbox(width, height,damage, kb_amount, angle, duration, type, angle_flipper, points, push, hitlag = 1):
	var facing: int = 1
	if entity.sprite.flip_h:
		facing = -1
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
	return hitbox_instance

func enter(msg: = {}):
	entity.set_collision_mask_value(4,false)
	animation_name = attack_name
	super.enter()
	frame = 0
	if entity.is_on_floor():
		switch_attack("GroundedAttack1")
	else:
		state_machine.transition_to("Fall")
		return
	frame = 0

func on_attack_hit(object):
	pass

func _on_attack_over(anim_name):
	pass

func physics_process(delta: float) -> void:
	active_attack.physics_process(delta)

func set_buffer_attack(attack_name: String):
	pass
	
func switch_attack(attack_name):
	if active_attack:
		active_attack.exit()
	active_attack = get_node(attack_name)
	frame = 0
	if active_attack:
		active_attack.enter()
		emit_signal("new_attack",active_attack.name)

func exit_state():
	if Input.is_action_pressed("jump"):
		state_machine.transition_to("Jump")
		return
	elif Input.is_action_pressed("dodge") and state_machine.get_timer("Dodge_Cooldown").is_stopped():
		state_machine.transition_to("Dodge")
		return
	elif enter_crouch_state():
		return
	enter_move_state()
	return

func exit():
	if active_attack:
		active_attack.exit()
	entity.set_collision_mask_value(4, true)

