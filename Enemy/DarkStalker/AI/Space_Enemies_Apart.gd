extends ActionLeaf


@export var acceptable_range: int = 5
@export var seperation_speed: int = 15
@onready var los: RayCast2D
@onready var ground_checker:RayCast2D

enum anim_status {
	WALK_BACKWARDS = 2,
	WALK_FORWARDS = 1,
	NOT_PLAYING = 0
}
var current_anim = anim_status.NOT_PLAYING
func before_run(actor: Node, blackboard: Blackboard) -> void:
	los = actor.get_raycast("LOS")
	ground_checker = actor.get_raycast("GroundChecker")
	ground_checker.lock_position()
func tick(actor: Node, _blackboard: Blackboard) -> int:
	for i in get_tree().get_nodes_in_group(actor.name + " Enemy Detectors"):
		var ray: RayCast2D = i
		ray.visible = true 
		while ray.is_colliding():
			#print("going away now")
#			ray.global_position = los.global_position
			if ray.global_position != los.global_position:
			#	print_debug("somethings going wrong")
			var point = ray.get_collision_point()
			var direction: int 
			if actor.global_position.x < point.x :
				direction = 1
			else:
				direction = -1
			move_enemy_away(actor, direction)
			ray.scale.x *= -1
			#flip ray to check for enemies on other side
			if !ray.is_colliding():
				continue
				#check to see if we can move on early 
			point = ray.get_collision_point()
			if actor.global_position.x < point.x :
				direction = -1
			else:
				direction = 1
			move_enemy_away(actor, direction)
		ray.queue_free()
	return SUCCESS
func move_enemy_away(entity:Entity, direction: int) -> bool:
	ground_checker.global_position = Vector2(entity.global_position.x + (12 * direction), entity.global_position.y)
	if !ground_checker.is_colliding():
		return false
	entity.motion.x = seperation_speed * direction
	if entity.sprite.flip_h:
		#facing left:
		if direction < 0:
			#if facing left and moving left, play anim normally
			if current_anim != anim_status.WALK_FORWARDS:
				current_anim = anim_status.WALK_FORWARDS
				entity.anim_player.play("Run")
		elif direction > 0:
			#if facing left and moving right, play anim backwards
			if current_anim != anim_status.WALK_BACKWARDS:
				current_anim = anim_status.WALK_BACKWARDS
				entity.anim_player.play_backwards("Run")
	else:
		if direction < 0:
			#if facing right and moving left, play anim backward
			if current_anim != anim_status.WALK_BACKWARDS:
				current_anim = anim_status.WALK_BACKWARDS
				entity.anim_player.play_backwards("Run")
		elif direction > 0:
			#if facing right and moving right, play anim normally
			if current_anim != anim_status.WALK_FORWARDS:
				current_anim = anim_status.WALK_FORWARDS
				entity.anim_player.play("Run")
	entity.default_move_and_slide()
	return true 
	
func after_run(actor: Node, blackboard: Blackboard) -> void:
	ground_checker.unlock_position()
