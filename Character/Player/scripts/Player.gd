class_name Player extends Entity

signal health_updated(health)
signal killed()
signal respawning()

@onready var state_tracker:Label = $Debug/StateTracker
@onready var debug_info:Node2D = $Debug
@onready var health:int = max_health 
@onready var invlv_timer = $Invlv_Timer
@onready var effects_aniamtion: AnimationPlayer = $EffectAnimator
@onready var death_screen = $"%UI/DeathScreen"
@onready var health_bar:HealthBar = $"%HealthBar"
@onready var sprite: AnimatedSprite2D = $"%AnimatedSprite2D"
@onready var camera: Camera2DPlus = $Camera
@onready var quick_menu:Control = $"%QuickMenu"
@onready var stopwatch: Label = $"%Stopwatch"
@onready var grapple: Hook = $"%GrapplingHook"
@onready var backdrops = $"%Backgrounds"
@onready var UI:CanvasLayer = $"%UI"
@export_category("Grapple")
@export var grapple_pull: int = 75
@export var max_grapple_speed: Vector2
#Even if you're insane at the video game i don't think you should be able to move at
#mach 3 unfortunatly. 
@export_category("Stats")
@export var max_health: int = 100

var items = []
var respawn_timeline: String = "Future"
var spawn_point: Vector2

#Grapple
var grapple_velocity: Vector2 = Vector2.ZERO
var grappling_upwards:bool = false
var player_braced: bool = false
var grapple_enabled: bool = true 
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
	$"%TimelineTracker".init(self)
	backdrops.init(self)
	connect_signals()

	debug_info.visible = GlobalScript.debug_enabled
	
func connect_signals():
	GlobalScript.connect("level_over", Callable(self, "_on_level_over"))
	GlobalScript.connect("game_over", Callable(self, "_on_game_over"))
	GlobalScript.connect("enabling_menu", Callable(self, "_on_game_over"))
	GlobalScript.connect("disabling_menu", Callable(self, "enable"))
	connect("health_updated", Callable(health_bar, "_on_health_updated"))
	

func grapple_boost():
	if grapple.attached:
		var boost_dir:Vector2 = (position.direction_to(grapple.hook_body.global_position) * grapple.boost_speed.length()).round()
		if !player_braced:
			if abs(grapple.hook_location.y - global_position.y) <= 30:
				boost_dir.y = 0
				#remove vertical boost if the hook's body is basically level with the player's.
			print(boost_dir)
			motion += boost_dir
			grappling_upwards = false
		if grapple.grappled_object is MoveableObject:
			print(grapple.grappled_object.name + " is the name of the object.")
			grapple.grappled_object.call_deferred("apply_central_impulse", -boost_dir )
		grapple.release()
func disable():
	camera.enabled = false
	
	UI.hide()
	
	set_process_input(false)
	set_physics_process(false)
	set_process(false)
	backdrops.hide()

func enable():
	camera.enabled = true
	
	UI.show()
	
	set_process_input(true)
	set_physics_process(true)
	set_process(true)
	backdrops.show()

func _on_game_over():
	queue_free()

func _on_level_over():
	queue_free()

func _physics_process(delta):
	if Input.get_connected_joypads() == []:
		grapple.set_pointer_direction(get_global_mouse_position() - global_position)
	else:
		grapple.set_pointer_direction(Vector2(Input.get_joy_axis(0,JOY_AXIS_RIGHT_X), Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y)))
	
	super._physics_process(delta)
	
	var walk = (Input.get_action_strength("right") - Input.get_action_strength("left")) * states.find_state("Run").move_speed
	if grapple.attached and !player_braced:
		grapple_velocity = to_local(grapple.hook_location).normalized()
		if grapple_velocity.y < 0:
			grapple_velocity.y *= grapple.rise_multiplier
			grappling_upwards = true 
		else:
			grapple_velocity.y *= grapple.fall_multiplier
			grappling_upwards = false 
		if sign(grapple_velocity.x) != sign(walk):
			grapple_velocity.x *= grapple.sideways_multiplier
	else: 
		grapple_velocity = Vector2.ZERO
	
	if states.get_current_state().grounded():
		grapple_velocity.y = 0
		#no pulling up/down while running/sliding/idle/crouching, only airborne states
		#also helps with pushing around objects n stuff
	if grapple.grappled_object:
		var object_pull = grapple.hook_location.direction_to(global_position) * grapple.pull_speed
		if abs(grapple.hook_location.y - global_position.y) <= 30:
			object_pull.y = -5
			#if you're on the ground, apply a light lift upwards to prevent being stuck
		grapple.grappled_object.call_deferred("apply_central_impulse", object_pull)
	motion += grapple_velocity
	motion = motion.clamp(-max_grapple_speed, max_grapple_speed)


func _input(event):
	states.input(event)
	if grapple_enabled:
		if event is InputEventMouseMotion:
			grapple.set_pointer_direction(get_global_mouse_position())
		elif event is InputEventJoypadMotion:
			grapple.set_pointer_direction(Vector2(Input.get_joy_axis(0,JOY_AXIS_RIGHT_X), Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y)))
		if Input.is_action_just_pressed("grapple"):
			if GlobalScript.controller_type == "Keyboard":
				grapple.shoot(get_global_mouse_position() - global_position)
			else:
				grapple.shoot(Vector2(Input.get_joy_axis(0,JOY_AXIS_RIGHT_X), Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y)))
		elif Input.is_action_just_released("grapple"):
			if grapple.attached:
				grapple.release()
		if Input.is_action_just_pressed("boost"):
			grapple_boost()
	if Input.is_action_just_pressed("options"):
		quick_menu.enable_menu(current_level.name)

func set_spawn(location: Vector2, res_timeline: String = "Future"):
	spawn_point = location
	respawn_timeline = res_timeline

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health, 5)
		if health <= 0:
			kill()
			emit_signal("killed")

func damage(amount, knockback:int = 0 , knockback_angle:int = 0, hitstun:int = 0, ignores_invuln = false):
	if invlv_timer.is_stopped() or ignores_invuln:
		Input.start_joy_vibration(0, 0.5,0, 0.2)
		invlv_timer.start()
		_set_health(health - amount)
		effects_aniamtion.play("Damaged")
		effects_aniamtion.queue("Invincible")
		grapple.release()
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
	grapple.release()
	motion = Vector2.ZERO
	if health > 0:
		states.transition_to("Fall")
	emit_signal("respawning")

func death_logic():
	GlobalScript.emit_signal("game_over")
	GlobalScript.player_instance = null

func brace():
	player_braced = true

func relax():
	player_braced = false 

func change_grapple_status(status:bool):
	grapple_enabled = status
	grapple.pointer.visible = status
