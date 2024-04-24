extends BaseState

@export var projectile:PackedScene

@onready var shoot_cooldown:Timer
@onready var target_position:Vector2
@onready var los_raycast: RayCast2D

#
const PROJECTILE_SPAWN_LOCATION = Vector2(-18, 15)

#
#@onready var state_machine: EntityStateMachine
#@onready var hitbox_owner 
#@onready var hitbox: CollisionShape2D = $"%Hitbox"
#@onready var area_box: CollisionObject2D = $"%Shape"
#@onready var area_node: Area2D = $"%Detection"
#@onready var duration_timer:Timer = $"%Duration"

func init(current_entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	shoot_cooldown = state_machine.get_timer("Shoot_Cooldown")
	los_raycast = state_machine.get_raycast("LOS")
	
func enter(msg: = {}):
	super.enter()
#	print_debug(entity.name + " entered shoot state, but we don't have code for that yet, so going to idle")
#	los_raycast.target_position = msg["target_position"]
#	state_machine.transition_to("Idle")
	entity.anim_player.connect("animation_finished", Callable(self, "_on_shoot_anim_over"))

func _on_shoot_anim_over(anim_name):
	var fireball_instance = projectile.instantiate()
	GlobalScript.add_child(fireball_instance)
	var points:Vector2 = entity.global_position + PROJECTILE_SPAWN_LOCATION
	var push:Vector2 = fireball_instance.object_push
	if entity.sprite.flip_h:
		points.x = abs(points.x)
		push.x = abs(push.x)
	var hitbox_info = {
		"global_position": points,
		"object_push": push,
		"direction": los_raycast.rotation
	}
	fireball_instance.set_parameters(hitbox_info)
	fireball_instance.set_future_collision()
	fireball_instance.set_past_collision()
	fireball_instance.add_to_group(name + "Projectiles")
	state_machine.transition_to("Idle")

func exit() -> void:
	entity.anim_player.disconnect("animation_finished", Callable(self, "_on_shoot_anim_over"))

