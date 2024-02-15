extends BaseStrike

@export var fall_speed:int = 400
@export var minimum_damage:int = 30
@export var maximum_damage:int = 65

var attack_status: String 

var fall_distance: int
var starting_position: float

var ground_pound_damage: int

var has_hit_ground: bool = false

func enter(_msg: = {}):
	has_hit_ground = false
	if !entity.anim_player.is_connected("animation_finished", Callable(self, "change_status")):
		entity.anim_player.connect("animation_finished", Callable(self, "change_status"))
	entity.anim_player.play("GroundPoundStart")
	entity.anim_player.queue("GroundPoundLoop")
	attack_status = "Start"
	starting_position = entity.position.y

func change_status(new_status):
	match attack_status:
		"Start":
			attack_status = "Falling"
		"Falling":
			attack_status = "Landing"


func physics_process(delta):
	var additional_damage = min(maximum_damage, abs(entity.position.y - starting_position))
	ground_pound_damage = clamp(ground_pound_damage, minimum_damage, additional_damage)
	match attack_status:
		"Start":
			entity.motion *= 0.15
		"Falling":
			entity.motion.y = fall_speed
	if entity.is_on_floor():
		if !has_hit_ground:
			entity.camera.apply_screen_shake(camera_shake_strength)
			entity.anim_player.disconnect("animation_finished", Callable(self, "change_status"))
			entity.anim_player.play("GroundPoundLand")
			entity.anim_player.connect("animation_finished", Callable(self, "_on_attack_over"))
			has_hit_ground = true
			change_status("Landing")
			attack_state.create_hitbox(39.625, 14.01,ground_pound_damage,1, 180, 4, "Normal", 1, Vector2(-1.375, 10.505), Vector2(700, -500))
	super.physics_process(delta)
