extends Line2D

@export_enum( "Future", "Past") var timeline = "Future"

@export var laser_damage: int = 5
@export var laser_knockback: Vector2 = Vector2(25, 0)
@export var hitstun: int = 5

@onready var hitbox:Hitbox = $"%Hitbox"

func _ready() -> void:
	hitbox.set_parameters({
		"damage": laser_damage,
		"knockback": laser_knockback,
		"hitstun": hitstun,
		"hitbox_owner": self, 
	})
	hitbox.global_position = self.global_position
	if timeline == "Future":
		hitbox.set_collision_layer_value(GlobalScript.collision_values.PROJECTILE_FUTURE, true)
		hitbox.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PROJ_HURTBOX_FUTURE, true)
		hitbox.set_collision_mask_value(GlobalScript.collision_values.ENEMY_PROJ_HURTBOX_FUTURE, true)
	else:
		hitbox.set_collision_layer_value(GlobalScript.collision_values.PROJECTILE_PAST, true)
		hitbox.set_collision_mask_value(GlobalScript.collision_values.PLAYER_PROJ_HURTBOX_PAST, true)
		hitbox.set_collision_mask_value(GlobalScript.collision_values.ENEMY_PROJ_HURTBOX_PAST, true)
func _on_laser_area_entered(body:PhysicsBody2D):
	if body is Player:
		body.damage(laser_damage, laser_knockback, hitstun, true)
	elif body is Entity:
		body.damage(laser_damage, laser_knockback, hitstun)
