class_name Wallrun extends Walljump


@export var time_until_decay:float = 0.4
@export var acceleration: int = 25
@export var max_speed: int = 900
@export var cd: float = 0.2



@onready var wallslide_node: Walljump
@onready var decay_timer:Timer
@onready var cd_timer:Timer

var hit_ground_post_wallrun:bool = true 




func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	decay_timer = state_machine.get_timer("Wallrun_Decay")
	decay_timer.wait_time = time_until_decay
	wallslide_node = state_machine.find_state("WallSlide")
	cd_timer = state_machine.get_timer("Wallrun_CD")
	cd_timer.wait_time = cd


func enter(msg: = {}):
	super.enter()
	decay_timer.start()
	entity = entity as Player
	if wall_direction > 0:
		entity.sprite.rotation_degrees = -90
		entity.sprite.flip_h = false

	else:
		entity.sprite.rotation_degrees = 90
		entity.sprite.flip_h = true

	
func physics_process(delta):
	wall_checker.position = Vector2(entity.position.x + (offset_x * -get_facing_as_int()), entity.position.y - offset_y)
	if grounded():
		state_machine.transition_if_available([
			"Dodge",
			"Slide",
			"Crouch",
			"Run",
			"Idle"
		])
		return
	if sign(get_movement_input()) != wall_direction or !wall_checker.is_colliding():
		eject_tracker -= delta * decay_multiplier
	else:
		eject_tracker = eject_timer
			
		
	if !Input.is_action_pressed("jump"):
		if state_machine.transition_if_available(["WallSlide"]):
			return
		
	current_slide_speed = clamp(current_slide_speed, base_slide_speed, max_slide_speed)
	if sign(get_movement_input()) != wall_direction or !wall_checker.is_colliding():
		eject_tracker -= delta * decay_multiplier
	else:
		eject_tracker = eject_timer
	entity.move_and_slide() 
	
	if decay_timer.is_stopped() or !hit_ground_post_wallrun:
		entity.velocity.y *= decel_rate
		if entity.velocity.y > -acceleration:
			state_machine.transition_to("WallSlide")
			return
	else:
		entity.velocity.y += acceleration
		if entity.velocity.y > max_speed:
			entity.velocity.y = max_speed

func inactive_process(_delta:float ) -> void:
	if grounded():
		hit_ground_post_wallrun = true 

func get_movement_input() -> float:
	var move = Input.get_axis("left", "right")
	return move

		
func exit():
	super.get_movement_input()
	_check_facing()
	entity.sprite.rotation_degrees = 0
	previous_wall_direction = wall_direction
	eject_tracker = eject_timer
	wall_checker.enabled = false
	wallbounce_timer.stop() 
	previous_speed = Vector2.ZERO
	hit_ground_post_wallrun = false
	entity.camera.override_facing_logic = false
	cd_timer.start()
	
func conditions_met() -> bool:
	if cd_timer.is_stopped():
		if wall_checker.is_colliding() and !grounded() and Input.is_action_pressed("jump") and entity.velocity.y <= acceleration:
			return get_movement_input() != 0
	return false
	
func _check_facing():
	var facing = entity.camera.facing
	var current_facing = -1 if entity.sprite.flip_h else 1
	if current_facing != facing:
		facing = current_facing
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(entity.camera, "FOLLOW_OFFSET:x", abs(entity.camera.LOOK_AHEAD_FACTOR) * facing, entity.camera.SHIFT_DURATION)
