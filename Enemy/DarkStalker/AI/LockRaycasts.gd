extends ActionLeaf

@export_enum("Lock", "Unlock") var ray_status: String


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var LOS:RayCast2D = actor.get_raycast("LOS")
	if ray_status == "Lock":
		LOS.lock_view()
		return SUCCESS
	elif ray_status == "Unlock":
		LOS.unlock_view()
		return SUCCESS
	return FAILURE
