extends RayCast2D

@export var entity: Entity = null
@export var vision_distance:int = 250
var view_locked: bool = false
var view_distance_locked: bool = false
##
func _ready():
	add_exception(entity)
#
func lock_view():
	view_locked = true

func unlock_view():
	view_locked = false

func lock_view_distance():
	view_distance_locked = true

func unlock_view_distance():
	view_distance_locked = false

func _physics_process(delta):
	var facing: int
	if entity.sprite.flip_h:
		facing = -1
	else:
		facing = 1
	if !view_locked:
		position.x = entity.position.x + (12 * facing)
		target_position = target_position * facing 
		position.y = entity.position.y + 10
	if is_colliding():
		var object = get_collider()
		if object is Player == false and object is Enemy == false and object is Portal == false:
			target_position.x =  abs (get_collision_point().x - entity.position.x ) * facing 
	else:
		if !view_distance_locked:
			target_position.x = vision_distance * facing * -1
