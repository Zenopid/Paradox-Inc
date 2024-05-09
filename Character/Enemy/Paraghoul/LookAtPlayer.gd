extends BaseState

var original_target_position:Vector2
var los_shapecast: ShapeCast2D
#@export var sprite_turn_speed: int = 20
#@export var ray_turn_speed: float = 0.7
@export var chase_speed: float = 450
@export var acceleration: int = 20
@export var random_spread:float = 0.75
#@export var push_force: Vector2 = Vector2(200,200)
@onready var player: Player
@onready var nav_timer:Timer
@onready var pathfinder: NavigationAgent2D
@onready var chase_location_update_rate: float = 0.1


func init(current_entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	los_shapecast = state_machine.get_shapecast("LOS")
	player = get_tree().get_first_node_in_group("Players")
	nav_timer = entity.nav_timer
	nav_timer.wait_time = chase_location_update_rate
	pathfinder = entity.pathfinder
	
func enter(_msg:= {}):
	nav_timer.connect("timeout", Callable(self, "_on_nav_timer_timeout"))
	nav_timer.start()
	los_shapecast.look_at(player.global_position)
	
func physics_process( delta:float ):
	if los_shapecast.is_colliding():
		for i in los_shapecast.get_collision_count():
			var collision = los_shapecast.get_collider(i)
			if collision is Player and state_machine.get_timer("Shoot_Cooldown").is_stopped():
				state_machine.transition_to("Shoot")
				return
	los_shapecast.position = entity.position
	los_shapecast.look_at(player.global_position)
	var dir = entity.global_position.direction_to(player.global_position)
	entity.velocity += acceleration * dir
	entity.velocity = entity.velocity.limit_length(chase_speed)
	await get_tree().create_timer(0.001).timeout
	entity.move_and_slide()
	push_objects()

func push_objects():
	for i in entity.get_slide_collision_count():
		var collision = entity.get_slide_collision(i)
		if collision.get_collider() is MoveableObject:
			collision.get_collider().call_deferred("apply_central_impulse", -collision.get_normal() * entity.motion.length()  )

func _on_nav_timer_timeout():
	#pathfinder.target_position = player.global_position
	nav_timer.start()

func exit(): 
	nav_timer.disconnect("timeout", Callable(self, "_on_nav_timer_timeout"))
	#entity.velocity = Vector2.ZERO
