class_name Entity extends CharacterBody2D

var move = 100
var motion: Vector2
var jump_force: int = 200


@onready var anim_player: AnimationPlayer = get_node("SpriteAnimator")
@onready var sfx: AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var states: EntityStateMachine = get_node("StateMachine")
var current_level: GenericLevel

func _physics_process(delta: float) -> void:
	states.physics_update(delta)

func _process(delta):
	states.update(delta)

func _unhandled_input(event: InputEvent):
	states.input(event)

func death_logic():
	pass

func get_level():
	return current_level
	
func damage(amount):
	pass
	
func heal(amount):
	pass
