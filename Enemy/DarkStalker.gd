class_name Enemy extends Entity

signal health_updated(health)
signal killed()

@export var max_health: int = 100
@onready var health:int = max_health 
@onready var health_bar = $UI/HealthBar
@onready var effects_animation = get_node_or_null("EffectAnimator")
@onready var sprite: Sprite2D = get_node("Sprite")
@onready var pathfinder: NavigationAgent2D = $Pathfinder
@onready var conditions: DarkStalkerConditions = $BehaviourTree/Conditions
var spawn_point: Vector2

func get_spawn():
	return spawn_point

func _ready():
	for nodes in states.get_node("Raycasts").get_children():
		if nodes is RayCast2D:
			nodes.add_exception(self)
	if states == null:
		print_debug("HEY! SOMETHING WENT HORRIBLY WRONG AND NOW ITS NULL")
	super._ready()
	states.init(self, get_node("Debug"))
	for node in get_parent().get_children():
		if node is GenericLevel:
			current_level = node
	connect("health_updated", Callable(health_bar, "_on_health_updated"))
	if get_node_or_null("GroundChecker"):
		get_node("GroundChecker").queue_free()

func _physics_process(delta):
	super._physics_process(delta)

func set_spawn(location: Vector2):
	spawn_point = location

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health, 5)
		if health <= 0:
			kill()
			emit_signal("killed")

func damage(amount, knockback: int = 0, knockback_angle: int = 0, hitstun: int = 0):
		_set_health(health - amount)
		effects_animation.play("Damaged")
		effects_animation.queue("Invincible")
		states.transition_to("Idle", {stun_duration = hitstun})

func heal(amount):
	_set_health(health + amount)

func kill():
	states.transition_to("Dead")

	
