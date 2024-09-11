extends PlayerBaseState

@onready var cooldown_timer: Timer
@onready var superjump_timer:Timer

@export var dodge_boost: int = 25
@export var dodge_speed: int = 50
@export var inital_fall_speed: int = 100
@export var dodge_cooldown: float = 0.9

var facing: String 

var is_actionable:bool = false
var dodge_over: bool = false

var jump_node: Jump
var fall_node: Fall
var jump_buffer:Timer
var dodge_buffer:Timer

var bunny_hop_boost: float 
var frame_tracker: int = 0

var hurtbox_area:Area2D

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	jump_node = state_machine.find_state("Jump")
	fall_node = state_machine.find_state("Fall")
	cooldown_timer = state_machine.get_timer("Dodge_Cooldown")
	superjump_timer = state_machine.get_timer("Superjump")
	jump_buffer = state_machine.get_timer("Jump_Buffer")
	dodge_buffer = state_machine.get_timer("Dodge_Buffer")
	cooldown_timer.wait_time = dodge_cooldown
	bunny_hop_boost = fall_node.bunny_hop_boost
	hurtbox_area = current_entity.get_node("HurtboxArea")

func enter(_msg: = {}):
	super.enter()
	var move = get_movement_input()
	frame_tracker = 0
	entity.velocity.y = clamp(entity.velocity.y, inital_fall_speed, fall_node.maximum_fall_speed)
	if move < 0:
		if entity.velocity.x > 0:
			entity.velocity.x = 0
	else:
		if entity.velocity.x < 0:
			entity.velocity.x = 0
	entity.velocity.x += dodge_boost * move
	
func physics_process(delta: float):
	entity = entity as Player
	frame_tracker += 1
	entity.velocity.y += jump_node.get_gravity() 
	entity.velocity.y = clamp(entity.velocity.y, 0, fall_node.maximum_fall_speed)
	entity.move_and_slide()
	if is_actionable:
		if !entity.entity_near():
			state_machine.transition_if_available([
					"Attack",
					"Jump",
					"Slide",
					"Crouch",
					"Run", 
				])
	if abs(entity.velocity.x) < dodge_speed: 
		entity.velocity.x = dodge_speed * get_facing_as_int()
	print(entity.invlv_type)

func leave_dodge():
	if !grounded():
		state_machine.transition_if_available([
			"Jump",
			"Fall",
			"Idle", #Contingency
			])
	else:
		state_machine.transition_if_available([
			"Jump",
			"Slide",
			"Crouch",
			"Run", 
			"Idle",
		])

func input(event):
	if is_actionable:
		if !Input.is_action_pressed("dodge"): 
			if !grounded():
				state_machine.transition_to("Fall")
			else:
				state_machine.transition_if_available([
					"Jump",
					"Slide",
					"Crouch",
					"Run",
					"Idle",
				])

func become_actionable():
	is_actionable = true 

func get_movement_input() -> float:
	return Input.get_axis("left", "right")

func exit():
	entity.sprite.position = Vector2.ZERO
	cooldown_timer.start()
	dodge_over = false
	is_actionable = false
	set_proj_invlv(false)
	set_strike_invlv(false)
	entity.set_invlv_type("None")	

func set_proj_invlv(status:bool):
	if entity.current_timeline == "Future":
		hurtbox_area.set_collision_layer_value(GlobalScript.collision_values.PLAYER_PROJ_HURTBOX_FUTURE, status)
		hurtbox_area.set_collision_layer_value(GlobalScript.collision_values.PLAYER_PROJ_HURTBOX_PAST, false)
	else:
		hurtbox_area.set_collision_layer_value(GlobalScript.collision_values.PLAYER_PROJ_HURTBOX_FUTURE, false)
		hurtbox_area.set_collision_layer_value(GlobalScript.collision_values.PLAYER_PROJ_HURTBOX_PAST, status)


func set_strike_invlv(status:bool):
	if entity.current_timeline == "Future":
		hurtbox_area.set_collision_layer_value(GlobalScript.collision_values.PLAYER_STRIKE_HURTBOX_FUTURE, status)
		hurtbox_area.set_collision_layer_value(GlobalScript.collision_values.PLAYER_STRIKE_HURTBOX_PAST, false)
	else:
		hurtbox_area.set_collision_layer_value(GlobalScript.collision_values.PLAYER_STRIKE_HURTBOX_FUTURE, false)
		hurtbox_area.set_collision_layer_value(GlobalScript.collision_values.PLAYER_STRIKE_HURTBOX_PAST, status)



func conditions_met() -> bool:
	if cooldown_timer.is_stopped():
		if !dodge_buffer.is_stopped() or Input.is_action_just_pressed("dodge"):
			return true
	return false
