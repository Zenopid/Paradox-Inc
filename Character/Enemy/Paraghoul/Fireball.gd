class_name FireBall extends Projectile
@onready var anim_player = $"%AnimationPlayer"
@onready var explosion_sfx:AudioStreamPlayer2D = $"%Explosion"
@onready var travelling_sfx:AudioStreamPlayer2D = $"%Travelling"
@onready var target: Player
var acceleration:= Vector2.ZERO
@export var STEER_FORCE: float = 25


func set_parameters(hitbox_info: = {}):
	super.set_parameters(hitbox_info)
	target = hitbox_info["target"]
	anim_player.play("Travel")       
	travelling_sfx.play()
	look_at(target.global_position)
	velocity = projectile_owner.global_position.direction_to(target.global_position) * speed

func seek():
	if is_instance_valid(target.global_position):
		var desired = (target.global_position - position).normalized() * speed
		var steer = (desired - velocity).normalized() * STEER_FORCE
		return steer
	return null

func play_explosion_sfx():
	if !explosion_sfx.playing and num_of_hits > 0:
		explosion_sfx.play()

func _physics_process(delta):
	var seek_value = seek()
	if seek_value:
		velocity += seek_value
	velocity = velocity.limit_length(speed)
	rotation = velocity.angle()
	var collision = move_and_collide(velocity * delta)
	if collision:
		queue_free()
	if framez < duration:
		framez += 1
	elif framez == duration:
		#print("Duration reached, deleting proj")
		queue_free()
		return
	var distance_travelled:Vector2 = abs(global_position - starting_position)
	if distance_travelled.length() >= max_distance and max_distance != -1:
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
	

func set_future_collision():
	set_collision_layer_value(GlobalScript.collision_values.PROJECTILE_FUTURE, true)
	
	hitbox_area.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PROJ_HURTBOX_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.WALL_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_FUTURE, true)

func set_past_collision():
	set_collision_layer_value(GlobalScript.collision_values.PROJECTILE_PAST, true)

	hitbox_area.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PROJ_HURTBOX_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.WALL_PAST, true)
	set_collision_mask_value(GlobalScript.collision_values.GROUND_PAST, true)
