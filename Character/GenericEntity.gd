class_name Entity extends CharacterBody2D

var move = 100
var motion: Vector2
var jump_force: int = 200


@onready var anim_player: AnimationPlayer = get_node("SpriteAnimator")
@onready var sfx: AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready var states: EntityStateMachine = get_node_or_null("StateMachine")
@export_enum ("Future", "Past", "Inherit Level's Timeline") var current_timeline:String = "Future"
@onready var health_bar:HealthBar = $"%HealthBar"
@onready var debug_ui:Node2D = get_node_or_null("Debug")
var current_level: GenericLevel

func _ready():
	if typeof(states) == TYPE_NIL:
		states = get_node_or_null("PrimaryMachine")
	connect("health_updated", Callable(health_bar, "_on_health_updated"))
	current_level = get_tree().get_first_node_in_group("CurrentLevel")
	current_level.connect("swapped_timeline", Callable(self, "_on_swapped_timeline"))
	if debug_ui:
		debug_ui.visible = GlobalScript.debug_enabled
		states.init(debug_ui)
	else:
		states.init(null)
	for nodes in get_tree().get_nodes_in_group("Collision"):
		nodes.visible = GlobalScript.debug_enabled

func _physics_process(delta: float) -> void:
	states.physics_update(delta)

func _process(delta):
	states.update(delta)

func death_logic():
	states.transition_to("Dead")

func get_level() -> GenericLevel:
	return current_level

func set_level(new_level:GenericLevel):
	current_level = new_level
	
func damage(amount, knockback: int = 0, knockback_angle: int = 0, hitstun:int = 0):
	pass
	
func heal(amount):
	pass

func get_state_machine():
	return states
