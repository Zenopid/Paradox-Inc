class_name FireBall extends Projectile
@onready var anim_player = $"%AnimationPlayer"

func _ready():
	anim_player.play("Travel")
