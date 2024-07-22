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

var timer_nodes: = {}
var ray_nodes: = {}
var shapecast_nodes: = {}

var states_with_inactive_process: = {}

var process_state:bool = true 
func init(debug_node: Node2D = null):
	for nodes in get_node("Timers").get_children():
		timer_nodes[nodes.name] = nodes
	for nodes in get_node("Raycasts").get_children():
		ray_nodes[nodes.name] = nodes
	var shapecast_node = get_node_or_null("ShapeCasts")
	if shapecast_node:
		for nodes in shapecast_node.get_children():
			shapecast_nodes[nodes.name] = nodes
	for nodes in get_children():
		if nodes is BaseState:
			state_nodes[nodes.name] = nodes
			if state_nodes[nodes.name].has_inactive_process:
				states_with_inactive_process[nodes.name] = nodes
	for states in state_nodes.keys():
		get_node(states).init(machine_owner, self)
	current_state = get_node(initial_state)
	current_state.enter()
	debug_info = debug_node
	if debug_node:
		state_tracker = debug_node.get_node("StateTracker")
		motion_tracker = debug_node.get_node("MotionTracker")
		state_tracker.text = "State: " + str(initial_state)
	state_nodes.make_read_only()
	timer_nodes.make_read_only()
	ray_nodes.make_read_only()

func physics_update(delta:float):
	current_state.physics_process(delta)
	for state in states_with_inactive_process.keys():
		if state == current_state.name:
			continue
		states_with_inactive_process[state].inactive_process(delta)
	if motion_tracker:
		motion_tracker.text ="Speed: " + str(round(machine_owner.velocity.x)) + "," + str(round(machine_owner.velocity.y))
	
func update(delta: float):
	current_state.process(delta)

func input(event: InputEvent):
	current_state.input(event)
	
func transition_to(target_state_name: String = "", msg: = {}, trans_anim: String = ""):
	if !state_nodes.has(target_state_name):
		push_error("Cannot find state name " + target_state_name)
		return
	if target_state_name != current_state.name:
		current_state.exit()
		previous_state = current_state
		current_state = state_nodes[target_state_name]
		if trans_anim:
			machine_owner.anim_player.play(trans_anim)
			await machine_owner.anim_player.animation_finished
		current_state.enter(msg)
		state_tracker.text = "State: " + str(current_state.name)
		#emit_signal("transitioned", current_state)
		#print("Transitioning from state " + previous_state.name + " to state " + current_state.name)
	

func find_state(state:String) -> BaseState:
	var desired_state = state_nodes[state]
	if desired_state:
		return desired_state
	return 

func set_timer(timer:String, wait_time: float):
	var desired_timer = timer_nodes[timer]
	if desired_timer:
		desired_timer.wait_time = wait_time

func get_timer(timer:String) -> Timer:
	if timer_nodes.has(timer):
		return timer_nodes[timer]
	return

func get_raycast(raycast:String) -> RayCast2D:
	if ray_nodes.has(raycast):
		return ray_nodes[raycast]
	return

func get_shapecast(shapecast:String) -> ShapeCast2D:
	if shapecast_nodes.has(shapecast):
		return shapecast_nodes[shapecast]
	return

func get_current_state():
	return current_state

func get_all_states():
	return state_nodes
	
func state_available(state_name:String) -> bool:
	var state_to_check:BaseState = state_nodes[state_name]
	if !typeof(state_to_check) == TYPE_NIL:
		return state_to_check.conditions_met()
	push_error("Couldn't find state " + state_name)
	return false 

func transition_if_available(state_names:= []) -> bool:
	if state_names != []:
		for state in state_names:
			if state_available(state):
				transition_to(state)
				return true 
	return false
