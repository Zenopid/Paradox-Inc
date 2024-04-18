extends BaseState

var teleport_location: Vector2 

var begin_teleport: bool = false
var exit_state:bool = false
var chase_script

@export var teleport_distance: int = 400
var los_raycast: RayCast2D



func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	chase_script = state_machine.find_state("Chase")
	los_raycast = state_machine.get_raycast("LOS")
	
func enter(msg: = {}):
	if !entity.anim_player.is_connected( "animation_finished", Callable (self, "on_tp_anim_over") ):
		entity.anim_player.connect("animation_finished", Callable(self, "on_tp_anim_over"))
	if msg.has("Location"):
		teleport_location = msg["Location"]
	else:
		print_debug("There's no location to teleport to. Returning.")
		state_machine.transition_to("Idle")
		return
	entity.motion = Vector2.ZERO
	begin_teleport = false
	exit_state = false

func physics_process(delta:float):
	if begin_teleport:
		entity.position = teleport_location
	if exit_state:
		var tween = get_tree().create_tween()
		var dir = -1 if entity.sprite.flip_h else 1
		tween.tween_property(los_raycast,"rotation", deg_to_rad(180 * dir), 0.01)
		if los_raycast.is_colliding():
			tween.kill()
			los_raycast.rotation = deg_to_rad(0)
			state_machine.transition_to("Chase")
			return
		state_machine.transition_to("Chase",{}, "", false, false)
		return
	else:
		state_machine.transition_to("Idle")
		return
			
func move_body():
	begin_teleport = true

func on_tp_anim_over(anim):
	exit_state = true

func get_tp_distance():
	return teleport_distance
