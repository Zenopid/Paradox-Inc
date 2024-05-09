class_name BaseStrike extends Node

signal leave_state()
signal attack_whiffed(attack_name)
var can_cancel:bool = false

var is_on_floor: bool 
var frame_tracker: int = 1
var perform_attack_logic:bool = true

@export var animation_name: String
@export var friction: float = 0.2


@export_enum("Ground", "Air") var attack_type: String = "Ground"
var entity: Entity
var frame: int


func init(current_entity:Entity):
	entity = current_entity

func enter(_msg: = {}):
	if !entity.anim_player.is_connected("animation_finished", Callable(self, "_on_attack_over")):
		entity.anim_player.connect("animation_finished", Callable(self, "_on_attack_over"))
	frame = 0
	entity.anim_player.play(animation_name)
	can_cancel = false

func current_active_hitbox():
	pass

func input(event):
	pass

func physics_process(delta: float):
	entity.velocity.x *= friction
	frame += 1


func on_attack_hit(object):
	pass

func exit():
	if entity.anim_player.is_connected("animation_finished", Callable(self, "_on_attack_over")):
		entity.anim_player.disconnect("animation_finished", Callable(self, "_on_attack_over"))
	frame = 0

func grounded():
	if entity.states.get_raycast("GroundChecker").is_colliding() or entity.is_on_floor():
		return true
	return false
