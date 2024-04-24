extends BaseState

@onready var detection_sphere:Area2D
@onready var direction_timer: Timer
@onready var worldscanner_raycast: ShapeCast2D
@onready var wander_area:CollisionShape2D
@onready var los_raycast:ShapeCast2D

@export var direction_cooldown: float = 0.4
@export var idle_speed: int = 55
@export var max_wander_distance:int = 300
@export var acceleration:float = 15
@export var worldscanner_length: int = 25

@export var bounce_randomness: int = 25
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
	worldscanner_raycast = state_machine.get_shapecast("WorldScanner")
	wander_area = entity.wander_area
	direction_timer.wait_time = direction_cooldown
	los_raycast = state_machine.get_shapecast("LOS")
func enter(_msg:= {}):
	super.enter()
	detection_sphere.connect("body_entered", Callable(self, "_on_player_near"))
	get_new_target()
func _on_player_near(body):
	pass
#	state_machine.transition_to("LookAtPlayer")

#func get_new_direction():
#	direction = Vector2(randf_range(-1,1), randf_range(-1,1))
#	direction_timer.start()

func get_new_target():
	var possible_range = (wander_area.shape.radius / 2)
	target_position.x = randf_range(entity.spawn_location.x - possible_range, entity.spawn_location.x + possible_range)
	target_position.y =  randf_range(entity.spawn_location.y - possible_range, entity.spawn_location.y + possible_range)
	direction_timer.start()
	set_raycast_position()

func bounce_target(point:Vector2):
#	var raycast = RayCast2D.new()
##	raycast.global_position = entity.global_position
#	raycast.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)
#	raycast.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
#	raycast.target_position.x = worldscanner_length
#	raycast.add_exception(entity)
#	raycast.hit_from_inside = true
#	var normal = raycast.get_collision_normal()
#	entity.add_child(raycast)
#	raycast.rotation = worldscanner_raycast.rotation
#	raycast.force_raycast_update()
#	target_position.x = normal.x * randf_range(idle_speed - bounce_randomness, idle_speed + bounce_randomness)
#	target_position.y = normal.y * randf_range(idle_speed - bounce_randomness, idle_speed + bounce_randomness)
#	direction_timer.start()
#	set_raycast_position()
#	raycast.queue_free()
	target_position *= randf_range( 1- bounce_rand, 1 + bounce_rand)
	
func physics_process(delta):
	if direction_timer.is_stopped() or abs(target_position - entity.global_position) <= target_reached_range:
		get_new_target()
	apply_speed(delta)
	default_move_and_slide()
	if worldscanner_raycast.is_colliding():
		var collision = worldscanner_raycast.get_collider(0)
		if collision is TileMap:
			print("Bouncing entity " + entity.name)
			bounce_target(worldscanner_raycast.get_collision_point(0))
			#if it hits the ground or a wall, bounce
			direction_timer.start()
		else:
			get_new_target()
	set_raycast_position()
#	entity.apply_central_impulse(motion)
	#(position.direction_to(grapple.hook_body.global_position) * grapple.boost_speed.length()).round()
#	else:
#		for i in entity.get_slide_collision_count():
#			var collision = entity.get_slide_collision(i)
#			if !collision.get_collider() is Player:
#				var new_direction = idle_speed * collision.get_normal().normalized()
#				move_in_new_direction(new_direction)
func apply_speed(delta:float):
	var dir_to_target = entity.global_position.direction_to(target_position)
#	entity.motion += dir_to_target * acceleration * delta
#	if abs(entity.motion) > abs(dir_to_target * idle_speed):
#		entity.motion = dir_to_target * idle_speed 
	speed += acceleration
	if speed > idle_speed:
		speed = idle_speed
	entity.motion = (dir_to_target * speed) 
#	if entity.motion > dir_to_target * idle_speed * delta:
#		entity.motion = idle_speed * dir_to_target * delta
#

func set_raycast_position():
	worldscanner_raycast.position = entity.position
	worldscanner_raycast.look_at(target_position)
	los_raycast.position = entity.position
	los_raycast.look_at(target_position)
	
func exit():
	detection_sphere.disconnect("body_entered", Callable(self, "_on_player_cworldscannere"))
