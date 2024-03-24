class_name Player extends Entity

signal health_updated(health)
signal killed()
signal respawning()

@onready var state_tracker = $Debug/StateTracker
@onready var debug_info = $Debug
@onready var health:int = max_health 
@onready var invlv_timer = $Invlv_Timer
@onready var effects_aniamtion: AnimationPlayer = $EffectAnimator
@onready var death_screen = $"%UI/DeathScreen"
@onready var health_bar = $"%HealthBar"
@onready var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var camera: Camera2DPlus = $Camera
@onready var quick_menu:Control = $"%QuickMenu"
@onready var stopwatch: Label = $"%Stopwatch"

@onready var UI:CanvasLayer = $"%UI"

@export var slow_down: float = 0.1
@export var max_health: int = 100

var items = []
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
	$UI/TimelineTracker.init(self)
	$Backgrounds.init(self)
	connect("health_updated", Callable(health_bar, "_on_health_updated"))
	if has_node("GroundChecker"):
		get_node("GroundChecker").queue_free()
	GlobalScript.connect("level_over", Callable(self, "_on_level_over"))
	GlobalScript.connect("game_over", Callable(self, "_on_game_over"))
	
func _on_game_over():
	self.queue_free()

func _on_level_over():
	print("level's over doing the script")
	camera.enabled = false
	
	UI.hide()
	
	set_process_input(false)
	set_physics_process(false)
	set_process(false)
	
	

func _physics_process(delta):
	super._physics_process(delta)

func _input(event):
	if Input.is_action_just_pressed("options"):
		quick_menu.enable_menu(current_level.name)
	if Input.is_action_pressed("slow_time"):
		Engine.time_scale = slow_down
	elif Input.is_action_just_released("slow_time"):
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
		emit_signal("health_updated", health, 5)
		if health <= 0:
			kill()
			emit_signal("killed")

func damage(amount, knockback:int = 0 , knockback_angle:int = 0, hitstun:int = 0):
	if invlv_timer.is_stopped():
		Input.start_joy_vibration(0, 0.5,0, 0.2)
		invlv_timer.start()
		_set_health(health - amount)
		effects_aniamtion.play("Damaged")
		effects_aniamtion.queue("Invincible")
		
#		camera.flash()
#		this will give an epilepsy warning lol

func heal(amount):
	_set_health(health + amount)

func kill():
	states.transition_to("Dead")

func _on_invlv_timer_timeout():
	effects_aniamtion.play("Rest")

func get_death_screen():
	return death_screen
	
func respawn():
	position = spawn_point
	motion = Vector2.ZERO
	if health > 0:
		states.transition_to("Fall")
	emit_signal("respawning")

func death_logic():
	GlobalScript.emit_signal("game_over")
	GlobalScript.player_instance = null
