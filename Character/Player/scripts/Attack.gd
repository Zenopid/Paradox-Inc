class_name Attack extends BaseState

signal new_attack(attack)

var attack_damage:int = 0
var attack_name: String

var combo_count:int = 1

@export var friction:float = 0.2


var timer = 10
#the attack index is a dict with every attack and their corresponding attack value.

@export var hitbox: PackedScene


var frame: int = 0

var jump_script: Jump

var active_attack:String 
var attack_node: Attack

var has_init:bool = false

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	for nodes in get_children():
		if nodes is BaseStrike:
			nodes.init(current_entity,s_machine)
			nodes.set_attack_state(self)
			nodes.connect("leave_state", Callable(self, "exit_state"))

#func set_parameters(d, w,h,amount, angle, type, af, pos, dur):
func create_hitbox(width, height,damage, kb_amount, angle, duration, type, angle_flipper, points, push, hitlag = 1):
	var hitbox_instance: Hitbox = hitbox.instantiate()
	self.add_child(hitbox_instance)
	get_node(active_attack).connect("hitbox_collided", Callable(self, "on_attack_hit"))
	if entity.sprite.flip_h:
		points = Vector2(-points.x, points.y)
		push = Vector2(-push.x, push.y)
	var hitbox_location = Vector2(entity.position.x + points.x, entity.position.y + points.y)
	hitbox_instance.set_parameters(damage, width, height, kb_amount, angle, type, angle_flipper, hitbox_location, duration, push)
	return hitbox_instance

#this is now a state machine within a state machine.
#here's how it works:
#idk how it works


func enter(msg: = {}):
#	state_machine.battle_stance_timer.start()
	jump_script = state_machine.find_state("Jump")
	animation_name = attack_name
	super.enter()
	frame = 0
	if entity.is_on_floor():
		attack_node = get_node("GroundedAttack1")
	else:
		state_machine.transition_to("Fall")
		return
	frame = 0
	if attack_node:
		attack_node.enter()
		emit_signal("new_attack",attack_node)

func input(event):
	pass
#	if Input.is_action_just_pressed("attack"):
#		if can_cancel:
#			state_machine.transition_to("Attack", {},"", true)
#			return
#		elif can_track_buffer:
#			track_buffer = true
#	if can_cancel:
#		if buffer_tracker > 0 and buffered_attack != "":
#			state_machine.transition_to("Attack", {},"", true)
#			return

func on_attack_hit(object):
	pass

func _on_attack_over(anim_name):
	pass

func physics_process(delta: float) -> void:
	attack_node.physics_process(delta)

func set_buffer_attack(attack_name: String):
	pass
	
func switch_attack(new_attack):
	attack_node.exit()
	attack_node = get_node(new_attack)
	frame = 0
	if attack_node:
		attack_node.enter()
		emit_signal("new_attack",attack_node)

func exit_state():
	if Input.is_action_pressed("jump"):
		state_machine.transition_to("Jump")
		return
	elif enter_crouch_state():
		return
	enter_move_state()
	return

func exit():
	attack_node.exit()
