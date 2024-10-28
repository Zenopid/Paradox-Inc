class_name Shockwave extends Projectile


@onready var particles:GPUParticles2D = $"%Particles"
@onready var ground_checker:RayCast2D = $"%GroundChecker"


func _physics_process(delta):
	rotation_degrees = 0
	var projectile_speed:Vector2 = (direction * speed)  
	if direction.x > 0:
		particles.scale.x = -1
	else:
		particles.scale.x = 1
	projectile_speed.y = -1
	#to make not stick to floors
	var collision = move_and_collide(projectile_speed * delta)
	if collision:
		if typeof(collision.get_collider()) != TYPE_NIL:
			_on_body_entered(collision.get_collider())
	var distance_travelled:Vector2 = abs(global_position - starting_position)
	if distance_travelled.length() >= max_distance and max_distance != -1:
		queue_free()
	hitbox.global_position = self.global_position
	if num_of_hits <= 0:
		queue_free()
	if !grounded():
		print("not on the ground")
		#queue_free()

func grounded():
	return ground_checker.is_colliding() or is_on_floor()

func _on_body_entered(body:Node2D):

	var true_collision:bool = false
	if body == projectile_owner:
		return
	elif body is TileMapLayer and is_on_wall():
		queue_free()
	elif body is RigidBody2D:
		if global_position > body.global_position:
			object_push = -abs(object_push + (int(velocity_effects_object_push) * velocity))
		else:
			object_push = abs(object_push + (int(velocity_effects_object_push) * velocity))
		body.call_deferred("apply_central_impulse",object_push)
		emit_signal("hitbox_collided", body)
		if body is MoveableObject:
			body = body as MoveableObject
			if body.link_object == projectile_owner:
				queue_free()
				return
		body.damage(damage)
		#There's no true collision, because shockwaves don't lose hits when colliding with objects.
	elif body is Entity or body is EnemyRigid:
		if body != projectile_owner:
			true_collision = true
			damage_entity(body)
	elif body is Projectile:
		if body.get_rid() == get_rid() or body.projectile_owner == projectile_owner:
			return
		if attack_type == body.attack_type:
			if abs(body.damage  - damage) <=  CLASH_RANGE:
				true_collision = true 
				body.num_of_hits -= 1
				print_debug("CLASH")
	if true_collision:
		num_of_hits -= 1
