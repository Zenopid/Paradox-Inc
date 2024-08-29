extends BaseState

var original_target_position:Vector2
var los_shapecast: ShapeCast2D
#@export var sprite_turn_speed: int = 20
#@export var ray_turn_speed: float = 0.7
@export var max_chase_duration:float = 7
@export var chase_speed: float = 450
@export var acceleration: int = 20
@export var random_spread:float = 0.75
@export var target_position_randomness: int = 50
@export var target_area_size: int = 20
#@export var push_force: Vector2 = Vector2(200,200)
@onready var player: Player
@onready var nav_timer:Timer
@onready var pathfinder: NavigationAgent2D
@onready var chase_location_update_rate: float = 0.1

var target_sphere:Area2D
var sphere_shape:CollisionShape2D

var shoot_cd: Timer
var chase_timer:Timer

var dir:Vector2
var test_target:Vector2 = Vector2(300, -650)



func init(current_entity, s_machine: EntityStateMachine):
	player = get_tree().get_first_node_in_group("Players")
	super.init(current_entity, s_machine)
	los_shapecast = state_machine.get_shapecast("LOS")
	shoot_cd = state_machine.get_timer("Shoot_Cooldown")
	chase_timer = state_machine.get_timer("Chase_Duration")
	chase_timer.wait_time = max_chase_duration
	nav_timer = entity.nav_timer
	nav_timer.wait_time = chase_location_update_rate
	init_sphere()
	var pathfinder: NavigationAgent2D = entity.pathfinder
	pathfinder.max_speed = chase_speed

func init_sphere(): 
	target_sphere = Area2D.new()
	sphere_shape = CollisionShape2D.new()
	var shape:CircleShape2D = CircleShape2D.new()
	shape.radius = target_area_size
	sphere_shape.set_shape(shape)
	target_sphere.add_child(sphere_shape)
	target_sphere.visible = true
	target_sphere.set_collision_mask_value(1, false)
	target_sphere.set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, true)
	target_sphere.set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, true)
	
func enter(_msg:= {}):
	super.enter(_msg)
	chase_timer.start()
	if typeof(player) != TYPE_NIL:
		los_shapecast.look_at(player.global_position)
	update_path()
	call_deferred("add_child", target_sphere)
	target_sphere.global_position = get_new_target()
	
	
func get_new_target() -> Vector2:
	entity = entity as ParaGhoul
	var x = randf_range(player.global_position.x - target_position_randomness, player.global_position.x + target_position_randomness)
	var y = randf_range(player.global_position.y - target_position_randomness, player.global_position.y - target_position_randomness * 2)
	return Vector2(x, y)


func physics_process( delta:float ):
	entity = entity as ParaGhoul
	if chase_timer.is_stopped():
		state_machine.transition_to("Idle")
		return
	los_shapecast.position = entity.position
	los_shapecast.look_at(player.global_position)
	#dir = entity.global_position.direction_to(target_sphere.global_position)
	var next_path = entity.pathfinder.get_next_path_position()
	await get_tree().create_timer(0.01).timeout
	dir = entity.global_position.direction_to(next_path)
	await get_tree().create_timer(0.01).timeout
	entity.velocity += (acceleration * dir)  #.rotated(randf_range(-random_spread, random_spread))
	entity.velocity = entity.velocity.limit_length(chase_speed)
	await get_tree().create_timer(0.001).timeout
	entity.move_and_slide()
	push_objects()
	var rng = randi_range(0, 10)
	if rng < 8:
		if state_machine.state_available("GroundPound"):
			state_machine.transition_to("GroundPound")
			return
	else:
		if state_machine.state_available("Charge"):
			state_machine.transition_to("Charge", {direction = entity.global_position.direction_to(get_tree().get_first_node_in_group("Players").global_position)})
			return
	if los_shapecast.is_colliding():
		for i in los_shapecast.get_collision_count():
			var collision = los_shapecast.get_collider(i)
			if collision is Player:
				if state_machine.transition_if_available(["Shoot"]):
					return
	for i in target_sphere.get_overlapping_bodies():
		if i == entity :
			if state_machine.transition_if_available(["Shoot"]):
				return
	if entity.pathfinder.is_target_reached():
		if state_machine.transition_if_available([
			"Shoot",
			"GroundPound",
			"Charge"
			]):
			return
		else:
			update_path()


func push_objects():
	for i in entity.get_slide_collision_count():
		var collision = entity.get_slide_collision(i)
		if collision.get_collider() is MoveableObject:
			collision.get_collider().call_deferred("apply_central_impulse", -collision.get_normal() * entity.velocity.length()  )
			
func update_path():
	entity.pathfinder.target_position = target_sphere.global_position
	nav_timer.start()
	#print("updating path to go to position " + str(entity.pathfinder.target_position))
	#print("the player's position is currently " + str(player.global_position) )

func exit(): 
	remove_child(target_sphere)

func conditions_met():
	if los_shapecast.is_colliding():
		return true
	else:
		for i in entity.detection_sphere.get_overlapping_bodies():
			if i is Player:
				return true
	return false
