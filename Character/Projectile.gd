class_name Projectile extends CharacterBody2D

signal hitbox_collided(object)
 
const CLASH_RANGE = 10

@export var damage: int = 100
@export var knockback_angle: int = 1
@export var knockback_amount: int = 1
@export var attack_type: String = "Normal"
@export var width:int = 100
@export var height:int = 100
@export var angle_flipper:int = 100
@export var object_push:Vector2 = Vector2(250, 50)
@export var hit_stop: int  = 1
@export var duration:int = 10
@export var speed: Vector2 = Vector2(200, 0)
@export var max_distance: Vector2 = Vector2.ZERO
@export var gravity_amount: int = 0
@export var max_fall_speed: int = 0
@export var direction: int =  180

@onready var state_machine: EntityStateMachine
@onready var hitbox_owner 
@onready var hitbox: CollisionShape2D = $"%Hitbox"
@onready var area_box: CollisionShape2D = $Detection/Shape
@onready var area_node: Area2D = $"%Detection"
@onready var duration_timer:Timer = $"%Duration"
@onready var starting_position
var gravity_tracker = 0
var current_level: GenericLevel
var framez: int = 0

func set_parameters(hitbox_info: = {}):
	if hitbox_info:
		for info in hitbox_info.keys():
			if info in self:
				set(info, hitbox_info[info])
			else:
				print_debug("Couldn't find value " + info + " in script.")
		update_extends()
		area_node.monitoring = true
		area_node.monitorable = true
		set_physics_process(true)
	else:
		print_debug("Projectile was created with no info.")

func _physics_process(delta):
	gravity_tracker += gravity_amount
	if gravity_amount > max_fall_speed:
		gravity_amount = max_fall_speed
	var motion = Vector2(speed.x, speed.y + gravity_tracker)
	move_and_collide(motion * direction * delta)
	
	hitbox.global_position = global_position
	area_box.global_position = global_position
	if framez < duration:
		framez += 1
	elif framez == duration:
		queue_free()
		return
	if abs(global_position - starting_position) >= max_distance and max_distance != Vector2(-1,-1):
		queue_free()

func update_extends():
	starting_position = global_position
	hitbox.shape.size = Vector2(width, height)
	hitbox.position = position
	area_box.shape.size = Vector2(width, height)
	area_box.position = position

func _on_body_entered(body):
	if body is RigidBody2D:
		body.call_deferred("apply_central_impulse",object_push)
		emit_signal("hitbox_collided", body)
		body.damage(damage)
	elif body is Entity or body is EnemyRigid:
		if body != hitbox_owner:
			damage_entity(body)
	elif body is Projectile:
		if attack_type == body.attack_type:
			if abs(body.damage  - damage) <=  CLASH_RANGE:
				body.queue_free()
				print_debug("CLASH")
	queue_free()


func damage_entity(body):
	body.damage(damage, knockback_amount, knockback_angle)
	emit_signal("hitbox_collided", body)
	GlobalScript.apply_hitstop(hit_stop)

func set_future_collision():
	set_collision_layer_value(GlobalScript.collision_values.HITBOX_FUTURE, true)
	
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)
	
	area_node.set_collision_layer_value(GlobalScript.collision_values.HITBOX_FUTURE, true)
	
	area_node.set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, true)
	area_node.set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
	area_node.set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, true)
	area_node.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)

func set_past_collision():
	set_collision_layer_value(GlobalScript.collision_values.HITBOX_PAST, true)

	area_node.set_collision_layer_value(GlobalScript.collision_values.HITBOX_PAST, true)

	set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
	
	area_node.set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, true)
	area_node.set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)
	area_node.set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, true)
	area_node.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
