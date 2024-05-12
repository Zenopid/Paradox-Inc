class_name ParaGhoul extends Enemy

@export var link_object:MoveableObject
@onready var link_line: Line2D = $"%LinkLine"
@onready var wander_area:CollisionShape2D = $"%WanderLimits"
@onready var injure_timer:Timer = $"%Injure_Timer"
@onready var spawn_location: Vector2 = self.global_position
@onready var nav_timer: Timer = $"%Nav_Timer"

var frame_cnt: int = 0
func _ready():
	super._ready()
	is_paradox = true
	if link_object:
		link_object.become_paradox()
	
func _physics_process(delta):
	if is_instance_valid(link_object):
		if link_object.is_queued_for_deletion():
			kill()
	else:
		kill()
	#print(states.get_current_state().name)
	stun_cnt = clamp(stun_cnt, 0, stun_cnt - 1)
	if stun_cnt <= 0:
		in_hitstun = false
	speed_tracker.text = "Speed: (" + str(round(velocity.x)) + "," + str(round(velocity.y)) + ")"
	if being_destroyed:
		queue_free()
	states.physics_update(delta)

func kill():
	for i in get_tree().get_nodes_in_group(name + " Projectiles"):
		i.queue_free()
	if is_instance_valid(link_object):
		if !link_object.is_in_group("Grappled Objects"):
			link_object.become_normal()
		super.kill()
	
func link_to_object(object:MoveableObject):
	link_object = object
	object.become_paradox()
	link_object.connect("damaged", Callable(self,  "_on_link_object_damaged"))
	
func _on_link_object_damaged(new_health):
	health_bar._on_health_updated(new_health, 5)
	effects_animation.play("Damaged")
	if hitsparks.emitting == false:
		hitsparks.emitting = true
	else:
		hitsparks.restart()
	injure_timer.start()

func damage(amount, knockback: int = 0, knockback_angle: int = 0, hitstun: int = 0):
	in_hitstun = true
	stun_cnt = hitstun
	effects_animation.play("Immune")
	if hitsparks.emitting == false:
		hitsparks.emitting = true
	else:
		hitsparks.restart()
	await anim_player.animation_finished

func _on_injure_timer_timeout():
	effects_animation.play("RESET")
	
func apply_push(push_amount:Vector2):
	#velocity += push_amount
	print("applying push of " + str(push_amount))


