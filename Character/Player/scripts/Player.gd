class_name Player extends Entity


const SAVE_FILE_PATH:String =  "user://save_info/player_data.tres"


signal killed()
signal respawning()

@export_category("Grapple")
@export var grapple_pull: int = 75
@export var max_grapple_speed: int = 900
@export var max_grapple_pull_speed:int = 500
@export var air_grapple_boosts:int = 1
@export var air_grapple_boost_amount:float
@export var level_with_grapple_range: int = 30
@export var grapple_boost_object_pull_multiplier: float = 0.3

@export_category("Stats")
@export var max_health: int = 100

@onready var state_tracker:Label = $Debug/StateTracker
@onready var health:int = max_health 
@onready var invlv_timer:Timer = $Invlv_Timer
@onready var effects_animation: AnimationPlayer = $EffectAnimator
@onready var death_screen:ColorRect = $"%UI/DeathScreen"
@onready var sprite: AnimatedSprite2D = $"%AnimatedSprite2D"
@onready var camera: Camera2DPlus = $Camera
@onready var quick_menu:Control = $"%QuickMenu"
@onready var stopwatch: Label = $"%Stopwatch"
@onready var grapple: Hook = $"%GrapplingHook"
@onready var backdrops = $"%Backgrounds"
@onready var UI:CanvasLayer = $"%UI"
@onready var timeline_tracker: Label = $"%TimelineTracker"
@onready var detection_area: Area2D = $"%DetectionArea"



var player_info:PlayerInfo = PlayerInfo.new():
	set(value):
		player_info = value
		set_physics_process(player_info != null)
	get:
		return player_info
var items: = {}
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

var state_machine_states := {}

#Ghost info
var ghost_info: PlayerGhost = PlayerGhost.new()
var update_ghost:bool = true
var player_positions: PackedVector2Array  = []
var player_animations: PackedStringArray = []
var checkpoint_timestamps: PackedInt32Array= []

var checkpoints_reached:int = 0

func get_spawn():
	return spawn_point

func get_camera():
	return camera

func _ready():
	sprite.position = Vector2.ZERO
	super._ready()
	effects_animation.play("Rest")
	timeline_tracker.init(self)
	backdrops.init(self)
	connect_signals()
	
	_on_swapped_timeline(current_level.current_timeline)
	state_machine_states = states.get_all_states()
	
	set_grapple_cursor(grapple_enabled)
	if GlobalScript.controller_type == "Keyboard":
		grapple.pointer.visible = false
	else:
		grapple.pointer.visible = true
	camera.make_current()
func connect_signals():
	GlobalScript.connect("level_over", Callable(self, "_on_level_over"))
	GlobalScript.connect("game_over", Callable(self, "_on_game_over"))
	GlobalScript.connect("enabling_menu", Callable(self, "_on_game_over"))
	GlobalScript.connect("disabling_menu", Callable(self, "enable"))
	GlobalScript.connect("save_game_state", Callable(self, "save"))
	connect("respawning", Callable(current_level, "_on_player_respawning"))

func _on_swapped_timeline(new_timeline:String):
	if new_timeline.to_lower() == "future":
		set_collision(true, false)
	else:
		set_collision(false, true)
	states._on_level_timeline_swapped(new_timeline)
	grapple._on_swapped_timeline(new_timeline)

func entity_near() -> bool:
	for body in detection_area.get_overlapping_bodies():
		if body != self:
			return true
	return false

func set_collision(future_value, past_value):
		detection_area.set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, future_value)
		detection_area.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, past_value)
		
		detection_area.set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, future_value)
		detection_area.set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, past_value)
	
		set_collision_layer_value(GlobalScript.collision_values.PLAYER_FUTURE, future_value)
		set_collision_layer_value(GlobalScript.collision_values.PLAYER_PAST, past_value)
		
		set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, future_value)
		set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, past_value)
		
		set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, future_value)
		set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, past_value)

		set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, future_value)
		set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, past_value)
		
		set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, future_value)
		set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, past_value)
		
		set_collision_mask_value(GlobalScript.collision_values.BOUNDARY_FUTURE, future_value)
		set_collision_mask_value(GlobalScript.collision_values.BOUNDARY_PAST, future_value)
		

func grapple_boost():
	grapple = grapple as Hook
	if grapple.attached:
		var boost_amount:Vector2 = (position.direction_to(grapple.hook_body.global_position) * grapple.boost_speed.length()).round()
		if !player_braced:
			if !states.get_current_state().grounded() and grappling_upwards:
				grapple_boost_tracker += 1
				if grapple_boost_tracker <= air_grapple_boosts:
					if velocity.y > 0:
						velocity.y = 0
					boost_amount.y *= 1 + air_grapple_boost_amount
					#allow grapple to pull you up easier a couple times.
			if abs(grapple.hook_location.y - global_position.y) <= level_with_grapple_range:
				boost_amount.y = 0
				#remove vertical boost if the hook's body is basically level with the player's.
			if velocity.length() < max_grapple_speed:
				velocity += boost_amount
				velocity = velocity.limit_length(max_grapple_speed)
		if grapple.object_pullable():
			grapple.grappled_object.call_deferred("apply_central_impulse", -(boost_amount * (1  + grapple_boost_object_pull_multiplier)) )
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
	update_ghost = false
	ghost_info.save_ghost_data()
	queue_free()

func _physics_process(delta):
	super._physics_process(delta)
	var grounded = states.get_current_state().grounded()
	var walk = (Input.get_action_strength("right") - Input.get_action_strength("left")) * state_machine_states["Run"].move_speed
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
	
	if grounded:
		grapple_velocity.y = 0
		#no pulling up/down while running/sliding/idle/crouching, only airborne states
		#also helps with pushing around objects n stuff
		grapple_boost_tracker = 0
	if grapple.object_pullable():
		var object_pull = grapple.hook_location.direction_to(global_position) * grapple.pull_speed
		if abs(grapple.hook_location.y - global_position.y) <= level_with_grapple_range :
			object_pull.y = -2
			#if you're trying to pull an object horiztonally , apply a light lift upwards to prevent being stuck, otherwise try to keep it level
		grapple.grappled_object.call_deferred("apply_central_impulse", object_pull)
		#grapple.grappled_object.set_timeline(current_level.current_timeline)
	if velocity.length() < max_grapple_speed:
		velocity += grapple_velocity
		velocity = velocity.limit_length(max_grapple_speed)
	if update_ghost:
		player_positions.append(global_position)
		player_animations.append(anim_player.get_current_animation())
	#velocity = velocity.clamp(-max_grapple_speed, max_grapple_speed)


func _input(event):
	states.input(event)
	if grapple_enabled:
		if GlobalScript.controller_type == "Keyboard":
			if event is InputEventMouseMotion:
				grapple.set_pointer_direction(get_global_mouse_position())
			if Input.is_action_just_pressed("grapple"):
				grapple.shoot(get_global_mouse_position() - global_position)
		elif GlobalScript.controller_type == "Controller":
			if event is InputEventJoypadMotion:
				grapple.pointer.visible = true 
				grapple.set_pointer_direction(Vector2(Input.get_joy_axis(0,JOY_AXIS_RIGHT_X), Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y)))
				grapple.shoot(Vector2(Input.get_joy_axis(0,JOY_AXIS_RIGHT_X), Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y)))
		if Input.is_action_just_released("grapple"):
			grapple.release()
		if Input.is_action_just_pressed("boost"):
			grapple_boost()
	if Input.is_action_just_pressed("options"):
		quick_menu.enable_menu(current_level.name)

func set_spawn(location: Vector2, res_timeline: String = "Future"):
	player_info.spawn_point = location
	player_info.respawn_timeline = res_timeline

func _set_health(value):
	var prev_health = player_info.health
	player_info._set_health(value) 
	if player_info.health != prev_health:
		emit_signal("health_updated", player_info.health, 5)
		if player_info.health <= 0:
			kill()
			emit_signal("killed")

func damage(amount, knockback:int = 0 , knockback_angle:int = 0, hitstun:int = 0, ignores_invuln = false):
	if invlv_timer.is_stopped() or ignores_invuln:
		Input.start_joy_vibration(0, 0.5,0, 0.2)
		invlv_timer.start()
		_set_health(player_info.health - amount)
		effects_animation.play("Damaged")
		effects_animation.queue("Invincible")

func heal(amount):
	_set_health(health + amount)

func kill():
	states.transition_to("Dead")

func _on_invlv_timer_timeout():
	effects_animation.play("Rest")

func get_death_screen():
	return death_screen
	
func respawn():
	position = player_info.spawn_point
	grapple.release()
	velocity = Vector2.ZERO
	if player_info.health > 0:
		states.transition_to("Fall")
	emit_signal("respawning")

func on_checkpoint_reached(heal_amount:int, new_timeline:String, new_spawn:Vector2):
	set_spawn(new_spawn)
	heal(heal_amount)
	respawn_timeline = new_timeline
	checkpoint_timestamps.append(stopwatch.get_total_time())
	emit_signal("respawning")

func brace():
	player_braced = true

func relax():
	player_braced = false 

func change_grapple_status(status:bool):
	grapple_enabled = status
	set_grapple_cursor(status)

func set_grapple_cursor(status:bool):
	if status:
		Input.set_custom_mouse_cursor(grapple.pointer.texture)
	else:
		Input.set_custom_mouse_cursor(null)

func get_max_speed() -> int:
	return max_grapple_speed

func get_checkpoints_reached():
	#warning-ignore: Integer

	return checkpoints_reached

func get_max_health() -> int:
	return player_info.max_health

func get_respawn_timeline() -> String:
	return player_info.respawn_timeline
