extends BaseState

@onready var direction_timer:Timer
@onready var ground_checker:RayCast2D
@onready var los_shapecast:ShapeCast2D

@export var strafe_speed:int = 450
@export var acceleration: int = 75
@export var strafe_time: float = 0.4

var strafe_direction: int = 1

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	direction_timer = state_machine.get_timer("StrafeTimer")
	ground_checker = state_machine.get_raycast("GroundChecker")
	direction_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	los_shapecast = state_machine.get_shapecast("LOS")
	direction_timer.wait_time = strafe_time
	
func _on_timer_timeout():
	strafe_direction = randi_range(-1, 1)
	direction_timer.start()

func enter(_msg: = {}):
	super.enter(_msg)
	direction_timer.start()
	
func physics_process(delta:float) -> void:
	if !ground_checker.is_colliding():
		strafe_direction *= -1
	entity.velocity.x += acceleration * strafe_direction
	entity.velocity = entity.velocity.limit_length(strafe_speed)
	await  get_tree().create_timer(0.001).timeout
	los_shapecast.position = entity.position
	var offset_x = -10 if facing_left() else 10
	ground_checker.position = Vector2(entity.position.x + offset_x, entity.position.y)
	if los_shapecast.is_colliding():
		for collision in los_shapecast.get_collision_count():
			if los_shapecast.get_collider(collision) is Player:
				state_machine.transition_if_available([
					"Shoot",
					"Chase"
					])
				return

	entity.move_and_slide()
