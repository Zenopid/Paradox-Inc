extends Camera2DPlus

const DEAD_ZONE = 160
const DEAD_ZONE_MOUSE = 100
const LOOK_AHEAD_FACTOR = 125
const SHIFT_TRANS = Tween.TRANS_SINE
const SHIFT_EASE = Tween.EASE_OUT
const SHIFT_DURATION = 1.0
const MINIMUM_CAMERA_ZOOM:Vector2 = Vector2(1.4, 1.4)
const MAXIMUM_CAMERA_ZOOM:Vector2 = Vector2(1.6, 1.6)

@export var zoom_speed: float = 0.1
@export var player:Entity

@onready var prev_camera_pos = get_camera_position()
@onready var current_offset:Vector2

var facing : int 

var override_facing_logic:bool = false


func _ready():
	current_offset = FOLLOW_OFFSET
	super._ready()

	
	ENABLE_CAMERA_FLASHING = GlobalScript.get_setting("camera_flash") 
	if ENABLE_CAMERA_FLASHING:
		SHAKE_ANGLE_MULTIPLIER = 0
	else:
		SHAKE_POSITION_MULTIPLIER = 1
	
	GlobalScript.connect("setting_changed", Callable(self, "camera_settings"))
	
func _process(delta: float) -> void:
	super._process(delta)
	if !override_facing_logic:
		_check_facing()
#	change_zoom()
	prev_camera_pos = get_camera_position()
	adjust_zoom()
	
func adjust_zoom():
	var weight = min((abs(player.velocity.x) / player.max_grapple_speed), 1)
	var new_zoom = lerp(MAXIMUM_CAMERA_ZOOM, MINIMUM_CAMERA_ZOOM, weight) 
	if new_zoom != zoom:
		var tween = get_tree().create_tween().set_ease(Tween.EASE_IN)
		tween.tween_property(self, "zoom", new_zoom, zoom_speed)
#func change_zoom() -> Vector2:
#	if player.velocity > Vector2(-2, -2) and player.velocity < Vector2(2,2):
#		return Vector2.ZERO
#	var new_zoom = (player.velocity / Vector2(125,125)) * zoom_multiplier
#	if zoom != new_zoom:
#		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
#		tween.tween_property(self, "zoom", new_zoom,1.4 )
#	return new_zoom
	

func _check_facing():
	
	#var current_facing = -1 if player.sprite.flip_h else 1
	#if current_facing != facing:
		#facing = current_facing
		#var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		#tween.tween_property(self, "FOLLOW_OFFSET:x", abs(LOOK_AHEAD_FACTOR) * facing, SHIFT_DURATION)
		#print(FOLLOW_OFFSET)
	if !player.sprite.flip_h and current_offset.x <= 0:
		current_offset.x = abs (FOLLOW_OFFSET.x)
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(self,"FOLLOW_OFFSET:x",current_offset.x, SHIFT_DURATION)
	elif player.sprite.flip_h and current_offset.x >= 0:
		current_offset.x = abs (FOLLOW_OFFSET.x) * -1
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(self,"FOLLOW_OFFSET:x",current_offset.x, SHIFT_DURATION)
	#FOLLOW_OFFSET = abs(FOLLOW_OFFSET) if !player.sprite.flip_h else abs(FOLLOW_OFFSET) * -1
	#var new_facing = sign(get_camera_position().x - prev_camera_pos.x)
	#if new_facing != 0 and facing != new_facing:
		#facing = new_facing
		#var target_offset = get_viewport_rect().size.x * LOOK_AHEAD_FACTOR * facing
		#var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		#tween.tween_property(self, "FOLLOW_OFFSET:x", target_offset, SHIFT_DURATION)

#func _input(event):
#	if event is InputEventMousevelocity:
#		var target:Vector2 = event.position - get_viewport().size * 0.5
#		if target.length() < DEAD_ZONE_MOUSE:
#			return
##		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
#		target = target.normalized() * (target.length() - DEAD_ZONE_MOUSE) * 0.5
#		position = target
	

func _on_Player_grounded_updated(is_grounded) -> void:
	drag_vertical_enabled = !is_grounded

func get_camera_position():
	return get_target_position()

func camera_settings(setting_name, new_setting):
	match setting_name:
		"camera_flash":
			ENABLE_CAMERA_FLASHING = new_setting
		"camera_shake":
			SHAKE_POSITION_MULTIPLIER = new_setting
