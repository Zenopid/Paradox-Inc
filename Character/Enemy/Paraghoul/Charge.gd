extends BaseState

@export var max_charge_duration: float = 4
@export var object_push: Vector2 = Vector2(1250, 400)
@export var damage:int = 15
@export var charge_speed:int = 500
@export var hitbox: PackedScene
@export var cd: float = 3

@onready var particles:GPUParticles2D = $"%Particles"
var charge_direction:Vector2
var los_shapecast: ShapeCast2D
var charging:bool = false
var charge_timer:Timer
var cd_timer:Timer
var original_rotation: int = 180

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	los_shapecast = s_machine.get_shapecast("LOS")
	charge_timer = s_machine.get_timer("Charge_Limit")
	charge_timer.wait_time = max_charge_duration
	cd_timer = s_machine.get_timer("Charge_Cooldown")
	cd_timer.wait_time = cd
	
func enter(msg: = {}):
	super.enter(msg)
	charge_direction = msg["direction"] 
	original_rotation = entity.sprite.rotation_degrees
	entity.sprite.look_at(charge_direction)

func _on_startup_finished():
	entity.anim_player.play("ChargeLoop")
	charge_timer.start()
	charging = true 
	var hitbox_instance: Hitbox = hitbox.instantiate()
	hitbox_instance = hitbox_instance as Hitbox
	entity.sprite.add_child(hitbox_instance)
	hitbox_instance.hitbox_owner = entity
	#add it to the sprite so it can rotate along with it
	hitbox_instance.set_future_collision()
	hitbox_instance.set_past_collision()
	hitbox_instance.connect("hitbox_collided", Callable (self, "_on_charge_landed"))
	hitbox_instance.set_parameters({
		"damage": damage,
		"object_push": object_push,
		"duration": -1,
		"width": 60, 
		"height": 45,
	})
	hitbox_instance.add_to_group(entity.name + " Hitboxes")
	original_rotation = entity.sprite.rotation_degrees
	particles.emitting = true
	particles.rotation_degrees = entity.sprite.rotation_degrees + 180

func _on_charge_landed(object):
	state_machine.transition_to("Chase")
	
func physics_process(delta:float):
	if entity.grounded():
		state_machine.transition_to("Chase")
		return
	if charging:
		if charge_timer.is_stopped():
			entity.pathfinder.target_position = entity.aggro_player.global_position
			state_machine.transition_to("Chase")
			return
		entity.velocity = charge_direction * charge_speed
		particles.global_position = Vector2(entity.global_position.x - 5, entity.global_position.y )
	else:
		entity.velocity = Vector2.ZERO
	entity.move_and_slide() 

func exit() -> void:
	super.exit()
	entity.sprite.modulate = Color(1, 1, 1, 1,) #charge the modulate back to normal
	entity.sprite.rotation_degrees = original_rotation
	cd_timer.start()
	for i in get_tree().get_nodes_in_group(entity.name + " Hitboxes"):
		i.queue_free()
	particles.emitting = false
	charging = false
	entity.set_color()

func conditions_met():
	entity = entity as ParaGhoul
	if is_instance_valid(entity.link_object):
		var object_type:String = entity.link_object.get_object_type()
		if object_type.contains("Garbage") and cd_timer.is_stopped():
			print("can charge at player ")
			return true
	return false 
