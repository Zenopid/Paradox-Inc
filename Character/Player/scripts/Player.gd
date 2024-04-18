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
@onready var sprite: AnimatedSprite2D = $"%AnimatedSprite2D"
@onready var camera: Camera2DPlus = $Camera
@onready var quick_menu:Control = $"%QuickMenu"
@onready var stopwatch: Label = $"%Stopwatch"
@onready var grapple: Hook = $"%GrapplingHook"
@onready var backdrops = $"%Backgrounds"
@onready var UI:CanvasLayer = $"%UI"
@onready var timeline_tracker: Label = $"%TimelineTracker"
@export_category("Grapple")
@export var grapple_pull: int = 75
@export var max_grapple_speed: Vector2
@export var air_grapple_boosts:int = 1
@export var air_grapple_boost_amount:float
@export_category("Stats")
@export var max_health: int = 100

var items = []
var respawn_timeline: String = "Future"
var spawn_point: Vector2

#Grapple
var grapple_velocity: Vector2 = Vector2.ZERO
var player_braced: bool = false
var grapple_enabled: bool = true 
var grapple_boost_tracker:int = 1
var grappling_upwards: bool = false
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
	states.init(debug_info)
	effects_aniamtion.play("Rest")
	timeline_tracker.init(self)
	backdrops.init(self)
	connect_signals()

	debug_info.visible = GlobalScript.debug_enabled
	_on_swapped_timeline(current_level.current_timeline)
	
func connect_signals():
	GlobalScript.connect("level_over", Callable(self, "_on_level_over"))
	GlobalScript.connect("game_over", Callable(self, "_on_game_over"))
	GlobalScript.connect("enabling_menu", Callable(self, "_on_game_over"))
	GlobalScript.connect("disabling_menu", Callable(self, "enable"))
	GlobalScript.connect("save_game_state", Callable(self, "save"))

func _on_swapped_timeline(new_timeline:String):
	print("changing player location to " + new_timeline)
	if new_timeline == "Past":
		print("Changing past right now")
		set_collision_layer_value(GlobalScript.collision_values.PLAYER_PAST, true)
		set_collision_layer_value(GlobalScript.collision_values.PLAYER_FUTURE, false)
		
		set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, false)
		set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
		
		set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, false)
		set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, true)
		
		set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, false)
		set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)
	else:
		print("Changing future right now")
		set_collision_layer_value(GlobalScript.collision_values.PLAYER_FUTURE, true)
		set_collision_layer_value(GlobalScript.collision_values.PLAYER_PAST, false)
		
		set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)
		set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, false)
		
		set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, true)
		set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, false)

		set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
		set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, false)
	states._on_level_timeline_swapped(new_timeline)
	grapple._on_swapped_timeline(new_timeline)

func grapple_boost():
	if grapple.attached:
		var boost_dir:Vector2 = (position.direction_to(grapple.hook_body.global_position) * grapple.boost_speed.length()).round()
		if !player_braced:
			if abs(grapple.hook_location.y - global_position.y) <= 30:
				boost_dir.y = 0
				#remove vertical boost if the hook's body is basically level with the player's.
			#print(boost_dir)
			if !states.get_current_state().grounded() and grappling_upwards:
				grapple_boost_tracker += 1
				if grapple_boost_tracker <= air_grapple_boosts:
					
					if motion.y > 0:
						motion.y = 0
					boost_dir.y *= 1 + air_grapple_boost_amount
					#allow grapple to pull you up easier a couple times.
			print(grapple_boost_tracker)
			motion += boost_dir
		if grapple.grappled_object is MoveableObject:
			#print(grapple.grappled_object.name + " is the name of the object.")
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
		grapple_boost_tracker = 0
	if grapple.grappled_object:
		var object_pull = grapple.hook_location.direction_to(global_position) * grapple.pull_speed
		if abs(grapple.hook_location.y - global_position.y) <= 30:
			object_pull.y = -2
			#if you're on the , apply a light lift upwards to prevent being stuck, otherwise try to keep it level
		grapple.grappled_object.call_deferred("apply_central_impulse", object_pull)
		#grapple.grappled_object.set_timeline(current_level.current_timeline)
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
	
func save() -> Dictionary:
	var save_data = {
		"global_position": global_position,
		"health": health,
		"items": items,
		"name": "Player",
	}
#	SaveSystem.set_var("Player", player_data)
	SaveSystem.set_var("Player", save_data)
	return save_data

func load_from_file():
	var save_data = SaveSystem.get_var("Player")
	if save_data:
		for i in save_data.keys():
			set(i, save_data[i])
		print("loaded player data")
#		print(str(player_data[i]) + " is the current value.")
#		if i.contains(":"):
#			set_indexed(get_indexed(i), player_data[i])
#		else:
#			set(get(i), player_data[i])
#
