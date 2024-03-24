@tool
extends AnimatableBody2D
#
#@export var idle_duration: float = 1.0
#@export var waypoints_path: = NodePath()
@export var speed:int = 400
#@onready var wait_timer: Timer = $Timer
#
#@export var editor_process = true:
#	set(value):
#		set_editor_process(value)
#	get:
#		return editor_process
#@onready var waypoints = get_node(waypoints_path)
#
#var target_position: Vector2 = Vector2()
#func _ready() -> void:
#	if not waypoints:
#		set_physics_process(false)
#		return
#	position = waypoints.get_start_position()
#	target_position = waypoints.get_next_point_position()
#
#func _physics_process(delta):
#	var direction = (target_position - position).normalized()
#	var motion = direction * speed * delta
#	var distance_to_target = position.distance_to(target_position)
#	if motion.length() > distance_to_target:
#		position = target_position
#		target_position = waypoints.get_next_point_position()
#		set_physics_process(false)
#		wait_timer.start()
#	else:
#		position += motion
#
#func _on_timer_timeout():
#	set_physics_process(true)
#
#func set_editor_process(value):
#	editor_process = value
