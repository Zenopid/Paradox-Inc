extends BaseState

@export_range(0.75, 0.99) var weight: float = 0.85
var hitstun_tracker:int = 0
var time_until_velocity_decay: int

func enter(msg: = {}):
	
	hitstun_tracker = msg["hitstun"]
	super.enter()
	if msg["knockback"] != Vector2.ZERO:
		entity.velocity = msg["knockback"]
	time_until_velocity_decay = hitstun_tracker/2 + 1
	
	
func input(event:InputEvent):
	pass

func process(delta:float):
	pass

func physics_process(delta:float):
	super.physics_process(delta)
	entity.move_and_slide()
	if time_until_velocity_decay <= 0:
		time_until_velocity_decay = 0
		entity.velocity *= weight

func on_animation_over():
	print(str(hitstun_tracker) + " frames remaining.")
	if hitstun_tracker <= 0:
		exit_hitstun()
	else:
		hitstun_tracker -= 1
		time_until_velocity_decay -= 1
		entity.anim_player.play(animation_name)
		
func exit_hitstun():
	pass #virtual method
	
