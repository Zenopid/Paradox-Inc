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
@export var speed: int = 25
@export var max_distance: int = -1
@export var gravity_amount: int = 0
@export var max_fall_speed: int = 0
@export var direction: Vector2 =  Vector2.ZERO
@export var num_of_hits: int = 1
@export var velocity_effects_object_push:bool = true 
@export_enum("Future", "Past", "All") var timeline:String = "Future"
@onready var state_machine: EntityStateMachine
@onready var projectile_owner:Entity
@onready var hitbox: CollisionShape2D = $"%Hitbox"
@onready var player:Player
@onready var starting_position:Vector2

var gravity_tracker = 0
var current_level: GenericLevel
var framez: int = 0



func set_parameters(hitbox_info: = {}):
	set_physics_process(false)
	if hitbox_info:
		for info in hitbox_info.keys():
			if info in self:
				set(info, hitbox_info[info])
			else:
				print_debug("Couldn't find value " + info + " in script.")
		update_extends()
		set_physics_process(true)
		direction = direction.normalized()
		match timeline:
			"Future":
				set_future_collision()
			"Past":
				set_past_collision()
			"All":
				set_future_collision()
				set_past_collision()
		look_at(direction)
		add_to_group(projectile_owner.name + " Projectiles")
	else:
		print_debug("Projectile was created with no info.")
	player = get_tree().get_first_node_in_group("Players")
func _physics_process(delta):
	var status = player.get_invlv_type().contains("Proj")
	if timeline == "All":
			set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, status)
			set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, status)
	elif timeline == "Past":
		set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, status)
	else:
		set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, status)
	#gravity_tracker += gravity_amount
	#if gravity_amount > max_fall_speed:
		#gravity_amount = max_fall_speed
	var projectile_speed:Vector2 = (direction * speed) 
	#projectile_speed.y += gravity_amount
	var collision = move_and_collide(projectile_speed * direction)
	if collision:
		if typeof(collision.get_collider()) != TYPE_NIL:
			_on_body_entered(collision.get_collider())
	#hitbox.global_position = global_position
	#area_box.global_position = global_position
	if framez < duration:
		framez += 1
	elif framez == duration:
		#print("framez == duration so proj is dying")
		queue_free()
		return
	var distance_travelled:Vector2 = abs(global_position - starting_position)
	if distance_travelled.length() >= max_distance and max_distance != -1:
		#print("went too far so proj is dying")
		queue_free()
	hitbox.global_position = self.global_position
	if num_of_hits <= 0:
		queue_free()

func update_extends():
	starting_position = global_position
	hitbox.shape.size = Vector2(width, height)
	hitbox.position = position
	
func _on_body_entered(body):
	var true_collision:bool = false
	#if you hit something that isn't invlv to proj then we decrease by a hit
	if body == projectile_owner:
		return
	elif body is TileMap:
		queue_free()
	elif body is RigidBody2D:
		if global_position > body.global_position:
			object_push = -abs(object_push + (int(velocity_effects_object_push) * velocity))
		else:
			object_push = abs(object_push + (int(velocity_effects_object_push) * velocity))
		body.call_deferred("apply_central_impulse",object_push)
		emit_signal("hitbox_collided", body)
		body.damage(damage)
		true_collision = true
	elif body is Entity or body is EnemyRigid:
		if body != projectile_owner:
			true_collision = true
			damage_entity(body)
	elif body is Projectile:
		if body.get_rid() == get_rid() or body.projectile_owner == projectile_owner:
			return
		if attack_type == body.attack_type:
			if abs(body.damage  - damage) <=  CLASH_RANGE:
				num_of_hits -= 1
				body.num_of_hits -= 1
				print_debug("CLASH")
	#print ("hit body " + body.name)
	if true_collision:
		num_of_hits -= 1


func damage_entity(body):
	body.damage(damage, knockback_amount, knockback_angle)
	emit_signal("hitbox_collided", body)
	#GlobalScript.apply_hitstop(hit_stop)

func set_future_collision():
	set_collision_layer_value(GlobalScript.collision_values.PROJECTILE_FUTURE, true)
	
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)
	#
	#area_node.set_collision_layer_value(GlobalScript.collision_values.PROJECTILE_FUTURE, true)
	#
	#area_node.set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, true)
	#area_node.set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, true)
	#area_node.set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
	#area_node.set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, true)
	#area_node.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)

func set_past_collision():
	set_collision_layer_value(GlobalScript.collision_values.PROJECTILE_PAST, true)

	#area_node.set_collision_layer_value(GlobalScript.collision_values.PROJECTILE_PAST, true)

	set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
	#
	#area_node.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, true)
	#area_node.set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, true)
	#area_node.set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)
	#area_node.set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, true)
	#area_node.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)

