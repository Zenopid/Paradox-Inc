class_name ParaGhoul extends Enemy

@export var link_object:MoveableObject
@onready var link_line: Line2D = $"%LinkLine"
@onready var wander_area:CollisionShape2D = $"%WanderLimits"
@onready var injure_timer:Timer = $"%Injure_Timer"
@onready var spawn_location: Vector2 = self.global_position
@onready var nav_timer: Timer = $"%Nav_Timer"

func _ready():
	super._ready()
	is_paradox = true
	print(spawn_location - global_position)

func _physics_process(delta):
	super._physics_process(delta)
	if link_object.being_destroyed:
		kill()
	link_line.set_point_position(1,to_local(link_object.global_position ))
	
func kill():
	super.kill()
	if !link_object.is_in_group("Grappled Objects"):
		link_object.become_normal()

func link_to_object(object:MoveableObject):
	link_object = object
	object.become_paradox()
	link_object.connect("damaged", Callable(self,  "_on_link_object_damaged"))

func _on_link_object_damaged(new_health):
	health_bar._on_health_updated(new_health, 0)
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
	injure_timer.start()

func _on_injure_timer_timeout():
	effects_animation.play("RESET")

func apply_push(push_amount:Vector2):
	velocity += push_amount
