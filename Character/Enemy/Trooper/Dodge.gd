extends BaseState

var dodge_area2D: Area2D
var roll_speed:int = 500
var ground_checker:RayCast2D
var los_shapecast:ShapeCast2D

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	dodge_area2D = current_entity.get_node("%Hurtbox").get_parent()
	ground_checker = state_machine.get_raycast("GroundChecker")
	los_shapecast = state_machine.get_shapecast("LOS")

func enter(_msg: = {}):
	super.enter(_msg)
	ground_checker.enabled = true
	los_shapecast.enabled = true 
	
func physics_process(delta:float):
	entity.move_and_slide()
	los_shapecast.position = entity.position
	var offset_x = -10 if facing_left() else 10
	ground_checker.position = Vector2(entity.position.x + offset_x, entity.position.y)


func start_dodge():
	dodge_area2D.monitoring = false 
	var speed = roll_speed if facing_left() else -roll_speed
	
	entity.velocity = Vector2(speed, 0)
	

func end_dodge():
	dodge_area2D.monitoring = true

func exit_state():
	state_machine.transition_if_available([
		"Shoot",
		"Active"
	])
func exit():
	dodge_area2D.monitoring = true 
	ground_checker.enabled = false
	los_shapecast.enabled = false 
