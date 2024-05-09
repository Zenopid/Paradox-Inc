extends PlayerBaseStrike

var lag_duration: int
@export var default_landing_lag: int = 4
@export var decelerate_value: float = 0.6

func enter(msg: = {}):
	entity.anim_player.play("Crouch")
	clear_hitboxes()
	if msg.has("duration"):
		lag_duration = msg["duration"]
	else:
		lag_duration = default_landing_lag

func input(event):
	pass

func physics_process(delta):
	if lag_duration <= 0:
		emit_signal("leave_state")
	lag_duration -= 1
	entity.velocity.x *= decelerate_value
#	entity.velocity.y += attack_state.jump_script.get_gravity() * delta

func clear_hitboxes():
	for hitboxes in get_tree().get_nodes_in_group("Player Hitboxes"):
		hitboxes.queue_free()
