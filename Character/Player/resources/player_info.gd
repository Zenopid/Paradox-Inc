class_name PlayerInfo extends Resource

@export var items:= []
@export var max_health:int = 100
@export var health:int = max_health:
	set(value):
		health = clamp(value, 0, max_health)
	get:
		return health
@export var save_pos:Vector2:
	set(value):
		save_pos = value
	get:
		return save_pos

func _set_health(value: int):
#	var prev_health = health
	health = clamp(value, 0, max_health)
#	if health != prev_health:
#		emit_signal("health_updated", health, 5)
#		if health <= 0:
#			kill()
#			emit_signal("killed")

func update_position(value:Vector2):
	save_pos
