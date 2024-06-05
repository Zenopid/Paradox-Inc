class_name PlayerAirState extends PlayerBaseState


@export var push:int = 100

@onready var wall_checker:ShapeCast2D

var remaining_jumps:int = 0
var speed_before_wallslide: float 
const air_acceleration: int = 17
const max_speed: int = 250
const MINIMUM_WALLBOUNCE_SPEED: int = 10


func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	wall_checker = s_machine.get_shapecast("WallScanner")


func enter(_msg: ={}):
	super.enter()
	wall_checker.enabled = true

func physics_process(_delta):

	if get_movement_input() != 0:
		if facing_left():
			if entity.velocity.x > -max_speed:
				entity.velocity.x -= air_acceleration
				if entity.velocity.x < -max_speed:
					entity.velocity.x = -max_speed
		else:
			if entity.velocity.x < max_speed:
				entity.velocity.x += air_acceleration
				if entity.velocity.x > max_speed:
					entity.velocity.x = max_speed
					
	if state_machine.state_available("WallSlide"):
		state_machine.transition_to("WallSlide", {previous_speed = speed_before_wallslide})
		return
	elif abs(entity.velocity.x) > MINIMUM_WALLBOUNCE_SPEED :
		speed_before_wallslide = entity.velocity.x
	wall_checker.position = Vector2(entity.position.x + 12.55 * get_facing_as_int(), entity.position.y - 10.5)
		
func default_move_and_slide():
	entity.move_and_slide()
	push_objects()

func push_objects():
	for i in entity.get_slide_collision_count():
		var collision = entity.get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			collision.get_collider().apply_central_impulse(-collision.get_normal() * push )

func exit() -> void:
	wall_checker.enabled = false
