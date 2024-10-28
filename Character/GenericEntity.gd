class_name Entity extends CharacterBody2D

signal health_updated(new_health)

@export_enum ("Future", "Past", "Inherit Level's Timeline") var current_timeline:String = "Future"

var move = 100
var jump_force: int = 200
var current_level: GenericLevel

@onready var anim_player: AnimationPlayer = get_node("SpriteAnimator")
@onready var states: EntityStateMachine = get_node_or_null("StateMachine")
@onready var health_bar:HealthBar = $"%HealthBar"
@onready var debug_ui:Node2D = get_node_or_null("Debug")

var invlv_type:String = "None"

func _ready():
	if typeof(states) == TYPE_NIL:
		states = get_node_or_null("PrimaryMachine")
	connect("health_updated", Callable(health_bar, "_on_health_updated"))
	current_level = get_tree().get_first_node_in_group("CurrentLevel")
	current_level.connect("swapped_timeline", Callable(self, "_on_swapped_timeline"))
	if debug_ui:
		debug_ui.visible = GlobalScript.debug_enabled
		states.init(debug_ui)
#func init(timer_node:Node, raycast_node: Node2D, shapecast_node:Node2D, debug_node: Node2D = null):	
	else:
		states.init(null)
	for nodes in get_tree().get_nodes_in_group("Collision"):
		nodes.visible = GlobalScript.debug_enabled
	health_bar.init(get_max_health())

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
	
func damage(amount, knockback: Vector2 = Vector2.ZERO, hitstun:int = 0):
	pass

func knockback_entity(knockback:Vector2, modifier:float):
	velocity = knockback * modifier

func heal(amount):
	pass

func get_state_machine():
	return states
	
func get_invlv_type() -> String:
	return invlv_type

func set_invlv_type(type:String):
	invlv_type = type
	if invlv_type == "":
		invlv_type = "None"

func add_invlv_type(type:String):
	if !invlv_type.contains(type):
		invlv_type += type
		invlv_type = invlv_type.replace("None", "")

func remove_invlv_type(type:String):
	invlv_type = invlv_type.replace(type, "")
	if invlv_type.is_empty():
		invlv_type = "None"
	

func get_max_health() -> int:
	return 100
