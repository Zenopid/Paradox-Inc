class_name Hook extends Node2D

signal launched()
signal attached_object(object_name)
signal detached()

@export var player: Player


@export_category("Grapple Projectile")
@export var launch_speed: int = 75
@export var damage: int = 10
@export var time_until_grapple_falls: float = 1.5
@export var gravity: int = 50
@export var max_fall_speed: int = 600
@export var cooldown: float = 0.1

@export_category("Player Pull Speed")
@export var fall_multiplier:float = 0.55
@export var rise_multiplier:float = 1.05
@export var sideways_multiplier: float = 0.7

@export_category("Boost Speed")
@export var boost_speed: Vector2

@export_category("Object Pull Speed")
@export var pull_speed:Vector2 = Vector2(100,100)

@onready var links: Line2D = $"%Chain"
@onready var hook_sprite: Sprite2D = $"%Hook_Sprite"
@onready var hook_body: CharacterBody2D = $"%Hook"
@onready var hook_location:= Vector2.ZERO
@onready var anim_player: AnimationPlayer = $"%Effects"
@onready var gravity_timer:Timer = $"%GravityTimer"
@onready var pointer: Sprite2D = $"%GrapplePointer"
@onready var cooldown_timer:Timer = $"%Cooldown"

var flying: bool = false
var attached:bool = false 
var direction := Vector2.ZERO
var grappled_object:Node2D
var attachment_point := Vector2.ZERO
var gravity_amount: int = 0
var hook_visible:bool = false 
var can_pull_object:bool = false

func _ready():
	connect("attached_object", Callable(self, "_on_object_grappled"))
	connect("detached", Callable(self, "_on_grapple_detatched"))
	connect("launched", Callable(self, "_on_grapple_launched" ))
	gravity_timer.wait_time = time_until_grapple_falls
	links.hide()
	hook_body.hide()
	visible = true

func _on_swapped_timeline(new_timeline:String ):
#	release()
#	print("Grapple is changing to timeline " + new_timeline)
	if new_timeline == "Future":
		hook_body.set_collision_layer_value(GlobalScript.collision_values.HOOK_FUTURE, true)
		hook_body.set_collision_layer_value(GlobalScript.collision_values.HOOK_PAST, false)
		
		hook_body.set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
		hook_body.set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, false)
		
		hook_body.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)
		hook_body.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, false)
		
		hook_body.set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, true)
		hook_body.set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, false)
		
		hook_body.set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, true)
		hook_body.set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, false)
		
	else:

		hook_body.set_collision_layer_value(GlobalScript.collision_values.HOOK_FUTURE, true)
		hook_body.set_collision_layer_value(GlobalScript.collision_values.HOOK_PAST, false)

		hook_body.set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, false)
		hook_body.set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)
		
		hook_body.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, false)
		hook_body.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
		
		hook_body.set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, false)
		hook_body.set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, true)
		
		hook_body.set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, false)
		hook_body.set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, true)
	var collision = hook_body.move_and_collide(get_speed(), true)
	if !collision is KinematicCollision2D and !grappled_object and attached:
		release()

func shoot(dir: Vector2 = Vector2.ZERO) :
	anim_player.play("RESET")
	if cooldown_timer.is_stopped():
		direction = dir.normalized()
		flying = true
		hook_location = self.global_position
		gravity_timer.start()
		emit_signal("launched")
		hook_visible = true 
		links.show()
		hook_body.show()

func release() -> void:
	flying = false
	attached = false
	emit_signal("detached")
	gravity_timer.stop()
	gravity_amount = 0
	hook_visible = false 
	links.hide()
	hook_body.hide()
	start_cooldown()

func _process(delta) -> void: 
	if !hook_visible: 
		return
	var tip_loc = to_local(hook_location)
	if !attached:
		hook_body.rotation = (position.angle_to_point(tip_loc) - deg_to_rad(90)) 
	links.set_point_position(1, hook_body.position)

func set_pointer_direction(location:Vector2):
#	pointer.look_at(location)
	var angle
	if GlobalScript.controller_type == "Keyboard":
		angle = pointer.position.angle_to(to_local(get_global_mouse_position()).normalized())
	else:
		angle = pointer.get_angle_to(Vector2(Input.get_joy_axis(0,JOY_AXIS_RIGHT_X), Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y)))
	pointer.rotation = angle
#	pointer.rotation = (pointer.global_position.angle_to_point(location) - deg_to_rad(90))

func _physics_process(delta):
	hook_body.global_position = hook_location
	if flying:
		var collision = hook_body.move_and_collide(get_speed())
		if collision is KinematicCollision2D:
			var object = collision.get_collider()
			anim_player.play("attach")
			attached = true
			flying = false 
			emit_signal("attached_object", object)
			if object is Enemy:
				object.damage(damage)
	elif attached:
		if grappled_object:
			if is_instance_valid(grappled_object):
				hook_body.global_position = grappled_object.global_position + attachment_point
	hook_location = hook_body.global_position


func _on_object_grappled(object):
	if !object is TileMap:
		grappled_object = object
	if object is MoveableObject:
		can_pull_object = true 
		grappled_object.add_to_group("Grappled Objects")
		grappled_object.become_paradox()
	attachment_point = object.global_position - hook_body.global_position

func _on_grapple_detatched():
	if is_instance_valid(grappled_object):
		if typeof(grappled_object) != TYPE_NIL:
			grappled_object.remove_from_group("Grappled Objects")
			if grappled_object.has_method("become_normal"):
				grappled_object.become_normal()
	can_pull_object = false
	grappled_object = null
	attachment_point = Vector2.ZERO
	links.hide()
	hook_body.hide()

func _on_grapple_launched():
	links.show()
	hook_body.show()

func start_cooldown():
	anim_player.play("cooldown_start")
	cooldown_timer.start()

func end_cooldown():
	anim_player.play("cooldown_end")

func get_speed():
	if gravity_timer.is_stopped():
		gravity_amount += gravity
		gravity_amount = clamp(gravity_amount, 0, max_fall_speed)
	else:
		gravity_amount = 0
	var speed: Vector2 = ((direction * launch_speed ) + player.velocity) * get_physics_process_delta_time()
	speed.y += gravity_amount
	return speed 

func object_pullable() -> bool:
	if grappled_object:
		if is_instance_valid(grappled_object):
			if can_pull_object and !grappled_object.is_queued_for_deletion():
				return true
	return false

func get_grappled_object() -> Variant:
	return grappled_object
