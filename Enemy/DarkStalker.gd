class_name Enemy extends Entity

signal health_updated(health)
signal killed()

@export var max_health: int = 100
@export_enum ("Future", "Past") var current_timeline:String = "Future"
@onready var health:int = max_health 
@onready var health_bar = $UI/HealthBar
@onready var effects_animation = get_node_or_null("EffectAnimator")
@onready var sprite: Sprite2D = get_node("Sprite")
@onready var pathfinder: NavigationAgent2D = $Pathfinder
@onready var beehave_tree: BeehaveTree = get_node_or_null("AI_Tree")
@onready var attack_node: DarkStalkerAttack = get_node_or_null("Attack")
@onready var speed_tracker =  $Debug/MotionTracker
@onready var detection_sphere: Area2D = $DetectionSphere
@onready var hitsparks: GPUParticles2D = $Hitsparks

var currently_attacking:bool = false
var in_hitstun: bool = false
var stun_cnt: int = 0
var spawn_point: Vector2

func get_spawn():
	return spawn_point

func _ready():
	#for now...
	#its changing tho... things going crazy hold on
	for nodes in get_node("Raycasts").get_children():
		if nodes is RayCast2D:
			nodes.add_exception(self)
	if beehave_tree == null:
		print_debug("HEY! SOMETHING WENT HORRIBLY WRONG AND NOW ITS NULL")
	super._ready()
	current_level = get_parent()
	print(current_level)
	connect("health_updated", Callable(health_bar, "_on_health_updated"))
	current_level.connect("swapped_timeline", Callable(self, "pause_logic"))
	if get_node_or_null("GroundChecker"):
		get_node("GroundChecker").queue_free()


func pause_logic(timeline):
	if current_timeline != timeline:
		visible = false
		beehave_tree.enabled = false
		set_physics_process(false)
	else:
		visible = true
		beehave_tree.enabled = true
		set_physics_process(true)

func _physics_process(delta):
#	super._physics_process(delta)
	stun_cnt = clamp(stun_cnt, 0, stun_cnt - 1)
	if stun_cnt <= 0:
		in_hitstun = false
	speed_tracker.text = "Speed: (" + str(round(motion.x)) + "," + str(round(motion.y)) + ")"
	

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
	hitsparks.emitting = true
	

func heal(amount):
	_set_health(health + amount)

func kill():
	beehave_tree.enabled = false
	anim_player.play("Dead")
	await anim_player.animation_finished
	queue_free()
	
func get_raycast(ray_name):
	if ray_name == "Ground Checker":
		ray_name = "GroundChecker"
	#some code is calling it that, don't know why.
	var raycast:RayCast2D = get_node("Raycasts").get_node(ray_name)
	if raycast:
		return raycast
	print_debug("Cannot find the raycast called " + ray_name)
	
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

func create_hitbox(width,height,damage, kb_amount, angle, duration, type, angle_flipper, points, push, hitlag):
	attack_node.create_hitbox(width, height, damage, kb_amount, angle, duration, type, angle_flipper, points, push, hitlag)

func player_near():
	for i in detection_sphere.get_overlapping_bodies():
		if i is Player:
			return true
	return false

func clear_hitboxes():
	get_node("Attack").clear_hitboxes()
