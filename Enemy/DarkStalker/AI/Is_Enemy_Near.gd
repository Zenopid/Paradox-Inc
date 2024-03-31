extends ConditionLeaf

@export var unacceptable_range: int = 5
#connor franchoso late period 2 
func before_run(actor: Node, blackboard: Blackboard) -> void:
	for nodes in get_tree().get_nodes_in_group(actor.name + "Enemy Detectors"):
		nodes.queue_free()
		
func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.enemy_near():
		var new_los:RayCast2D = RayCast2D.new()
		var target = unacceptable_range
		if actor.sprite.flip_h:
			target = -unacceptable_range
		new_los.target_position = Vector2(target, 0)
		new_los.set_collision_mask_value(8, true)
		#set enemy layer to be true
		new_los.set_collision_mask_value(1, false)
		#set player layer to be false
		new_los.hit_from_inside = true 
		new_los.visible = true 
		actor.add_child(new_los)
		new_los.force_raycast_update()
		if new_los.is_colliding():
			if abs(new_los.get_collision_point().x - actor.position.x) <= unacceptable_range: 
				#print("yeah its too close")
				new_los.free()
				return SUCCESS
		else:
			new_los.free()
	return FAILURE
