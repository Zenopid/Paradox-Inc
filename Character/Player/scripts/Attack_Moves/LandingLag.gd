extends BaseStrike

var lag_duration: int

func enter(msg: = {}):
	entity.anim_player.play("Crouch")
	attack_state.clear_hitboxes()
	if msg.has("duration"):
		lag_duration = msg["duration"]

func input(event):
	pass

func physics_process(delta):
	lag_duration -= 1
	if lag_duration <= 0:
		emit_signal("leave_state")
	entity.motion.y += attack_state.jump_script.get_gravity() * delta
