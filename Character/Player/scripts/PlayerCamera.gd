extends Camera2D

const DEAD_ZONE = 160

const LOOK_AHEAD_FACTOR = 0.01
const SHIFT_TRANS = Tween.TRANS_SINE
const SHIFT_EASE = Tween.EASE_OUT
const SHIFT_DURATION = 1.0
var facing = 0

@onready var prev_camera_pos = get_camera_position()


func _process(_delta: float) -> void:
	_check_facing()
	prev_camera_pos = get_camera_position()

func _check_facing():
	var new_facing = sign(get_camera_position().x - prev_camera_pos.x)
	if new_facing != 0 && facing != new_facing:
		facing = new_facing
		var target_offset = get_viewport_rect().size.x * LOOK_AHEAD_FACTOR * facing
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position:x", target_offset, SHIFT_DURATION)

func _on_Player_grounded_updated(is_grounded) -> void:
	drag_vertical_enabled = !is_grounded

func get_camera_position():
	return get_screen_center_position()
