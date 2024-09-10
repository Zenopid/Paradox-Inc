class_name TrooperBullet extends Projectile


var target:Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = projectile_owner.global_position.direction_to(target) * speed
