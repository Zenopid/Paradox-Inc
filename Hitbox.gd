class_name Hitbox extends Area2D

signal hitbox_collided(object)

var parent = get_parent()

const CLASH_RANGE: int = 5

@export var damage: int = 100
@export var knockback_angle: int = 1
@export var knockback_amount: int = 1
@export var attack_type: String = "Normal"
@export var width:int = 100
@export var height:int = 100
@export var angle_flipper:int = 100
@export var object_push:Vector2 = Vector2(250, 50)
@export var hit_stop: int = 0

@export var duration:int = 10

@onready var state_machine: EntityStateMachine
@onready var hitbox_owner: Entity 
var current_level: GenericLevel
@onready var hitbox: CollisionShape2D = get_node("Shape")

var framez = 0.0

func set_parameters(d, w,h,amount, angle, type, af, pos, dur, push, hitstop = 1):
	position = Vector2.ZERO
	duration = dur
	damage = d
	angle_flipper = af
	width = w
	height = h
	knockback_amount = amount
	knockback_angle = angle
	attack_type = type
	position = pos
	object_push = push
	hit_stop = hitstop
	update_extends()
	monitoring = true
	set_physics_process(true)

func update_extends():
	hitbox.shape.size = Vector2(width, height)
	hitbox.position = position

func _ready():
	hitbox_owner = get_parent()
	if hitbox_owner.has_method("get_state_machine"):
		state_machine = hitbox_owner.get_state_machine()
	monitoring = false 
	hitbox.shape = RectangleShape2D.new()
	set_physics_process(false)
	current_level = get_tree().get_first_node_in_group("CurrentLevel")

func _physics_process(delta:float ) -> void:
	hitbox.global_position = global_position
	if framez < duration:
		if duration != -1:
			framez += 1
	elif framez == duration:
		queue_free()
		return
	if state_machine:
		if state_machine.get_current_state().name != "Attack":
			queue_free()
			return

func _on_body_entered(body):
	if body is RigidBody2D:
		body.call_deferred("apply_central_impulse",object_push)
		emit_signal("hitbox_collided", body)
		body.damage(damage)
	elif body is Entity:
		if body != hitbox_owner:
			damage_entity(body)
	elif body is Hitbox:
		#Check to see if one person is actually hitting the other.
		for i in get_overlapping_bodies():
			if i == body.get_parent():
				if i is Entity:
					#If hitbox A is hitting hitbox B and hurtbox B, 
					#but hitbox B is only hitting hitbox A,
					#Person B takes the damage. Hopefully.
					damage_entity(body)
					return
		#Then we check to see if they're the same type.
		if attack_type == body.attack_type:
			#If they're the same type, they can clash, and we move on.
			if abs(body.damage  - damage) <=  CLASH_RANGE:
				#If they're around the same damage, then we clash, and both hitboxes dissapear.
				body.queue_free()
				self.queue_free()
				#To do: add particle effects 
				print_debug("CLASH")

func damage_entity(body):
	body.damage(damage, knockback_amount, knockback_angle)
	emit_signal("hitbox_collided", body)
	GlobalScript.apply_hitstop(hit_stop)
#	queue_free()
func set_future_collision():
	set_collision_layer_value(GlobalScript.collision_values.HITBOX_FUTURE, true)
	
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)

func set_past_collision():
	set_collision_layer_value(GlobalScript.collision_values.HITBOX_PAST, true)
	
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
