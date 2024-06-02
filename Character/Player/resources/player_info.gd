class_name PlayerInfo extends Resource

@export var stopwatch_time: int = 0
@export var items:= []
var all_items:= []
@export var max_health:int = 100
@export var health:int = max_health:
	set(value):
		health = clamp(value, 0, max_health)
	get:
		return health
@export var global_position:Vector2 
@export var spawn_point:Vector2
@export var respawn_timeline:String

func _set_health(value: int):
#	var prev_health = health
	health = clamp(value, 0, max_health)
#	if health != prev_health:
#		emit_signal("health_updated", health, 5)
#		if health <= 0:
#			kill()
#			emit_signal("killed")

func enable_all_items():
	items = all_items
