class_name EntityStateMachine extends Node

signal transitioned(new_state)

var current_state: BaseState 
var previous_state: BaseState

@export var initial_state: String

@export var machine_owner: Entity 

var debug_info: Node2D = null
var state_tracker: Label = null
var motion_tracker: Label = null

var test_num:int = 0

var state_names: = {}
var state_count: int = 0

func init(entity: Entity, debug_node: Node2D):
	for nodes in get_children():
		if nodes is BaseState: 
			state_count += 1
			nodes.init(entity, self)
			state_names[str(state_count)] = nodes.name
	if initial_state:
		current_state = get_node(initial_state)
	else:
		current_state = get_node("Idle")
	current_state.enter()
	debug_info = debug_node
	state_tracker = debug_node.get_node_or_null("StateTracker")
	motion_tracker = debug_node.get_node_or_null("MotionTracker")
func physics_update(delta):
	current_state.physics_process(delta)
	if motion_tracker:
		motion_tracker.text ="Speed: " + str(round(machine_owner.motion.x)) + "," + str(round(machine_owner.motion.y))

func update(delta):
	current_state.process(delta)

func input(event: InputEvent):
	current_state.input(event)
	
func transition_to(target_state_name: String = "", msg: = {}, trans_anim: String = "", overide: bool = false, call_enter: bool = true):
	if target_state_name != current_state.name or overide:
		current_state.exit()
		if get_node(target_state_name) is State:
			current_state = get_node(target_state_name)
			if trans_anim:
				machine_owner.anim_player.play(trans_anim)
				await machine_owner.anim_player.animation_finished
			if call_enter:
				current_state.enter(msg)
			if machine_owner.state_tracker:
				machine_owner.state_tracker.text ="State: " + str(current_state.name)
		else:
			print("Couldn't find state " + target_state_name)
func find_state(state):
	if get_node(state):
		return get_node(state)

func set_timer(timer, wait_time):
	var state_timer: Timer = get_node("Timers/" + timer)
	state_timer.wait_time = wait_time

func get_timer(timer) -> Timer:
	var state_timer: Timer = get_node("Timers/" + timer)
	if state_timer:
		return state_timer
	return
func get_raycast(raycast) -> RayCast2D:
	var state_raycast: RayCast2D = get_node("Raycasts/" + raycast)
	if state_raycast:
		return state_raycast
	return 

func get_current_state():
	return current_state