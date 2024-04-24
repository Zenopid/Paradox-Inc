class_name EnemyRigid extends RigidBody2D

@export var is_paradox: bool = false
@export_enum ("Future", "Past") var current_timeline:String = "Future"
@export var max_health: int = 100

@onready var state_tracker:Label = $"%StateTracker"
@onready var debug_ui: Node2D = $"%Debug"
@onready var states:EntityStateMachine = $"%StateMachine"
@onready var health_bar:HealthBar = $"%HealthBar"
@onready var anim_player: AnimationPlayer = $"%SpriteAnimator"
@onready var effects_animation:AnimationPlayer = $"%EffectAnimator"
@onready var current_level: GenericLevel
@onready var hitsparks:GPUParticles2D = $"%Hitsparks"
@onready var detection_sphere: Area2D = $"%DetectionSphere"
@onready var injure_timer: Timer = $"%Injure_Timer"
@onready var health:int  = max_health
#@onready var projectile_2d:Projectile2D = $"%Projectile2D"
@onready var sprite:AnimatedSprite2D = $"%Sprite"
var in_hitstun: bool = false
var stun_cnt: int = 0
var being_destroyed = false


func _ready():
	current_level = get_tree().get_first_node_in_group("CurrentLevel")
	states.init(debug_ui)
	
func _physics_process(delta):
	debug_ui.rotation_degrees = 0
	states.physics_update(delta)
	if being_destroyed:
		queue_free()

func kill():
	health_bar.hide()
	if current_level.is_connected("swapped_timeline", Callable(self, "_on_swapped_timeline")):
		current_level.disconnect("swapped_timeline", Callable(self, "_on_swapped_timeline"))
	anim_player.play("Dead")
	destroy()
	

func _process(delta):
	states.update(delta)
	
func _on_swapped_timeline(timeline: String):
	if !being_destroyed:
		if is_paradox:
			return
		if current_timeline != timeline:
			modulate.a = 0.25
			continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
		else:
			modulate.a = 1
			continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE

func damage(amount, knockback: int = 0, knockback_angle: int = 0, hitstun: int = 0):
	in_hitstun = true
	stun_cnt = hitstun
	_set_health(health - amount)
	effects_animation.play("Damaged")
	if hitsparks.emitting == false:
		hitsparks.emitting = true
	else:
		hitsparks.restart()

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health, 5)
		if health <= 0:
			kill()
			emit_signal("killed")

func destroy():
	being_destroyed = true
	
func queued_destruction():
	return being_destroyed

func _on_injure_timer_timeout():
	effects_animation.play("RESET")
