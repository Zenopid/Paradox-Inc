class_name Paraghoul extends RigidBody2D

@export var link_object: MoveableObject

@onready var state_tracker:Label = $"%StateTracker"
@onready var link_line: Line2D = $"%LinkLine"
@onready var debug_ui: Node2D = $"%Debug"
@onready var states:EntityStateMachine = $"%StateMachine"
@onready var health_bar:HealthBar = $"%HealthBar"
@onready var anim_player: AnimationPlayer = $"%SpriteAnimator"
@onready var effects_animation:AnimationPlayer = $"%EffectAnimator"
@onready var current_level: GenericLevel
@onready var hitsparks:GPUParticles2D = $"%Hitsparks"
@onready var detection_sphere: Area2D = $"%DetectionSphere"
@onready var injure_timer: Timer = $"%Injure_Timer"
var in_hitstun: bool = false
var stun_cnt: int = 0
var being_destroyed = false
func _ready():
	current_level = get_tree().get_first_node_in_group("CurrentLevel")
	states.init(debug_ui)
	
func _physics_process(delta):
#	super._physics_process(delta)
	debug_ui.rotation_degrees = 0
	states.physics_update(delta)
	if being_destroyed:
		queue_free()
	if link_object.being_destroyed:
		kill()
	link_line.set_point_position(1,to_local(link_object.global_position ))
	#	links.set_point_position(1, hook_body.position)

func kill():
	health_bar.hide()
	if current_level.is_connected("swapped_timeline", Callable(self, "_on_swapped_timeline")):
		current_level.disconnect("swapped_timeline", Callable(self, "_on_swapped_timeline"))
	anim_player.play("Dead")
	destroy()
	
	if !link_object.is_in_group("Grappled Objects"):
		link_object.become_normal()

func _process(delta):
#	super._process(delta)
	states.update(delta)
func _on_swapped_timeline(timeline: String):
	pass
	#its a paradox, so no logic here
func link_to_object(object:MoveableObject):
	link_object = object
	object.become_paradox()
	link_object.connect("damaged", Callable(self,  "_on_link_object_damaged"))

func _on_link_object_damaged(health):
	health_bar._on_health_updated(health, 0)
	effects_animation.play("Damaged")
	if hitsparks.emitting == false:
		hitsparks.emitting = true
	else:
		hitsparks.restart()
	injure_timer.start()
		
func damage(amount, knockback: int = 0, knockback_angle: int = 0, hitstun: int = 0):
	in_hitstun = true
	stun_cnt = hitstun
	effects_animation.play("Damaged")
	if hitsparks.emitting == false:
		hitsparks.emitting = true
	else:
		hitsparks.restart()

func destroy():
	being_destroyed = true
	
func queued_destruction():
	return being_destroyed

func _on_injure_timer_timeout():
	effects_animation.play("RESET")
