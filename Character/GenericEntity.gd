class_name Entity extends CharacterBody2D

var move = 100
var motion: Vector2
var jump_force: int = 200


@onready var anim_player: AnimationPlayer = get_node("SpriteAnimator")
@onready var sfx: AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready var states: EntityStateMachine = get_node_or_null("StateMachine")
@export_enum ("Future", "Past", "Inherit Level's Timeline") var current_timeline:String = "Future"
@onready var health_bar:HealthBar = $"%HealthBar"
var current_level: GenericLevel

func _ready():
	if states == null:
		states = get_node_or_null("PrimaryMachine")
	connect("health_updated", Callable(health_bar, "_on_health_updated"))
	current_level = get_tree().get_first_node_in_group("CurrentLevel")
	current_level.connect("swapped_timeline", Callable(self, "_on_swapped_timeline"))

func _physics_process(delta: float) -> void:
	if states:
		states.physics_update(delta)

func _process(delta):
	if states:
		states.update(delta)

func _unhandled_input(event: InputEvent):
	if states:
		states.input(event)

func death_logic():
	if states:
		states.transition_to("Dead")

func get_level() -> GenericLevel:
	return current_level

func set_level(new_level:GenericLevel):
	current_level = new_level
	
func damage(amount, knockback: int = 0, knockback_angle: int = 0, hitstun:int = 0):
	pass
	
func heal(amount):
	pass
