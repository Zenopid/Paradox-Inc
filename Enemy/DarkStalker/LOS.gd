extends RayCast2D

@export var entity: Entity = null
@export var vision_distance:int = 250
var view_locked: bool = false
var view_distance_locked: bool = false

func _ready():
	add_exception(entity)
	
func lock_view():
	view_locked = true

func unlock_view():
	view_locked = false

func lock_view_distance():
	view_distance_locked = true

func unlock_view_distance():
	view_distance_locked = false

func _physics_process(delta):
	if !view_locked:
		if entity.sprite.flip_h: 
			position.x = entity.position.x - 12
			target_position.x = vision_distance
		else:
			position.x = entity.position.x + 12
			target_position.x = -vision_distance
		position.y = entity.position.y + 10
	var dir = -1 if entity.sprite.flip_h else 1
	if is_colliding():
		var object = get_collider()
		if object is Player == false and object is Enemy == false and object is Portal == false:
			target_position.x =  (get_collision_point().x - entity.position.x ) * dir
	else:
		if !view_distance_locked:
			target_position.x = vision_distance * (dir * -1)
