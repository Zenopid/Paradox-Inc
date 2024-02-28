class_name Player extends Entity

signal health_updated(health)
signal killed()

@onready var state_tracker = $Debug/StateTracker
@onready var debug_info = $Debug
@onready var health:int = max_health 
@onready var invlv_timer = $Invlv_Timer
@onready var effects_aniamtion: AnimationPlayer = $EffectAnimator
@onready var death_screen = $UI/DeathScreen
@onready var health_bar = $UI/HealthBar
@onready var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var camera: Camera2DPlus = $Camera

@export var slow_down: float = 0.1
@export var max_health: int = 100

var respawn_timeline: String = "Future"

var spawn_point: Vector2
#
#func set_camera(camera_name: Camera2DPlus):
#	camera = camera_name

func get_spawn():
	return spawn_point

func get_camera():
	return camera

func _ready():
	sprite.position = Vector2.ZERO
	super._ready()
	states.init(self, debug_info)
	effects_aniamtion.play("Rest")
	for node in get_parent().get_children():
		if node is GenericLevel:
			current_level = node
	$UI/TimelineTracker.init(self)
	$Backgrounds.init(self)
	connect("health_updated", Callable(health_bar, "_on_health_updated"))
	if get_node_or_null("GroundChecker"):
		get_node("GroundChecker").queue_free()

func _physics_process(delta):
	super._physics_process(delta)

func _input(event):
	if Input.is_action_pressed("slow_time"):
		Engine.time_scale = slow_down
	else: 
		Engine.time_scale = 1

func set_spawn(location: Vector2, res_timeline: String = "Future"):
	spawn_point = location
	respawn_timeline = res_timeline

func _on_menu_button_pressed():
	get_parent().enable_menu()

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health)
		if health <= 0:
			kill()
			emit_signal("killed")

func damage(amount, knockback:int = 0 , knockback_angle:int = 0, hitstun:int = 0):
	if invlv_timer.is_stopped():
		invlv_timer.start()
		_set_health(health - amount)
		effects_aniamtion.play("Damaged")
		effects_aniamtion.queue("Invincible")
		
		camera.flash()

func heal(amount):
	_set_health(health + amount)

func kill():
	states.transition_to("Dead")

func _on_invlv_timer_timeout():
	effects_aniamtion.play("Rest")

func get_death_screen():
	return death_screen
	
func death_logic():
	_on_menu_button_pressed()
	
func respawn():
	position = spawn_point
	get_level().set_timeline(respawn_timeline)
	motion = Vector2.ZERO
	states.transition_to("Fall")

