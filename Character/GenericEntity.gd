class_name Entity extends CharacterBody2D

var move = 100
var motion: Vector2
var jump_force: int = 200


@onready var anim_player: AnimationPlayer = get_node("SpriteAnimator")
@onready var sfx: AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready var states: EntityStateMachine = get_node_or_null("StateMachine")
var current_level: GenericLevel

func _ready():
	if states == null:
		states = get_node_or_null("PrimaryMachine")

func _physics_process(delta: float) -> void:
	states.physics_update(delta)

func _process(delta):
	states.update(delta)

func _unhandled_input(event: InputEvent):
	states.input(event)

func death_logic():
	states.transition_to("Dead")

func get_level():
	return current_level
	
func damage(amount, knockback: int = 0, knockback_angle: int = 0, hitstun:int = 0):
	pass
	
func heal(amount):
	pass
