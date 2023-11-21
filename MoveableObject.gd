extends RigidBody2D

@export var timeline: String 
var current_level: GenericLevel

@onready var collision = $CollisionShape2D

var should_reset = false
var new_position = Vector2(0,0)

var is_paradox:bool = false

var entity_holding_object
var speed: Vector2

#@export var gravity: int = 25
#@export var max_fall_speed: int = 100
#@export var cooldown:int = 5
#var timer = cooldown


func _ready():
	freeze_mode = RigidBody2D.FREEZE_MODE_STATIC

func enable():
	set_deferred("freeze", false)
	set_deferred("visible",true)
	collision.set_deferred("disabled", false)

func disable():
	if is_paradox == false:
		set_deferred("freeze", true)
		set_deferred("visible", false)
		collision.set_deferred("disabled", true)

func swap_status():
	if freeze:
		disable()
	else:
		enable()

func set_new_location(location):
	new_position = location

func get_timeline():
	return timeline

func get_paradox_status():
	return is_paradox

func being_held():
	return entity_holding_object
func _integrate_forces(state):
	if should_reset:
		state.transform.origin = new_position
		should_reset = false
		print("resetting")
	angular_velocity = 0
	rotation_degrees = 0
