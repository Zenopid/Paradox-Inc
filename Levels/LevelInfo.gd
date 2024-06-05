class_name LevelInfo extends Resource

@export var level_name:String = "Emergence"

@export var level_conditions:= {}
@export var current_timeline:String = "Future"
@export var player_time:int
@export var bronze_time: float = 5
@export var sliver_time:float = 3
@export var gold_time:float = 1
@export var player_deaths:int = 0


func get_level_name():
	return level_name.capitalize()
