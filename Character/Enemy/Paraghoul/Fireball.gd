class_name FireBall extends Projectile
@onready var anim_player = $"%AnimationPlayer"
@onready var explosion_sfx:AudioStreamPlayer2D = $"%Explosion"
@onready var travelling_sfx:AudioStreamPlayer2D = $"%Travelling"
@onready var target:Player
var acceleration:= Vector2.ZERO
@export var STEER_FORCE: float = 25


func _ready():
	anim_player.play("Travel")       
	target = get_tree().get_first_node_in_group("Players")
	travelling_sfx.play()
	look_at(target.global_position)
	velocity = projectile_owner.global_position.direction_to(target.global_position) * speed
	
func seek():
	if is_instance_valid(target):
		var desired = (target.position - position).normalized() * speed
		var steer = (desired - velocity).normalized() * STEER_FORCE
		return steer
	return null

func play_explosion_sfx():
	if !explosion_sfx.playing and num_of_hits > 0:
		explosion_sfx.play()

func _physics_process(delta):
	var status = !(player.get_invlv_type().contains("Proj"))
	if timeline == "All":
		set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, status)
		set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, status)
	elif timeline == "Past":
		set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, status)
	else:
		set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, status)
	var seek_value = seek()
	if seek_value:
		velocity += seek_value
	velocity = velocity.limit_length(speed)
	rotation = velocity.angle()
	var collision = move_and_collide(velocity * delta)
	if collision:
		if typeof(collision.get_collider()) != TYPE_NIL:
			play_explosion_sfx()
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
		hide()
		hitbox.disabled = true
		travelling_sfx.stop()
		if travelling_sfx.is_connected("finished", Callable(self, "_on_travelling_finished")):
			travelling_sfx.disconnect("finished", Callable(self, "_on_travelling_finished"))
		if !explosion_sfx.playing:
			queue_free()

func _on_travelling_finished():
	travelling_sfx.play()
