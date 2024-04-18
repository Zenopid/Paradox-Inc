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
@export var link_object: MoveableObject

@export var id: int
#An id of 0 means that its a generic object that was spawned,
#so we can just add it back. if its greater, we get whatever object
#in the current tree and delete it, and replace it with the saved variable.

@onready var current_level:GenericLevel 
@onready var collision:CollisionShape2D = $"%Collision"
@onready var timer:Timer = $"%Destruction_Timer"
@onready var anim_player = $"%ColorChanger"

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
#	if get_parent() is GenericLevel:
#		current_level = get_parent()
#	elif get_parent() is Entity:
#		current_level = get_parent().get_level()
	add_to_group("MoveableObjects")
	current_level = get_tree().get_first_node_in_group("CurrentLevel")
	check_state(current_level.current_timeline)
	current_level.connect("swapped_timeline", Callable(self,"check_state"))
#	print(str(current_level.name) + " is the current level")
#	print(current_level.current_timeline + " is the current timeline")
	if is_paradox:
		become_paradox()
	else:
		if current_timeline == "Future":
			set_collision(true, false)
		else:
			set_collision(false, true)
	if link_object:
		init_link_object()
#			else:
#				link_object.connect(i["name"], Callable(self, "_on_link_object_status_changed"))

#func _on_link_object_status_changed(signal_info):
#	pass
	#virtual method ot overwirte on case by case basis in case generic functions don't work

func _on_link_object_object_status(new_status):
	pass

func _on_link_object_position_changed(new_pos):
	pass

func _on_link_object_timeline_changed(new_timeline):
	pass

func check_state(timeline: String):
	if is_paradox:
		enable()
		return
	if timeline != current_timeline:
#		print("Object " + str(self) + " is disabling itself.")
		disable()
	else:
#		print("Object " + str(self) + " is enabling itself.")
		enable()
	emit_signal("object_status", current_state)
#	print(timeline + " is the new timeline.")
#	print(current_state)
#
#func swap_timeline(disable_afterwards:bool):
#	current_timeline = current_level.get_next_timeline_swap()
#	if disable_afterwards:
#		disable()

func disable():
	#position_before_disable = global_position
#	collision.set_deferred("disabled", true ) 
	modulate.a  = 0.2
	set_continuous_collision_detection_mode(RigidBody2D.CCD_MODE_CAST_RAY) #need less collision checks hopefully, so we can demote it to just rays
	current_state = state.DISABLED
#	freeze = true 
func enable():
#	collision.set_deferred("disabled", false ) 
	modulate.a = 1
	set_continuous_collision_detection_mode(RigidBody2D.CCD_MODE_CAST_SHAPE)
	current_state = state.ENABLED
#	set_deferred("freeze", false )


#func _physics_process(delta):
#	if current_state == state.DISABLED:
#		global_position = position_before_disable
#		print("changing the global position of box " + name + " to location " + str(position_before_disable) )
#	var ground_checker: RayCast2D 
#	var num_of_ground_rays: int = 0
#	for nodes in get_children():
#		if nodes.get_class() == "RayCast2D":
#			if nodes.get_collider() is Entity == false:
#				ground_checker = nodes
#				num_of_ground_rays += 1
#	if num_of_ground_rays > 1:
#		is_on_slope = true
#	else:
#		if ground_checker:
#			var angle = ground_checker.get_collision_normal().angle_to(self.position)
#			if angle > 0.02 or angle < -0.02:
#				is_on_slope = true
#	if being_pushed:
#		if !is_on_slope:
#			lock_rotation = true
#		linear_velocity.x = clamp(linear_velocity.x, -push_speed, push_speed)
#	else:
#		lock_rotation = false
#	if !$LeftSideChecker.is_colliding() and !$RightSideChecker.is_colliding() and !$SouthSideChecker.is_colliding() and !$NorthSideChecker.is_colliding():
#		push_count += 1
#		if push_count > max_frames_without_pushing:
#			being_pushed = false
#	else:
#		push_count = 0
#		height_pre_pushing = roundi(position.y)
#		being_pushed = true
#	if !being_pushed:
#		push_count += 1
#		if push_count > max_frames_without_pushing:
#			lock_rotation = false
#	print(being_pushed)

#func _integrate_forces(state):
##	var should_lock: bool = false
##	for i in get_colliding_bodies():
##		if i is TileMap:
##			should_lock = true
##
##	set_deferred("lock_rotation", should_lock)
##	if should_lock:
##		set_deferred("rotation", 0)
#	if should_reset:
#		state.transform.origin = new_position
#		should_reset = false
#		linear_velocity = movement_speed
func set_new_location(pos):
	movement_speed = linear_velocity
	new_position = pos
	should_reset = true
	

#func _on_body_entered(body):
#	pass
##	if body is Entity:
##		being_pushed = true
##		push_count = 0
##		set_deferred("lock_rotation",true)
##		entity_pushing = body
#
#func _on_body_exited(body):
#	pass
#	for i in get_colliding_bodies():
#		if i is Entity:
#			return
#	being_pushed = false
func set_timeline(new_timeline):
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
	
	set_collision_mask_value(GlobalScript.collision_values.HITBOX_FUTURE, future_collision_values)
	set_collision_mask_value(GlobalScript.collision_values.HITBOX_PAST, past_collision_values)

func damage(amount):
	if amount == 0:
		return
	amount = roundi(amount)
	health -= amount
	if health <= 0:
		destroy()
	emit_signal("damaged", health)

func destroy():
	if !being_destroyed:
		being_destroyed = true 
		timer.start()
		current_level.remove_child(self)
		await timer.timeout
		self.queue_free()
		

func queued_destruction() -> bool:
	return being_destroyed
	
func become_paradox():
	anim_player.play("Become Paradox")
	is_paradox = true
	set_collision(true, true)
	enable()
	current_state = state.PARADOX
	
func become_normal():
	anim_player.play("Return")
	is_paradox = false
	set_timeline(current_level.get_current_timeline())
	current_state = state.ENABLED

func get_id():
	return id
func save() -> Dictionary:
	var moveable_objects = SaveSystem.get_var("MoveableObject")
	if !moveable_objects:
		moveable_objects = {}
	var save_dict = {
		"is_paradox": is_paradox,
		"global_position": global_position,
		"health": health,
		"current_timeline": current_timeline,
		"rotation": rotation,
		"name": name,
		"id": id,
		"current_state": current_state
	}
	moveable_objects[name] = save_dict
	SaveSystem.set_var("MoveableObject", moveable_objects)
	return save_dict

func load_from_file():
	pass

func link_to_object(object):
	link_object = object
	init_link_object()

func init_link_object():
	for i in link_object.get_signal_list():
		var target_method = "_on_link_object_" + i["name"]
		if has_method(target_method):
			link_object.connect(i["name"], Callable(self, target_method))

