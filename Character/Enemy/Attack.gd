class_name DarkStalkerAttack extends BaseState

signal new_attack(attack_name)

var timer = 10

@export var hitbox: PackedScene
@export var current_entity: Entity

var frame: int = 0

var active_attack: BaseStrike

var has_init:bool = false

var ground_checker: RayCast2D 

var temp_position: Vector2

var jump_script

var num_of_active_hitboxes: int

var test_num:int = 0

var los_raycast: RayCast2D

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	los_raycast = state_machine.get_raycast("LOS")
	ground_checker = state_machine.get_raycast("GroundChecker")
	
func create_hitbox(width, height,damage, kb_amount, angle, duration, type, angle_flipper, points, push, hitlag = 1):
	var hitbox_instance: Hitbox = hitbox.instantiate()
	if current_entity.sprite.flip_h:
		points = Vector2(-points.x, points.y)
		push = Vector2(-push.x, push.y)
	var hitbox_location = Vector2(current_entity.position.x + points.x, current_entity.position.y + points.y)
	entity.add_child(hitbox_instance)
	hitbox.call("set_" + entity.current_timeline.to_lower() +"_collision")
	hitbox_instance.set_parameters(damage, width, height, kb_amount, angle, type, angle_flipper, hitbox_location, duration, push, hitlag)
	if active_attack:
		hitbox_instance.connect("hitbox_collided", Callable(active_attack, "on_attack_hit"))
	hitbox_instance.add_to_group(current_entity.name + " Hitboxes")
	return hitbox_instance

func enter(msg: = {}):
	temp_position = ground_checker.target_position
	ground_checker.target_position.y += 3
	#just to make attacks more consistant. sometimes they wouldn't work on slopes
	#cuz of hurtbox shifts
	entity.set_collision_mask_value(4,false)
	super.enter()
	switch_attack("GroundedAttack")

func on_attack_hit(object):
	pass

func _on_attack_over(anim_name):
	pass

func physics_process(delta: float) -> void:
	if active_attack:
		active_attack.physics_process(delta)
	ground_checker.position = Vector2(current_entity.position.x, entity.position.y + 13.5)
	default_move_and_slide()
	
	
func switch_attack(attack_name):
	if active_attack:
		active_attack.exit()
	if has_node(attack_name):
		active_attack = get_node(attack_name)
	if active_attack:
		active_attack.enter()
		emit_signal("new_attack",active_attack.name)

func clear_hitboxes():
	for nodes in get_tree().get_nodes_in_group(current_entity.name + " Hitboxes"):
		nodes.queue_free()

func exit():
	if active_attack:
		active_attack.exit()
	entity.set_collision_mask_value(4, true)
	ground_checker.target_position = temp_position


