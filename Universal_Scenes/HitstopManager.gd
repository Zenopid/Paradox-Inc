class_name HitstopManager extends Node

const HITSTOP_TIMESCALE = 0.05
var hitstop_tracker = 0
var hitstop_active: bool = false 
var duration: int = 0
func _ready():
	set_physics_process(false)
	
func apply_hitstop(amount):
	Engine.time_scale = HITSTOP_TIMESCALE
	hitstop_tracker = 0
	self.duration = amount
	set_physics_process(true)
	hitstop_active = true
	
func _physics_process(delta):
	if in_hitstop():
		hitstop_tracker += 1
		if hitstop_tracker >= duration:
			end_hitstop()
#	print(hitstop_tracker)
		
func end_hitstop():
	Engine.time_scale = 1
	set_physics_process(false)
	hitstop_active = false
	

func in_hitstop():
	return hitstop_active
