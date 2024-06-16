extends PlayerAirStrike


@export_category("Ground Pound")
@export var fall_speed:int = 400
@export var minimum_damage:int = 30
@export var maximum_damage:int = 65
@export var height_scaler: float = 0.25
@export var decel_rate:float = 0.4

@export_category("Hitbox")
@export var duration: int = 4
@export var knockback_amount: int = 1
@export var object_push: Vector2 = Vector2(300, 150)

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
	starting_position = entity.global_position.y

func change_status(new_status):
	match attack_status:
		"Start":
			attack_status = "Falling"
		"Falling":
			attack_status = "Landing"


func physics_process(delta):
	
	
	
	frame += 1

	var additional_damage = roundi(min(maximum_damage, abs((entity.global_position.y - starting_position) * height_scaler )))
	ground_pound_damage = min(maximum_damage, minimum_damage + additional_damage)
	match attack_status:
		"Start":
			entity.velocity *= decel_rate
		"Falling":
			entity.velocity.y = fall_speed
	if entity.is_on_floor():
		entity.velocity.x = 0
		if !has_hit_ground:
			entity.anim_player.disconnect("animation_finished", Callable(self, "change_status"))
			entity.anim_player.play("GroundPoundLand")
			entity.anim_player.connect("animation_finished", Callable(self, "_on_attack_over"))
			has_hit_ground = true
			change_status("Landing")
			var hitbox_info = {
			"position":  Vector2(-1.375, 10.505),
			"duration": duration,
			"damage": ground_pound_damage,
			"width": 55, 
			"height": 14.01,
			"knockback_amount": knockback_amount,
			"knockback_angle": 360,
			"attack_type": "Normal",
			"object_push": object_push,
			"hit_stop": hitstop,
		}
			attack_state.create_hitbox(hitbox_info)
			entity.camera.set_shake(camera_shake_strength)
			#print(str(ground_pound_damage) + " is the ground pound's damage.")
	buffer_tracker = clamp(buffer_tracker, 0, buffer_tracker - 1)
	entity.move_and_slide()

func input(event):
	super.input(event)
	attack_state.state_machine.transition_if_available([
		"Dodge"
	])
