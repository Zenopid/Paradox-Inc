class_name Enemy extends Entity

signal killed()

@export var max_health: int = 100
@export var detection_color: Color
@export var no_detection_color: Color
@export var gravity: int = 25
@export var max_fall_speed: int = 150
@export var is_paradox: bool = false
@export var hitbox: Hitbox

@onready var health:int = max_health 
@onready var effects_animation:AnimationPlayer = get_node_or_null("EffectAnimator")
@onready var sprite = get_node("Sprite")
@onready var pathfinder: NavigationAgent2D = $"%Pathfinder"
@onready var beehave_tree: BeehaveTree = get_node_or_null("AI_Tree")
@onready var speed_tracker:Label=  $Debug/MotionTracker
@onready var detection_sphere: Area2D = $DetectionSphere
@onready var detection_shape: CollisionShape2D = $DetectionSphere/CollisionShape2D
@onready var enemy_sphere: Area2D = $EnemySphere
@onready var enemy_sphere_shape: CollisionShape2D = $EnemySphere/CollisionShape2D
@onready var hitsparks: GPUParticles2D = $Hitsparks
@onready var los_raycast = $"%LOS"
@onready var ground_raycast:RayCast2D = $"%GroundChecker"
@onready var raycast_node = $"%Raycasts"
@onready var shapecast_node = $"StateMachine".get_node_or_null("ShapeCasts")

var currently_attacking:bool = false
var in_hitstun: bool = false
var stun_cnt: int = 0
var spawn_point: Vector2
var player_close:bool = false
var enemy_close: bool = false
var raycasts = []
var detection_areas = []
var being_destroyed:bool = false 

func get_spawn():
	return spawn_point

func _ready():
	add_to_group("Enemy")
	if raycast_node:
		for nodes in raycast_node.get_children():
			nodes.add_exception(self)
	if shapecast_node:
		for nodes in shapecast_node.get_children():
			nodes.add_exception(self)
	super._ready()
	detection_shape.debug_color = no_detection_color
	raycasts = get_tree().get_nodes_in_group("Raycasts")
	detection_areas = get_tree().get_nodes_in_group("Detection")
	_on_swapped_timeline(current_level.get_current_timeline())
	init_collision()
	current_level.connect("level_over", Callable(self, "queue_free"))
	GlobalScript.connect("game_over", Callable(self, "_on_game_over"))

func _on_game_over():
	for projectiles in get_tree().get_nodes_in_group(self.name + " Projectiles"):
		projectiles.queue_free()
	queue_free()
	
func init_collision():
	if is_paradox:
		set_collision(true, true)
		modulate.a = 1
	else:
		if current_timeline.to_lower() == "future":
			set_collision(true, false)
		else:
			set_collision(false, true)
	
func _on_swapped_timeline(timeline: String):
	if !being_destroyed:
		if is_paradox:
			return
		if current_timeline != timeline:
			modulate.a = 0.25
		else:
			modulate.a = 1


func set_collision(future_value, past_value):
	
	detection_sphere.set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, future_value)
	detection_sphere.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, past_value)
	
	enemy_sphere.set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, future_value)
	enemy_sphere.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, past_value)
	
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, future_value)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, future_value)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, future_value)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, future_value)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, future_value)
	
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, past_value)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, past_value)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, past_value)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, past_value)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, past_value)
	
	if ground_raycast:
		ground_raycast.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, future_value)
		ground_raycast.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, past_value)
		
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, future_value)
	set_collision_layer_value(GlobalScript.collision_values.ENTITY_FUTURE, future_value)
	set_collision_layer_value(GlobalScript.collision_values.ENTITY_PAST, past_value)
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, past_value)
	
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, future_value)
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, past_value)
	
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, future_value)
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, past_value)

	set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, future_value)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, past_value)
	
	set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, future_value)
	set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, past_value)
	
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, future_value)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, past_value)

	set_collision_mask_value(GlobalScript.collision_values.PROJECTILE_FUTURE, future_value)
	set_collision_mask_value(GlobalScript.collision_values.PROJECTILE_PAST, past_value)


func _physics_process(delta):
	super._physics_process(delta)
	stun_cnt = clamp(stun_cnt, 0, stun_cnt - 1)
	if stun_cnt <= 0:
		in_hitstun = false
	speed_tracker.text = "Speed: (" + str(round(velocity.x)) + "," + str(round(velocity.y)) + ")"
	velocity.y += gravity
	velocity.y = clamp(velocity.y, 0, velocity.y)
	if being_destroyed:
		queue_free()

func _process(delta):
	states.update(delta)
		
func set_spawn(location: Vector2):
	spawn_point = location

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health, 5)
		if health <= 0:
			kill()
			emit_signal("killed")

func damage(amount, knockback: int = 0, knockback_angle: int = 0, hitstun: int = 0):
	in_hitstun = true
	stun_cnt = hitstun
	_set_health(health - amount)
	effects_animation.play("Damaged")
	if hitsparks.emitting == false:
		hitsparks.emitting = true
	else:
		hitsparks.restart()

func heal(amount):
	_set_health(health + amount)

func kill():
	health_bar.hide()
	if current_level.is_connected("swapped_timeline", Callable(self, "_on_swapped_timeline")):
		current_level.disconnect("swapped_timeline", Callable(self, "_on_swapped_timeline"))
	if beehave_tree:
		beehave_tree.free()
	anim_player.play("Dead")
	await anim_player.animation_finished
	queue_free()
	
func get_raycast(ray_name:String) -> RayCast2D:
	if ray_name.contains(" "):
		ray_name.replace(" ", "")
		#get rid of spaces because something is calling it with spaces
	var raycast:RayCast2D = get_node("Raycasts").get_node(ray_name)
	if raycast:
		return raycast
	print_debug("Cannot find the raycast called " + ray_name)
	return null
	
func is_in_hitstun():
	return in_hitstun
	


func create_hitbox(hitbox_info: = {}):
#	attack_node.create_hitbox(width, height,attack_damage, kb_amount, angle, duration, type, angle_flipper, points, push, hitlag)
	var hitbox_instance: Hitbox = hitbox.instantiate()
	if sprite.flip_h:
		hitbox_info["position"] *= -1 
		hitbox_info ["object_push"] *= -1
	add_child(hitbox_instance)
	hitbox_instance.call("set_" + current_timeline.to_lower() +"_collision")
	hitbox_instance.set_parameters(hitbox_info)
	hitbox_instance.add_to_group(name + " Hitboxes")
	return hitbox_instance
	
func player_near():
	return player_close

func clear_hitboxes():
	for i in get_tree().get_nodes_in_group(name + "Hitboxes"):
		i.free()

func _on_detection_sphere_body_entered(body):
	if body is Player:
		detection_shape.debug_color = detection_color
		player_close = true

func _on_detection_sphere_body_exited(body):
	if body is Player:
		detection_shape.debug_color = no_detection_color
		player_close = false


func enemy_near():
	return enemy_close


func get_max_health() -> int:
	return max_health

func on_grapple_pulled():
	pass
