class_name Hitbox extends Area2D

signal hitbox_collided(object)

var parent = get_parent()

const CLASH_RANGE: int = 5

var damage: int = 100
var knockback_angle: int = 1
var knockback_amount: int = 1
var attack_type: String = "Normal"
var width:int = 100
var height:int = 100
var angle_flipper:int = 100
var object_push:Vector2 = Vector2(250, 50)
var hit_stop: int = 0

var duration:int = 10

@onready var state_machine: EntityStateMachine
@onready var hitbox_owner : Entity
@onready var hitbox: CollisionShape2D = get_node("Shape")

var framez = 0.0
var current_level: GenericLevel

func set_parameters(hitbox_info: = {}):
#	position = Vector2.ZERO
#	duration = dur
#	damage = d
#	angle_flipper = af
#	width = w
#	height = h
#	knockback_amount = amount
#	knockback_angle = angle
#	attack_type = type
#	position = pos
#	object_push = push
#	hit_stop = hitstop
	if hitbox_info:
		var errors: = []
		for info in hitbox_info.keys():
			if info in self:
				set(info, hitbox_info[info])
			else:
				errors.append(info)
		update_extends()
		monitoring = true
		set_physics_process(true)
		if errors != []:
			print("Error: The following values do not exist:")
			print("-------------------------------------------")
			for i in errors:
				print(i)
			print("-------------------------------------------")
		visible = true 
	else:
		print_debug(hitbox_owner.name + " created hitbox without info.")
		queue_free()
	

func update_extends():
	hitbox.shape.size = Vector2(width, height)
	#hitbox.position = position
	if GlobalScript.debug_enabled:
		print("making rectangle")
		var rect:ColorRect = ColorRect.new()
		rect.size = hitbox.shape.size
		rect.color = hitbox.debug_color
		#rect.position += hitbox.position
		add_child(rect)

func _ready():
	if !hitbox_owner:
		hitbox_owner = get_parent()
	if hitbox_owner.has_method("get_state_machine"):
		state_machine = hitbox_owner.get_state_machine()
	monitoring = false 
	hitbox.shape = RectangleShape2D.new()
	set_physics_process(false)
	current_level = get_tree().get_first_node_in_group("CurrentLevel")
		
#	hitbox.position = position
	
func _physics_process(delta:float ) -> void:
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
		if global_position > body.global_position:
			object_push = -abs(object_push)
		else:
			object_push = abs(object_push)
		body.call_deferred("apply_central_impulse",object_push)
		emit_signal("hitbox_collided", body)
		body.damage(damage)
	elif body is Entity:
		if body != hitbox_owner:
			var invlv_type:String = body.get_invlv_type()
			if !invlv_type.contains("Strike"):
				damage_entity(body)
				if body.has_method("apply_push"):
					body.apply_push(object_push)
	elif body is Hitbox:
		#Check to see if one person is actually hitting the other.
		for i in get_overlapping_bodies():
			if i == body.get_parent():
				if i is Entity or i is EnemyRigid:
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
#	queue_free()
func set_future_collision():
	set_collision_layer_value(GlobalScript.collision_values.HITBOX_FUTURE, true)
	
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)

func set_past_collision():
	set_collision_layer_value(GlobalScript.collision_values.HITBOX_PAST, true)
	
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
