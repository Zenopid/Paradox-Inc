class_name ParaGhoul extends Enemy

signal damaged(amount:int)

@export var link_object:MoveableObject
@export_category("Link Object Colors")
@export var garbage_container_color:Color = Color.DARK_GREEN
@onready var link_line: Line2D = $"%LinkLine"
@onready var wander_area:CollisionShape2D = $"%WanderLimits"
@onready var injure_timer:Timer = $"%Injure_Timer"
@onready var spawn_location: Vector2 = self.global_position
@onready var nav_timer: Timer = $"%Nav_Timer"
@onready var fireball_sprite:AnimatedSprite2D = $"%Fireball"
var frame_cnt: int = 0

func _ready():
	print(link_object)
	super._ready()
	is_paradox = true
	link_object.become_paradox()
	link_to_object(link_object)
	link_object.link_to_object(self)
	match link_object.get_object_type():
		"Garbage Container":
			sprite.modulate = garbage_container_color
		_:
			pass
	max_health = link_object.health
	health = max_health
	health_bar.init(link_object.health)
	print(link_object)

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
	if !link_object.is_connected("damaged", Callable(self,  "_on_link_object_damaged")):
		link_object.connect("damaged", Callable(self,  "_on_link_object_damaged"))
	
	if typeof(health_bar) != TYPE_NIL:
		health_bar.init(link_object.health)
	
func _on_link_object_damaged(new_health:int ):
	if states.get_current_state().name == "Idle":
		states.transition_to("Chase")
	health = new_health
	health_bar._on_health_updated(new_health, 5)
	effects_animation.play("Damaged")
	if hitsparks.emitting == false:
		hitsparks.emitting = true
	else:
		hitsparks.restart()
	injure_timer.start()
	emit_signal("damaged", health - new_health)

func damage(amount, knockback: int = 0, knockback_angle: int = 0, hitstun: int = 0):
	in_hitstun = true
	stun_cnt = hitstun
	effects_animation.play("Immune")
	if hitsparks.emitting == false:
		hitsparks.emitting = true
	else:
		hitsparks.restart()
	emit_signal("damaged", amount)
	
	
func _on_injure_timer_timeout():
	effects_animation.play("RESET")
	
func apply_push(push_amount:Vector2):
	velocity += push_amount

func grounded():
	ground_raycast.force_raycast_update()
	return ground_raycast.is_colliding() or is_on_floor()

func set_color():
	match link_object.get_object_type():
		"Garbage Container":
			sprite.modulate = garbage_container_color
		_:
			pass

func on_grapple_pulled():
	var current_state:BaseState = states.get_current_state()
	if current_state.name == "Charge":
		if !current_state.charging:
			states.transition_to("Dazed")
