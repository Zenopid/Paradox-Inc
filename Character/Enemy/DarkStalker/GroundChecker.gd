extends RayCast2D

@export var entity: Entity 

var position_locked: bool = false

func lock_position():
	position_locked = true

func unlock_position():
	position_locked = false

func _ready():
	add_exception(entity)

func _physics_process(delta):
	if !position_locked:
		if entity.sprite.flip_h: 
			position.x = entity.position.x - 14
		else:
			position.x = entity.position.x + 14
	position.y = entity.position.y + 10
