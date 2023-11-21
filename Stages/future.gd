extends TileMap

var player = preload("res://Character/player.tscn")

func _ready():
	var player_instance = player.instantiate()
	player_instance.position.y = position.y - 30
	player_instance.spawn_point = Vector2(position.x, position.y - 30)
	add_child(player_instance)
