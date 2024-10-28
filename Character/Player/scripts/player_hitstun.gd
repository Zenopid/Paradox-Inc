extends "res://Character/Hitstun.gd"

func input(event):
	entity = entity as Player
	if Input.is_action_just_pressed("jump"):
		state_machine.get_timer("Jump_Buffer").start()
	if Input.is_action_just_released("crouch"):
		state_machine.get_timer("Superjump").start()
	if Input.is_action_just_pressed("dodge"):
		state_machine.get_timer("Dodge_Buffer").start()
	if Input.is_action_just_pressed("attack"):
		state_machine.get_timer("Attack_Buffer").start()

func exit_hitstun():
	state_machine.transition_if_available([
		"Attack",
		"Fall",
		"Jump",
		"Slide",
		"Crouch",
		"Run",
		"Idle",
	])
