class_name Enemy extends Entity

signal health_updated(health)
signal killed()

@export var max_health: int = 100
@export var detection_color: Color
@export var no_detection_color: Color
@export var gravity: int = 25
@export var max_fall_speed: int = 150

@onready var health:int = max_health 
@onready var effects_animation:AnimationPlayer = get_node_or_null("EffectAnimator")
@onready var sprite = get_node("Sprite")
@onready var pathfinder: NavigationAgent2D = $Pathfinder
@onready var beehave_tree: BeehaveTree = get_node_or_null("AI_Tree")
@onready var attack_node: BaseState = $"%Attack"
@onready var speed_tracker:Label=  $Debug/MotionTracker
@onready var detection_sphere: Area2D = $DetectionSphere
@onready var detection_shape: CollisionShape2D = $DetectionSphere/CollisionShape2D
@onready var enemy_sphere: Area2D = $EnemySphere
@onready var enemy_sphere_shape: CollisionShape2D = $EnemySphere/CollisionShape2D
@onready var hitsparks: GPUParticles2D = $Hitsparks
@onready var debug_ui: Node2D = $"%Debug"
@onready var los_raycast:RayCast2D = $"%LOS"
@onready var ground_raycast:RayCast2D = $"%GroundChecker"
@onready var raycast_node = $"%Raycasts"

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
			if nodes is RayCast2D:
				nodes.add_exception(self)
	super._ready()
	current_level = get_tree().get_first_node_in_group("CurrentLevel")
	detection_shape.debug_color = no_detection_color
	if debug_ui:
		debug_ui.visible = GlobalScript.debug_enabled
	
	raycasts = get_tree().get_nodes_in_group("Raycasts")
	detection_areas = get_tree().get_nodes_in_group("Detection")
	_on_swapped_timeline(current_level.get_current_timeline())
	
func _on_swapped_timeline(timeline: String):
	if !being_destroyed:
		if current_timeline != timeline:
			modulate.a = 0.25
#			beehave_tree.enabled = false
#			set_physics_process(false)
#
#			for nodes in raycasts:
#				nodes.enabled = false
#			for nodes in detection_areas:
#				nodes.set_deferred("monitoring", false)
#				nodes.set_deferred("monitorable",false)
#			for i in get_tree().get_nodes_in_group("Chase Locations"):
#				i.queue_free()
		else:
			modulate.a = 1
#		print(timeline + " is the current timeline.")
#		if timeline == "Future":
#			set_future_collision()
#		else:
#			set_past_collision()
		call("set_" +timeline.to_lower() + "_collision")
#			beehave_tree.enabled = true
#			set_physics_process(true)
#			for nodes in raycasts:
#				nodes.enabled = true
#			for nodes in detection_areas:
#				nodes.set_deferred("monitoring", true)
#				nodes.set_deferred("monitorable",true)
				
#	for nodes in raycasts:
#		nodes.set(get("collision_mask"), get("collision_mask"))
	#print(being_destroyed)

func set_future_collision():
	
	detection_sphere.set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, true)
	detection_sphere.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, false)
	
	enemy_sphere.set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, true)
	enemy_sphere.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, false)
	
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, true)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, true)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, true)
	
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, false)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, false)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, false)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, false)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, false)
	
	ground_raycast.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)
	ground_raycast.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, false)
	
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, true)
	set_collision_layer_value(GlobalScript.collision_values.ENTITY_FUTURE, true)
	set_collision_layer_value(GlobalScript.collision_values.ENTITY_PAST, false)
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, false)
	
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, false)
	
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, false)

	set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, false)
	
	set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, false)
	
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, false)

func set_past_collision():
	
	detection_sphere.set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, false)
	detection_sphere.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, true)
	
	enemy_sphere.set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, false)
	enemy_sphere.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, true)
	
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, false)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, false)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, false)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, false)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, false)
	
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, true)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, true)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)
	los_raycast.set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, true)
	
	
	ground_raycast.set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, false)
	ground_raycast.set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
	
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, false)
	set_collision_layer_value(GlobalScript.collision_values.ENTITY_FUTURE, false)
	set_collision_layer_value(GlobalScript.collision_values.ENTITY_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, true)
	
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, false)
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, true)
	
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, false)
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, true)

	set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, false)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
	
	set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, false)
	set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, true)
	
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, false)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)

func _physics_process(delta):
#	super._physics_process(delta)
	stun_cnt = clamp(stun_cnt, 0, stun_cnt - 1)
	if stun_cnt <= 0:
		in_hitstun = false
	speed_tracker.text = "Speed: (" + str(round(motion.x)) + "," + str(round(motion.y)) + ")"
	motion.y += gravity
	motion.y = clamp(motion.y, 0, max_fall_speed)
	if being_destroyed:
		queue_free()
		
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
	destroy()
	
func get_raycast(ray_name:String) -> RayCast2D:
#	if ray_name == "Ground Checker":
#		ray_name = "GroundChecker"
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
	
func default_move_and_slide():
	set_velocity(motion)
	set_up_direction(Vector2.UP)
	set_floor_stop_on_slope_enabled(true)
	set_max_slides(4)
	set_floor_max_angle(PI/4)
	move_and_slide()
	motion = velocity

func create_hitbox(width,height,attack_damage, kb_amount, angle, duration, type, angle_flipper, points, push, hitlag):
	attack_node.create_hitbox(width, height,attack_damage, kb_amount, angle, duration, type, angle_flipper, points, push, hitlag)

func player_near():
	return player_close

func clear_hitboxes():
	attack_node.clear_hitboxes()

func save() -> Dictionary:
	var save_dict = {
	"position": global_position,
	"health": health,
	"current_timeline": current_timeline,
	"name": name,
	}
#	SaveSystem.set_var(self.name, save_dict)
	SaveSystem.set_var("Enemies:" + name, save_dict) 
	return save_dict

func load_from_file():
	var save_data = SaveSystem.get_var("Enemies:" + name)
	if save_data:
		for i in save_data.keys():
			set(i, save_data[i])

func _on_detection_sphere_body_entered(body):
	if body is Player:
		detection_shape.debug_color = detection_color
		player_close = true

func _on_detection_sphere_body_exited(body):
	#print(body)
	if body is Player:
		detection_shape.debug_color = no_detection_color
		player_close = false


func enemy_near():
	return enemy_close

func destroy():
	being_destroyed = true
	