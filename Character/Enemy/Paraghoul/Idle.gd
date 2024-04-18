extends BaseState

@onready var detection_sphere:Area2D
@onready var direction_timer: Timer
@onready var los_raycast: RayCast2D
@onready var wander_vector:Vector2 

@export var direction_cooldown: float = 0.4
@export var idle_speed: int = 55
@export var max_wander_distance:int = 300

func init(current_entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	detection_sphere = current_entity.detection_sphere
	direction_timer = state_machine.get_timer("New_Random_Direction")
	los_raycast = state_machine.get_raycast("LOS")
	wander_vector = Vector2(entity.global_position.x, entity.global_position.y)
	los_raycast.add_exception(entity)

func enter(_msg:= {}):
	super.enter()
	detection_sphere.connect("body_entered", Callable(self, "_on_player_close"))

func _on_player_close(body):
	state_machine.transition_to("LookAtPlayer")

func get_new_direction() -> Vector2:
	return Vector2(randf_range(-1,1), randf_range(-1,1))

func move_in_new_direction(new_direction: Vector2 = Vector2.ZERO):
	if new_direction == Vector2.ZERO:
		new_direction = get_new_direction()
	entity.apply_central_force(new_direction * idle_speed)
	los_raycast.look_at(new_direction)
	direction_timer.start()
	
func physics_process(delta):
	if direction_timer.is_stopped():
		move_in_new_direction()
#	else:
#		for i in entity.get_slide_collision_count():
#			var collision = entity.get_slide_collision(i)
#			if !collision.get_collider() is Player:
#				var new_direction = idle_speed * collision.get_normal().normalized()
#				move_in_new_direction(new_direction)
#
func exit():
	detection_sphere.disconnect("body_entered", Callable(self, "_on_player_close"))
