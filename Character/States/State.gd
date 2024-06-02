class_name State extends Node

var entity: Entity

@export var has_inactive_process:bool = false 

func enter(_msg: = {}) -> void:
	pass
	
func physics_process(_delta: float) -> void:
	pass

func process(_delta: float) -> void:
	pass 

func inactive_process(_delta:float) -> void:
	pass
	
func input(_event: InputEvent) -> void:
	pass
	
func exit() -> void:
	pass
