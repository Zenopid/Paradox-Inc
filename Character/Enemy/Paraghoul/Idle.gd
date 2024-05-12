extends BaseState

@onready var detection_sphere:Area2D
@onready var direction_timer: Timer
@onready var worldscanner_shapecast: ShapeCast2D
@onready var wander_area:CollisionShape2D
@onready var los_raycast:ShapeCast2D

@export var direction_cooldown: float = 0.4
@export var idle_speed: int = 55
@export var max_wander_distance:int = 300
@export var acceleration:float = 15
@export var worldscanner_length: int = 25

@export var bounce_rand:float = 0.9
@export var target_reached_range: Vector2 = Vector2(10,10)

@onready var direction:Vector2
@onready var target_position: Vector2
@onready var old_worldscanner_length

@onready var speed:float

func init(current_entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	detection_sphere = current_entity.detection_sphere
	direction_timer = state_machine.get_timer("New_Random_Direction")
	worldscanner_shapecast = state_machine.get_shapecast("WorldScanner")
	wander_area = entity.wander_area
	direction_timer.wait_time = direction_cooldown
	los_raycast = state_machine.get_shapecast("LOS")
	
	
func enter(_msg:= {}):
	super.enter()
	get_new_target()

func get_new_target():
	var possible_range = (wander_area.shape.radius / 2)
	target_position.x = randf_range(entity.spawn_location.x - possible_range, entity.spawn_location.x + possible_range)
	target_position.y =  randf_range(entity.spawn_location.y - possible_range, entity.spawn_location.y + possible_range)
	direction_timer.start()
	set_raycast_position()

func bounce_target(point:Vector2):
	target_position *= randf_range( 1- bounce_rand, 1 + bounce_rand)
	
func physics_process(delta):
	for body in detection_sphere.get_overlapping_bodies():
		if body is Player:
			state_machine.transition_to("Chase")
			return
	if direction_timer.is_stopped() or abs(target_position - entity.global_position) <= target_reached_range:
		get_new_target()
	apply_speed()
	entity.move_and_slide()
	if worldscanner_shapecast.is_colliding():
		var collision = worldscanner_shapecast.get_collider(0)
		if collision is TileMap:
			bounce_target(worldscanner_shapecast.get_collision_point(0) * worldscanner_shapecast.get_collision_normal(0))
			direction_timer.start()
		else:
			get_new_target()
	set_raycast_position()

func apply_speed():
	var dir_to_target = entity.global_position.direction_to(target_position)
	entity.velocity += acceleration * dir_to_target
	entity.velocity = entity.velocity.limit_length(idle_speed)

func set_raycast_position():
	worldscanner_shapecast.position = entity.position
	worldscanner_shapecast.look_at(target_position)
	los_raycast.position = entity.position
	los_raycast.look_at(target_position)
	
