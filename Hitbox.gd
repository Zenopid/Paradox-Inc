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

@onready var parent_state = get_parent().get_parent().get_current_state()
@onready var hitbox: CollisionShape2D = get_node("Shape")
var framez = 0.0

func set_parameters(d, w,h,amount, angle, type, af, pos, dur, push):
	self.position = Vector2.ZERO
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
	connect("body_entered", Callable(self, "hitbox_collide"))
	set_physics_process(true)

func update_extends():
	hitbox.shape.size = Vector2(width, height)

func _ready():
	set_physics_process(false)
	hitbox.shape = RectangleShape2D.new()
	
func _physics_process(delta):
	if framez < duration:
		framez += 1
	elif framez == duration:
		Engine.time_scale = 1
		queue_free()
		return
	if get_parent().get_parent().get_current_state() != parent_state:
		Engine.time_scale = 1
		queue_free()
		return

func hitbox_collide(body):
	if body is MoveableObject:
		body.apply_impulse(object_push)
	else:
		print("hit something else.")
	emit_signal("hitbox_collided", body)


func _on_hitbox_collided(object):
	print("hitbox collided with " + str(object))
