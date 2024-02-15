class_name GeneralManager extends Node

var hitstop_frames_remaining: int = 0
var HITSTOP_TIMESCALE: float = 0.2
var in_hitstop: bool = false

func apply_hitstop(duration):
	print_debug("Applying hitstop...")
	hitstop_frames_remaining = duration
	Engine.time_scale = HITSTOP_TIMESCALE
	in_hitstop = true 
	
func remove_hitstop():
	print_debug("Removing hitstop...")
	in_hitstop = false
	Engine.time_scale = 1
	hitstop_frames_remaining = 0

func _physics_process(delta):
	if in_hitstop:
		print(hitstop_frames_remaining)
		hitstop_frames_remaining -= 1
		if hitstop_frames_remaining <= 0:
			remove_hitstop()
