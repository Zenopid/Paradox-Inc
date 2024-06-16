@tool
extends Line2D

@export var paraghoul:ParaGhoul 

func _physics_process(delta):
	if is_instance_valid(paraghoul.link_object):
		if typeof(paraghoul.link_object) != TYPE_NIL:
			set_point_position(1,to_local(paraghoul.link_object.global_position))
			


func _on_paraghoul_property_list_changed():
	if is_instance_valid(paraghoul.link_object):
		if typeof(paraghoul.link_object) != TYPE_NIL:
			set_point_position(1,to_local(paraghoul.link_object.global_position))
	else:
		push_error("Link object not found!")
