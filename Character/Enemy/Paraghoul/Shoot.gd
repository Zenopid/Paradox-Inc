extends BaseState

@export var projectile:PackedScene
@export var entity_speed_multiplier: float = 0.15

@onready var shoot_cooldown:Timer
@onready var target_position:Vector2
@onready var los_raycast: ShapeCast2D
@onready var player:Player

#
const PROJECTILE_SPAWN_LOCATION = Vector2(18, 15)

#
#@onready var state_machine: EntityStateMachine
#@onready var hitbox_owner 
#@onready var hitbox: CollisionShape2D = $"%Hitbox"
#@onready var area_box: CollisionObject2D = $"%Shape"
#@onready var area_node: Area2D = $"%Detection"
#@onready var duration_timer:Timer = $"%Duration"

@onready var debug_sphere:Area2D
@onready var sphere_shape:CollisionShape2D
@onready var chase_node

var do_physics_process:bool = false

var target

func init(current_entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	shoot_cooldown = state_machine.get_timer("Shoot_Cooldown")
	los_raycast = state_machine.get_shapecast("LOS")
	player = get_tree().get_first_node_in_group("Players")
	chase_node = state_machine.find_state("Chase")
	if GlobalScript.debug_enabled:
		debug_sphere = Area2D.new()
		sphere_shape = CollisionShape2D.new()
		var shape:CircleShape2D = CircleShape2D.new()
		shape.radius = 20
		sphere_shape.set_shape(shape)
		debug_sphere.add_child(sphere_shape)
		add_child(debug_sphere)
		debug_sphere.visible = true

func enter(msg: = {}):
	player = get_tree().get_first_node_in_group("Players")
	entity.anim_player.connect("animation_finished", Callable(self, "projectile_attack"))
	super.enter()
	entity.velocity *= entity_speed_multiplier
	
func projectile_attack(attack_name):
	var fireball_instance = projectile.instantiate()
	GlobalScript.add_child(fireball_instance)
	var points:Vector2 = entity.global_position + PROJECTILE_SPAWN_LOCATION
	var push:Vector2 = fireball_instance.object_push
	if !entity.sprite.flip_h:
		points.x = abs(points.x)
		push.x = abs(push.x)
	
	var hitbox_info = {
		"global_position": points,
		"projectile_owner": entity,
		"direction": entity.global_position.direction_to(player.global_position).rotated(entity.sprite.rotation )
	}
	fireball_instance.set_parameters(hitbox_info)
	fireball_instance.set_future_collision()
	fireball_instance.set_past_collision()
	state_machine.transition_to("Chase")

func physics_process(delta:float):
	entity.move_and_slide()

func exit() -> void:
	shoot_cooldown.start()
	entity.anim_player.disconnect("animation_finished", Callable(self, "projectile_attack"))
