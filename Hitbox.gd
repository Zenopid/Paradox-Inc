class_name Hitbox extends Area2D

signal hitbox_collided(object)

var parent = get_parent()

var CLASH_RANGE: int = 5

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

@onready var parent_state: BaseState = get_parent()
@onready var state_machine = get_parent().get_parent()
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
	if state_machine is EntityStateMachine:
		hitbox_owner = state_machine.get_parent()
	else:
		hitbox_owner = get_parent().get_parent()
		state_machine = null
	monitoring = false 
	hitbox.shape = RectangleShape2D.new()
	set_physics_process(false)
	current_level = hitbox_owner.get_level()

func _physics_process(delta:float ) -> void:
	if framez < duration:
		framez += 1
	elif framez == duration:
		queue_free()
		return
	if state_machine:
		if state_machine.get_current_state() != parent_state:
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
				print_debug("CLASH")

func damage_entity(body):
	body.damage(damage, knockback_amount, knockback_angle)
	emit_signal("hitbox_collided", body)
	GlobalScript.apply_hitstop(hit_stop)
