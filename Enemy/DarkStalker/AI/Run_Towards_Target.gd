extends ActionLeaf

@export var anim_name:String = "Run"
@export var chase_speed: int = 315
@export var accel_speed: int = 35
var facing:int = 1
var chase_location:Vector2
var destination_area: Area2D
var area_shape: CollisionShape2D
var acceptable_range: int = 15

func before_run(actor: Node, blackboard: Blackboard) -> void:
	actor.anim_player.play(anim_name)
	chase_location = blackboard.get_value("chase_location")
	destination_area = Area2D.new()
	destination_area.visible = false
	destination_area.position = chase_location
	var circle: CircleShape2D = CircleShape2D.new()
	area_shape = CollisionShape2D.new()
	circle.radius = acceptable_range
	area_shape.shape = circle
	destination_area.add_child(area_shape)
	actor.add_child(destination_area)



func tick(actor: Node, _blackboard: Blackboard) -> int:
	for i in destination_area.get_overlapping_bodies():
		if i == actor:
			return SUCCESS
	if chase_location.x > actor.position.x:
		facing = 1
	else:
		facing = -1
	actor.motion.x += facing * accel_speed
	actor.motion.x = clamp(actor.motion.x, -chase_speed, chase_speed)
	actor.default_move_and_slide()
	return RUNNING

