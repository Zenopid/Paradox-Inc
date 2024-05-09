class_name FireBall extends Projectile
@onready var anim_player = $"%AnimationPlayer"

@onready var target:Player
var acceleration:= Vector2.ZERO
@export var STEER_FORCE: float = 25

func _init():
	set_physics_process(false)
func _ready():
	anim_player.play("Travel")       
	target = get_tree().get_first_node_in_group("Players")
	set_physics_process(true)
func seek():
	var desired = (target.position - position).normalized() * speed
	var steer = (desired - velocity).normalized() * STEER_FORCE
	return steer

func _physics_process(delta):
	velocity += seek()
	velocity = velocity.limit_length(speed)
	rotation = velocity.angle()
	var collision = move_and_collide(velocity * delta)
	if collision:
		if typeof(collision.get_collider()) != TYPE_NIL:
			_on_body_entered(collision.get_collider())
	if framez < duration:
		framez += 1
	elif framez == duration:
		#print("Duration reached, deleting proj")
		queue_free()
		return
	var distance_travelled:Vector2 = abs(global_position - starting_position)
	if distance_travelled.length() >= max_distance and max_distance != -1:
		#print("went too far so proj is dying")
		queue_free()
	hitbox.global_position = self.global_position
	if num_of_hits <= 0:
		#print("Hits exhausted, deleting proj")
		queue_free()
