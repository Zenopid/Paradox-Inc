extends BaseStrike

@export var dash_speed: int = 200

func enter(msg:= {}):
	super.enter()

func physics_process(delta):
	super.physics_process(delta)
	var dir: int
	if entity.sprite.flip_h:
		dir = 1
	else:
		dir = -1
	entity.motion.x = dash_speed * dir
	if frame >= 8:
		emit_signal("leave_state")

func exit():
	super.exit()
