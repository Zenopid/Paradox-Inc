
class_name MoveableObject extends RigidBody2D

const MAX_FRAMES_WITHOUT_PUSHING:int = 10

signal update_link_object(object_dict)
signal timeline_changed(new_timeline)
signal object_status(current_status)
signal position_changed(new_position)
signal damaged(new_health)
@export var health: int = 100
@export_enum ("Future", "Past") var current_timeline:String = "Future"
@export var is_paradox:bool = false
@export var link_object: Node2D
@export var object_type:String = "Box"
@export var id: int = 0
#An id of 0 means that its a generic object that was spawned,
#so we can just add it back. if its greater, we get whatever object
#in the current tree and delete it, and replace it with the saved variable.

@onready var current_level:GenericLevel 
@onready var collision = $"%Collision"
@onready var anim_player:AnimationPlayer = $"ColorChanger"
@onready var hurtbox_area:Area2D = $"%HurtboxArea"

var being_pushed: bool = false
var push_speed: int
var push_count:int = 0
var height_pre_pushing: int = 0
var should_reset:bool = false
var new_position: Vector2 = Vector2.ZERO
var is_on_slope:bool = false
var entity_pushing: Entity
var movement_speed: Vector2
var being_destroyed:bool = false

enum state {
	DISABLED,
	ENABLED,
	PARADOX
}

var current_state = state.DISABLED
var position_before_disable: Vector2 = Vector2.ZERO

func _ready():
	add_to_group("MoveableObjects")
	current_level = get_tree().get_first_node_in_group("CurrentLevel")
	check_state(current_level.current_timeline)
	current_level.connect("swapped_timeline", Callable(self,"check_state"))

	if is_paradox:
		become_paradox()
	else:
		if current_timeline == "Future":
			set_collision(true, false)
		else:
			set_collision(false, true)
	if link_object:
		init_link_object()
#
func _on_link_object_object_status(new_status):
	pass

func _on_link_object_position_changed(new_pos:Vector2):
	pass

func _on_link_object_timeline_changed(new_timeline:String):
	pass

func check_state(timeline: String):
	if is_paradox:
		return
	if timeline != current_timeline:
		disable()
	else:
		enable()
	emit_signal("object_status", current_state)

func disable():
	modulate.a  = 0.35
	set_continuous_collision_detection_mode(RigidBody2D.CCD_MODE_CAST_RAY) #need less collision checks hopefully, so we can demote it to just rays
	current_state = state.DISABLED
	
func enable():
	modulate.a = 1
	set_continuous_collision_detection_mode(RigidBody2D.CCD_MODE_CAST_SHAPE)
	current_state = state.ENABLED

func set_new_location(pos:Vector2):
	movement_speed = linear_velocity
	new_position = pos
	should_reset = true

func set_timeline(new_timeline:String ):
	if current_timeline != new_timeline:
		if !is_paradox:
			current_timeline = new_timeline
			check_state(current_timeline)
			if new_timeline == "Future":
				set_collision(true, false)
			else:
				set_collision(false, true)
			emit_signal("timeline_changed", new_timeline)

func set_collision(future_collision_values: bool = true, past_collision_values: bool = false):
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, future_collision_values)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, past_collision_values)
	
	set_collision_layer_value(GlobalScript.collision_values.OBJECT_FUTURE, future_collision_values)
	set_collision_layer_value(GlobalScript.collision_values.OBJECT_PAST,past_collision_values)

	set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, future_collision_values)
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, past_collision_values)
	
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, future_collision_values)
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, past_collision_values)
	
	set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, future_collision_values)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, past_collision_values)
	
	set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, future_collision_values)
	set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, past_collision_values)
	
	set_collision_mask_value(GlobalScript.collision_values.PROJECTILE_FUTURE, future_collision_values)
	set_collision_mask_value(GlobalScript.collision_values.PROJECTILE_PAST, past_collision_values)
	
	if hurtbox_area:
		hurtbox_area.set_collision_layer_value(GlobalScript.collision_values.OBJECT_FUTURE, future_collision_values)
		hurtbox_area.set_collision_layer_value(GlobalScript.collision_values.OBJECT_PAST, past_collision_values)
		print("changed the thingy")

func damage(amount: int):
	if amount == 0:
		return
	health -= amount
	if health <= 0:
		kill()
	emit_signal("damaged", health)

func kill():
	queue_free()

func queued_destruction() -> bool:
	return being_destroyed
	
func become_paradox():
	if typeof(anim_player) != TYPE_NIL:
		anim_player.play("Become Paradox")
	is_paradox = true
	set_collision(true, true)
	enable()
	current_state = state.PARADOX
	
func become_normal():
	anim_player.play("Return")
	is_paradox = false
	var new_timeline = current_level.get_current_timeline()
	if new_timeline == "Future":
		set_collision(true, false)
	else:
		set_collision(false, true)
	current_timeline = new_timeline
	current_state = state.ENABLED

func get_id():
	return id

func get_object_type() -> String:
	return object_type

func link_to_object(object):
	link_object = object
	init_link_object()

func init_link_object():
	for i in link_object.get_signal_list():
		var target_method = "_on_link_object_" + i["name"]
		if has_method(target_method):
			link_object.connect(i["name"], Callable(self, target_method))
