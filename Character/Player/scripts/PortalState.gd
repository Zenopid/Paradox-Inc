extends BaseState

var portal_a: Portal
var portal_b: Portal

var active_portal: Portal
var active_portal_name: String

var original_state_name:String 

var original_state: BaseState

func enter(msg: = {}) -> void:
	super.enter()
	original_state= msg["state"]
	var portal_type
	if msg.has("Portal_Type"):
		portal_type = msg["Portal_Type"]
	elif msg.has("portal_type"):
		portal_type = msg["portal_type"]
	active_portal_name = "portal_" + portal_type.to_lower()
	active_portal = get(active_portal_name.to_lower())
	original_state_name = original_state.name
	

func input(event):
	original_state.input(event)
	if !Input.is_action_pressed(active_portal_name):
		state_machine.transition_to(original_state_name,{},"",false, true)

func process(delta):
	original_state.process(delta)
	
func physics_process(delta):
	original_state.physics_process(delta)

func anim_over():
	active_portal.position = get_viewport().get_camera_2d().get_global_mouse_position()
	active_portal.change_portal_state()
	state_machine.transition_to(original_state_name,{},"", false, true)
	return
