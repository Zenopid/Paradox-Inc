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
	entity.sprite.flip_h = (strafe_direction < 0)
	direction_timer.start()

func enter(_msg: = {}):
	super.enter(_msg)
	direction_timer.start()
	
func physics_process(delta:float) -> void:
	ground_checker.global_position = Vector2(entity.global_position.x + 10, entity.global_position.y)
	los_shapecast.global_position = entity.global_position
	if !ground_checker.is_colliding():
		strafe_direction *= -1
		entity.sprite.flip_h = !entity.sprite.flip_h
	entity.velocity.x += acceleration * strafe_direction
	entity.velocity = entity.velocity.limit_length(strafe_speed)
	await  get_tree().create_timer(0.001).timeout
	los_shapecast.position = entity.position
	var offset_x = -10 if facing_left() else 10
	ground_checker.position = Vector2(entity.position.x + offset_x, entity.position.y)
	var can_see_player:bool = false
	if los_shapecast.is_colliding():
		for collision in los_shapecast.get_collision_count():
			var collider = los_shapecast.get_collider(collision)
			if los_shapecast.get_collider(collision) is Player:
				can_see_player = true
				if state_machine.state_available("Shoot"):
					state_machine.transition_to("Shoot", {target_location = los_shapecast.get_collision_point(collision)})
					return;
				los_shapecast.look_at(Vector2(collider.global_position.x, collider.global_position.y + 5 ))
				#the added value is to make it aim more towards the torso
	if !can_see_player:
		los_shapecast.rotation_degrees = 0
	entity.move_and_slide()
