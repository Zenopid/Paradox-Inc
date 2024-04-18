extends ActionLeaf

@export var anim_name:String = "Run"
@export var chase_speed: int = 315
@export var accel_speed: int = 35
var facing:int = 1
var chase_location:Vector2
var destination_area: Area2D
var area_shape: CollisionShape2D
@export var acceptable_range: int = 15
var circle: CircleShape2D = CircleShape2D.new()
var ground_checker:RayCast2D
var los:RayCast2D 
var reached_destination:bool = false

var entity: Entity

func _ready():
	destination_area = Area2D.new()
	destination_area.visible = true
	destination_area.set_collision_layer_value(1,false)
	destination_area.set_collision_layer_value(8, true)
	destination_area.set_collision_mask_value(1, false)
	destination_area.set_collision_mask_value(8, true)
	area_shape = CollisionShape2D.new()
	circle.radius = acceptable_range
	area_shape.shape = circle
	destination_area.add_child(area_shape)
	destination_area.connect("body_entered", Callable(self, "_on_destination_reached"))

func before_run(actor: Node, blackboard: Blackboard) -> void:
	reached_destination = false
	actor.anim_player.play(anim_name)
	if blackboard.has_value("target_position"):
		chase_location = blackboard.get_value("target_position")
	if !los:
		los = actor.get_raycast("LOS")
		entity = actor
		ground_checker = actor.get_raycast("GroundChecker")
	init_destination_area()

func init_destination_area():
	destination_area.global_position = chase_location
	add_child(destination_area)
	destination_area.add_to_group(entity.name + " Chase Locations")

func _on_destination_reached(body):
	if body == entity:
		reached_destination = true
	

func tick(actor: Node, blackboard: Blackboard) -> int:
	if los.is_colliding():
		var object = los.get_collider()
		if object is Player:
			chase_location = los.get_collision_point()
			destination_area.global_position = chase_location
	if chase_location == Vector2.ZERO:
		print_debug("Error occured while chasing")
		return FAILURE
	if !ground_checker.is_colliding():
		actor.sprite.flip_h = !actor.sprite.flip_h
		actor.motion.x *= -1
		actor.default_move_and_slide()
		#get em outta the way before he falls and dies
		return FAILURE
	
	if reached_destination:
		return SUCCESS
	if chase_location.x < actor.global_position.x:
		facing = -1
		actor.sprite.flip_h = true
	else:
		facing = 1
		actor.sprite.flip_h = false
	actor.motion.x += (facing * accel_speed) 
	actor.motion.x = clamp(actor.motion.x, -chase_speed, chase_speed)
	actor.default_move_and_slide()
	return RUNNING

func after_run(actor: Node, blackboard: Blackboard) -> void:
	remove_child(destination_area)
