extends RayCast2D

@export var entity: Entity 

func _ready():
	add_exception(entity)

func _physics_process(delta):
	if entity.sprite.flip_h: 
		position.x = entity.position.x - 14
	else:
		position.x = entity.position.x + 14
	position.y = entity.position.y + 10
