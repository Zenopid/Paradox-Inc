extends VisionCone2D

@export var entity: Entity

func _physics_process(delta):
	super._physics_process(delta)
	position = entity.position
