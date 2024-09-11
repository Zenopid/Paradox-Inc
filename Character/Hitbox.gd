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
@export var hitstun: int  = 0
@export var duration:int = 10

@onready var state_machine: EntityStateMachine
@onready var hitbox_owner : Entity
@onready var hitbox: CollisionShape2D = get_node("Shape")

var framez = 0.0
var current_level: GenericLevel

func set_parameters(hitbox_info: = {}):
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
		if !hitbox_owner:
			push_error("Hitbox created without")
		if hitbox_owner.has_method("get_state_machine"):
			state_machine = hitbox_owner.get_state_machine()
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

	monitoring = false 
	hitbox.shape = RectangleShape2D.new()
	set_physics_process(false)
	current_level = get_tree().get_first_node_in_group("CurrentLevel")
		
#	hitbox.position = position
	
func _physics_process(delta:float ) -> void:
	if framez < duration:
		framez += 1
	elif framez == duration:
		queue_free()
		return
	#if state_machine:
		#if state_machine.get_current_state().name != "Attack":
			#queue_free()
			#return

func _on_body_entered(body):
	if body is RigidBody2D:
		if global_position > body.global_position:
			object_push = -abs(object_push)
		else:
			object_push = abs(object_push)
		body.call_deferred("apply_central_impulse",object_push)
		emit_signal("hitbox_collided", body)
		if body.has_method("damage"):
			body.damage(damage)
	#	if body.has_method("knockback_entity"):
		#	body.knockback_entity(object_push, knockback_amount)
			# knockback_entity(knockback_amount:int, hitbox_location:Vector2, knockback_angle_modifier:float = 0, ):
	elif body is Entity:
		if body != hitbox_owner:
			var invlv_type:String = body.get_invlv_type()
			if !invlv_type.contains("Strike"):
				damage_entity(body)



func _on_area_entered(area:Area2D):
	var area_parent = area.get_parent()
	if area is Hitbox:
		#Check to see if one person is actually hitting the other.
		for i in get_overlapping_bodies():
			if i == area.get_parent():
				if i is Entity or i is EnemyRigid:
					#If hitbox A is hitting hitbox B and hurtbox B, 
					#but hitbox B is only hitting hitbox A,
					#Person B takes the damage. 
					damage_entity(area_parent)
					return
		#Then we check to see if they're the same type.
		if attack_type == area.attack_type:
			#If they're the same type, they can clash, and we move on.
			if abs(area.damage  - damage) <=  CLASH_RANGE:
				#If they're around the same damage, then we clash, and both hitboxes dissapear.
				area.queue_free()
				self.queue_free()
				print_debug("CLASH")
	elif area_parent is Entity:
		if area_parent != hitbox_owner:
			var invlv_type:String = area_parent.get_invlv_type()
			if !invlv_type.contains("Strike"):
				damage_entity(area_parent)

func damage_entity(body):
	body.damage(damage, knockback_amount, knockback_angle)
	emit_signal("hitbox_collided", body)
#	queue_free()
func set_future_collision():
	set_collision_layer_value(GlobalScript.collision_values.HITBOX_FUTURE, true)
	
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_STRIKE_HURTBOX_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.ENEMY_STRIKE_HURTBOX_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)

func set_past_collision():
	set_collision_layer_value(GlobalScript.collision_values.HITBOX_PAST, true)
	
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_STRIKE_HURTBOX_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.ENEMY_STRIKE_HURTBOX_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
