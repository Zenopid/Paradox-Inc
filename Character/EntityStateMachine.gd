class_name EntityStateMachine extends Node

signal transitioned(new_state)

var current_state: BaseState 
var previous_state: BaseState

@export var initial_state: String

@export var machine_owner: Entity 

var debug_info: Node2D = null
var state_tracker: Label = null
var motion_tracker: Label = null

var state_nodes: = {}

var timer_nodes = {}
var ray_nodes = {}

var can_transition:bool = true 

func init(entity: Entity, debug_node: Node2D = null):
	for nodes in get_node("Timers").get_children():
		timer_nodes[nodes.name] = nodes
	for nodes in get_node("Raycasts").get_children():
		ray_nodes[nodes.name] = nodes
	for nodes in get_children():
		if nodes is BaseState:
			state_nodes[nodes.name] = nodes
	for nodes in get_children():
		if nodes is BaseState: 
			nodes.init(entity, self)
	current_state = get_node(initial_state)
	if !current_state:
		current_state = get_node("Idle")
	current_state.enter()
	debug_info = debug_node
	if debug_node:
		state_tracker = debug_node.get_node_or_null("StateTracker")
		motion_tracker = debug_node.get_node_or_null("MotionTracker")

	state_nodes.make_read_only()
	timer_nodes.make_read_only()
	ray_nodes.make_read_only()

func physics_update(delta):
	current_state.physics_process(delta)
	motion_tracker.text ="Speed: " + str(round(machine_owner.motion.x)) + "," + str(round(machine_owner.motion.y))

func update(delta):
	current_state.process(delta)

func input(event: InputEvent):
	current_state.input(event)
	
func transition_to(target_state_name: String = "", msg: = {}, trans_anim: String = "", overide: bool = false, call_enter: bool = true):
	if can_transition:
		if target_state_name != current_state.name or overide:
			current_state.exit()
			if get_node(target_state_name) is State:
				current_state = get_node(target_state_name)
				if trans_anim:
					machine_owner.anim_player.play(trans_anim)
					await machine_owner.anim_player.animation_finished
				if call_enter:
					current_state.enter(msg)
				if debug_info:
					debug_info.get_node("StateTracker").text = "State: " + str(current_state.name)
				emit_signal("transitioned", current_state)
			else:
				print("Couldn't find state " + target_state_name)
	else:
		print_debug("Couldn't transition to state " + target_state_name +  " as the state machine is locked.")
#
#func get_state_names():
#	return state_names

func find_state(state:String) -> BaseState:
	#print(state_nodes)
	var desired_state = state_nodes[state]
	if desired_state:
		return desired_state
	return 

func set_timer(timer:String, wait_time: float):
	var desired_timer = timer_nodes[timer]
	if desired_timer:
		desired_timer.wait_time = wait_time

func get_timer(timer:String) -> Timer:
	var desired_timer = timer_nodes[timer]
	if desired_timer:
		return desired_timer
	return

func get_raycast(raycast:String) -> RayCast2D:
	var desired_raycast = ray_nodes[raycast]
	if desired_raycast:
		return desired_raycast
	return

func get_current_state():
	return current_state
	
func lock_into_current_state():
	can_transition = false 
