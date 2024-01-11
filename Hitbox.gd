class_name Hitbox extends Area2D

signal hitbox_collided(object)

var parent = get_parent()
@export var damage: int = 100
@export var knockback_angle: int = 1
@export var knockback_amount: int = 1
@export var attack_type: String = "Normal"
@export var width:int = 100
@export var height:int = 100
@export var angle_flipper:int = 100
@export var object_push:Vector2 = Vector2(250, 50)

@export var duration:int = 10

@onready var parent_state: BaseState = get_parent()
@onready var state_machine: EntityStateMachine = get_parent().get_parent()
@onready var hitbox_owner: Entity = state_machine.get_parent()
@onready var hitbox: CollisionShape2D = get_node("Shape")

var framez = 0.0

func set_parameters(d, w,h,amount, angle, type, af, pos, dur, push):
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
	update_extends()
	monitoring = true
	set_physics_process(true)

func update_extends():
	hitbox.shape.size = Vector2(width, height)
	$Shape.position = position

func _ready():
	monitoring = false 
	hitbox.shape = RectangleShape2D.new()
	set_physics_process(false)

func _physics_process(delta:float ) -> void:
#	if get_overlapping_bodies() != []:
#		print("Somethings inside the hitbox.")
#	print("changing position")
	position = hitbox_owner.position
#	print("I, " + str(name), " do exist.")
#	print(get_overlapping_areas())
#	print(get_overlapping_bodies())
#	print(get_collision_mask_value(4))
	if framez < duration:
		framez += 1
	elif framez == duration:
		Engine.time_scale = 1
		queue_free()
		return
	if state_machine.get_current_state() != parent_state:
		Engine.time_scale = 1
		queue_free()
		return

func _on_body_entered(body):
	print(body)
#	for i in get_overlapping_bodies():
#		print(i)
	if body is RigidBody2D:
#		print(hitbox.position) 
#		print("---------------------------------------------------------------")
#		print(hitbox_owner.position)
		body.call_deferred("apply_central_impulse",object_push)
		emit_signal("hitbox_collided", body)
	elif body is Entity:
		if body != hitbox_owner:
			body.damage(damage, knockback_amount, knockback_angle)
		emit_signal("hitbox_collided", body)
	elif body is Hitbox:
		if body.hitbox_owner != hitbox_owner:
			print("CLASH")
#	print("You hit a " + str(body.name) + " with a push of " + str(object_push))
