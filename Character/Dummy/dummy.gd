class_name TrainingDummy extends Entity

@onready var heal_timer:Timer = $"%HealTimer"
@onready var damage_numbers:Label = $"%DamageNumber"
@onready var effects_anim:AnimationPlayer = $"%EffectAnimator"

@export var light_damage_threshold: int = 10
@export var medium_damage_threshold:int = 15
@export var heavy_damage_threshold:int = 20


@export var max_health:int = 250
@onready var health:int = 250

func damage(amount, knockback: Vector2 = Vector2.ZERO, hitstun:int = 0):
	anim_player.stop()
	if amount >= heavy_damage_threshold:
		anim_player.play("Damaged3")
	elif amount >= medium_damage_threshold:
		anim_player.play("Damaged2")
	else:
		anim_player.play("Damaged")
	health -= amount
	health = clampi(health, 0, max_health)
	health_bar._on_health_updated(health, amount)
	damage_numbers.text = str(amount)
	effects_anim.stop()
	effects_anim.play("DamageNumber")
	heal_timer.start()

func _on_timer_timeout():
	health = max_health
	health_bar._on_health_updated(health)

func get_max_health():
	return max_health
