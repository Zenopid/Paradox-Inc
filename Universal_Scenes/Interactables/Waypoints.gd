@tool

extends Path2D

@onready var path_to_follow:PathFollow2D = get_node("PathFollow2D")
@onready var path_curve:Curve2D = self.get_curve()
@onready var platform : AnimatableBody2D
@onready var timer:Timer = get_node("Pause_Duration")

@export var pause_time:float = 1


var lock_position:bool = false

func _ready():
	timer.wait_time = pause_time
	platform = path_to_follow.get_node("MovingPlatform")
	platform.position = path_curve.get_point_in(0)

func _physics_process(delta):
	path_to_follow.progress += platform.speed * delta

func _on_pause_duration_timeout():
	lock_position = false
