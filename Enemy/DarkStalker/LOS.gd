extends RayCast2D

@export var entity: Entity = null
@export var vision_distance:int = 250

var view_locked: bool = false
var view_distance_locked: bool = false

var angle_cone_of_vision := deg_to_rad(30.0)
var angle_between_rays := deg_to_rad(5.0)

func _ready():
	add_exception(entity)
func generate_raycasts() -> void:
	var ray_count := angle_cone_of_vision / angle_between_rays
	
	for index in ray_count:
		var ray := RayCast2D.new()
		var angle := angle_between_rays * (index - ray_count / 2)
		ray.target_position = Vector2.UP.rotated(angle) * vision_distance
		add_child(ray)
		ray.enabled = true
		
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
		facing = - 1
	else:
		facing = 1
	position = Vector2(entity.position.x, entity.position.y + 12)
	if !view_locked:
		scale.x = facing
	if is_colliding():
		var object = get_collider()
		if object is Player == false and object is Enemy == false and object is Portal == false:
			target_position.x =  abs (get_collision_point().x - entity.position.x )  
	else:
		if !view_distance_locked:
			target_position.x =  vision_distance
