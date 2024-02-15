extends ActionLeaf


@export var anim_name:String = "Run"
@export var attack_damage: int = 15
@export var hitstun: int = 1
@export var knockback_amount: int = 1
@export var push_factor: Vector2 = Vector2(600, -100)


var facing: int = 0
var frame: int = 0
var attack_ended: bool
var attack_connected: bool = false

func before_run(actor: Node, blackboard: Blackboard) -> void:
	attack_ended = false
	attack_connected = false
	frame = 0
	if !actor.anim_player.is_connected("animation_finished", Callable(self, "attack_over")):
		actor.anim_player.connect("animation_finished", Callable(self, "attack_over"))
	actor.anim_player.play(anim_name)
	
func on_successful_attack(object):
	if object is Entity:
		attack_connected = true 

func attack_over(attack_name):
	attack_ended = true 

func tick(actor: Node, _blackboard: Blackboard) -> int:
	frame += 1
	if actor.is_in_hitstun():
		actor.clear_hitboxes()
		return FAILURE
		
	if attack_ended:
		actor.clear_hitboxes()
		return FAILURE
		
	if attack_connected:
		return SUCCESS
	if frame == 19:
		actor.create_hitbox(31.745, 42.426, attack_damage, knockback_amount, 180, 3, "Normal", 1, Vector2(25.672, 4.423), push_factor, 1)
	return RUNNING

func after_run(actor: Node, blackboard: Blackboard) -> void:
	actor.anim_player.stop()
	actor.anim_player.disconnect("animation_finished", Callable(self, "attack_over"))
